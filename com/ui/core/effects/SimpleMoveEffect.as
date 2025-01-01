package com.ui.core.effects
{
	import com.Application;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.parade.core.IView;

	public class SimpleMoveEffect extends Effect
	{
		public static const NAME:String  = "simpleMoveEffect";
		public static const LEFT:String  = "left";
		public static const RIGHT:String = "right";
		public static const UP:String    = "up";
		public static const DOWN:String  = "down";

		private var _easeIn:Function;
		private var _easeOut:Function;
		private var _end:String;
		private var _height:Number       = 0;
		private var _screen:IView;
		private var _stage:Stage;
		private var _start:String;
		private var _state:int;
		private var _timeIN:Number;
		private var _timeOUT:Number;
		private var _width:Number        = 0;

		public function init( start:String, end:String, timeIN:Number, timeOUT:Number, ei:Function = null, eo:Function = null ):void
		{
			_start = start;
			_end = end;
			_timeIN = timeIN;
			_timeOUT = timeOUT;
			_easeIn = (ei == null) ? Quad.easeOut : ei;
			_easeOut = (eo == null) ? Quad.easeOut : eo;
		}

		override internal function goIn( screen:IView ):void
		{
			super.goIn(screen);
			_state = 0;
			_stage = Application.STAGE;
			_stage.removeEventListener(Event.RESIZE, resize);
			_stage.addEventListener(Event.RESIZE, resize, false, 0, true);
			_screen = screen;
			_height = (_height == 0) ? screen.height : _height;
			_width = (_width == 0) ? screen.width : _width;
			var start:Point = position(screen, _start);

			TweenLite.from(screen, _timeIN, {x:start.x, y:start.y, onComplete:doneIn, ease:_easeIn, overwrite:false});
		}

		override internal function goOut( screen:IView ):void
		{
			super.goOut(screen);
			_state = 1;
			var end:Point = position(screen, _end);
			TweenLite.to(screen, _timeOUT, {x:end.x, y:end.y, onComplete:doneOut, ease:_easeOut, overwrite:false});
		}

		private function position( screen:IView, pos:String ):Point
		{
			var rect:Rectangle = screen.bounds;
			var point:Point    = new Point(screen.x, screen.y);

			switch (pos)
			{
				case LEFT:
					point.x = 0 - Math.abs(rect.right - screen.x);
					break;
				case RIGHT:
					point.x = _stage.stageWidth + Math.abs(screen.x - rect.left)
					break;
				case UP:
					point.y = 0 - Math.abs(rect.bottom - screen.y);
					break;
				case DOWN:
					point.y = _stage.stageHeight + Math.abs(screen.y - rect.top);
					break;
			}

			return point;
		}

		protected function resize( e:Event = null ):void
		{
		/*var p:Point = (_state == 0) ? position(_screen, CENTER) : position(_screen, _end);
		   TweenLite.killTweensOf(_screen, false, {x:true, y:true});
		   TweenLite.to(_screen, (_state == 0) ? _timeIN : _timeOUT, {x:p.x, y:p.y, onComplete:(_state == 0) ? doneIN : doneOUT, ease:(_state == 0) ? _easeIn : _easeOut, overwrite:false});*/
		}

		public function set height( v:Number ):void  { _height = v; }
		public function set width( v:Number ):void  { _width = v; }

		override public function destroy():void
		{
			if (_stage)
			{
				_stage.removeEventListener(Event.RESIZE, resize);
				_stage = null;
			}
			_screen = null;
			_width = _height = 0;
			_easeIn = null;
			_easeOut = null;
		}
	}
}
