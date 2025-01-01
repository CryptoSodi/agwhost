package com.ui
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.presenter.shared.IUIPresenter;
	import com.ui.core.View;
	import com.ui.core.effects.EffectFactory;

	import flash.events.Event;
	import flash.geom.Rectangle;

	import org.parade.enum.PlatformEnum;
	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.starling.core.Starling;

	public class GameView extends View
	{
		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.removeStateListener(onStateChange);

			addEffects();
			effectsIN();
			onResize();
		}

		private function onResize( e:Event = null ):void
		{
			if (Application.STARLING_ENABLED)
			{
				var viewPortRectangle:Rectangle = new Rectangle();
				viewPortRectangle.width = DeviceMetrics.WIDTH_PIXELS;
				viewPortRectangle.height = DeviceMetrics.HEIGHT_PIXELS;
				Starling.current.viewPort = viewPortRectangle;

				Starling.current.stage.stageWidth = DeviceMetrics.WIDTH_PIXELS;
				Starling.current.stage.stageHeight = DeviceMetrics.HEIGHT_PIXELS;
			}

			var scaleX:Number = Math.min(1, DeviceMetrics.WIDTH_PIXELS / Application.MIN_SCREEN_X);
			var scaleY:Number = Math.min(1, DeviceMetrics.HEIGHT_PIXELS / Application.MIN_SCREEN_Y);
			Application.SCALE = Math.min(scaleX, scaleY);
			if(CONFIG::IS_DESKTOP){
				//Application.SCALE = .63;
				Application.SCALE = Math.max(Application.SCALE, .63);
			} else {
				Application.SCALE = Math.max(Application.SCALE, DeviceMetrics.PLATFORM == PlatformEnum.BROWSER ? .63 : .1);
			}
			presenter.changeResolution();
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.LEFT, PositionEnum.TOP, onResize));
		}

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function get type():String  { return ViewEnum.UI; }
	}
}
