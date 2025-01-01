package com.presenter.starbase
{

	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.ResearchVO;
	import com.presenter.IImperiumPresenter;

	import flash.utils.Dictionary;

	public interface IStorePresenter extends IImperiumPresenter
	{
		function getTransactions():Dictionary;
		function getStoreItemPrototypes():Vector.<IPrototype>;
		function getCurrentState():String;
		function getPrototypeUIName( prototype:IPrototype ):String;
		function getPrototypeUISmallImage( prototype:IPrototype ):String;
		function getProtoTypeUIDescriptionText( prototype:IPrototype ):String;
		function loadIconFromPrototype( prototype:IPrototype, callback:Function ):void
		function addOnTransactionUpdatedListener( callback:Function ):void;
		function removeOnTransactionUpdatedListener( callback:Function ):void;
		function addOnTransactionRemovedListener( callback:Function ):void;
		function removeOnTransactionRemovedListener( callback:Function ):void;
		function getHardCurrencyCostFromSeconds( buildTimeSeconds:Number ):int;
		function getHardCurrencyCostFromResource( resources:int, type:String ):int;
		function getCanAfford( prototype:IPrototype ):Boolean;
		function getShipById( id:String ):ShipVO;
		function getFleetById( id:String ):FleetVO;
		function getBuildingByID( id:String ):BuildingVO;
		function getResearchByID( id:String ):ResearchVO;
		function getBuildingVOByClass( itemClass:String ):BuildingVO;
		function getMaxResources():uint;
		function getMaxCredits():uint;
		function getResourceCount( type:String ):uint;
		function speedUpTransaction( serverKey:String, token:int, instant:Boolean, speedUpBy:int, fromStore:Boolean, cost:int ):void;
		function buyResourceTransaction( prototype:IPrototype, percent:int, centerBase:Boolean, cost:int ):void;
		function buyItemTransaction( buffPrototype:IPrototype, centerBase:Boolean, cost:int ):void;
		function buyOtherItemTransaction( prototype:IPrototype, amount:int, centerBase:Boolean, cost:int ):void;
	}
}
