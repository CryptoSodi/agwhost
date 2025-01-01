package com.ui.core
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.events.MouseEvent;
	import flash.events.Event;

	public class DefaultWindowBG extends Sprite
	{
		private var _bg:ScaleBitmap;
		private var _closeButton:BitmapButton;
		private var _headerClose:ScaleBitmap;
		private var _headerSide:ScaleBitmap;
		private var _headerTop:ScaleBitmap;
		private var _label:Label;

		public function DefaultWindowBG()
		{
			_bg = UIFactory.getScaleBitmap(PanelEnum.WINDOW);
			_closeButton = UIFactory.getButton(ButtonEnum.CLOSE);
			_headerClose = UIFactory.getScaleBitmap(PanelEnum.WINDOW_X_HEADER);
			_headerSide = UIFactory.getScaleBitmap(PanelEnum.WINDOW_SIDE_HEADER);
			_headerTop = UIFactory.getScaleBitmap(PanelEnum.WINDOW_HEADER);

			addChild(_bg);
			addChild(_headerSide);
			addChild(_headerTop);
			addChild(_headerClose);
			addChild(_closeButton);

			layout();
		}
		
		public function getBkgdScale9Grid():Rectangle
		{
			return _bg ? _bg.scale9Grid : null;
		}

		public function addTitle( text:String, width:Number ):void
		{
			_headerTop.setSize(0, 0);
			_headerTop.setSize(width + _headerTop.src.width, 0);
			if (_label)
			{
				removeChild(_label);
				_label = UIFactory.destroyLabel(_label);
			}
			_label = UIFactory.getLabel(LabelEnum.H1, _headerTop.width - 196, 40, 25, 2);
			_label.align = TextFormatAlign.LEFT;
			_label.constrictTextToSize = true;
			_label.text = text;
			addChild(_label);
			layout();
		}

		public function setBGSize( width:Number, height:Number ):void
		{
			_bg.setSize(0, 0);
			_bg.setSize(width, height);
			layout();
		}

		public function setSideSize( width:Number, height:Number ):void
		{
			_headerSide.setSize(0, 0);
			_headerSide.setSize(width, height);
			layout();
		}

		private function layout():void
		{
			_bg.x = 11;
			_bg.y = _headerTop.height;

			_headerSide.x = 0;
			_headerSide.y = _headerTop.height;

			_headerTop.x = 0;
			_headerTop.y = 0;

			_headerClose.x = _bg.width - 113 + _bg.x;
			_headerClose.y = 20;

			_closeButton.x = _headerClose.x + 60;
			_closeButton.y = _headerClose.y + 1;
			
			if(CONFIG::IS_MOBILE){
				_closeButton.scaleX = _closeButton.scaleY = 4;
				_closeButton.y -= 64;
			}
		}

		public function get bg():ScaleBitmap  { return _bg; }
		public function get closeButton():BitmapButton  { return _closeButton; }
		public function set titleFontSize( v:int ):void  { _label.fontSize = v; }

		public function destroy():void
		{			
			x = y = 0;
			if (_label)
			{
				removeChild(_label);
				_label = UIFactory.destroyLabel(_label);
			}
		}
	}
}
