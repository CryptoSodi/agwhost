package com.game.entity.systems.shared.background
{
	import com.util.rtree.RRectangle;

	public class BackgroundItem
	{
		public var id:String;
		public var bounds:RRectangle;
		public var label:String;
		public var layer:int;
		public var width:Number;
		public var height:Number;
		public var parallaxSpeed:Number;
		public var scale:Number;
		public var type:String;
		public var x:Number;
		public var y:Number;

		public function BackgroundItem( id:String, type:String, label:String, layer:int, parallaxSpeed:Number, x:Number, y:Number, width:Number, height:Number, scale:Number )
		{
			this.id = id;
			this.label = label;
			this.layer = layer;
			this.width = width * scale;
			this.height = height * scale;
			this.parallaxSpeed = parallaxSpeed;
			this.scale = scale;
			this.type = type;
			this.x = x;
			this.y = y
		}
	}
}
