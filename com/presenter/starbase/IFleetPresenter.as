package com.presenter.starbase
{
	import com.controller.transaction.requirements.RequirementVO;
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.transaction.TransactionVO;
	import com.presenter.IImperiumPresenter;

	public interface IFleetPresenter extends IImperiumPresenter
	{
		function assignShipToFleet( selectedFleet:FleetVO, selectedShip:ShipVO, index:int ):void;
		function removeShipFromFleet( selectedFleet:FleetVO, shipID:String ):void;
		function changeFleetName( fleetToRename:FleetVO, newName:String ):void
		function repairFleet( fleetToRepair:FleetVO, purchaseType:uint ):void;
		function updateRepair():void;
		function cancelTransaction( transaction:TransactionVO ):void;
		function loadIcon( url:String, callback:Function ):void
		function loadIconFromEntityData( type:String, callback:Function ):void;
		function getProtoTypeUIName( prototype:IPrototype, callback:Function ):void;
		function getAssetVO( prototype:IPrototype ):AssetVO;
		function launchFleet( fleetsToLaunch:Array ):void;
		function gotoFleet( fleet:FleetVO ):void;
		function recallFleet( id:String ):void;
		function canRepair( fleet:FleetVO ):RequirementVO;
		function addTransactionListener( listener:Function ):void;
		function removeTransactionListener( listener:Function ):void;
		function getStatPrototypeByName( name:String ):IPrototype;
		function getConstantPrototypeValueByName( name:String ):Number;
		function getFleet( id:String ):FleetVO;
		function addListenerOnFleetUpdated( listener:Function ):void;
		function removeListenerOnFleetUpdated( listener:Function ):void;

		function get dockLevel():int;
		function get dockTransaction():TransactionVO;
		function get shipyardTransaction():TransactionVO;
		function get fleets():Vector.<FleetVO>;
		function get maxFleetPower():int;
		function get unassignedShips():Vector.<ShipVO>;
		function set selectedFleetID( v:String ):void;
		function get selectedFleetID():String;
		function set shipSelectionFilter( v:Array ):void;
		function get shipSelectionFilter():Array;
	}
}


