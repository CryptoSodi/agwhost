package com.ui.core.effects
{
	import com.Application;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.greensock.TweenLite;
	import org.parade.core.IView;

	public class SimpleBackingEffect extends Effect
	{
		public static const NAME:String = "simpleBackingEffect";

		private static var BACKING:Bitmap;
		private static var INTERACTIVE_OBJECT:Sprite;
		private static var APPLY_TO:Array;
		private static var CLICK_CALLBACKS:Array;

		private var _alpha:Number;
		private var _timeIN:Number;
		private var _timeOUT:Number;
		private var _stage:Stage;

		public function init( a:Number, timeIN:Number, timeOUT:Number, clickCallback:Function = null ):void
		{
			_name = NAME;
			if (!BACKING)
			{
				BACKING = new Bitmap(new BitmapData(5, 5, false, 0));
				INTERACTIVE_OBJECT = new Sprite();
				INTERACTIVE_OBJECT.addChild(BACKING);
				BACKING.alpha = 0;
				APPLY_TO = [];
				CLICK_CALLBACKS = [];
			}

			INTERACTIVE_OBJECT.addEventListener(MouseEvent.CLICK, onMouseEvent, false, 0, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent, false, 1, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent, false, 1, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseEvent, false, 1, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent, false, 1, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.ROLL_OUT, onMouseEvent, false, 0, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.ROLL_OVER, onMouseEvent, false, 0, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.RIGHT_CLICK, onMouseEvent, false, 1, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseEvent, false, 1, true);
			INTERACTIVE_OBJECT.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseEvent, false, 1, true);

			_alpha = a;
			CLICK_CALLBACKS.push(clickCallback);
			_timeIN = timeIN;
			_timeOUT = timeOUT;
		}

		override internal function goIn( screen:IView ):void
		{
			super.goIn(screen);
			_stage = Application.STAGE
			_stage.removeEventListener(Event.RESIZE, resize);
			_stage.addEventListener(Event.RESIZE, resize, false, 0, true);
			resize();
			APPLY_TO.push(screen);

			var s:* = screen;
			s.parent.addChild(INTERACTIVE_OBJECT);
			s.parent.swapChildren(INTERACTIVE_OBJECT, screen);

			if (BACKING.alpha < _alpha || BACKING.alpha > _alpha)
				TweenLite.to(BACKING, _timeIN, {alpha:_alpha, onComplete:doneIn});
			else
				doneIn();
		}

		override internal function goOut( screen:IView ):void
		{
			super.goOut(screen);
			var index:int = APPLY_TO.indexOf(screen);
			if (index > -1)
				APPLY_TO.splice(index, 1);
			if (CLICK_CALLBACKS.length > 0)
				CLICK_CALLBACKS.pop();
			if (APPLY_TO.length > 0)
			{
				screen = APPLY_TO[APPLY_TO.length - 1];
				var s:* = screen;
				s.parent.addChild(INTERACTIVE_OBJECT);
				s.parent.swapChildren(INTERACTIVE_OBJECT, screen);
				doneOut();
			} else
			{
				_stage.removeEventListener(Event.RESIZE, resize);
				TweenLite.to(BACKING, _timeOUT, {alpha:0, onComplete:doneOut});
			}
		}

		private function onMouseEvent( e:MouseEvent ):void
		{
			e.stopImmediatePropagation();
			if (e.type == MouseEvent.CLICK && CLICK_CALLBACKS.length > 0 && CLICK_CALLBACKS[CLICK_CALLBACKS.length - 1] != null)
				CLICK_CALLBACKS[CLICK_CALLBACKS.length - 1]();
		}

		protected function resize( e:Event = null ):void
		{
			BACKING.width = _stage.stageWidth;
			BACKING.height = _stage.stageHeight;
		}

		override public function destroy():void
		{
			if (APPLY_TO.length == 0)
			{
				if (_stage)
				{
					_stage.removeEventListener(Event.RESIZE, resize);
					_stage = null;
				}
				if (INTERACTIVE_OBJECT.parent)
				{
					INTERACTIVE_OBJECT.removeEventListener(MouseEvent.CLICK, onMouseEvent);
					INTERACTIVE_OBJECT.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
					INTERACTIVE_OBJECT.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
					INTERACTIVE_OBJECT.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseEvent);
					INTERACTIVE_OBJECT.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent);
					INTERACTIVE_OBJECT.removeEventListener(MouseEvent.RIGHT_CLICK, onMouseEvent);
					INTERACTIVE_OBJECT.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseEvent);
					INTERACTIVE_OBJECT.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseEvent);
					INTERACTIVE_OBJECT.parent.removeChild(INTERACTIVE_OBJECT);
				}
				TweenLite.killTweensOf(BACKING);
			}
		}
	}

}
