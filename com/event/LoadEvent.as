package com.event
{

	import com.service.loading.loaditems.ILoadItem;

	import flash.events.Event;

	public final class LoadEvent extends Event
	{

		////////////////////////////////////////////////////////////
		//   CONSTANTS 
		////////////////////////////////////////////////////////////

		public static const LOCALIZATION_COMPLETE:String = "LocalizationComplete";

		public static const COMPLETE:String              = "complete";

		public var loadItem:ILoadItem;

		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		public function LoadEvent( loadItem:ILoadItem )
		{
			super(COMPLETE);
			this.loadItem = loadItem;
		}

		////////////////////////////////////////////////////////////
		//   PUBLIC API 
		////////////////////////////////////////////////////////////

		public override function clone():Event
		{
			return new LoadEvent(loadItem);
		}
	}
}
