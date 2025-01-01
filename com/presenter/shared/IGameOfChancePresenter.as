package com.presenter.shared
{
	import com.model.asset.AssetVO;
	import com.model.battle.BattleRerollVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.prototype.IPrototype;
	import com.presenter.IImperiumPresenter;

	public interface IGameOfChancePresenter extends IImperiumPresenter
	{
		function loadIcon( url:String, callback:Function ):void;
		function getAssetVO( assetName:String ):AssetVO;
		function getResearchPrototypeByName( v:String ):IPrototype;
		function getConstantPrototypeValueByName( name:String ):Number;
		function getConstantPrototypeByName( name:String ):IPrototype;
		function getModulePrototypeByName( v:String ):IPrototype;
		function getShipPrototype( v:String ):IPrototype;
		function getBlueprintByName( prototype:String ):BlueprintVO;
		function getBlueprintPrototypeByName( v:String ):IPrototype;
		function getBlueprintByID( id:String ):BlueprintVO;
		function getBlueprintHardCurrencyCost( blueprint:BlueprintVO, partsPurchased:Number ):Number;
		function removeBlueprintByName( name:String ):void;
		function purchaseBlueprint( blueprint:BlueprintVO, partsPurchased:Number ):void;
		function purchaseReroll( battleKey:String ):void;
		function purchaseDeepScan( battleKey:String ):void;
		function removeRerollFromAvailable( battleID:String ):void;
		function getAvailableRerolls():Vector.<BattleRerollVO>;

		function addAvailableRerollUpdatedListener( callback:Function ):void;
		function addRerollFromRerollCallback( callback:Function ):void;
		function addRerollFromScanCallback( callback:Function ):void;

		function removeAvailableRerollUpdatedListener( callback:Function ):void;
		function removeRerollFromRerollCallback( callback:Function ):void;
		function removeRerollFromScanCallback( callback:Function ):void;
	}
}
