package com.model.starbase
{
	import com.enum.CurrencyEnum;
	import com.enum.StarbaseCategoryEnum;
	import com.enum.TypeEnum;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.incoming.data.BaseData;
	import com.service.server.incoming.data.BuffData;
	import com.service.server.incoming.data.BuildingData;
	import com.service.server.incoming.data.ResearchData;
	import com.service.server.incoming.data.SectorData;
	import com.service.server.incoming.data.TradeRouteData;
	import com.util.statcalc.StatCalcUtil;

	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class BaseVO
	{
		public var battleServerAddress:String;
		public var instancedMissionAddress:String;
		public var sectorLocationX:int;
		public var sectorLocationY:int;

		public var onResourcesChange:Signal     = new Signal();
		public var onResourceDepotChange:Signal = new Signal(BuildingVO);

		private var _alloy:uint;
		private var _credits:uint;
		private var _energy:uint;
		private var _synthetic:uint;

		private var _bubbleTimeRemaining:Number;
		private var _clientTime:int;

		private var _buffs:Vector.<BuffVO>;
		private var _buffsLookup:Dictionary;
		private var _buildings:Vector.<BuildingVO>;
		private var _buildingsLookup:Dictionary;
		private var _research:Vector.<ResearchVO>;
		private var _researchLookup:Dictionary;
		private var _tradeRouteID:int           = 0;
		private var _tradeRoutes:Vector.<TradeRouteVO>;
		private var _tradeRouteLookup:Dictionary;

		private var _disableReqs:Number         = 0;
		private var _grid:StarbaseGrid;
		private var _id:String;

		private var _baseResourceIncome:uint;
		private var _baseCreditIncome:uint;
		private var _baseResourcePurchaseScale:Number;
		private var _baseCreditPurchaseScale:Number;
		private var _sector:SectorData;
		private var _tradeRouteResourceIncome:uint;
		private var _tradeRouteCreditIncome:uint;
		private var _derivedStatsDirty:Boolean  = true;
		private var _maxResources:int;
		private var _maxCredits:int;

		public function init( baseData:BaseData ):void
		{
			_id = baseData.id;
			_buffs = new Vector.<BuffVO>;
			_buffsLookup = new Dictionary();
			_buildings = new Vector.<BuildingVO>;
			_buildingsLookup = new Dictionary();
			_grid = new StarbaseGrid();
			_research = new Vector.<ResearchVO>;
			_researchLookup = new Dictionary();
		}

		internal function importData( baseData:BaseData ):void
		{
			_clientTime = getTimer();
			_alloy = baseData.alloy;
			_credits = baseData.credits;
			_energy = baseData.energy;
			_synthetic = baseData.synthetic;
			_bubbleTimeRemaining = baseData.bubbleTimeRemaining;

			_sector = baseData.sector;
			sectorLocationX = baseData.sectorLocationX;
			sectorLocationY = baseData.sectorLocationY;
			onResourcesChange.dispatch();
		}

		//============================================================================================================
		//************************************************************************************************************
		//													BUILDINGS
		//************************************************************************************************************
		//============================================================================================================

		internal function importBuildingData( buildingData:BuildingData ):void
		{
			if (!_buildingsLookup[buildingData.id])
			{
				var buildingVO:BuildingVO = ObjectPool.get(BuildingVO);
				buildingVO.init(buildingData);
				addBuilding(buildingVO);
			} else
				_buildingsLookup[buildingData.id].importData(buildingData);
			_derivedStatsDirty = true;
		}

		internal function addBuilding( vo:BuildingVO ):void
		{
			_buildings.push(vo);
			_buildingsLookup[vo.id] = vo;
			_grid.addToGrid(vo, true);
		}

		internal function updateBuildingID( oldID:String, newID:String ):void
		{
			//ensure that the server didn't beat us to it
			if (_buildingsLookup[newID] != null)
			{
				_buildingsLookup[oldID] = null;
				delete _buildingsLookup[oldID];
			} else
			{
				var buildingVO:BuildingVO = _buildingsLookup[oldID];
				_buildingsLookup[oldID] = null;
				delete _buildingsLookup[oldID];
				buildingVO.forceSetID(newID);
				_buildingsLookup[newID] = buildingVO;
			}
		}

		public function getBuildingCount( buildingClass:String ):int
		{
			var count:int                       = 0;
			var countStarbaseStructures:Boolean = (buildingClass == TypeEnum.STARBASE_ARM ||
				buildingClass == TypeEnum.STARBASE_PLATFORMA ||
				buildingClass == TypeEnum.STARBASE_PLATFORMB);
			for (var i:int = 0; i < _buildings.length; i++)
			{
				if (countStarbaseStructures)
				{
					if (_buildings[i].getValue('category') == StarbaseCategoryEnum.STARBASE_STRUCTURE)
						count += (_buildings[i].sizeX / 5) * (_buildings[i].sizeY / 5);
				} else if (_buildings[i].itemClass == buildingClass)
					count++;
			}
			return count;
		}

		public function getBuildingMaxCount( buildingClass:String ):int
		{
			switch (buildingClass)
			{
				case TypeEnum.POINT_DEFENSE_PLATFORM:
					return StatCalcUtil.baseStatCalc("MaxTurret");
				case TypeEnum.PYLON:
					return StatCalcUtil.baseStatCalc("MaxPylon");
				case TypeEnum.SHIELD_GENERATOR:
					return StatCalcUtil.baseStatCalc("MaxShield");
				case TypeEnum.RESOURCE_DEPOT:
					return StatCalcUtil.baseStatCalc("MaxDepot");
				case TypeEnum.STARBASE_ARM:
				case TypeEnum.STARBASE_PLATFORMA:
				case TypeEnum.STARBASE_PLATFORMB:
					return StatCalcUtil.baseStatCalc("MaxPlatform");
				case TypeEnum.STARBASE_WALL:
					return StatCalcUtil.baseStatCalc("MaxWall");
			}
			if(CONFIG::DEBUG == true)
			{
				switch (buildingClass)
				{				
					case TypeEnum.COMMAND_CENTER:
					return StatCalcUtil.baseStatCalc("MaxCommand");
					case TypeEnum.ADVANCED_TECH:
					case TypeEnum.DEFENSE_DESIGN:
					case TypeEnum.SHIPYARD:
					case TypeEnum.WEAPONS_FACILITY:
					return StatCalcUtil.baseStatCalc("MaxResearch");
					case TypeEnum.SURVEILLANCE:
					return StatCalcUtil.baseStatCalc("MaxSurveillance");
					case TypeEnum.DOCK:
					return StatCalcUtil.baseStatCalc("MaxDock");
					case TypeEnum.CONSTRUCTION_BAY:
					return StatCalcUtil.baseStatCalc("MaxShipyard");
					case TypeEnum.REACTOR_STATION:
					return StatCalcUtil.baseStatCalc("MaxReactor");
				}
			}
			return 1;
		}

		internal function getBuildingByID( id:String ):BuildingVO
		{
			if (_buildingsLookup[id])
				return _buildingsLookup[id];
			return null;
		}

		internal function getBuildingByClass( buildingClass:String, highestLevel:Boolean = false ):BuildingVO
		{
			var vo:BuildingVO;
			for (var i:int = 0; i < _buildings.length; i++)
			{
				if (_buildings[i].itemClass == buildingClass)
				{
					if (!highestLevel)
						return _buildings[i];
					else if (!vo || vo.level < _buildings[i].level)
						vo = _buildings[i];
				}
			}
			return vo;
		}

		internal function removeBuilding( buildingVO:BuildingVO ):void
		{
			var index:int = _buildings.indexOf(buildingVO);
			_buildings.splice(index, 1);
			_grid.removeFromGrid(buildingVO);
			//remove from the lookup
			delete _buildingsLookup[buildingVO.id];
			_buildingsLookup[buildingVO.id] = null;
			_derivedStatsDirty = true;
		}

		internal function get buildings():Vector.<BuildingVO>  { return _buildings; }

		//============================================================================================================
		//************************************************************************************************************
		//													RESEARCH
		//************************************************************************************************************

		internal function importResearchData( researchData:ResearchData ):void
		{
			if (!_researchLookup[researchData.id])
			{
				var researchVO:ResearchVO = ObjectPool.get(ResearchVO);
				researchVO.init(researchData.id);
				_research.push(researchVO);
				_researchLookup[researchVO.id] = researchVO;
			}
			_researchLookup[researchData.id].importData(researchData);
			_derivedStatsDirty = true;
		}

		internal function getResearchByID( id:String ):ResearchVO
		{
			if (_researchLookup[id])
				return _researchLookup[id];
			return null;
		}

		internal function removeResearch( researchVO:ResearchVO ):void
		{
			var index:int = _research.indexOf(researchVO);
			_research.splice(index, 1);
			//remove from the lookup
			ObjectPool.give(_researchLookup[researchVO.id]);
			delete _researchLookup[researchVO.id];
			_researchLookup[researchVO.id] = null;
			_derivedStatsDirty = true;
		}

		internal function get research():Vector.<ResearchVO>  { return _research; }

		//============================================================================================================
		//************************************************************************************************************
		//													 BUFFS
		//************************************************************************************************************
		//============================================================================================================

		internal function importBuffData( buffData:BuffData ):void
		{
			var added:Boolean = false;
			if (!_buffsLookup[buffData.id])
			{
				var buffVO:BuffVO = ObjectPool.get(BuffVO);
				_buffsLookup[buffData.id] = buffVO;
				_buffs.push(buffVO);
				added = true;
			}
			_buffsLookup[buffData.id].importData(buffData);
			if (added)
			{
				_derivedStatsDirty = true;
				_disableReqs = StatCalcUtil.baseStatCalc("disableReqs");
			}
		}

		internal function getBuffByID( id:String ):BuffVO
		{
			if (_buffsLookup[id])
				return _buffsLookup[id];
			return null;
		}

		internal function getBuffByType( type:String ):BuffVO
		{
			for (var i:int = 0; i < _buffs.length; i++)
			{
				if (_buffs[i].buffType == type)
					return _buffs[i];
			}
			return null;
		}

		internal function updateBuffID( oldID:String, newID:String ):void
		{
			//ensure that the server didn't beat us
			if (_buffsLookup[newID] != null)
			{
				for (var i:int = 0; i < _buffs.length; i++)
				{
					if (_buffs[i].id == oldID)
					{
						_buffs.splice(i, 1);
						break;
					}
				}

				_buffsLookup[oldID] = null;
				delete _buffsLookup[oldID];
			} else
			{
				var buffVO:BuffVO = _buffsLookup[oldID];
				_buffsLookup[oldID] = null;
				delete _buffsLookup[oldID];
				buffVO.forceSetID(newID);
				_buffsLookup[newID] = buffVO;
			}
		}

		internal function removeBuff( buffVO:BuffVO ):void
		{
			var index:int = _buffs.indexOf(buffVO);
			_buffs.splice(index, 1);
			//remove from the lookup
			ObjectPool.give(_buffsLookup[buffVO.id]);
			delete _buffsLookup[buffVO.id];
			_buffsLookup[buffVO.id] = null;
			_disableReqs = StatCalcUtil.baseStatCalc("disableReqs");
			_derivedStatsDirty = true;
		}

		public function get buffs():Vector.<BuffVO>  { return _buffs; }
		public function get reqsDisabled():Number  { return _disableReqs; }

		//============================================================================================================
		//************************************************************************************************************
		//											  TRADE ROUTES
		//************************************************************************************************************
		//============================================================================================================

		internal function initTradeRoutes():void
		{
			_tradeRoutes = new Vector.<TradeRouteVO>;
			_tradeRouteLookup = new Dictionary();
			setUpDefaultTradeRoutes();
		}

		internal function importTradeRouteData( tradeRouteData:TradeRouteData ):void
		{
			if (!_tradeRouteLookup[tradeRouteData.id])
			{
				//can only have one trade route per faction
				//if we're getting a traderoute from the server that does not match the id but matches the faction then update the id
				if (_tradeRouteLookup[tradeRouteData.corporation])
				{
					updateTradeRouteID(_tradeRouteLookup[tradeRouteData.corporation].id, tradeRouteData.id);
				} else
				{
					var tradeRouteVO:TradeRouteVO = ObjectPool.get(TradeRouteVO);
					tradeRouteVO.init(tradeRouteData.id);
					_tradeRoutes.push(tradeRouteVO);
					_tradeRouteLookup[tradeRouteVO.id] = tradeRouteVO;
					_tradeRouteLookup[tradeRouteData.corporation] = tradeRouteVO;
				}
			}
			_tradeRouteLookup[tradeRouteData.id].importData(tradeRouteData);
			_derivedStatsDirty = true;
		}

		internal function updateTradeRouteID( oldID:String, newID:String ):void
		{
			//ensure that the server didn't beat us to it
			if (_tradeRouteLookup[newID] != null)
			{
				_tradeRouteLookup[oldID] = null;
				delete _tradeRouteLookup[oldID];
			} else
			{
				var tradeRouteVO:TradeRouteVO = _tradeRouteLookup[oldID];
				_tradeRouteLookup[oldID] = null;
				delete _tradeRouteLookup[oldID];
				tradeRouteVO.forceSetID(newID);
				_tradeRouteLookup[newID] = tradeRouteVO;
			}
		}

		internal function getTradeRouteByID( id:String ):TradeRouteVO
		{
			if (_tradeRouteLookup[id])
				return _tradeRouteLookup[id];
			return null;
		}

		internal function getTradeRouteByCorporation( corportation:String ):TradeRouteVO
		{
			if (_tradeRouteLookup[corportation])
				return _tradeRouteLookup[corportation];
			return null;
		}

		internal function removeTradeRoute( tradeRouteVO:TradeRouteVO ):void
		{
			var index:int = _tradeRoutes.indexOf(tradeRouteVO);
			_tradeRoutes.splice(index, 1);
			//remove from the lookup
			ObjectPool.give(_tradeRouteLookup[tradeRouteVO.id]);
			_tradeRouteLookup[tradeRouteVO.id] = null;
			delete _tradeRouteLookup[tradeRouteVO.id];
			_tradeRouteLookup[tradeRouteVO.corporation] = null;
			delete _tradeRouteLookup[tradeRouteVO.corporation];
			_derivedStatsDirty = true;
		}

		private function setUpDefaultTradeRoutes():void
		{
			var factions:Vector.<IPrototype> = PrototypeModel.instance.getFactionPrototypes();
			var currentFaction:IPrototype;
			var tradeRouteData:TradeRouteData;
			for (var i:uint = 0; i < factions.length; ++i)
			{
				currentFaction = factions[i];
				if (currentFaction.getValue('contractGroup') != "")
				{
					tradeRouteData = ObjectPool.get(TradeRouteData);
					tradeRouteData.baseID = _id;
					tradeRouteData.id = tradeRouteID;
					tradeRouteData.factionPrototype = factions[i];
					tradeRouteData.reputation = 0;
					importTradeRouteData(tradeRouteData);
				}
			}
		}

		internal function get tradeRoutes():Vector.<TradeRouteVO>  { return _tradeRoutes; }
		private function get tradeRouteID():String  { ++_tradeRouteID; return CurrentUser.name + '.clientside_tradeRoute.' + String(_tradeRouteID); }

		//============================================================================================================
		//************************************************************************************************************
		//											  RESOURCE MANAGEMENT
		//************************************************************************************************************
		//============================================================================================================

		public function updateResources():void
		{
			if (_derivedStatsDirty)
			{
				calcDerivedStats();
				_derivedStatsDirty = false;
			}

			// clamp resources to their maximums
			var maxCredit:int   = maxCredits;
			var maxResource:int = maxResources;
			_alloy = Math.min(maxResource, _alloy);
			_credits = Math.min(maxCredit, _credits);
			_energy = Math.min(maxResource, _energy);
			_synthetic = Math.min(maxResource, _synthetic);

			onResourcesChange.dispatch();
		}

		public function deposit( amount:uint, type:String ):void
		{
			switch (type)
			{
				case CurrencyEnum.ALLOY:
					_alloy += amount;
					break;
				case CurrencyEnum.CREDIT:
					_credits += amount;
					break;
				case CurrencyEnum.ENERGY:
					_energy += amount;
					break;
				case CurrencyEnum.SYNTHETIC:
					_synthetic += amount;
					break;
			}

			onResourcesChange.dispatch();
		}

		public function withdraw( amount:uint, type:String ):Boolean
		{
			switch (type)
			{
				case CurrencyEnum.ALLOY:
					if (_alloy < amount)
						return false;
					_alloy -= amount;
					break;
				case CurrencyEnum.CREDIT:
					if (_credits < amount)
						return false;
					_credits -= amount;
					break;
				case CurrencyEnum.ENERGY:
					if (_energy < amount)
						return false;
					_energy -= amount;
					break;
				case CurrencyEnum.SYNTHETIC:
					if (_synthetic < amount)
						return false;
					_synthetic -= amount;
					break;
			}
			onResourcesChange.dispatch();
			return true;
		}

		public function calcDerivedStats():void
		{
			_baseResourceIncome = StatCalcUtil.baseStatCalc("ExpectedResourceIncome");
			_baseCreditIncome = StatCalcUtil.baseStatCalc("ExpectedCreditIncome");

			_baseResourcePurchaseScale = StatCalcUtil.baseStatCalc("resourceBuyScale");
			_baseCreditPurchaseScale = StatCalcUtil.baseStatCalc("creditBuyScale");

			_tradeRouteResourceIncome = StatCalcUtil.baseStatCalc("ResIncome");
			_tradeRouteCreditIncome = StatCalcUtil.baseStatCalc("CredIncome");

			var newResourceCap:int = StatCalcUtil.baseStatCalc("ResourceCap");
			var newCreditsCap:int  = StatCalcUtil.baseStatCalc("CreditCap");

			if (newResourceCap != _maxResources || newCreditsCap != _maxCredits)
			{
				_maxCredits = newCreditsCap;
				_maxResources = newResourceCap;
				onResourcesChange.dispatch();
			}
		}

		public function set dirty( v:Boolean ):void  { _derivedStatsDirty = true; }

		public function get grid():StarbaseGrid  { return _grid; }

		public function get alloy():uint  { return _alloy; }
		public function get credits():uint  { return _credits; }
		public function get energy():uint  { return _energy; }
		public function get synthetic():uint  { return _synthetic; }

		public function get bubbleTimeRemaining():Number
		{
			var temp:Number = _bubbleTimeRemaining - (getTimer() - _clientTime);
			if (temp < 0)
				temp = 0;
			return temp;
		}

		public function get baseResourceIncome():uint  { return _baseResourceIncome; }
		public function get baseCreditIncome():uint  { return _baseCreditIncome; }

		public function get baseResourcePurchaseScale():Number  { return _baseResourcePurchaseScale; }
		public function get baseCreditPurchaseScale():Number  { return _baseCreditPurchaseScale; }

		public function get tradeRouteResourceIncome():uint  { return _tradeRouteResourceIncome; }
		public function get tradeRouteCreditIncome():uint  { return _tradeRouteCreditIncome; }

		public function get id():String  { return _id; }

		public function get maxPower():int  { return StatCalcUtil.baseStatCalc("MaxPower"); }
		public function get maxResources():int  { return _maxResources; }
		public function get maxCredits():int  { return _maxCredits; }

		public function get sector():SectorData  { return _sector; }
		public function get sectorID():String  { return _sector.id; }

		public function destroy():void
		{

		}
	}
}


