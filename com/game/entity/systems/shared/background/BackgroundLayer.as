package com.game.entity.systems.shared.background
{
	import com.util.rtree.RRectangle;
	import com.util.rtree.RTree;

	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import org.parade.util.DeviceMetrics;

	public class BackgroundLayer
	{
		private var _bounds:Rectangle;
		private var _id:int;
		private var _layer:int;
		private var _lookup:Dictionary;
		private var _parallaxSpeed:Number;
		private var _rect:RRectangle;
		private var _scale:Number;
		private var _tree:RTree;

		public function init( layer:int, parallaxSpeed:Number, scale:Number, width:Number, height:Number, lookup:Dictionary ):void
		{
			_id = 10000 * layer;
			_layer = layer;
			_lookup = lookup;
			_parallaxSpeed = parallaxSpeed;
			_rect = new RRectangle(0, 0, 0, 0);
			_scale = scale;
			_tree = new RTree();
			_bounds = new Rectangle(0, 0, DeviceMetrics.MAX_WIDTH_PIXELS + width * _parallaxSpeed, DeviceMetrics.MAX_HEIGHT_PIXELS + height * _parallaxSpeed);
		}

		public function addItemFromData( type:String, name:String, width:Number, height:Number, scale:Number = 1, tile:Boolean = false, x:Number = 0, y:Number = 0, addToTree:Boolean = true ):BackgroundItem
		{
			var item:BackgroundItem;
			var rect:RRectangle = new RRectangle(0, 0, 0, 0);

			if (!tile)
			{
				item = new BackgroundItem(id, type, name, _layer, _parallaxSpeed, x, y, width, height, _scale * scale);
				rect = new RRectangle(item.x, item.y, item.x + item.width, item.y + item.height);
				item.bounds = rect;
				if (addToTree)
					_tree.addRRectangle(rect, item.id);
				_lookup[item.id] = item;
			} else
			{
				scale = _scale * scale;
				var dwidth:Number  = 0;
				var dheight:Number = 0;
				while (dheight <= _bounds.height)
				{
					while (dwidth <= _bounds.width)
					{
						item = new BackgroundItem(id, type, name, _layer, _parallaxSpeed, dwidth, dheight, width, height, scale);
						rect = new RRectangle(dwidth, dheight, dwidth + item.width, dheight + item.height);
						item.bounds = rect;
						if (addToTree)
							_tree.addRRectangle(rect, item.id);
						_lookup[item.id] = item;
						dwidth += item.width;
					}
					dwidth = 0;
					dheight += item.height;
				}
			}
			return item;
		}

		public function addItem( item:BackgroundItem ):void
		{
			_tree.addRRectangle(item.bounds, item.id);
		}

		public function getItemsByRect( viewArea:Rectangle ):Array
		{
			_rect.setValues(viewArea.x * _parallaxSpeed, viewArea.y * _parallaxSpeed, viewArea.x * _parallaxSpeed + viewArea.width, viewArea.y * _parallaxSpeed + viewArea.height);
			return _tree.contains(_rect);
		}

		public function get bounds():Rectangle  { return _bounds; }
		public function get parallaxSpeed():Number  { return _parallaxSpeed; }

		private function get id():String  { _id++; return "bg" + _id; }

		public function destroy():void
		{
			_bounds = null;
			_lookup = null;
			_rect = null;
			_tree = null;
		}
	}
}
