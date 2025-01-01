package com.ui.core.effects
{
	import org.greensock.TweenLite;
	import org.parade.core.IView;

	public class AlphaEffect extends Effect
	{
		public static const NAME:String = "alphaEffect";

		private var _start:Number;
		private var _middle:Number;
		private var _end:Number;
		private var _timeIN:Number;
		private var _timeOUT:Number;

		public function init( start:Number, middle:Number, end:Number, timeIN:Number, timeOUT:Number ):void
		{
			_name = NAME;
			_start = start;
			_middle = middle;
			_end = end;
			_timeIN = timeIN;
			_timeOUT = timeOUT;
		}

		override internal function goIn( screen:IView ):void
		{
			super.goIn(screen);
			screen.alpha = _start;
			TweenLite.to(screen, _timeIN, {alpha:_middle, onComplete:doneIn, overwrite:false});
		}

		override internal function goOut( screen:IView ):void
		{
			super.goOut(screen);
			TweenLite.to(screen, _timeOUT, {alpha:_end, onComplete:doneOut, overwrite:false});
		}
	}
}
