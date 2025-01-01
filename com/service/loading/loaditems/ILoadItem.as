package com.service.loading.loaditems
{

	import com.util.priorityqueue.IPrioritizable;

	import flash.system.ApplicationDomain;

	public interface ILoadItem extends IPrioritizable
	{
		function cancel():void;
		function load():void;

		function addUpdateListener( callback:Function ):void;
		function removeUpdateListener( callback:Function ):void;

		function get absoluteURL():Boolean;

		function get applicationDomain():ApplicationDomain;

		function get asset():Object;
		function set asset( asset:Object ):void;

		function get filename():String;

		function get loaded():Boolean;

		function set prefix( v:String ):void;

		function get progress():Number;

		function get type():int;

		function get url():String;

		function get fullPath():String;

		function get loadStartTime():int;

		function get totalBytes():int;
		function get totalBytesLoaded():int;
		function get totalBytesLoadedLastFrame():int;

		function get tracked():Boolean;
		function set tracked( v:Boolean ):void;
	}
}
