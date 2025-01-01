package com.ui.core.component.bar
{
	import com.ui.core.component.IComponent;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;

	public class ProgressBar extends Sprite implements IComponent
	{
		public static const HORIZONTAL:int = 0;
		public static const VERTICAL:int   = 1;

		private var _amount:Number;
		private var _base:DisplayObject;
		private var _dwidth:Number;
		private var _dheight:Number;
		private var _min:Number;
		private var _max:Number;
		private var _orientation:int;
		private var _overlayHolder:Sprite;
		private var _overlay:DisplayObject;
		private var _tweenThreshold:Number;
		private var _mask:DisplayObject;
		private var _reverse:Boolean;
		private var _tweenSpeed:Number     = .5;

		protected const _logger:ILogger    = getLogger('ProgressBar');

		public function init( orientation:int, overlay:DisplayObject = null, base:DisplayObject = null, tweenThreshold:Number = 0.15, reverse:Boolean = false ):void
		{
			_overlayHolder = new Sprite();
			_amount = _dwidth = _dheight = _min = _max = 0;
			_orientation = orientation;
			_base = base;
			_overlay = overlay;
			_tweenThreshold = tweenThreshold;
			_reverse = reverse;

			if (_base)
				addChild(_base);

			if (_overlay)
			{
				_dwidth = _overlay.width;
				_dheight = _overlay.height;

				if (_orientation == VERTICAL)
				{
					_overlay.scaleY = -1;
					_overlayHolder.y = _overlay.height;
				}

				_overlayHolder.addChild(_overlay);
				addChild(_overlayHolder);

				if (_base)
				{
					_overlayHolder.x = (_base.width - _overlay.width) / 2;
					_overlayHolder.y = (_base.height - _overlay.height) / 2;
				}
			}
		}

		public function setMinMax( min:Number, max:Number ):void
		{
			_min = min;
			_max = max;
			amount = _amount;
		}

		public function createDefaultOverlay( color:uint, dalpha:Number, dwidth:Number, dheight:Number ):void
		{
			amount = _amount;
		}

		public function setBase( base:DisplayObject ):void
		{
			if (_base)
				removeChild(_base);

			_base = base;

			if (_base)
			{
				addChildAt(_base, 0);

				if (_overlayHolder)
				{
					_overlayHolder.x = (_base.width - _overlay.width) / 2;
					_overlayHolder.y = (_base.height - _overlay.height) / 2;
				}
			}
		}

		public function setOverlay( overlay:DisplayObject ):void
		{
			if (_overlay)
				_overlayHolder.removeChild(_overlay);

			_overlay = overlay;
			_dwidth = _overlay.width;
			_dheight = _overlay.height;

			if (_orientation == VERTICAL)
			{
				var holder:Sprite = new Sprite();
				_overlay.scaleY = -1;
				_overlayHolder.y = _overlay.height;
			}

			_overlayHolder.addChild(_overlay);
		}

		public function addMask( mask:DisplayObject ):void
		{
			_mask = mask;
			mask.cacheAsBitmap = true;
			_overlayHolder.mask = mask;

			if (_base)
			{
				mask.x = (_base.width - _overlay.width) / 2;
				mask.y = (_base.height - _overlay.height) / 2;
			}

			addChild(mask);
			_overlayHolder.cacheAsBitmap = true;
		}

		public function setSize( w:Number, h:Number ):void
		{
			if (_overlay)
			{
				_overlay.width = w;
				_overlay.height = h;
			}

			if (_base)
			{
				_base.width = w;
				_base.height = h;
			}
		}

		public function get amount():Number  { return _amount; }
		public function set amount( v:Number ):void
		{
			var oldAmount:Number = _amount;
			_amount = v;

			if (_amount < _min)
				_amount = _min;

			if (_amount > _max)
				_amount = _max;

			var oldScale:Number  = (oldAmount - _min) / (_max - _min);
			var newScale:Number  = (_amount - _min) / (_max - _min);
			var nwidth:Number    = (_orientation == HORIZONTAL) ? _dwidth * newScale : _dwidth;
			var nheight:Number   = (_orientation == HORIZONTAL) ? _dheight : _dheight * newScale;

			if (!_overlayHolder)
				return;

			if (Math.abs(newScale - oldScale) > _tweenThreshold)
			{
				if (_reverse)
					TweenLite.to(_overlayHolder, _tweenSpeed, {width:nwidth, height:nheight, x:(_dwidth - nwidth), y:(_dheight - nheight), ease:Quad.easeIn});
				else
					TweenLite.to(_overlayHolder, _tweenSpeed, {width:nwidth, height:nheight, ease:Quad.easeIn});
			} else
			{
				TweenLite.killTweensOf(_overlayHolder);

				_overlayHolder.width = nwidth;
				_overlayHolder.height = nheight;

				if (_reverse)
				{
					if (_orientation == HORIZONTAL)
					{
						_overlayHolder.x = _dwidth - nwidth;
					} else
					{
						_overlayHolder.y = _dheight - nheight;
					}
				}
			}
		}

		public function get base():DisplayObject  { return _base; }
		public function get overlay():DisplayObject  { return _overlay; }

		public function set overrideAmount( v:Number ):void
		{
			var threshold:Number = _tweenThreshold;
			_tweenThreshold = 100000;
			amount = v;
			_tweenThreshold = threshold;
		}

		public function get enabled():Boolean  { return visible; }
		public function set enabled( value:Boolean ):void  { visible = value; }

		public function get barWidth():Number  { return _overlayHolder.width; }

		public function set tweenSpeed( v:Number ):void  { _tweenSpeed = v; }

		public function destroy():void
		{
			filters = [];

			while (numChildren > 0)
				removeChildAt(0);

			if (_overlay && _overlay.parent)
				_overlay.parent.removeChild(_overlay);

			_overlayHolder = null;
			_base = null;
			_overlay = null;
			_tweenSpeed = .5;
			visible = true;
		}
	}
}
