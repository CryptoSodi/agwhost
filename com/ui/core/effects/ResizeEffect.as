package com.ui.core.effects
{
	import com.Application;

	import flash.display.Stage;
	import flash.events.Event;

	import org.parade.core.IView;
	import org.parade.util.DeviceMetrics;

	public class ResizeEffect extends Effect
	{
		public static const NAME:String = "stageResizeEffect";

		private var _callback:Function;
		private var _screen:IView;
		private var _stage:Stage;

		public function init( callback:Function = null ):void
		{
			_callback = callback;
		}

		override internal function goIn( screen:IView ):void
		{
			super.goIn(screen);
			_screen = screen;
			_stage = Application.STAGE;
			_stage.removeEventListener(Event.RESIZE, resize);
			_stage.addEventListener(Event.RESIZE, resize, false, 0, true);
			resize();
		}

		override internal function goOut( screen:IView ):void
		{
			super.goOut(screen);
			_stage.removeEventListener(Event.RESIZE, resize);
			doneOut();
		}

		protected function resize( e:Event = null ):void
		{
			var h:Number      = Math.max(_screen.height + 20, DeviceMetrics.HEIGHT_PIXELS);
			var w:Number      = Math.max(_screen.width + 20, DeviceMetrics.WIDTH_PIXELS);
			var scaleH:Number = DeviceMetrics.HEIGHT_PIXELS / h;
			var scaleW:Number = DeviceMetrics.WIDTH_PIXELS / w;
			_screen.scaleX = _screen.scaleY = Math.min(scaleH, scaleW);
			if (_callback != null)
				_callback();
			doneIn();
		}

		override public function destroy():void
		{
			if (_stage)
			{
				_stage.removeEventListener(Event.RESIZE, resize);
				_stage = null;
			}
			_screen = null;
			_callback = null;
		}
	}
}
