package com.ui.core.component.tooltips
{
	import com.ui.core.component.label.Label;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	import org.parade.util.DeviceMetrics;

	public class Tooltip extends Sprite
	{
		//private static const MARGIN:int    = 5;
		private static const MARGIN_TOP:int = 4;
		private static const MARGIN_RIGHT:int = 5;
		private static const MARGIN_BOTTOM:int = 8;
		private static const MARGIN_LEFT:int = 5;

		private var _background:Sprite;
		private var _pointer:Sprite;
		private var _label:Label;
		private var _layer:Sprite;
		private var _width:Number;
		private var _orientationUp:Boolean = true;

		public function Tooltip()
		{
			_background = new Sprite();
			_background.mouseChildren = _background.mouseEnabled = false
			addChild(_background);

			_pointer = new Sprite();
			_pointer.graphics.lineStyle(2, 0x2c598f);
			_pointer.graphics.beginFill(0x131515);
			_pointer.graphics.moveTo(0, 0);
			_pointer.graphics.lineTo(10, 15);
			_pointer.graphics.lineTo(20, 0);
			_pointer.graphics.lineTo(0, 0);
			_pointer.graphics.lineStyle(2, 0x131515);
			_pointer.graphics.lineTo(20, 0);
			_pointer.graphics.endFill();
			_pointer.mouseChildren = _pointer.mouseEnabled = false;
			addChild(_pointer);

			_label = new Label(12, 0xffffff, 200, 20, false, 1);
			_label.constrictTextToSize = false;
			_label.autoSize = TextFieldAutoSize.LEFT;
			_label.align = TextFormatAlign.LEFT;
			_label.mouseEnabled = false;
			_background.addChild(_label);

			mouseEnabled = mouseChildren = false;
		}

		public function init( layer:Sprite, tipText:String = "", width:Number = 200, fontSize:int = 18, multiline:Boolean = false ):void
		{
			_layer = layer;
			_width = width;
			//_label.fontSize = fontSize;
			_label.multiline = multiline;
			text = tipText;
			drawBackground();
			_pointer.x = -(_pointer.width / 2);
			_pointer.y = -_pointer.height;
			adjustToOrientation();
			_layer.addChild(this);
			x = _layer.mouseX;
			y = (_orientationUp) ? _layer.mouseY - 4 : _layer.mouseY + 4;
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}

		protected function drawBackground():void
		{
			//position the elements
			var bounds:Rectangle = _background.getBounds(_background);
			var offsetX:Number   = 0;
			var offsetY:Number   = 0;
			if (bounds.left > 0)
				offsetX = MARGIN_RIGHT - bounds.left;
			else
				offsetX = bounds.left + MARGIN_LEFT;
			if (bounds.top > 0)
				offsetY = MARGIN_BOTTOM - bounds.top;
			else
				offsetY = bounds.top + MARGIN_TOP;
			for (var i:int = 0; i < _background.numChildren; i++)
			{
				var clip:* = _background.getChildAt(i);
				clip.x += offsetX;
				clip.y += offsetY;
			}

			_background.graphics.lineStyle(2, 0x2c598f);
			_background.graphics.beginFill(0x131515);
			_background.graphics.drawRoundRect(0, 0, _background.width + (MARGIN_LEFT + MARGIN_RIGHT), _background.height + (MARGIN_TOP + MARGIN_BOTTOM), 16, 16);
			_background.graphics.endFill();
			_background.x = -(_background.width / 2);
		}

		protected function adjustToOrientation():void
		{
			//position the pointer
			_orientationUp = true;
			_background.y = -(_pointer.height + _background.height) + 5;
			if (_layer.mouseY - height < 0)
			{
				_pointer.scaleY = -1;
				_pointer.y = _pointer.height;
				_background.y = _pointer.height - 5;
				_orientationUp = false;
			}
		}

		protected function onEnterFrame( e:Event = null ):void
		{
			_background.x = -(_background.width / 2);
			var bounds:Rectangle = getBounds(_layer);
			if (bounds.right > DeviceMetrics.WIDTH_PIXELS)
				_background.x -= (bounds.right - DeviceMetrics.WIDTH_PIXELS);
			else if (bounds.left < 0)
				_background.x -= bounds.left;
			x = _layer.mouseX;
			y = (_orientationUp) ? _layer.mouseY - 4 : _layer.mouseY + 4;
		}

		public function set text( tipText:String ):void
		{
			_label.width = 1000;
//			_label.constrictTextToSize = false;
//			_label.autoSize = TextFieldAutoSize.LEFT;
			//_label.text = tipText;
			_label.htmlText = tipText;
			_label.width = (_label.textWidth + 5 > _width) ? _width : _label.textWidth + 5;
//			_label.align = TextFormatAlign.LEFT;
		}

		public function destroy():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_layer.removeChild(this);

			_label.x = _label.y = 0;
			_label.text = "";
			if (!_orientationUp)
				_pointer.scaleY = 1;
			_orientationUp = true;
			_background.graphics.clear();
		}
	}
}
