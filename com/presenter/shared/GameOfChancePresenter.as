package com.presenter.shared
{
	import com.controller.transaction.TransactionController;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleModel;
	import com.model.battle.BattleRerollVO;
	import com.model.blueprint.BlueprintModel;
	import com.model.blueprint.BlueprintVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.presenter.ImperiumPresenter;

	public class GameOfChancePresenter extends ImperiumPresenter implements IGameOfChancePresenter
	{

		private var _transactionController:TransactionController;

		private var _assetModel:AssetModel;
		private var _blueprintModel:BlueprintModel;
		private var _battleModel:BattleModel;
		private var _prototypeModel:PrototypeModel;

		[PostConstruct]
		override public function init():void
		{
			super.init();
		}

		public function loadIcon( url:String, callback:Function ):void
		{
			_assetModel.getFromCache("assets/" + url, callback);
		}

		public function getAssetVO( assetName:String ):AssetVO
		{
			return _assetModel.getEntityData(assetName);
		}

		public function getConstantPrototypeValueByName( name:String ):Number
		{
			var proto:IPrototype = _prototypeModel.getConstantPrototypeByName(name);
			return proto.getValue('value');
		}

		public function getConstantPrototypeByName( name:String ):IPrototype
		{
			return _prototypeModel.getConstantPrototypeByName(name);
		}

		public function getBlueprintByName( prototype:String ):BlueprintVO
		{
			return _blueprintModel.getBlueprintByName(prototype);
		}

		public function getBlueprintPrototypeByName( v:String ):IPrototype
		{
			return _prototypeModel.getBlueprintPrototype(v);
		}

		public function getResearchPrototypeByName( v:String ):IPrototype
		{
			return _prototypeModel.getResearchPrototypeByName(v);
		}

		public function getShipPrototype( v:String ):IPrototype
		{
			return _prototypeModel.getShipPrototype(v);
		}

		public function getModulePrototypeByName( v:String ):IPrototype
		{
			var iproto:IPrototype = _prototypeModel.getShipPrototype(v);
			if (!iproto)
				iproto = _prototypeModel.getWeaponPrototype(v);
			return iproto;
		}

		public function getBlueprintByID( id:String ):BlueprintVO
		{
			return _blueprintModel.getBlueprintByID(id);
		}

		public function getBlueprintHardCurrencyCost( blueprint:BlueprintVO, partsPurchased:Number ):Number
		{
			return _transactionController.getBlueprintHardCurrencyCost(blueprint, partsPurchased);
		}

		public function removeBlueprintByName( name:String ):void
		{
			_blueprintModel.removeBlueprintByName(name);
		}

		public function purchaseBlueprint( blueprint:BlueprintVO, partsPurchased:Number ):void
		{
			_transactionController.buyBlueprintTransaction(blueprint, partsPurchased);
		}
		public function completeBlueprintResearch( blueprint:BlueprintVO):void  
		{ 
			_transactionController.completeBlueprintResearchTransaction(blueprint); 
		}

		public function purchaseReroll( battleKey:String ):void
		{
			_transactionController.starbasePurchaseReroll(battleKey);
		}

		public function purchaseDeepScan( battleKey:String ):void
		{
			_transactionController.starbasePurchaseDeepScan(battleKey);
		}

		public function removeRerollFromAvailable( battleID:String ):void
		{
			_battleModel.removeRerollByID(battleID);
		}

		public function getAvailableRerolls():Vector.<BattleRerollVO>
		{
			return _battleModel.getAllAvailableRerolls();
		}

		public function addAvailableRerollUpdatedListener( callback:Function ):void  { _battleModel.onRerollAdded.add(callback); }
		public function removeAvailableRerollUpdatedListener( callback:Function ):void  { _battleModel.onRerollAdded.remove(callback); }

		public function addRerollFromRerollCallback( callback:Function ):void  { _battleModel.onRerollUpdated.add(callback); }
		public function removeRerollFromRerollCallback( callback:Function ):void  { _battleModel.onRerollUpdated.remove(callback); }

		public function addRerollFromScanCallback( callback:Function ):void  { _battleModel.onRerollUpdated.add(callback); }
		public function removeRerollFromScanCallback( callback:Function ):void  { _battleModel.onRerollUpdated.remove(callback); }

		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set blueprintModel( v:BlueprintModel ):void  { _blueprintModel = v; }
		[Inject]
		public function set battleModel( value:BattleModel ):void  { _battleModel = value; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
	}
}
