package com.service.loading
{
	import com.service.loading.loaditems.ILoadItem;

	public interface ILoadService
	{
		function cancel( loadItem:ILoadItem ):void;
		function lazyLoad( url:String, priority:int = 3, doLoad:Boolean = true, absoluteURL:Boolean = false ):ILoadItem;
		function load( loadItem:ILoadItem ):void;
		function loadBatch( type:int, urls:Array, priority:int = 3 ):ILoadItem;
		function pause():void;
		function reset():void;
		function resume():void;

		function get estimatedLoadCompleted():Number;
		function get highPrioritiesInProgress():int;
		function get highPrioritiesInWaiting():int;
		function get highPrioritiesTotal():int;
		function get itemsInWaiting():int;
	}
}
