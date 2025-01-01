package com.ui.core.effects
{
	import com.Application;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;

	import org.greensock.TweenLite;
	import org.parade.core.IView;

	public class FullscreenFadeEffect extends Effect
	{
		public static const NAME:String = "FullscreenFadeEffect";

		private static var COVER:Bitmap;

		private var _stage:Stage;
		private var _timeIN:Number;
		private var _timeOUT:Number;

		//adds a fade in effect to "screen"
		public function init( timeIN:Number, timeOUT:Number ):void
		{
			_name = NAME;
			_timeIN = timeIN;
			_timeOUT = timeOUT;

			if (!COVER)
				COVER = new Bitmap(new BitmapData(5, 5, false, 0));
		}

		override internal function goIn( screen:IView ):void
		{
			super.goIn(screen);
			_stage = Application.STAGE;
			_stage.removeEventListener(Event.RESIZE, resize);
			_stage.addEventListener(Event.RESIZE, resize, false, 0, true);
			resize();
			COVER.alpha = 0;
			Application.STAGE.addChild(COVER);
			TweenLite.to(COVER, _timeIN, {alpha:1, onComplete:doneIn});
		}

		override internal function goOut( screen:IView ):void
		{
			super.goOut(screen);
			TweenLite.to(COVER, _timeOUT, {alpha:0, onComplete:doneOut});
		}

		protected function resize( e:Event = null ):void
		{
			COVER.width = _stage.stageWidth;
			COVER.height = _stage.stageHeight;
		}

		override public function destroy():void
		{
			super.destroy();
			if (_stage)
			{
				_stage.removeEventListener(Event.RESIZE, resize);
				_stage = null;
			}
			TweenLite.killTweensOf(COVER);

			if (COVER.parent)
				COVER.parent.removeChild(COVER);
		}
	}

}
