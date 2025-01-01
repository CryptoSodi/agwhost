package com.event.signal
{
	import org.osflash.signals.Signal;

	public class InteractSignal extends Signal
	{
		public static const CLICK:String             = "click";
		public static const RESOLUTION_CHANGE:String = "resolutionChange";
		public static const SCROLL:String            = "scroll";
		public static const ZOOM:String              = "zoom";

		public function InteractSignal()
		{
			super(String, Number, Number);
		}

		public function click( dx:Number, dy:Number ):void
		{
			dispatch(CLICK, dx, dy);
		}

		public function resolutionChange():void
		{
			dispatch(RESOLUTION_CHANGE, 0, 0);
		}

		public function scroll( dx:Number, dy:Number ):void
		{
			dispatch(SCROLL, dx, dy);
		}

		public function zoom( scale:Number ):void
		{
			dispatch(ZOOM, scale, 0);
		}
	}
}
