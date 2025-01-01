package com.model.fleet
{
	import com.enum.TypeEnum;
	import com.enum.server.StarbaseBuildStateEnum;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.incoming.data.ShipData;
	import com.util.CommonFunctionUtil;
	import com.util.statcalc.StatCalcUtil;
	
	import flash.utils.Dictionary;
	
	import org.adobe.utils.StringUtil;

	public class ShipVO implements IPrototype
	{
		public static const EMPTY_SLOT:IPrototype = new EmptySlotVO();

		public var id:String;
		public var ownerID:String;
		public var fleetOwner:String;
		public var built:Boolean;
		public var refiting:Boolean;
		public var modules:Dictionary             = new Dictionary();
		public var refitModules:Dictionary        = new Dictionary();
		public var inFleet:Boolean                = false;
		public var shipName:String;
		public var refitShipName:String;

		private var _buildCreditCost:int          = 0;
		private var _buildAlloyCost:int           = 0;
		private var _buildEnergyCost:int          = 0;
		private var _buildSyntheticCost:int       = 0;
		private var _buildTime:int                = 0;

		private var _repairCreditCost:int         = 0;
		private var _repairAlloyCost:int          = 0;
		private var _repairEnergyCost:int         = 0;
		private var _repairSyntheticCost:int      = 0;
		private var _repairTime:Number            = 0;

		private var _scrapCreditCost:int          = 0;
		private var _scrapAlloyCost:int           = 0;
		private var _scrapEnergyCost:int          = 0;
		private var _scrapSyntheticCost:int       = 0;

		public var powerUsage:int                 = 0;

		private var _currentHealth:Number         = 1;
		private var _healthAmount:Number;
		private var _shipDps:int;
		private var _maxWeaponRange:int;
		private var _rating:int;
		private var _prototypeVO:IPrototype;
		private var _rank:int;
		private var _tooltip:String;
		private var _healthPercentGainASecond:Number;

		public function importData( shipData:ShipData ):void
		{
			built = (shipData.buildState == StarbaseBuildStateEnum.DONE) ? true : false;
			_currentHealth = shipData.currentHealth;
			fleetOwner = shipData.fleetOwner;
			id = shipData.id;
			shipName = shipData.shipName;
			refitShipName = shipName;
			modules = shipData.modules;
			ownerID = shipData.ownerID;
			_prototypeVO = shipData.prototype;
			refitModules = shipData.refitModules ? shipData.refitModules : new Dictionary();
			calculateCosts();
		}

		public function clone():ShipVO
		{
			var vo:ShipVO = new ShipVO();
			vo.prototypeVO = _prototypeVO;
			vo.ownerID = ownerID;
			vo.fleetOwner = fleetOwner;
			vo.built = built;
			vo.refiting = refiting;
			
			vo.shipName = shipName;
			vo.refitShipName = refitShipName;
			
			var key:String;

			for (key in modules)
			{
				vo.equipModule(modules[key], key);
			}

			for (key in refitModules)
			{
				vo.equipRefitModule(refitModules[key], key);
			}

			return vo;
		}
		
		public function setNewShipName( name:String ):void
		{
			refitShipName = name;
			calculateCosts();
		}

		public function equipModule( vo:IPrototype, index:String ):void
		{
			modules[index] = vo;
			calculateCosts();
		}

		public function equipRefitModule( vo:IPrototype, index:String ):void
		{
			if (vo != null && modules[index] != null && modules[index].name == vo.name)
				delete refitModules[index];
			else
				refitModules[index] = (vo == null) ? EMPTY_SLOT : vo;
			calculateCosts();
		}

		public function getUnsafeValue( key:String ):*  { return prototypeVO.getUnsafeValue(key); }
		public function getValue( key:String ):*  { return prototypeVO.getValue(key); }

		/** This is actually the PERCENTAGE of current health, expressed as a floating pt number between 0 and 1 */
		public function get currentHealth():Number  { return _currentHealth; }
		public function set currentHealth( currentHealth:Number ):void
		{
			if (currentHealth > maxHealth)
				_currentHealth = maxHealth;
			else
				_currentHealth = currentHealth;
		}

		public function get prototypeVO():IPrototype  { return _prototypeVO; }
		public function set prototypeVO( prototypeVO:IPrototype ):void
		{
			//just received a new prototype.
			if (_prototypeVO && _prototypeVO != prototypeVO)
			{
				modules = new Dictionary();
				refitModules = new Dictionary();
			}
			_prototypeVO = prototypeVO;
			calculateCosts();
		}

		public function calculateCosts():void
		{
			try{
			var refitVO:IPrototype;
			var vo:IPrototype;
			var key:String;

			_buildCreditCost = 0;
			_buildAlloyCost = 0;
			_buildEnergyCost = 0;
			_buildSyntheticCost = 0;
			_scrapCreditCost = 0;
			_scrapAlloyCost = 0;
			_scrapEnergyCost = 0;
			_scrapSyntheticCost = 0;
			_buildTime = 0;
			powerUsage = 0;
			_shipDps = 0;
			var currentRange:int = 0;
			
			var id:Number = _prototypeVO.getValue('id');
			_healthAmount = _prototypeVO.getValue('health');

			//repair cost of the hull
			_repairCreditCost = _prototypeVO.getValue('repairCredits');
			_repairAlloyCost = _prototypeVO.getValue('repairAlloy');
			_repairEnergyCost = _prototypeVO.getValue('repairEnergy');
			_repairSyntheticCost = _prototypeVO.getValue('repairSynthetic');
			_repairTime = _prototypeVO.getValue('repairTimeSeconds');

			//build cost of the hull
			if (!built)
			{
				_buildCreditCost = _prototypeVO.creditsCost;
				_buildAlloyCost = _prototypeVO.alloyCost;
				_buildEnergyCost = _prototypeVO.energyCost;
				_buildSyntheticCost = _prototypeVO.syntheticCost;
				_buildTime = _prototypeVO.buildTimeSeconds;
			} else
			{
				_scrapCreditCost += _prototypeVO.creditsCost;
				_scrapAlloyCost += _prototypeVO.alloyCost;
				_scrapEnergyCost += _prototypeVO.energyCost;
				_scrapSyntheticCost += _prototypeVO.syntheticCost;
			}

			for (key in modules)
			{
				vo = modules[key];
				refitVO = refitModules[key];
				//repair cost of components
				if (vo != null)
				{
					_repairCreditCost += vo.getValue('repairCredits');
					_repairAlloyCost += vo.getValue('repairAlloy');
					_repairEnergyCost += vo.getValue('repairEnergy');
					_repairSyntheticCost += vo.getValue('repairSynthetic');
					_repairTime += vo.getValue('repairTimeSeconds');
				}

				vo = (refitVO != null) ? (refitVO != EMPTY_SLOT) ? refitVO : null : vo;
				if (vo)
				{
					if (vo == refitVO || !built)
					{
						_buildCreditCost += vo.creditsCost;
						_buildAlloyCost += vo.alloyCost;
						_buildEnergyCost += vo.energyCost;
						_buildSyntheticCost += vo.syntheticCost;
						_buildTime += vo.buildTimeSeconds;
					}

					if (built)
					{
						_scrapCreditCost += vo.creditsCost;
						_scrapAlloyCost += vo.alloyCost;
						_scrapEnergyCost += vo.energyCost;
						_scrapSyntheticCost += vo.syntheticCost;
					}

					powerUsage += vo.getValue("powerCost");
					_shipDps += calcSingleDps(vo, key);
					var calcedHealth:Number = calcHealth(vo);
					if (calcedHealth != 0)
						_healthAmount = calcedHealth;
					currentRange = calcMaxWeaponRange(vo, key);
					if (currentRange > _maxWeaponRange)
						_maxWeaponRange = currentRange;
				}
			}
			
			if(shipName != refitShipName)
			{
				_buildCreditCost += 50000;
				_buildTime += 5;
			}

			_scrapCreditCost *= 0.2;
			_scrapAlloyCost *= 0.2;
			_scrapEnergyCost *= 0.2;
			_scrapSyntheticCost *= 0.2;

			_repairCreditCost *= PrototypeModel.SHIP_REPAIR_RESOURCE_COST_SCALAR;
			_repairAlloyCost *= PrototypeModel.SHIP_REPAIR_RESOURCE_COST_SCALAR;
			_repairEnergyCost *= PrototypeModel.SHIP_REPAIR_RESOURCE_COST_SCALAR;
			_repairSyntheticCost *= PrototypeModel.SHIP_REPAIR_RESOURCE_COST_SCALAR;
			_repairTime *= PrototypeModel.SHIP_REPAIR_TIME_SCALAR;

			_buildCreditCost *= PrototypeModel.SHIP_BUILD_RESOURCE_COST_SCALAR;
			_buildAlloyCost *= PrototypeModel.SHIP_BUILD_RESOURCE_COST_SCALAR;
			_buildEnergyCost *= PrototypeModel.SHIP_BUILD_RESOURCE_COST_SCALAR;
			_buildSyntheticCost *= PrototypeModel.SHIP_BUILD_RESOURCE_COST_SCALAR;
			_buildTime *= PrototypeModel.SHIP_BUILD_TIME_SCALAR;

			_healthPercentGainASecond = (_healthAmount / _repairTime) / _healthAmount;
	}catch(t){}
		}

		public function get rank():int  { return _rank; }
		public function get healthAmount():Number  { return _healthAmount; }
		public function get rotationSpeed():Number  { return 1; }
		public function get mapSpeed():Number  { return 1; }
		public function get cargo():int  { return 1; }
		public function get maxSpeed():Number  { return 1; }
		public function get loadSpeed():Number  { return 1; }
		public function get shipDps():int  { return _shipDps; }
		public function get rating():int  { return _rating; }
		public function get power():int  { return 1; }
		public function get maxHealth():int  { return 1; }
		public function get evasion():Number  { return 1; }
		public function get armor():Number  { return 1; }
		public function get profile():Number  { return 1; }
		public function get masking():Number  { return 1; }
		public function get maxRange():Number  { return _maxWeaponRange; }
		public function get rarity():Number  { return 1; }
		public function get slots():Array  { return []; }
		public function get health():Number  { return 1; }

		public function get asset():String  { return prototypeVO.asset; }
		public function get uiAsset():String  { return prototypeVO.uiAsset; }

		public function get name():String  { return prototypeVO.name; }
		public function get itemClass():String  { return prototypeVO.itemClass; }
		public function get buildTimeSeconds():uint  { return _buildTime; }

		public function get alloyCost():int  { return _buildAlloyCost; }
		public function get creditsCost():int  { return _buildCreditCost; }
		public function get energyCost():int  { return _buildEnergyCost; }
		public function get syntheticCost():int  { return _buildSyntheticCost; }

		public function get repairAlloyCost():int  { return (1 - _currentHealth) * _repairAlloyCost; }
		public function get repairCreditsCost():int  { return (1 - _currentHealth) * _repairCreditCost; }
		public function get repairEnergyCost():int  { return (1 - _currentHealth) * _repairEnergyCost; }
		public function get repairSyntheticCost():int  { return (1 - _currentHealth) * _repairSyntheticCost; }

		public function get scrapAlloyCost():int  { return _scrapAlloyCost; }
		public function get scrapCreditsCost():int  { return _scrapCreditCost; }
		public function get scrapEnergyCost():int  { return _scrapEnergyCost; }
		public function get scrapSyntheticCost():int  { return _scrapSyntheticCost; }

		public function get healthGainedASecond():Number  { return _healthPercentGainASecond; }

		public function get currentRepairTime():Number  { return (1 - _currentHealth) * _repairTime; }

		public function get accelerationTime():Number
		{
			var accelTime:Number = StatCalcUtil.entityStatCalc(this, 'accelerationTime');
			var maxSpeed:Number  = StatCalcUtil.entityStatCalc(this, 'maxSpeed');
			return maxSpeed / accelTime;
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
				totalDamage = damage * Math.max(burstSize, 1) * Math.max(volleySize, 1) * Math.max(duration / Math.max(tickRate, 1), 1);
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

		private function calcMaxWeaponRange( mod:IPrototype, slot:String ):Number
		{
			var range:Number = 0;

			if (!mod || mod.getValue('slotType') == 'Defense' || mod.getValue('slotType') == 'Tech' || mod.getValue('slotType') == 'Structure')
				range = 0;
			else
				range = StatCalcUtil.entityStatCalc(this, 'maxRange', 0, mod, slot);

			return range;
		}

		private function calcHealth( mod:IPrototype ):Number
		{
			return StatCalcUtil.entityStatCalc(this, 'health');
		}

		public function get tooltip():String
		{
			_tooltip = StringUtil.getTooltip(String(TypeEnum.SHIP_BUILT_TT), this);
			return _tooltip;
		}

		public function destroy():void
		{
		}
	}
}


