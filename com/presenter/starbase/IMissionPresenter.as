package com.presenter.starbase
{
	import com.model.mission.MissionInfoVO;
	import com.model.mission.MissionVO;
	import com.presenter.IImperiumPresenter;

	public interface IMissionPresenter extends IImperiumPresenter
	{
		function getMissionInfo( type:String, chapterID:int = -1, missionID:int = -1, forCaptainsLog:Boolean = false ):MissionInfoVO;
		function acceptMission():void;
		function showReward():void;
		function showSector():void;
		function acceptMissionReward():void;
		function dispatchMissionEvent( type:String ):void;
		function loadIcon( url:String, callback:Function ):void;
		function fteNextStep():void;
		function fteSkip():void;
		function startInstancedMission(id:String):void;
		function isInstancedMissionOn():Boolean;
		function moveToMissionTarget():String;
		function getStoryMission( chapter:int, mission:int ):MissionVO;
		function unpauseBattle():void;
		function addTransactionListener( callback:Function ):void;
		function removeTransactionListener( callback:Function ):void;
		function requestAllScores():void;
		function onAddAllScoresUpdatedListener( Listener:Function ):void;
		function onRemoveAllScoresUpdatedListener( Listener:Function ):void;

		function get currentMission():MissionVO;
		function get fteStep():int;
	}
}


