package com.ui.core.effects
{
	import com.Application;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import org.as3commons.logging.level.ERROR;
	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.parade.core.IView;

	public class GenericMoveEffect extends Effect
	{
		public static const NAME:String   = "genericMoveEffect";
		public static const LEFT:String   = "left";
		public static const RIGHT:String  = "right";
		public static const UP:String     = "up";
		public static const DOWN:String   = "down";
		public static const CENTER:String = "center";

		private var _easeIn:Function;
		private var _easeOut:Function;
		private var _end:String;
		private var _height:Number        = 0;
		private var _screen:IView;
		private var _stage:Stage;
		private var _start:String;
		private var _state:int;
		private var _timeIN:Number;
		private var _timeOUT:Number;
		private var _width:Number         = 0;

		public function init( start:String, end:String, timeIN:Number, timeOUT:Number, ei:Function = null, eo:Function = null ):void
		{
			_name = NAME;
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
			_height = (_height == 0) ? screen.height * screen.scaleY : _height;
			_width = (_width == 0) ? screen.width * screen.scaleX : _width;
			var start:Point = position(screen, _start);
			var end:Point   = position(screen, CENTER);
			screen.x = start.x;
			screen.y = start.y;

			TweenLite.to(screen, _timeIN, {x:end.x, y:end.y, onComplete:doneIn, ease:_easeIn, overwrite:false});
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
			try
			{
				_height = (screen) ? screen.height * screen.scaleY : _height;
				_width = (screen) ? screen.width * screen.scaleX : _width;
			} catch ( e:Error )
			{
				_height = _height;
				_width = _width;
			}
			var rect:Rectangle = screen.bounds;
			var point:Point    = new Point(_stage.stageWidth / 2, _stage.stageHeight / 2);
			var center:Point   = new Point(rect.left + (_width / 2), rect.top + (_height / 2));
			var xDiff:Number   = center.x - screen.x;
			var yDiff:Number   = center.y - screen.y;

			switch (pos)
			{
				case LEFT:
					point.x = 0 - Math.abs(rect.right - screen.x);
					point.y -= yDiff;
					break;
				case RIGHT:
					point.x = _stage.stageWidth + Math.abs(screen.x - rect.left)
					point.y -= yDiff;
					break;
				case UP:
					point.y = 0 - Math.abs(rect.bottom - screen.y);
					point.x -= xDiff;
					break;
				case DOWN:
					point.y = _stage.stageHeight + Math.abs(screen.y - rect.top);
					point.x -= xDiff;
					break;
				case CENTER:
					point.x -= xDiff;
					point.y -= yDiff;
					break;
			}
			return point;
		}

		protected function resize( e:Event = null ):void
		{
			var p:Point = (_state == 0) ? position(_screen, CENTER) : position(_screen, _end);
			TweenLite.killTweensOf(_screen, false, {x:true, y:true});
			TweenLite.to(_screen, (_state == 0) ? _timeIN : _timeOUT, {x:p.x, y:p.y, onComplete:(_state == 0) ? doneIn : doneOut, ease:(_state == 0) ? _easeIn : _easeOut, overwrite:false});
		}

		public function set height( v:Number ):void  { _height = v; }
		public function set width( v:Number ):void  { _width = v; }

		override public function destroy():void
		{
			super.destroy();
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
