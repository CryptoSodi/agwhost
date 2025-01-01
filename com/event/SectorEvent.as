package com.event
{
	import flash.events.Event;

	public class SectorEvent extends Event
	{
		public static const CHANGE_SECTOR:String = "ChangeSector";

		public var sector:String;
		public var focusFleetID:String;
		public var focusX:int;
		public var focusY:int;

		public function SectorEvent( type:String, sector:String = null, focusFleetID:String = null, focusX:int = 0, focusY:int = 0 )
		{
			super(type, false, false);
			this.sector = sector;
			this.focusFleetID = focusFleetID;
			this.focusX = focusX;
			this.focusY = focusY;
		}
	}
}


