package com.ui.core.effects
{
	import com.Application;
	import com.enum.ui.PanelEnum;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.greensock.TweenLite;
	import org.parade.core.IView;

	public class StageLetterboxEffect extends Effect
	{
		public static const NAME:String = "stageLetterboxEffect";

		private var LETTERBOX:Bitmap;
		private var INTERACTIVE_OBJECT:Sprite;

		private var _clickCallback:Function;
		private var _isTop:Boolean;
		private var _screen:IView;
		private var _stage:Stage;
		private var _timeIn:Number;
		private var _timeOut:Number;
		private var _titleBar:ScaleBitmap;

		public function init( timeIn:Number, timeOut:Number, isTop:Boolean, boxHeight:int = 130, clickCallback:Function = null ):void
		{
			_clickCallback = clickCallback;
			_name = NAME;
			_timeIn = timeIn;
			_timeOut = timeOut;

			LETTERBOX = new Bitmap(new BitmapData(5, 5, false, 0));
			LETTERBOX.height = boxHeight;

			INTERACTIVE_OBJECT = new Sprite();
			INTERACTIVE_OBJECT.addChild(LETTERBOX);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.CLICK, onMouseEvent, false, 0, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent, false, 1, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent, false, 1, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseEvent, false, 1, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.RIGHT_CLICK, onMouseEvent, false, 0, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseEvent, false, 0, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseEvent, false, 0, true);

			if (!isTop)
			{
				_titleBar = UIFactory.getScaleBitmap(PanelEnum.HEADER);
				INTERACTIVE_OBJECT.addChild(_titleBar);
			}
			_isTop = isTop;
		}

		override internal function goIn( screen:IView ):void
		{
			_stage = Application.STAGE
			_stage.removeEventListener(Event.RESIZE, resize);
			_stage.addEventListener(Event.RESIZE, resize, false, 0, true);

			_screen = screen;
			View(_screen).parent.addChild(INTERACTIVE_OBJECT);
			View(_screen).parent.swapChildren(INTERACTIVE_OBJECT, View(_screen));
			resize();

			if (_timeIn > 0)
			{
				INTERACTIVE_OBJECT.alpha = 0;
				TweenLite.to(INTERACTIVE_OBJECT, _timeIn, {alpha:1});
			}

			doneIn();
		}

		override internal function goOut( screen:IView ):void
		{
			doneOut();

			if (_timeOut > 0)
				TweenLite.to(INTERACTIVE_OBJECT, _timeOut, {alpha:0});
		}

		protected function resize( e:Event = null ):void
		{
			LETTERBOX.width = _stage.stageWidth;
			INTERACTIVE_OBJECT.scaleY = _screen.scaleX;

			if (!_isTop)
			{
				_titleBar.width = LETTERBOX.width;
				_titleBar.height = 30;
				_titleBar.x = _titleBar.y = 0;
				INTERACTIVE_OBJECT.y = _stage.stageHeight - LETTERBOX.height * _screen.scaleX;
			}
		}

		private function onMouseEvent( e:MouseEvent ):void
		{
			e.stopImmediatePropagation();
			if (e.type == MouseEvent.CLICK && _clickCallback != null)
				_clickCallback();
		}

		override public function destroy():void
		{
			_clickCallback = null;
			if (_stage)
			{
				_stage.removeEventListener(Event.RESIZE, resize);
				_stage = null;
			}

			INTERACTIVE_OBJECT.removeEventListener(MouseEvent.CLICK, onMouseEvent);
			INTERACTIVE_OBJECT.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
			INTERACTIVE_OBJECT.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			INTERACTIVE_OBJECT.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseEvent);
			INTERACTIVE_OBJECT.removeEventListener(MouseEvent.RIGHT_CLICK, onMouseEvent);
			INTERACTIVE_OBJECT.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseEvent);
			INTERACTIVE_OBJECT.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseEvent);

			TweenLite.killTweensOf(INTERACTIVE_OBJECT);

			if (INTERACTIVE_OBJECT.parent)
				INTERACTIVE_OBJECT.parent.removeChild(INTERACTIVE_OBJECT);

			while (INTERACTIVE_OBJECT.numChildren > 0)
				INTERACTIVE_OBJECT.removeChildAt(0);
			INTERACTIVE_OBJECT = null;

			if (_titleBar)
				_titleBar = UIFactory.destroyPanel(_titleBar);
			_screen = null;
		}
	}
}
