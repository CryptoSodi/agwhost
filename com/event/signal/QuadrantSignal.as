package com.event.signal
{
	import com.util.rtree.RRectangle;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import org.osflash.signals.Signal;

	public class QuadrantSignal extends Signal
	{
		public static const VISIBLE_HASH_CHANGED:int = 0;

		public function QuadrantSignal()
		{
			super(int, Rectangle);
		}

		public function visibleHashChanged( viewBounds:Rectangle ):void
		{
			dispatch(VISIBLE_HASH_CHANGED, viewBounds);
		}
	}
}
