package com.presenter.shared
{
	import com.event.StateEvent;
	import com.presenter.IImperiumPresenter;

	public interface ITransitionPresenter extends IImperiumPresenter
	{
		function sendEvents():void;

		function addEvents( initEvent:StateEvent, cleanupEvent:StateEvent ):void;

		function transitionComplete():void;

		function addCompleteListener( callback:Function ):void;
		function removeCompleteListener( callback:Function ):void;

		function addUpdateListener( callback:Function ):void;
		function removeUpdateListener( callback:Function ):void;
		function updateView():void;

		function get connectingText():String;

		function get estimatedLoadCompleted():Number;
		function get trackAnalytics():Boolean;

		function set failed( v:Boolean ):void;
		function get failed():Boolean;

		function get hasWaiting():Boolean;
	}
}
