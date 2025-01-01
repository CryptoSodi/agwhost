package com.ui.core.component.pips
{
	import flash.events.Event;

	public class PipEvent extends Event
	{
		public static const PIP_CLICKED:String 				= "PageChanged";
		
		public var oldIndex:int;
		public var index:int;
		
		public function PipEvent( type:String, pipIndex:int, pipOldIndex:int )
		{
			super(type, true, true);
			index = pipIndex;
			oldIndex = pipOldIndex;
		}
	}
}