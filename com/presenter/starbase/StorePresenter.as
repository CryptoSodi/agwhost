package com.presenter.starbase
{
	import com.Application;
	import com.controller.transaction.TransactionController;
	import com.enum.server.PurchaseTypeEnum;
	import com.event.signal.TransactionSignal;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.ResearchVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.presenter.ImperiumPresenter;
	import com.service.server.incoming.data.BuffData;

	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import org.shared.ObjectPool;

	public class StorePresenter extends ImperiumPresenter implements IStorePresenter
	{
		[Inject]
		public var assetModel:AssetModel;
		[Inject]
		public var prototypeModel:PrototypeModel;
		[Inject]
		public var starbaseModel:StarbaseModel;
		[Inject]
		public var fleetModel:FleetModel;
		[Inject]
		public var transactionController:TransactionController;
		[Inject]
		public var transactionModel:TransactionModel;


		private static var _tempID:int = 0;
		private static var _tempOtherID:int = 0;

		public function getCurrentState():String
		{
			return Application.STATE;
		}

		public function getStoreItemPrototypes():Vector.<IPrototype>
		{
			return prototypeModel.getStoreItemPrototypes();
		}

		public function getPrototypeUIName( prototype:IPrototype ):String
		{
			var assetName:String       = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;

			var currentAssetVO:AssetVO = assetModel.getEntityData(assetName);
			return currentAssetVO.visibleName;
		}

		public function getProtoTypeUIDescriptionText( prototype:IPrototype ):String
		{
			var currentAssetVO:AssetVO = assetModel.getEntityData(prototype.getValue('uiAsset'));
			return currentAssetVO.descriptionText;
		}

		public function getPrototypeUISmallImage( prototype:IPrototype ):String
		{
			var currentAssetVO:AssetVO = assetModel.getEntityData(prototype.getValue('uiAsset'));
			return currentAssetVO.smallImage;
		}

		public function loadIconFromPrototype( prototype:IPrototype, callback:Function ):void
		{
			assetModel.getFromCache("assets/" + getPrototypeUISmallImage(prototype), callback);
		}

		public function speedUpTransaction( serverKey:String, token:int, instant:Boolean, speedUpBy:int, fromStore:Boolean, cost:int ):void
		{
			transactionController.speedUpTransaction(serverKey, token, instant, speedUpBy, fromStore, cost);
		}

		public function buyResourceTransaction( prototype:IPrototype, percent:int, centerBase:Boolean, cost:int ):void
		{
			transactionController.buyResourceTransaction(prototype, percent, centerBase, cost);
		}

		public function buyItemTransaction( buffPrototype:IPrototype, centerBase:Boolean, cost:int ):void
		{
			//save a new buff in the same way that the server would send it to us
			var buffData:BuffData = ObjectPool.get(BuffData);
			buffData.baseID = starbaseModel.currentBaseID;
			buffData.id = tempID;
			buffData.playerOwnerID = CurrentUser.id;
			buffData.prototype = prototypeModel.getBuffPrototype(buffPrototype.name);
			buffData.began = getTimer();
			buffData.ends = buffData.began + buffData.prototype.getValue("durationSeconds") * 1000;
			buffData.now = buffData.began;
			starbaseModel.importBuffData(buffData);
			transactionController.buyStoreItemTransaction(buffPrototype, centerBase, buffData.id, cost);
		}
		
		public function buyOtherItemTransaction( prototype:IPrototype, amount:int, centerBase:Boolean, cost:int ):void
		{
			transactionController.buyOtherStoreItemTransaction(prototype, amount, centerBase, tempOtherID, cost);
		}

		public function getHardCurrencyCostFromSeconds( buildTimeSeconds:Number ):int
		{
			return transactionController.getHardCurrencyCostFromSeconds(buildTimeSeconds);
		}

		public function getHardCurrencyCostFromResource( resources:int, type:String ):int
		{
			return transactionController.getHardCurrencyCostFromResource(resources, type);
		}

		public function getCanAfford( prototype:IPrototype ):Boolean
		{
			return transactionController.checkCost(prototype, PurchaseTypeEnum.NORMAL, true);
		}

		public function getMaxResources():uint
		{
			return starbaseModel.maxResources
		}

		public function getMaxCredits():uint
		{
			return starbaseModel.maxCredits;
		}

		public function getResourceCount( type:String ):uint
		{
			return starbaseModel.getCurrentResourceCount(type);
		}

		public function getShipById( id:String ):ShipVO
		{
			return fleetModel.getShip(id);
		}

		public function getFleetById( id:String ):FleetVO
		{
			return fleetModel.getFleet(id);
		}

		public function getBuildingByID( id:String ):BuildingVO
		{
			return starbaseModel.getBuildingByID(id);
		}

		public function getResearchByID( id:String ):ResearchVO
		{
			return starbaseModel.getResearchByID(id);
		}

		public function getBuildingVOByClass( itemClass:String ):BuildingVO
		{
			return starbaseModel.getBuildingByClass(itemClass, false);
		}

		public function addOnTransactionUpdatedListener( callback:Function ):void  { transactionModel.addListener(TransactionSignal.TRANSACTION_UPDATED, callback); }
		public function removeOnTransactionUpdatedListener( callback:Function ):void  { transactionModel.removeListener(callback); }

		public function addOnTransactionRemovedListener( callback:Function ):void  { transactionModel.addListener(TransactionSignal.TRANSACTION_REMOVED, callback); }
		public function removeOnTransactionRemovedListener( callback:Function ):void  { transactionModel.removeListener(callback); }

		public function get tempID():String  { _tempID++; return 'clientSide.buff' + _tempID; }
		public function get tempOtherID():String  { _tempOtherID++; return 'clientSide.otherItem' + _tempOtherID; }

		public function getTransactions():Dictionary
		{
			return transactionModel.transactions;
		}
	}
}


