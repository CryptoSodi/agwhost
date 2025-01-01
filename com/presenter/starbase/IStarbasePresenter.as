package com.presenter.starbase
{
	import com.controller.transaction.requirements.RequirementVO;
	import com.model.asset.AssetVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BaseVO;
	import com.model.starbase.BuildingVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.shared.IGamePresenter;

	import org.ash.core.Entity;

	public interface IStarbasePresenter extends IGamePresenter
	{
		function cancelTransaction( trans:TransactionVO ):void;
		function moveEntity():void;
		function onInteractionWithBaseEntity( x:int, y:int, baseEntity:Entity ):void;
		function performTransaction( transactionType:String, prototype:IPrototype, purchaseType:uint, ... args ):void;

		function getBuildingUpgrade( buildingVO:BuildingVO ):IPrototype;
		function getBuildingVO( id:String ):BuildingVO;
		function getBuildingVOByClass( itemClass:String, highestLevel:Boolean = false ):BuildingVO;
		function getPrototypeByName( proto:String ):IPrototype;
		function getBlueprintByName( prototype:String ):BlueprintVO;
		function getBlueprintHardCurrencyCost( blueprint:BlueprintVO, partsPurchased:Number ):Number;
		function purchaseBlueprint( blueprint:BlueprintVO, partsPurchased:Number ):void;
		function getRequirements( transactionType:String, prototype:IPrototype ):RequirementVO;
		function getSlotType( key:String ):String;
		function getFilterAssetVO( prototype:IPrototype ):AssetVO;
		function getStarbaseBuildingTransaction( constructionCategory:String = null, buildingID:String = null ):TransactionVO;
		function getStarbaseResearchTransaction( buildingType:String ):TransactionVO;
		function loadIcon( url:String, callback:Function ):void;
		function getRepairCost():int;
		function getRepairTime( getTotal:Boolean = false ):int;
		function getEntityName( assetName:String ):String;

		function showBuildings():void;

		function addBaseInteractionListener( callback:Function ):void;
		function addTransactionListener( listener:Function ):void;
		function removeTransactionListener( listener:Function ):void;
		function addOnGenericAllianceMessageRecievedListener( callback:Function ):void;
		function removeOnGenericAllianceMessageRecievedListener( callback:Function ):void;

		function getConstantPrototypeValueByName( name:String ):Number;
		function getStatPrototypeByName( name:String ):IPrototype;

		function get buildingPrototypes():Vector.<IPrototype>;
		function get currentBase():BaseVO;
		function get researchPrototypes():Vector.<IPrototype>;

		function get totalDamagedBuildings():int;
		function get totalDestroyedBuildings():int;
		function get totalBaseDamage():Number;
	}
}
