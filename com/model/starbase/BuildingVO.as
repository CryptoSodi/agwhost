package com.model.starbase
{
	import com.enum.TypeEnum;
	import com.enum.server.StarbaseBuildStateEnum;
	import com.game.entity.components.shared.Detail;
	import com.model.fleet.EmptySlotVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.incoming.data.BuildingData;
	import com.util.CommonFunctionUtil;
	import com.util.statcalc.StatCalcUtil;

	import flash.utils.Dictionary;

	import org.ash.core.Entity;
	import org.osflash.signals.Signal;

	public class BuildingVO implements IPrototype
	{
		public static const EMPTY_SLOT:IPrototype = new EmptySlotVO();

		public var baseID:String;
		public var damaged:Boolean                = false;
		public var destroyed:Boolean              = false;
		public var baseX:Number;
		public var baseY:Number;
		public var buildState:int;
		public var modules:Dictionary;
		public var percentFilled:Number; //used by resource depots to show how full they are
		public var refitModules:Dictionary;

		private var _refitBuildCreditCost:int     = 0;
		private var _refitBuildAlloyCost:int      = 0;
		private var _refitBuildEnergyCost:int     = 0;
		private var _refitBuildSyntheticCost:int  = 0;
		private var _refitBuildTime:int           = 0;

		private var _currentHealth:Number         = 1;
		private var _buildingDps:int              = 0;
		private var _built:Boolean;
		private var _forceShielding:int           = 0;
		private var _explosiveShielding:int       = 0;
		private var _energyShielding:int          = 0;

		private var _slots:Array;

		private var _id:String;
		private var _onHealthChange:Signal        = new Signal(Number, Number);
		private var _playerOwnerID:String;
		private var _prototype:IPrototype;
		private var _shieldRadius:int; //used by shield generators
		private var _type:String;

		public function BuildingVO()
		{
			modules = new Dictionary();
			refitModules = new Dictionary();
		}

		internal function init( buildingData:BuildingData ):void
		{
			baseID = buildingData.baseID;
			_id = buildingData.id;
			_built = _id.indexOf('clientside') == -1;
			percentFilled = 0;
			_playerOwnerID = buildingData.playerOwnerID;
			_shieldRadius = -1;
			_type = buildingData.type;
			importData(buildingData);
			calculateCosts();
		}

		internal function importData( buildingData:BuildingData ):void
		{
			baseID = buildingData.baseID;
			baseX = buildingData.baseX;
			baseY = buildingData.baseY;
			buildState = buildingData.buildState;
			currentHealth = buildingData.currentHealth;
			modules = buildingData.modules ? buildingData.modules : modules;
			prototype = buildingData.prototype;
			refitModules = buildingData.refitModules ? buildingData.refitModules : refitModules;

			if (prototype)
				_slots = prototype.getValue('slots');

		}

		public function popuplateFromEntity( entity:Entity ):void
		{
			_id = entity.id;
			_playerOwnerID = CurrentUser.id;
			_type = Detail(entity.get(Detail)).type;
		}

		public function equipModule( vo:IPrototype, slot:String ):void
		{
			modules[slot] = vo;
			calculateCosts();
		}

		public function equipRefitModule( vo:IPrototype, slot:String ):void
		{
			refitModules[slot] = vo;
			calculateCosts();
		}

		public function calculateCosts():void
		{
			var vo:IPrototype;
			var refitVO:IPrototype;
			_buildingDps = 0;
			_forceShielding = 0;
			_explosiveShielding = 0;
			_energyShielding = 0;

			_refitBuildCreditCost = 0;
			_refitBuildAlloyCost = 0;
			_refitBuildEnergyCost = 0;
			_refitBuildSyntheticCost = 0;
			_refitBuildTime = 0;

			if (_slots)
			{
				var len:uint = _slots.length;
				var slot:String;
				for (var i:uint = 0; i < len; ++i)
				{
					slot = _slots[i];

					vo = modules[slot];
					refitVO = refitModules[slot];
					vo = (refitVO != null) ? (refitVO != EMPTY_SLOT) ? refitVO : null : vo;
					if (vo)
					{
						_refitBuildCreditCost += vo.creditsCost;
						_refitBuildAlloyCost += vo.alloyCost;
						_refitBuildEnergyCost += vo.energyCost;
						_refitBuildSyntheticCost += vo.syntheticCost;
						_refitBuildTime += vo.buildTimeSeconds;

						_buildingDps += calcSingleDps(vo, slot);
						_forceShielding = calcShielding(vo, slot, 1);
						_explosiveShielding = calcShielding(vo, slot, 2);
						_energyShielding = calcShielding(vo, slot, 3);
					}
				}
			}

			_refitBuildCreditCost *= PrototypeModel.BUILDING_RESOURCE_COST_SCALAR;
			_refitBuildAlloyCost *= PrototypeModel.BUILDING_RESOURCE_COST_SCALAR;
			_refitBuildEnergyCost *= PrototypeModel.BUILDING_RESOURCE_COST_SCALAR;
			_refitBuildSyntheticCost *= PrototypeModel.BUILDING_RESOURCE_COST_SCALAR;
			_refitBuildTime *= PrototypeModel.BUILDING_BUILD_TIME_SCALAR;
		}

		private function calcSingleDps( mod:IPrototype, slot:String ):Number
		{
			var slotType:String    = mod.getValue('slotType');
			if (!(slotType == "Weapon" || slotType == "Spinal" || slotType == "Arc" || slotType == "Drone" || slotType == "BaseTurret"))
				return 0;

			var fireTime:Number    = StatCalcUtil.entityStatCalc(this, 'fireTime', 0, mod, slot);
			var burstSize:Number   = StatCalcUtil.entityStatCalc(this, 'burstSize', 0, mod, slot);
			var reloadTime:Number  = StatCalcUtil.entityStatCalc(this, 'reloadTime', 0, mod, slot);
			var chargeTime:Number  = StatCalcUtil.entityStatCalc(this, 'chargeTime', 0, mod, slot);
			var volleySize:Number  = StatCalcUtil.entityStatCalc(this, 'volleySize', 0, mod, slot);
			var duration:Number    = StatCalcUtil.entityStatCalc(this, 'duration', 0, mod, slot);
			var tickRate:Number    = StatCalcUtil.entityStatCalc(this, 'tickRate', 0, mod, slot);
			var damageTime:Number  = StatCalcUtil.entityStatCalc(this, 'damageTime', 0, mod, slot);
			var maxDrones:Number   = StatCalcUtil.entityStatCalc(this, 'maxDrones', 0, mod, slot);
			var damage:Number      = StatCalcUtil.entityStatCalc(this, 'damage', 0, mod, slot);

			// Do the appropriate calculation based on the attack type
			var type:int           = mod.getValue('attackMethod');
			var totalDamage:Number = 0;
			var totalPeriod:Number = 0;
			if (type == 1 || type == 2 || type == 3)
			{
				// Beams and Projectiles
				totalDamage = damage * Math.max(burstSize, 1) * Math.max(volleySize, 1);
				totalPeriod = (fireTime * burstSize) + reloadTime + chargeTime;
			} else if (type == 4)
			{
				// Areas
				totalDamage = damage * Math.max(burstSize, 1) * Math.max(volleySize, 1) * Math.max(duration / tickRate, 1);
				totalPeriod = (fireTime * burstSize) + reloadTime + chargeTime + duration;
			} else if (type == 5)
			{
				// Drones
				totalDamage = damage * Math.max(maxDrones, 1);
				totalPeriod = damageTime;
			}

			var DPS:Number         = totalDamage / totalPeriod;
			return DPS;
		}

		private function calcShielding( mod:IPrototype, slot:String, type:Number ):Number
		{
			var typeShielding:Number = 0;
			switch (type)
			{
				case 1: // Force
					typeShielding = StatCalcUtil.entityStatCalc(this, 'forceShielding', 0, mod, slot);
					break;
				case 2: // Explosive
					typeShielding = StatCalcUtil.entityStatCalc(this, 'explosiveShielding', 0, mod, slot);
					break;
				case 3: // Energy
					typeShielding = StatCalcUtil.entityStatCalc(this, 'energyShielding', 0, mod, slot);
					break;
			}

			var shielding:Number     = StatCalcUtil.entityStatCalc(this, 'shielding', 0, mod, slot);

			return (typeShielding + shielding);
		}

		internal function forceSetID( v:String ):void  { _id = v; }

		public function getUnsafeValue( key:String ):*  { return _prototype.getUnsafeValue(key); }
		public function getValue( key:String ):*  { return _prototype.getValue(key); }

		public function get asset():String  { return _prototype.asset; }
		public function get uiAsset():String  { return _prototype.uiAsset; }

		public function get name():String  { return _prototype.name; }
		public function get itemClass():String  { return _prototype.itemClass; }
		public function get buildTimeSeconds():uint  { return (buildState == StarbaseBuildStateEnum.DONE) ? _refitBuildTime : (_prototype.buildTimeSeconds * PrototypeModel.BUILDING_BUILD_TIME_SCALAR); }
		public function get refitBuildTimeSeconds():uint  { return _refitBuildTime; }

		public function get alloyCost():int  { return (buildState == StarbaseBuildStateEnum.DONE) ? _refitBuildAlloyCost : (_prototype.alloyCost * PrototypeModel.BUILDING_RESOURCE_COST_SCALAR); }
		public function get creditsCost():int  { return (buildState == StarbaseBuildStateEnum.DONE) ? _refitBuildCreditCost : (_prototype.creditsCost * PrototypeModel.BUILDING_RESOURCE_COST_SCALAR); }
		public function get energyCost():int  { return (buildState == StarbaseBuildStateEnum.DONE) ? _refitBuildEnergyCost : (_prototype.energyCost * PrototypeModel.BUILDING_RESOURCE_COST_SCALAR); }
		public function get syntheticCost():int  { return (buildState == StarbaseBuildStateEnum.DONE) ? _refitBuildSyntheticCost : (_prototype.syntheticCost * PrototypeModel.BUILDING_RESOURCE_COST_SCALAR); }

		public function get constructionCategory():String  { return _prototype.getValue('constructionCategory'); }

		public function get currentHealth():Number  { return _currentHealth; }
		public function set currentHealth( v:Number ):void
		{
			var change:Number = (_currentHealth - v);
			_currentHealth = v;
			_onHealthChange.dispatch(_currentHealth, change);
		}

		public function get level():int  { return _prototype.getValue('level'); }

		public function get id():String  { return _id; }

		public function get playerOwnerID():String  { return _playerOwnerID; }

		public function get prototype():IPrototype  { return _prototype; }
		public function set prototype( v:IPrototype ):void
		{
			_prototype = v;
			if (_shieldRadius != -1)
			{
				if (_prototype.itemClass == TypeEnum.SHIELD_GENERATOR)
					_shieldRadius = StatCalcUtil.baseStatCalc('radius', 0.0, _id);
				else if (_prototype.itemClass == TypeEnum.PYLON)
					_shieldRadius = StatCalcUtil.baseStatCalc('maxWallLength', 0.0, _id);
			}
		}

		public function get shieldRadius():int
		{
			if (_shieldRadius == -1)
			{
				if (_prototype.itemClass == TypeEnum.SHIELD_GENERATOR)
					_shieldRadius = StatCalcUtil.baseStatCalc('radius', 0.0, _id);
				else if (_prototype.itemClass == TypeEnum.PYLON)
					_shieldRadius = StatCalcUtil.baseStatCalc('maxWallLength', 0.0, _id);
			}
			return _shieldRadius;
		}

		public function get sizeX():int  { return _prototype.getValue('sizeX'); }
		public function get sizeY():int  { return _prototype.getValue('sizeY'); }

		public function get type():String  { return _type; }

		public function addHealthListener( callback:Function ):void  { _onHealthChange.add(callback); }
		public function removeHealthListener( callback:Function ):void  { _onHealthChange.remove(callback); }

		public function get buildingDps():int  { return _buildingDps; }

		public function get built():Boolean
		{
			if (_built)
				return true;
			else if (_id && _id.indexOf('clientside') == -1)
				_built = true;
			return _built;
		}

		public function get forceShielding():int  { return _forceShielding; }

		public function get explosiveShielding():int  { return _explosiveShielding; }

		public function get energyShielding():int  { return _energyShielding; }


	}
}
