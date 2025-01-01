package com.presenter.starbase
{
	import com.Application;
	import com.controller.transaction.TransactionController;
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.TypeEnum;
	import com.enum.server.PurchaseTypeEnum;
	import com.event.BattleEvent;
	import com.event.SectorEvent;
	import com.event.StateEvent;
	import com.event.signal.TransactionSignal;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.sector.SectorModel;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionVO;
	import com.presenter.ImperiumPresenter;

	import org.ash.core.Entity;
	import org.ash.core.Game;

	public class FleetPresenter extends ImperiumPresenter implements IFleetPresenter
	{
		private static var _selectedFleetID:String;
		private static var _shipSelectionFilter:Array;

		private var _game:Game;
		private var _assetModel:AssetModel;
		private var _fleetModel:FleetModel;
		private var _sectorModel:SectorModel;
		private var _starbaseModel:StarbaseModel;
		private var _prototypeModel:PrototypeModel;
		private var _transactionController:TransactionController;

		public function assignShipToFleet( selectedFleet:FleetVO, selectedShip:ShipVO, index:int ):void
		{
			_fleetModel.assignShipToFleet(selectedFleet, selectedShip, index);
			_transactionController.dockUpdateFleet(selectedFleet);
		}

		public function removeShipFromFleet( selectedFleet:FleetVO, shipID:String ):void
		{
			_fleetModel.removeShipFromFleet(shipID);
			_transactionController.dockUpdateFleet(selectedFleet);
		}

		public function changeFleetName( fleetToRename:FleetVO, newName:String ):void
		{
			_fleetModel.renameFleet(fleetToRename, newName);
			_transactionController.dockChangeFleetName(fleetToRename.id, newName);
		}

		public function repairFleet( fleetToRepair:FleetVO, purchaseType:uint ):void
		{

			_transactionController.dockRepairShip(fleetToRepair, purchaseType);

			if (purchaseType == PurchaseTypeEnum.INSTANT)
			{
				var id:String;
				var fleetToUse:FleetVO;
				id = fleetToRepair.id;
				fleetToUse = fleetToRepair;
				_fleetModel.repairFleet(fleetToUse, true);
			}
		}

		public function updateRepair():void
		{
			var transaction:TransactionVO = _transactionController.getDockTransaction();
			if (transaction && transaction.timeRemainingMS > 0)
				_fleetModel.repairFleet(_fleetModel.getFleet(transaction.id), false, transaction);
		}

		public function cancelTransaction( transaction:TransactionVO ):void
		{
			_transactionController.transactionCancel(transaction.id);
		}

		public function loadIcon( url:String, callback:Function ):void
		{
			_assetModel.getFromCache(url, callback);
		}

		public function loadIconFromEntityData( type:String, callback:Function ):void
		{
			var _currentAssetVO:AssetVO = _assetModel.getEntityData(type);
			loadIcon("assets/" + _currentAssetVO.smallImage, callback);
		}

		public function getProtoTypeUIName( prototype:IPrototype, callback:Function ):void
		{
			var currentAssetVO:AssetVO = _assetModel.getEntityData(prototype.getValue('uiAsset'));
			if (callback != null)
				callback(currentAssetVO.visibleName);
		}

		public function launchFleet( fleetsToLaunch:Array ):void
		{
			_transactionController.dockLaunchFleet(fleetsToLaunch);

			gotoFleet(fleetsToLaunch[0]);
		}

		public function gotoFleet( fleet:FleetVO ):void
		{
			var sectorEvent:SectorEvent;
			if (fleet.inBattle)
			{
				_sectorModel.focusFleetID = fleet.id;
				var battleEvent:BattleEvent = new BattleEvent(BattleEvent.BATTLE_JOIN, fleet.battleServerAddress);
				dispatch(battleEvent);
			} else
			{

				if (Application.STATE == StateEvent.GAME_STARBASE)
				{
					sectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, fleet.sector != "" ? fleet.sector : _starbaseModel.getBaseByID(fleet.starbaseID).sectorID, fleet.id);
					dispatch(sectorEvent);
				} else if (Application.STATE == StateEvent.GAME_SECTOR)
				{

					if (fleet.sector != '' && _sectorModel.sectorID != fleet.sector || (fleet.sector == '' && _sectorModel.sectorID != _starbaseModel.getBaseByID(fleet.starbaseID).sectorID))
					{
						sectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, fleet.sector != "" ? fleet.sector : _starbaseModel.getBaseByID(fleet.starbaseID).sectorID, fleet.id);
						dispatch(sectorEvent);
					} else
					{
						var system:SectorInteractSystem = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
						if (system != null)

							if (system != null)
							{
								var entity:Entity = _game.getEntity(fleet.id);
								if (entity != null)
									system.selectEntity(entity, true);
							}
					}

				}
			}
		}

		public function recallFleet( id:String ):void
		{
			if (id != '')
				_transactionController.dockRecallFleet(id);
		}

		public function canRepair( fleet:FleetVO ):RequirementVO
		{
			return _transactionController.canRepair(fleet);
		}

		public function getAssetVO( prototype:IPrototype ):AssetVO
		{
			var assetName:String = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;
			return _assetModel.getEntityData(assetName);
		}

		public function addTransactionListener( listener:Function ):void
		{
			_transactionController.addListener(TransactionSignal.TRANSACTION, listener);
			_fleetModel.onUpdatedFleetsSignal.add(listener);
		}

		public function removeTransactionListener( listener:Function ):void
		{
			_transactionController.removeListener(listener);
			_fleetModel.onUpdatedFleetsSignal.remove(listener);
		}

		public function addListenerOnFleetUpdated( listener:Function ):void
		{
			_fleetModel.onUpdatedFleetsSignal.add(listener);
		}

		public function removeListenerOnFleetUpdated( listener:Function ):void
		{
			_fleetModel.onUpdatedFleetsSignal.remove(listener);
		}

		public function getConstantPrototypeValueByName( name:String ):Number
		{
			var proto:IPrototype = _prototypeModel.getConstantPrototypeByName(name);
			return proto.getValue('value');
		}

		public function getStatPrototypeByName( name:String ):IPrototype
		{
			var proto:IPrototype = _prototypeModel.getStatPrototypeByName(name);
			return proto;
		}

		public function getFleet( id:String ):FleetVO
		{
			return _fleetModel.getFleet(id);
		}

		public function get dockLevel():int  { return BuildingVO(_starbaseModel.getBuildingByClass(TypeEnum.DOCK)).level; }
		public function get dockTransaction():TransactionVO  { return _transactionController.getDockTransaction(); }
		public function get shipyardTransaction():TransactionVO  { return _transactionController.getShipyardTransaction(); }
		public function get fleets():Vector.<FleetVO>  { return _fleetModel.fleets; }
		public function get maxFleetPower():int  { return _starbaseModel.currentBase.maxPower; }
		public function get unassignedShips():Vector.<ShipVO>  { return _fleetModel.ships; }
		public function set selectedFleetID( v:String ):void  { _selectedFleetID = v; }
		public function get selectedFleetID():String  { return _selectedFleetID; }
		public function set shipSelectionFilter( v:Array ):void  { _shipSelectionFilter = v; }
		public function get shipSelectionFilter():Array  { return _shipSelectionFilter; }

		[Inject]
		public function set game( v:Game ):void  { _game = v; }
		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
	}
}


