package com.game.entity.components.battle
{
	import flash.geom.Point;

	import org.ash.core.Entity;

	public class TrailFX
	{
		// Configuration members
		public var alphaChange:Number;
		public var color:uint;
		public var maxSegments:int;
		public var type:String;
		public var thickness:Number;

		// Runtime data tracking
		public var currentSegment:Entity;
		public var segments:Vector.<Entity>;

		public var lastPosition:Point = new Point();

		public function TrailFX()
		{
			segments = new Vector.<Entity>();
		}

		public function destroy():void
		{
			currentSegment = null;
			lastPosition.setTo(0, 0);
			segments.length = 0;
		}
	}
}


