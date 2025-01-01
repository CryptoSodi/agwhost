package com.presenter.shared
{
	import com.model.asset.AssetVO;
	import com.model.event.EventVO;
	import com.model.prototype.IPrototype;
	import com.presenter.IImperiumPresenter;

	public interface IEventPresenter extends IImperiumPresenter
	{
		function loadIcon( url:String, callback:Function ):void;
		function getResearchItemPrototypeByName( v:String ):IPrototype;
		function getAssetVO( prototype:IPrototype ):AssetVO;
		function getScoreValueByName( v:String ):uint;
		function requestAchievements():void;
		function requestAllScores():void;

		function addEventUpdatedListener( callback:Function ):void;
		function removeEventUpdatedListener( callback:Function ):void;

		function onAddAchievementsUpdatedListener( Listener:Function ):void;
		function onRemoveAchievementsUpdatedListener( Listener:Function ):void;
		function onAddAllScoresUpdatedListener( Listener:Function ):void;
		function onRemoveAllScoresUpdatedListener( Listener:Function ):void;

		function get currentActiveEvent():EventVO;
		function get activeEvents():Vector.<EventVO>;
		function get upcomingEvents():Vector.<EventVO>;
	}
}
