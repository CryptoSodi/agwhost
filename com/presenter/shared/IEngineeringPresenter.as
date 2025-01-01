package com.presenter.shared
{
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.ResearchVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.IImperiumPresenter;
	
	import flash.utils.Dictionary;

	public interface IEngineeringPresenter extends IImperiumPresenter
	{
		function getAssetVO( name:String ):AssetVO;
		function getBaseRepairTransaction():TransactionVO;
		function getBuildingCount( buildingClass:String ):int;
		function getBuildingByID( id:String ):BuildingVO;
		function getBuildingPrototypeByClassAndLevel( itemClass:String, level:int ):IPrototype;
		function getResearchByID( id:String ):ResearchVO;
		function getStarbaseBuildingTransaction( constructionCategory:String ):TransactionVO;
		function getStarbaseResearchTransaction( buildingType:String ):TransactionVO;
		function loadIcon( url:String, callback:Function ):void;
		function getShipVOByID( id:String ):ShipVO;
		function getRepairFleetByID( id:String ):FleetVO;
		function loadTransactionIcon( transaction:TransactionVO, callback:Function ):void;

		function addTransactionListener( type:int, callback:Function ):void;
		function removeTransactionListener( callback:Function ):void;

		function get transactions():Dictionary;
	}
}
