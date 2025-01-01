package com.ui.core.component.button
{
	import com.enum.ui.ButtonEnum;
	import com.ui.core.ScaleBitmap;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import org.osflash.signals.Signal;

	public class BitmapButton extends ButtonBase
	{
		protected var _bitmap:ScaleBitmap = new ScaleBitmap();
		private var _upSkin:BitmapData;
		private var _overSkin:BitmapData;
		private var _downSkin:BitmapData;
		private var _disabledSkin:BitmapData;
		private var _selectSkin:BitmapData;

		public var onStateChange:Signal;

		public function init( upSkin:BitmapData, overSkin:BitmapData = null, downSkin:BitmapData = null, disabledSkin:BitmapData = null, selectSkin:BitmapData = null ):void
		{
			_upSkin = upSkin;
			_overSkin = overSkin;
			_downSkin = downSkin;
			_disabledSkin = disabledSkin;
			_selectSkin = selectSkin;

			addChild(_bitmap);

			_state = ButtonEnum.STATE_NORMAL;
			_selectable = _selected = false;
			horzTxtMargin = vertTxtMargin = DEFAULT_MARGIN;
			addListeners();
			enabled = true;

			onStateChange = new Signal(BitmapButton);
		}

		public function updateBackgrounds( upSkin:BitmapData, overSkin:BitmapData = null, downSkin:BitmapData = null, disabledSkin:BitmapData = null, selectSkin:BitmapData = null ):void
		{
			if (upSkin)
				_upSkin = upSkin;

			if (overSkin)
				_overSkin = overSkin;

			if (downSkin)
				_downSkin = downSkin;

			if (disabledSkin)
				_disabledSkin = disabledSkin;

			if (selectSkin)
				_selectSkin = selectSkin;

			showState();
		}

		override protected function showState():void
		{
			super.showState();
			switch (_state)
			{
				case ButtonEnum.STATE_NORMAL:
					if (_upSkin)
						_bitmap.bitmapData = _upSkin;
					else
						_bitmap.bitmapData = null;
					if (_labelFormat && _label)
					{
						_label.bold = _labelFormat.upBold;
						_label.textColor = _labelFormat.upColor;
						_label.text = _label.text;
					}
					break;
				case ButtonEnum.STATE_OVER:
					if (_overSkin)
						_bitmap.bitmapData = _overSkin;
					if (_labelFormat && _label)
					{
						_label.bold = _labelFormat.roBold;
						_label.textColor = _labelFormat.roColor;
						_label.text = _label.text;
					}
					break;
				case ButtonEnum.STATE_DOWN:
					if (_downSkin)
						_bitmap.bitmapData = _downSkin;
					if (_labelFormat && _label)
					{
						_label.bold = _labelFormat.downBold;
						_label.textColor = _labelFormat.downColor;
						_label.text = _label.text;
					}
					break;
				case ButtonEnum.STATE_SELECTED:
					if (_selectSkin)
						_bitmap.bitmapData = _selectSkin;
					if (_labelFormat && _label)
					{
						_label.bold = _labelFormat.selectedBold;
						_label.textColor = _labelFormat.selectedColor;
						_label.text = _label.text;
					}
					break;
				case ButtonEnum.STATE_DISABLED:
					if (_disabledSkin)
						_bitmap.bitmapData = _disabledSkin;
					else
					{
						if (_upSkin)
							_bitmap.bitmapData = _upSkin;
					}
					if (_labelFormat && _label)
					{
						_label.bold = _labelFormat.disabledBold;
						_label.textColor = _labelFormat.disabledColor;
						_label.text = _label.text;
					}
					break;
			}
			_bitmap.smoothing = true;
		}

		private function stateChanged( event:Event ):void
		{
			if (onStateChange)
				onStateChange.dispatch(this);
		}

		override protected function onMouse( e:MouseEvent ):void
		{
			var oldState:String = _state;
			super.onMouse(e);
			if (_state != oldState)
			{
				stateChanged(e);
			}
		}

		override public function setSize( width:int, height:int ):void
		{
			if (width == 0 && _upSkin)
				width = _upSkin.width;
			if (height == 0 && _upSkin)
				height = _upSkin.height;
			_bitmap.setSize(width, height);
			setLabelSize(width, height);
		}

		override public function get defaultSkinHeight():Number  { return _bitmap.height; }
		override public function get defaultSkinWidth():Number  { return _bitmap.width; }

		override public function set height( value:Number ):void  { _bitmap.height = value; }
		override public function set width( value:Number ):void  { _bitmap.width = value; }

		override public function set scale9Grid( innerRectangle:Rectangle ):void  { _bitmap.scale9Grid = innerRectangle; }

		override public function destroy():void
		{
			super.destroy();
			if (_bitmap)
			{
				setSize(0, 0);
				_bitmap.bitmapData = null;
				_bitmap.visible = true;
			}
			_upSkin = null;
			_overSkin = null;
			_downSkin = null;
			_disabledSkin = null;
			_selectSkin = null;
			onStateChange.removeAll();
		}
	}
}
