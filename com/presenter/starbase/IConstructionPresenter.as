package com.presenter.starbase
{
	import com.controller.transaction.requirements.RequirementVO;
	import com.model.asset.AssetVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BuildingVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.IImperiumPresenter;

	import org.parade.core.IView;

	public interface IConstructionPresenter extends IImperiumPresenter
	{
		function performTransaction( transactionType:String, prototype:IPrototype, purchaseType:uint, ... args ):void;
		function getBuildingPrototypes( groupID:String, subItemID:String ):Vector.<IPrototype>;
		function getBuildingCount( buildingClass:String ):int;
		function getBuildingMaxCount( buildingClass:String ):int;
		function getBuildingUpgrade( upgrade:String ):IPrototype;
		function getBuildingVO( id:String ):BuildingVO;
		function getBuildingVOByClass( itemClass:String, highestLevel:Boolean = false ):BuildingVO;
		function getStarbaseBuildingTransaction( constructionCategory:String = null, buildingID:String = null ):TransactionVO;
		function getStarbaseResearchTransaction( buildingType:String ):TransactionVO;

		function getComponents( groupID:String, subItemID:String, slotID:String, showHighest:Boolean, showAdvancedOnly:Boolean, showCommonOnly:Boolean, showUncommonOnly:Boolean, showRareOnly:Boolean, showEpicOnly:Boolean, showLegendaryOnly:Boolean):Vector.<IPrototype>;
		function canEquip( prototype:IPrototype, slotType:String ):RequirementVO;

		function getResearchPrototypes( groupID:String, subItemID:String ):Vector.<IPrototype>;

		function isResearched( tech:String ):Boolean;
		function getRequirements( transactionType:String, prototype:IPrototype ):RequirementVO;
		function requirementsMet( proto:IPrototype ):Boolean;
		function loadImage( url:String, callback:Function ):void;
		function getAssetVO( prototype:IPrototype ):AssetVO;
		function getBlueprint( name:String ):BlueprintVO;
		function getPrototypeByName( proto:String ):IPrototype;
		function getResearchItemPrototypeByName( v:String ):IPrototype;
		function getFilterNameByKey( v:String ):String;

		function getBlueprintHardCurrencyCost( blueprint:BlueprintVO, partsPurchased:Number ):Number;
		function purchaseBlueprint( blueprint:BlueprintVO, partsPurchased:Number ):void;
		function completeBlueprintResearch( blueprint:BlueprintVO):void;

		function addOnTransactionRemovedListener( callback:Function ):void;
		function removeOnTransactionRemovedListener( callback:Function ):void;

		function getView( view:Class ):IView;
		function mintNFT( tokenType:int, tokenAmount:int, tokenPrototype:String ):void;
	}
}
