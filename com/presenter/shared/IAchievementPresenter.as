package com.presenter.shared
{
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.presenter.IImperiumPresenter;

	public interface IAchievementPresenter extends IImperiumPresenter
	{
		function getAchievementPrototypes():Vector.<IPrototype>;
		function getFilterAchievementPrototypes():Vector.<IPrototype>;
		function loadIcon( url:String, callback:Function ):void;
		function getAssetVOFromIPrototype( prototype:IPrototype ):AssetVO;
		function requestAchievements():void;
		function requestAllScores():void;
		function claimAchievementReward( achievement:String ):void;
		function maxCredits():int;
		function getScoreValueByName( v:String ):uint
		function onAddAchievementsUpdatedListener( Listener:Function ):void;
		function onRemoveAchievementsUpdatedListener( Listener:Function ):void;
		function onAddAllScoresUpdatedListener( Listener:Function ):void;
		function onRemoveAllScoresUpdatedListener( Listener:Function ):void;

	}
}
