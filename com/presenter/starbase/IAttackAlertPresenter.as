package com.presenter.starbase
{
	import com.presenter.IImperiumPresenter;

	public interface IAttackAlertPresenter extends IImperiumPresenter
	{
		function joinBattle( battleServerAddress:String, fleetID:String = null ):void;
		function removeAllAlerts( viewClass:Class ):void
		function hasBattleEnded( battleServerAddress:String, fleetID:String = null ):Boolean;
		function addFleetUpdateListener( listener:Function ):void;
		function removeFleetUpdateListener( listener:Function ):void;
	}
}
