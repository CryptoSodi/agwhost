package com.ui.core.component.bar
{
	import com.Application;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.PanelEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.core.ScaleBitmap;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.osflash.signals.Signal;

	public class Slider extends Sprite
	{
		public var onSliderUpdate:Signal;

		private var _selector:BitmapButton;
		private var _bg:ScaleBitmap;
		private var _bar:Bitmap;
		private var _currentText:Label;
		private var _minText:Label;
		private var _maxText:Label;

		private var _minValue:Number;
		private var _maxValue:Number;
		private var _tick:Number;
		private var _currentValue:Number;
		private var _percent:Number;

		private var _width:Number;
		private var _yOffset:Number;

		public function Slider()
		{
			super();

			onSliderUpdate = new Signal(Number, Number);

			_bg = UIFactory.getScaleBitmap(PanelEnum.INPUT_BOX_BLUE);

			_bar = UIFactory.getBitmap(PanelEnum.SCROLL_BAR);

			_selector = UIFactory.getButton(ButtonEnum.SLIDER);
			_selector.useHandCursor = true;

			_currentText = new Label(14, 0xffffff, 100, 20, false, 1);
			_currentText.align = TextFormatAlign.CENTER;

			_minText = new Label(16, 0xffffff, 100, 20, false, 1);
			_minText.align = TextFormatAlign.LEFT;

			_maxText = new Label(16, 0xffffff, 100, 20, false, 1);
			_maxText.align = TextFormatAlign.RIGHT;

			addChild(_bg);
			addChild(_bar);
			addChild(_selector);
			addChild(_currentText);
			addChild(_minText);
			addChild(_maxText);
		}

		public function init( width:Number, height:Number, min:Number, max:Number, parent:DisplayObject ):void
		{
			_minValue = min;
			_maxValue = max;
			_tick = _maxValue / 10;

			_bg.width = width;
			_bg.height = height;

			_width = _bg.width - _selector.width * 0.5;

			_selector.addEventListener(MouseEvent.MOUSE_DOWN, onSelectorDown, false, 0, true);
			_selector.addEventListener(MouseEvent.MOUSE_UP, onSelectorUp, false, 0, true);

			if (parent)
			{
				parent.addEventListener(MouseEvent.MOUSE_UP, onSelectorUp, false, 0, true);
				parent.addEventListener(MouseEvent.ROLL_OUT, onSelectorUp, false, 0, true);
			}

			layout();

			_minText.text = String(min);
			_maxText.text = String(max);
		}

		private function layout():void
		{
			_bar.height = _bg.height - 6;

			_selector.x = _bg.x
			_selector.y = _bg.y - 3;

			_bar.x = _bg.x + 4;
			_bar.y = _bg.y + 3;

			_currentText.x = _bg.x + (_bg.width - _currentText.width) * 0.5;

			_maxText.x = _bg.x + _bg.width - _maxText.width;

			_minText.y = _maxText.y = _currentText.y = _bg.y + _bg.height + 5;
		}

		public function set enabled( enabled:Boolean ):void
		{
			if (enabled)
			{
				_selector.visible = true;
				_selector.addEventListener(MouseEvent.MOUSE_DOWN, onSelectorDown, false, 0, true);
				_selector.addEventListener(MouseEvent.MOUSE_UP, onSelectorUp, false, 0, true);

			} else
			{
				_selector.visible = false;
				_selector.removeEventListener(MouseEvent.MOUSE_DOWN, onSelectorDown);
				_selector.removeEventListener(MouseEvent.MOUSE_UP, onSelectorUp);
			}
		}

		public function set currentValue( currentValue:Number ):void
		{
			_currentValue = clamp(currentValue);
			updateSelector();
		}

		public function get currentValue():Number
		{
			return _currentValue;
		}

		private function updateSelector():void
		{
			_percent = ((_currentValue - _minValue) / (_maxValue - _minValue));
			_selector.x = _percent * _width;
			_bar.width = _selector.x - _bar.x + _selector.width * 0.5;

			_currentText.text = String(_currentValue);
		}

		private function onSelectorDown( e:MouseEvent ):void
		{
			_yOffset = mouseX - _selector.x;
			_selector.addEventListener(MouseEvent.MOUSE_MOVE, onSelectorMove, false, 0, true);

			if (parent)
			{
				parent.addEventListener(MouseEvent.MOUSE_UP, onSelectorUp, false, 0, true);
				parent.addEventListener(MouseEvent.ROLL_OUT, onSelectorUp, false, 0, true);
				parent.addEventListener(MouseEvent.MOUSE_MOVE, onSelectorMove, false, 0, true);
			}
		}

		private function onSelectorMove( e:MouseEvent ):void
		{
			var x:int        = mouseX - _yOffset;
			_selector.x = x;

			if (_selector.x > _width)
				_selector.x = _width;

			if (_selector.x < _bg.x)
				_selector.x = _bg.x;

			var range:Number = _maxValue - _minValue;
			_percent = Math.floor(_selector.x / _width * 100);
			_currentValue = range * _percent / 100 + _minValue;

			_bar.width = _selector.x - _bar.x + _selector.width * 0.5;

			onSliderUpdate.dispatch(_currentValue, _percent);
			_currentText.text = String(_currentValue);
		}

		private function onSelectorUp( e:MouseEvent ):void
		{
			_yOffset = mouseX - _selector.x;
			_selector.removeEventListener(MouseEvent.MOUSE_MOVE, onSelectorMove);

			if (parent)
			{
				parent.removeEventListener(MouseEvent.MOUSE_UP, onSelectorUp);
				parent.removeEventListener(MouseEvent.ROLL_OUT, onSelectorUp);
				parent.removeEventListener(MouseEvent.MOUSE_MOVE, onSelectorMove);
			}
		}

		public function destroy():void
		{

			_selector.removeEventListener(MouseEvent.MOUSE_DOWN, onSelectorDown);
			_selector.removeEventListener(MouseEvent.MOUSE_UP, onSelectorUp);
			_currentText.destroy();
		}


		private function clamp( val:Number ):Number
		{
			return Math.max(_minValue, Math.min(_maxValue, val))
		}

	}
}
