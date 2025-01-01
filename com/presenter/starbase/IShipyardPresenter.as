package com.presenter.starbase
{
	import com.controller.transaction.requirements.RequirementVO;
	import com.model.asset.AssetVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.transaction.TransactionVO;
	import com.presenter.IImperiumPresenter;

	public interface IShipyardPresenter extends IImperiumPresenter
	{
		function loadIcon( url:String, callback:Function ):void;
		function loadIconFromEntityData( type:String, callback:Function ):void;
		function getModules( slotType:String ):Vector.<IPrototype>;
		function getConstantPrototypeValueByName( name:String ):Number
		function getSlotPrototype( key:String ):IPrototype;
		function getBuildingShip():ShipVO;
		function getShipByID( id:String ):ShipVO;
		function buildShip( ship:ShipVO, purchaseType:uint ):void;
		function refitShip( ship:ShipVO, purchaseType:uint ):void;
		function cancelTransaction( transaction:TransactionVO ):void;
		function recycleShip( shipVO:ShipVO ):void
		function getAssetVO( prototype:IPrototype ):AssetVO;
		function isResearched( tech:String ):Boolean;
		function addTransactionListener( listener:Function ):void;
		function removeTransactionListener( listener:Function ):void;
		function canBuild( ship:IPrototype ):RequirementVO;
		function isShipyardRepairing():Boolean;
		function getPrototypeByName( proto:String ):IPrototype;
		function get currentShip():ShipVO;
		function set currentShip( v:ShipVO ):void;
		function get refittingShip():ShipVO;
		function get savedShip():ShipVO;
		function set savedShip( v:ShipVO ):void;
		function get shipPrototypes():Vector.<IPrototype>;
		function get shipyardTransaction():TransactionVO;
		function get builtShipCount():Number;
		function get maxAvailableShipSlots():Number;
		function get canBuildNewShips():Boolean;
		function getStatPrototypeByName( name:String ):IPrototype;
	}
}


