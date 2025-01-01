package com.presenter.shared
{
	import com.controller.transaction.TransactionController;
	import com.event.TransactionEvent;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.ResearchVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionVO;
	import com.presenter.ImperiumPresenter;
	
	import flash.utils.Dictionary;

	public class EngineeringPresenter extends ImperiumPresenter implements IEngineeringPresenter
	{
		private var _assetModel:AssetModel;
		private var _fleetModel:FleetModel;
		private var _prototypeModel:PrototypeModel;
		private var _starbaseModel:StarbaseModel;
		private var _transactionController:TransactionController;

		[PostConstruct]
		override public function init():void
		{
			super.init();
		}

		public function getAssetVO( name:String ):AssetVO  { return _assetModel.getEntityData(name); }
		public function getBaseRepairTransaction():TransactionVO  { return _transactionController.getBaseRepairTransaction(); }
		public function getBuildingCount( buildingClass:String ):int  { return _starbaseModel.currentBase.getBuildingCount(buildingClass); }
		public function getBuildingByID( id:String ):BuildingVO  { return _starbaseModel.getBuildingByID(id, false); }
		public function getBuildingPrototypeByClassAndLevel( itemClass:String, level:int ):IPrototype  { return _prototypeModel.getBuildingPrototypeByClassAndLevel(itemClass, level); }
		public function getResearchByID( id:String ):ResearchVO  { return _starbaseModel.getResearchByID(id, false); }
		public function getStarbaseBuildingTransaction( constructionCategory:String ):TransactionVO  { return _transactionController.getStarbaseBuildingTransaction(constructionCategory, null); }
		public function getStarbaseResearchTransaction( buildingType:String ):TransactionVO  { return _transactionController.getStarbaseResearchTransactionByBuildingType(buildingType); }
		public function loadIcon( url:String, callback:Function ):void  { _assetModel.getFromCache("assets/" + url, callback); }
		public function getShipVOByID( id:String ):ShipVO { return _fleetModel.getShip(id); }
		public function getRepairFleetByID( id:String ):FleetVO { return _fleetModel.getFleet(id); }
		
		public function loadTransactionIcon( transaction:TransactionVO, callback:Function ):void
		{
			var assetVO:AssetVO;
			switch (transaction.type)
			{
				case TransactionEvent.STARBASE_BUILD_SHIP:
				case TransactionEvent.STARBASE_REFIT_SHIP:
					var ship:ShipVO         = _fleetModel.getShip(transaction.id);
					if (ship)
					{
						assetVO = _assetModel.getEntityData(ship.asset);
						loadIcon(assetVO.largeImage, callback);
					}
					break;

				case TransactionEvent.STARBASE_BUILDING_BUILD:
				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
				case TransactionEvent.STARBASE_REFIT_BUILDING:
				case TransactionEvent.STARBASE_REPAIR_BASE:
					var building:BuildingVO = _starbaseModel.getBuildingByID(transaction.id, false);
					if (building)
					{
						assetVO = _assetModel.getEntityData(building.asset);
						loadIcon(assetVO.mediumImage, callback);
					}
					break;

				case TransactionEvent.STARBASE_REPAIR_FLEET:
					var fleet:FleetVO       = _fleetModel.getFleet(transaction.id);
					if (fleet)
					{
						ship = fleet.ships[0];
						if (ship)
						{
							assetVO = _assetModel.getEntityData(ship.asset);
							loadIcon(assetVO.largeImage, callback);
						}
					}
					break;

				case TransactionEvent.STARBASE_RESEARCH:
					var research:ResearchVO = _starbaseModel.getResearchByID(transaction.id);
					if (research)
					{
						assetVO = _assetModel.getEntityData(research.uiAsset);
						loadIcon(assetVO.mediumImage, callback);
					}
					break;
			}
		}

		public function addTransactionListener( type:int, callback:Function ):void  { _transactionController.addListener(type, callback); }
		public function removeTransactionListener( callback:Function ):void  { _transactionController.removeListener(callback); }

		public function get transactions():Dictionary  { return _transactionController.transactions; }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }

		override public function destroy():void
		{
			super.destroy();

			_assetModel = null;
			_fleetModel = null;
			_prototypeModel = null;
			_starbaseModel = null;
			_transactionController = null;
		}
	}
}
