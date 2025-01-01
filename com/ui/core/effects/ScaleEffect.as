package com.ui.core.effects
{
	import org.greensock.TweenLite;
	import org.parade.core.IView;

	public class ScaleEffect extends Effect
	{
		public static const NAME:String = "scaleEffect";

		private var _start:Number;
		private var _end:Number;
		private var _reposition:Boolean;
		private var _timeIN:Number;
		private var _timeOUT:Number;

		public function init( start:Number, end:Number, timeIN:Number, timeOUT:Number, reposition:Boolean = false ):void
		{
			_name = NAME;
			_start = start;
			_end = end;
			_reposition = reposition;
			_timeIN = timeIN;
			_timeOUT = timeOUT;
		}

		override internal function goIn( screen:IView ):void
		{
			super.goIn(screen);
			if (screen.scaleX != _end)
			{
				if (_reposition)
					reposition(screen, true);
				if (_timeIN > 0)
					TweenLite.to(screen, _timeIN, {scaleX:_end, scaleY:_end, onComplete:doneIn, overwrite:false});
				else
				{
					screen.scaleX = _end;
					screen.scaleY = _end;
					doneIn();
				}
			}
		}

		override internal function goOut( screen:IView ):void
		{
			super.goOut(screen);
			if (screen.scaleX != _start)
			{
				TweenLite.killTweensOf(screen, false, {scaleX:true, scaleY:true});
				if (_reposition)
					reposition(screen, false);
				if (_timeOUT > 0)
					TweenLite.to(screen, _timeOUT, {scaleX:_start, scaleY:_start, onComplete:doneOut, overwrite:false});
				else
				{
					screen.scaleX = _start;
					screen.scaleY = _start;
					doneOut();
				}
			}
		}

		protected function reposition( screen:IView, start:Boolean ):void
		{
			var ds:Number   = screen.scaleX;
			screen.scaleX = screen.scaleY = _start;
			var diff:Number = _end - _start;
			var dx:Number   = screen.x - Math.round(screen.width * diff / 2 * ((start) ? 1 : -1));
			var dy:Number   = screen.y - Math.round(screen.height * diff / 2 * ((start) ? 1 : -1));
			screen.scaleX = screen.scaleY = ds;
			var time:Number = (start) ? _timeIN : _timeOUT;
			if (time > 0)
				TweenLite.to(screen, time, {x:dx, y:dy, overwrite:false});
			else
			{
				screen.x = dx;
				screen.y = dy;
			}
		}
	}

}
