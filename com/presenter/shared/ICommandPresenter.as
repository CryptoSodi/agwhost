package com.presenter.shared
{
	import com.model.fleet.FleetVO;
	import com.model.starbase.BaseVO;
	import com.model.starbase.BuildingVO;
	import com.presenter.IImperiumPresenter;

	import org.ash.core.Entity;

	public interface ICommandPresenter extends IImperiumPresenter
	{
		function selectFleet( fleetID:String, gotoLocation:Boolean = true, canEnterBattle:Boolean = true ):Boolean;
		function jumpToLocation( x:Number, y:Number ):void;
		function getEntity( fleetID:String ):Entity;
		function getFleetVO( id:String ):FleetVO;
		function loadIconImageFromEntityData( type:String, callback:Function ):void;
		function loadSmallImageFromEntityData( type:String, callback:Function ):void;
		function loadIcon( url:String, callback:Function ):void;

		function getBuildingVOByClass( itemClass:String, highestLevel:Boolean = false ):BuildingVO;

		function addListenerForFleetUpdate( listener:Function ):void;
		function removeListenerForFleetUpdate( listener:Function ):void;

		function addSelectionChangeListener( listener:Function ):void;
		function removeSelectionChangeListener( listener:Function ):void;

		function get sectorID():String;
		function get focusFleetID():String;
		function get fleets():Vector.<FleetVO>;
		function get currentBase():BaseVO;
	}
}
