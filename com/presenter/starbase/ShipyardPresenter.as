package com.presenter.starbase
{
	import com.controller.ServerController;
	import com.controller.transaction.TransactionController;
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.TypeEnum;
	import com.event.TransactionEvent;
	import com.event.signal.TransactionSignal;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetModel;
	import com.model.fleet.ShipVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionVO;
	import com.presenter.ImperiumPresenter;

	public class ShipyardPresenter extends ImperiumPresenter implements IShipyardPresenter
	{
		private static var _tempID:int       = 0;

		private var _assetModel:AssetModel;
		private var _fleetModel:FleetModel;
		private var _prototypeModel:PrototypeModel;
		private var _starbaseModel:StarbaseModel;
		private var _serverController:ServerController;
		private var _transactionController:TransactionController;

		/** Currently selected ship the player is working on, i.e. what will get built when they click "build" */
		private var _currentShip:ShipVO      = new ShipVO();

		/** When a player refits a ship, this gets set. Used to continue refitting a ship when canceled */
		private var _refittingShip:ShipVO;

		/** Stores the ship design we have been working on this session so it doesn't get stomped by scrapping, refitting etc. */
		private static var _savedShip:ShipVO = new ShipVO();

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_transactionController.shipyardPresenter = this;
		}

		public function loadIcon( url:String, callback:Function ):void
		{
			_assetModel.getFromCache("assets/" + url, callback);
		}

		public function loadIconFromEntityData( type:String, callback:Function ):void
		{
			var _currentAssetVO:AssetVO = _assetModel.getEntityData(type);
			loadIcon(_currentAssetVO.smallImage, callback);
		}

		public function buildShip( ship:ShipVO, purchaseType:uint ):void
		{
			ship.id = tempID;
			_fleetModel.addShip(ship);
			_transactionController.dockBuildShip(ship, purchaseType);
		}

		public function refitShip( ship:ShipVO, purchaseType:uint ):void
		{
			var existingShip:ShipVO = getShipByID(ship.id);
			existingShip.refitShipName = ship.refitShipName;
			existingShip.refitModules = ship.refitModules;
			existingShip.calculateCosts();
			_transactionController.dockRefitShip(existingShip, purchaseType);
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

		public function getModules( slotType:String ):Vector.<IPrototype>  { return _prototypeModel.getModulesBySlotType(slotType); }

		public function getSlotPrototype( key:String ):IPrototype  { return _prototypeModel.getSlotPrototype(key); }

		public function getBuildingShip():ShipVO
		{
			var ship:ShipVO;
			var transaction:TransactionVO = _transactionController.getShipyardTransaction();
			if (transaction)
				ship = _fleetModel.getShip(transaction.id);
			if (ship)
			{
				if (ship.refiting)
				{
					_refittingShip = ship.clone();
					_refittingShip.id = ship.id;
					_refittingShip.built = true;
				} else
					_refittingShip = null;
			}
			return ship;
		}

		public function getShipByID( id:String ):ShipVO  { return _fleetModel.getShip(id); }

		public function cancelTransaction( transaction:TransactionVO ):void
		{
			if (transaction)
			{
				_transactionController.transactionCancel(transaction.id);
			}
		}

		public function recycleShip( shipVO:ShipVO ):void
		{
			if (shipVO)
			{
				_transactionController.dockRecycleShip(shipVO);
			}
		}

		public function isResearched( tech:String ):Boolean
		{
			if (tech == '')
				return true;

			var requiredBuildingClass:String = _prototypeModel.getResearchPrototypeByName(tech).getValue('requiredBuildingClass');
			return _transactionController.isResearched(tech, requiredBuildingClass);
		}

		public function canBuild( ship:IPrototype ):RequirementVO  { return _transactionController.canBuildShip(ship); }

		public function getAssetVO( prototype:IPrototype ):AssetVO
		{
			var assetName:String = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;
			return _assetModel.getEntityData(assetName);
		}

		public function isShipyardRepairing():Boolean
		{
			var repairing:Boolean = false;
			var shipyard:BuildingVO = _starbaseModel.getBuildingByClass(TypeEnum.CONSTRUCTION_BAY);
			if (shipyard)
			{
				var transaction:TransactionVO = _transactionController.getStarbaseBuildingTransaction(shipyard.constructionCategory, shipyard.id);
				if (transaction && transaction.type == TransactionEvent.STARBASE_REPAIR_BASE)
					repairing = true;
			}

			return repairing;
		}

		public function getPrototypeByName( proto:String ):IPrototype
		{
			var iproto:IPrototype = _prototypeModel.getBuildingPrototype(proto);
			if (!iproto)
				iproto = _prototypeModel.getResearchPrototypeByName(proto);
			if (!iproto)
				iproto = _prototypeModel.getShipPrototype(proto);
			if (!iproto)
				iproto = _prototypeModel.getStoreItemPrototypeByName(proto);
			if (!iproto)
				iproto = _prototypeModel.getWeaponPrototype(proto);
			return iproto;
		}

		public function addTransactionListener( listener:Function ):void  { _transactionController.addListener(TransactionSignal.TRANSACTION, listener); }
		public function removeTransactionListener( listener:Function ):void  { _transactionController.removeListener(listener); }

		public function get currentShip():ShipVO  { return _currentShip; }
		public function set currentShip( value:ShipVO ):void  { _currentShip = value; }

		public function get builtShipCount():Number  { return _fleetModel.builtShipCount; }
		public function get maxAvailableShipSlots():Number  { return _fleetModel.maxAvailableShipSlots; }
		public function get canBuildNewShips():Boolean  { return _fleetModel.canBuildNewShips; }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }

		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }

		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }

		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }

		public function get refittingShip():ShipVO
		{
			if (_refittingShip)
			{
				//update the modules in case the ship has finished its refit
				var existingShip:ShipVO = _fleetModel.getShip(_refittingShip.id);
				if (existingShip)
					_refittingShip.modules = existingShip.modules;
				else
					_refittingShip = null;
			}
			return _refittingShip;
		}
		public function get savedShip():ShipVO  { return _savedShip; }
		public function set savedShip( value:ShipVO ):void  { _savedShip = value; }
		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		public function get shipPrototypes():Vector.<IPrototype>  { return _prototypeModel.getShipPrototypesByFaction(CurrentUser.faction); }
		public function get shipyardTransaction():TransactionVO  { return _transactionController.getShipyardTransaction(); }
		private function get tempID():String  { _tempID++; return CurrentUser.name + '.clientside_ship.' + _tempID; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }

		override public function destroy():void
		{
			_assetModel = null;
			_fleetModel = null;
			_prototypeModel = null;
			_starbaseModel = null;
			_serverController = null;
			_transactionController.shipyardPresenter = null;
			_transactionController = null;
		}
	}
}


