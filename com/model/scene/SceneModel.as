package com.model.scene
{
	import com.model.Model;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import org.parade.util.DeviceMetrics;

	public class SceneModel extends Model
	{
		private var _bounds:Rectangle;
		private var _focus:Point;
		private var _ready:Boolean;
		private var _viewArea:Rectangle;
		private var _zoom:Number;

		[PostConstruct]
		public function init():void
		{
			_focus = new Point();
			_ready = false;
			_viewArea = new Rectangle(0, 0, DeviceMetrics.WIDTH_PIXELS, DeviceMetrics.HEIGHT_PIXELS);
			_zoom = 1;
		}

		public function buildScene( width:Number, height:Number ):void
		{
			_bounds = new Rectangle(0, 0, width, height);
			//set the default focus to the center of the play area
			setFocus(_bounds.width / 2, _bounds.height / 2);
			_ready = true;
		}

		public function adjustFocus( dx:Number, dy:Number ):void
		{
			_focus.x += dx;
			_focus.y += dy;

			//attempt to center
			var w2:Number = DeviceMetrics.WIDTH_PIXELS * .5 / _zoom;
			var h2:Number = DeviceMetrics.HEIGHT_PIXELS * .5 / _zoom;
			_viewArea.x = _focus.x - w2;
			_viewArea.y = _focus.y - h2;
			if (_viewArea.x < 0)
			{
				_focus.x = w2;
				_viewArea.x = 0;
			}
			if (_viewArea.y < 0)
			{
				_focus.y = h2;
				_viewArea.y = 0;
			}
			if (_viewArea.right >= _bounds.width)
			{
				var ox:Number = _viewArea.right - _bounds.width + 1;
				_focus.x -= ox;
				_viewArea.x -= ox;
			}
			if (_viewArea.bottom >= _bounds.height)
			{
				var oy:Number = _viewArea.bottom - _bounds.height + 1;
				_focus.y -= oy;
				_viewArea.y -= oy;
			}
		}

		public function setFocus( dx:Number, dy:Number ):void
		{
			_focus.x = dx;
			_focus.y = dy;
			adjustFocus(0, 0);
		}

		public function changeResolution():void
		{
			_viewArea.setTo(_viewArea.x, _viewArea.y, DeviceMetrics.WIDTH_PIXELS / _zoom, DeviceMetrics.HEIGHT_PIXELS / _zoom);
			if (_ready)
				adjustFocus(0, 0);
		}

		public function get bounds():Rectangle  { return _bounds; }
		public function get focus():Point  { return _focus; }
		public function get ready():Boolean  { return _ready; }
		public function get viewArea():Rectangle  { return _viewArea; }
		public function get zoom():Number  { return _zoom; }
		public function set zoom( v:Number ):void  { _zoom = v; changeResolution(); }

		public function cleanup():void
		{
			_ready = false;
			_bounds = null;
			zoom = 1;
		}
	}
}
