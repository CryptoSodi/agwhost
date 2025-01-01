package com.event
{
	import flash.events.Event;

	public class RequestLoadEvent extends Event
	{
		public static const REQUEST:String = "requestLoad";

		public var absoluteURL:Boolean     = false;
		public var url:String;
		public var urls:Array;
		public var batchType:int;
		public var priority:int;

		public function RequestLoadEvent( url:String = null, priority:int = 3, absolute:Boolean = false )
		{
			super(REQUEST, false, false);
			absoluteURL = absolute;
			this.url = url;
			this.priority = priority;
		}

		public function batchLoad( batchType:int, urls:Array ):void
		{
			this.urls = urls;
			this.batchType = batchType;
		}
	}
}
