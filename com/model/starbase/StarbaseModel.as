package com.model.starbase
{
	import com.enum.CurrencyEnum;
	import com.model.Model;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.BaseData;
	import com.service.server.incoming.data.BuffData;
	import com.service.server.incoming.data.BuildingData;
	import com.service.server.incoming.data.ResearchData;
	import com.service.server.incoming.data.TradeRouteData;

	import flash.utils.Dictionary;

	import org.shared.ObjectPool;

	/**
	 * Keeps tracks of the player's bases.
	 */
	public class StarbaseModel extends Model
	{
		public var entryData:*;
		public var entryView:Class; //the view to show upon entering the starbase

		private var _bases:Dictionary;
		private var _currentBase:BaseVO;
		private var _tempBase:BaseVO;

		[PostConstruct]
		public function init():void
		{
			_bases = new Dictionary();
		}

		//============================================================================================================
		//************************************************************************************************************
		//													BASES
		//************************************************************************************************************
		//============================================================================================================

		public function importBaseData( baseData:BaseData, initTradeRoutes:Boolean = true ):void
		{
			if (!_bases[baseData.id])
			{
				var baseVO:BaseVO     = ObjectPool.get(BaseVO);
				baseVO.init(baseData);
				if (initTradeRoutes)
					baseVO.initTradeRoutes();
				_bases[baseData.id] = baseVO;
			}
			if (_currentBase == null)
				_currentBase = _bases[baseData.id];
			_bases[baseData.id].importData(baseData);
		}

		public function getBaseByID( id:String ):BaseVO  { return _bases[id]; }

		public function switchBase( baseID:String ):void
		{
			_tempBase = _bases[baseID];
			if (_tempBase)
				_currentBase = _tempBase;
		}

		public function setBaseDirty():void
		{
			for each (var base:BaseVO in _bases)
			{
				base.dirty = true;
			}
		}

		public function updateBases():void
		{
			for each (var base:BaseVO in _bases)
			{
				base.dirty = true;
			}
		}

		public function isBaseDamaged( baseID:String = null ):Boolean
		{
			var baseVO:BaseVO = (baseID != null) ? getBaseByID(baseID) : _currentBase;
			for (var i:int = 0; i < baseVO.buildings.length; i++)
			{
				if (baseVO.buildings[i].currentHealth != 1)
					return true;
			}
			return false;
		}

		public function removeBaseByID( id:String ):void
		{
			if (_bases[id])
			{
				ObjectPool.give(_bases[id]);
				delete _bases[id];
				_bases[id] = null;
			}
		}

		//============================================================================================================
		//************************************************************************************************************
		//													BUILDINGS
		//************************************************************************************************************
		//============================================================================================================

		public function importBuildingData( buildingData:BuildingData ):void
		{
			_tempBase = _bases[buildingData.baseID];
			if (_tempBase)
				_tempBase.importBuildingData(buildingData);
		}

		public function addBuilding( buildingVO:BuildingVO ):void
		{
			_tempBase = _bases[buildingVO.baseID];
			if (_tempBase)
				_tempBase.addBuilding(buildingVO);
		}

		public function updateBuildingID( oldID:String, newID:String ):void
		{
			//ensure the building exists
			var buildingVO:BuildingVO = getBuildingByID(oldID, false);
			if (buildingVO)
			{
				//update its' id
				_tempBase = _bases[buildingVO.baseID];
				_tempBase.updateBuildingID(oldID, newID);
			}
		}

		public function getBuildingByID( id:String, useCurrentBase:Boolean = true ):BuildingVO
		{
			var buildingVO:BuildingVO;
			if (useCurrentBase)
				buildingVO = _currentBase.getBuildingByID(id);
			else
			{
				for each (var base:BaseVO in _bases)
				{
					buildingVO = base.getBuildingByID(id);
					if (buildingVO)
						break;
				}
			}
			return buildingVO;
		}

		public function getBuildingsByBaseID( id:String = null ):Vector.<BuildingVO>
		{
			_tempBase = (id == null) ? _currentBase : _bases[id];
			if (_tempBase)
				return _tempBase.buildings;
			return null;
		}

		public function getBuildingByClass( buildingClass:String, highestLevel:Boolean = false ):BuildingVO
		{
			var buildingVO:BuildingVO = _currentBase.getBuildingByClass(buildingClass, highestLevel);
			if (buildingVO)
				return buildingVO;
			return null;
		}

		public function removeBuildingByID( id:String ):BuildingVO
		{
			var buildingVO:BuildingVO = getBuildingByID(id, false);
			if (buildingVO)
				_bases[buildingVO.baseID].removeBuilding(buildingVO);
			return buildingVO;
		}

		//============================================================================================================
		//************************************************************************************************************
		//													RESEARCH
		//************************************************************************************************************
		//============================================================================================================

		public function importResearchData( researchData:ResearchData ):void
		{
			_tempBase = _bases[researchData.baseID];
			if (_tempBase)
				_tempBase.importResearchData(researchData);
		}

		public function addBeginnerResearch( research:Vector.<IPrototype> ):void
		{
			var researchData:ResearchData = ObjectPool.get(ResearchData);
			for (var i:int = 0; i < research.length; i++)
			{
				if (research[i].getValue('requiredBuilding') == '')
				{
					for each (var base:BaseVO in _bases)
					{
						researchData.baseID = base.id;
						researchData.id = 'Research' + i;
						researchData.playerOwnerID = CurrentUser.id;
						researchData.prototype = research[i];
						importResearchData(researchData);
					}
				}
			}
			ObjectPool.give(researchData);
		}

		public function getAllStarbaseResearchTransactions():Vector.<ResearchVO>
		{
			var v:Vector.<ResearchVO> = new Vector.<ResearchVO>();

			for each (var base:BaseVO in _bases)
				v.concat(base.research);

			return v;
		}

		public function getResearchByID( id:String, useCurrentBase:Boolean = true ):ResearchVO
		{
			var researchVO:ResearchVO;
			if (useCurrentBase)
				researchVO = _currentBase.getResearchByID(id);
			else
			{
				for each (var base:BaseVO in _bases)
				{
					researchVO = base.getResearchByID(id);
					if (researchVO)
						break;
				}
			}
			return researchVO;
		}

		public function removeResearchByID( id:String ):ResearchVO
		{
			var researchVO:ResearchVO = getResearchByID(id, false);
			if (researchVO)
				_bases[researchVO.baseID].removeResearch(researchVO);
			return researchVO;
		}

		public function isResearched( name:String ):Boolean
		{
			var baseVO:BaseVO                  = currentBase;
			if (name == '' || name == null || baseVO.reqsDisabled != 0)
				return true;
			var researched:Vector.<ResearchVO> = research;
			for (var i:int = 0; i < researched.length; i++)
			{
				if (researched[i].name == name)
					return true;
			}
			return false;
		}

		public function get research():Vector.<ResearchVO>  { return _currentBase ? _currentBase.research : null; }

		//============================================================================================================
		//************************************************************************************************************
		//													TRADE ROUTES
		//************************************************************************************************************
		//============================================================================================================

		public function importTradeRouteData( tradeRouteData:TradeRouteData ):void
		{
			_tempBase = _bases[tradeRouteData.baseID];
			if (_tempBase)
				_tempBase.importTradeRouteData(tradeRouteData);
		}

		public function updateTradeRouteID( oldID:String, newID:String ):void
		{
			//ensure the traderoute exists
			var tradeRouteVO:TradeRouteVO = getTradeRouteByID(oldID, false);
			if (tradeRouteVO)
			{
				_tempBase = _bases[tradeRouteVO.baseID];
				_tempBase.updateTradeRouteID(oldID, newID);
			}
		}

		public function getTradeRouteByID( id:String, useCurrentBase:Boolean = true ):TradeRouteVO
		{
			var tradeRouteVO:TradeRouteVO;
			if (useCurrentBase)
				tradeRouteVO = _currentBase.getTradeRouteByID(id);
			else
			{
				for each (var base:BaseVO in _bases)
				{
					tradeRouteVO = base.getTradeRouteByID(id);
					if (tradeRouteVO)
						break;
				}
			}
			return tradeRouteVO;
		}

		public function getTradeRouteByCorporation( corporation:String, useCurrentBase:Boolean = true ):TradeRouteVO
		{
			var tradeRouteVO:TradeRouteVO;
			if (useCurrentBase)
				tradeRouteVO = _currentBase.getTradeRouteByCorporation(corporation);
			else
			{
				for each (var base:BaseVO in _bases)
				{
					tradeRouteVO = base.getTradeRouteByCorporation(corporation);
					if (tradeRouteVO)
						break;
				}
			}
			return tradeRouteVO;
		}

		public function getTradeRoutesByBaseID( id:String = null ):Vector.<TradeRouteVO>
		{
			_tempBase = (id == null) ? _currentBase : _bases[id];
			if (_tempBase)
				return _tempBase.tradeRoutes;
			return null;
		}

		public function removeTradeRouteByID( id:String ):TradeRouteVO
		{
			var tradeRouteVO:TradeRouteVO = getTradeRouteByID(id, false);
			if (tradeRouteVO)
				_bases[tradeRouteVO.baseID].removeTradeRoute(tradeRouteVO);
			return tradeRouteVO;
		}

		//============================================================================================================
		//************************************************************************************************************
		//													 BUFFS
		//************************************************************************************************************
		//============================================================================================================

		public function importBuffData( buffData:BuffData ):void
		{
			_tempBase = _bases[buffData.baseID];
			if (_tempBase)
				_tempBase.importBuffData(buffData);
		}

		public function getBuffByID( id:String, useCurrentBase:Boolean = true ):BuffVO
		{
			var buffVO:BuffVO;
			if (useCurrentBase)
				buffVO = _currentBase.getBuffByID(id);
			else
			{
				for each (var base:BaseVO in _bases)
				{
					buffVO = base.getBuffByID(id);
					if (buffVO)
						break;
				}
			}
			return buffVO;
		}

		public function getBuffByType( type:String, useCurrentBase:Boolean = true ):BuffVO
		{
			var buffVO:BuffVO;
			if (useCurrentBase)
				buffVO = _currentBase.getBuffByType(type);
			else
			{
				for each (var base:BaseVO in _bases)
				{
					buffVO = base.getBuffByType(type);
					if (buffVO)
						break;
				}
			}
			return buffVO;
		}

		public function getBuffsByBaseID( id:String = null ):Vector.<BuffVO>
		{
			_tempBase = (id == null) ? _currentBase : _bases[id];
			if (_tempBase)
				return _tempBase.buffs;
			return null;
		}

		public function updateBuffID( oldID:String, newID:String ):void
		{
			//ensure the building exists
			var buffVO:BuffVO = getBuffByID(oldID, false);
			if (buffVO)
			{
				//update its' id
				_tempBase = _bases[buffVO.baseID];
				_tempBase.updateBuffID(oldID, newID);
			}
		}

		public function removeBuffByID( id:String ):BuffVO
		{
			var buffVO:BuffVO = getBuffByID(id, false);
			if (buffVO)
				_bases[buffVO.baseID].removeBuff(buffVO);
			return buffVO;
		}

		public function getCurrentResourceCount( type:String ):uint
		{
			if (_currentBase)
			{
				var resource:uint = 0;
				switch (type)
				{
					case CurrencyEnum.ALLOY:
						resource = _currentBase.alloy;
						break;
					case CurrencyEnum.CREDIT:
						resource = _currentBase.credits;
						break;
					case CurrencyEnum.ENERGY:
						resource = _currentBase.energy;
						break;
					case CurrencyEnum.SYNTHETIC:
						resource = _currentBase.synthetic;
						break;
				}
				return resource;
			} else
				return 0;
		}

		public function addListener( callback:Function ):void  { _currentBase.onResourcesChange.add(callback); }
		public function removeListener( callback:Function ):void  { _currentBase.onResourcesChange.remove(callback); }

		public function get baseCreditIncome():uint  { return _currentBase ? _currentBase.baseCreditIncome : null; }
		public function get baseResourceIncome():uint  { return _currentBase ? _currentBase.baseResourceIncome : null; }

		public function get baseResourcePurchaseScale():Number  { return _currentBase ? _currentBase.baseResourcePurchaseScale : 0; }
		public function get baseCreditPurchaseScale():Number  { return _currentBase ? _currentBase.baseCreditPurchaseScale : 0; }


		public function get tradeRouteCreditIncome():uint  { return _currentBase ? _currentBase.tradeRouteCreditIncome : null; }
		public function get tradeRouteResourceIncome():uint  { return _currentBase ? _currentBase.tradeRouteResourceIncome : null; }

		public function get buildings():Vector.<BuildingVO>  { return _currentBase ? _currentBase.buildings : null; }

		public function get currentBase():BaseVO  { return _currentBase; }
		public function get currentBaseID():String  { return _currentBase.id; }

		public function get homeBase():BaseVO  { return _bases[CurrentUser.homeBase]; }
		public function get centerSpaceBase():BaseVO
		{
			if (CurrentUser.centerSpaceBase)
				return _bases[CurrentUser.centerSpaceBase];
			return null;
		}

		public function get maxCredits():uint  { return _currentBase ? _currentBase.maxCredits : 0; }
		public function get maxResources():uint  { return _currentBase ? _currentBase.maxResources : 0; }

		public function get grid():StarbaseGrid  { return _currentBase.grid; }
	}
}


