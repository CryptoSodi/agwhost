package com.ui
{
	import com.enum.ui.ButtonEnum;
	import com.presenter.preload.IPreloadPresenter;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.effects.EffectFactory;
	import com.ui.core.effects.GenericMoveEffect;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;

	import org.parade.enum.ViewEnum;

	public class ReconnectView extends View
	{
		private var _loadingImage:Bitmap;
		private var _reconnectButton:BitmapButton;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.completeSignal.add(onComplete);
			_loadingImage = new PreloadView.loadingScreen();
			_reconnectButton = UIFactory.getButton(ButtonEnum.GREEN_A, _loadingImage.width, 40, _loadingImage.x, _loadingImage.y + _loadingImage.height + 5, "RECONNECT");

			addListener(_reconnectButton, MouseEvent.CLICK, onReconnect);

			addChild(_loadingImage);
			addChild(_reconnectButton);

			addEffects();
			effectsIN();
		}

		private function onReconnect( e:MouseEvent ):void
		{
			_reconnectButton.enabled = false;
			presenter.transitionToLoad();
		}

		private function onResize():void
		{
			_loadingImage.x = 0;
			_loadingImage.y = 0;

			_reconnectButton.x = _loadingImage.x;
			_reconnectButton.y = _loadingImage.y + _loadingImage.height + 5;
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.resizeEffect(onResize));
			_effects.addEffect(EffectFactory.simpleBackingEffect(1, 0, 0));
			_effects.addEffect(EffectFactory.genericMoveEffect(GenericMoveEffect.UP, GenericMoveEffect.UP, .1, .1));
		}

		private function onComplete():void  { destroy(); }

		override public function get height():Number  { return 400; }
		override public function get width():Number  { return 1024; }

		[Inject]
		public function set presenter( value:IPreloadPresenter ):void  { _presenter = value; }
		public function get presenter():IPreloadPresenter  { return IPreloadPresenter(_presenter); }

		override public function get type():String  { return ViewEnum.UI; }

		override public function destroy():void
		{
			super.destroy();

			_loadingImage.bitmapData.dispose();
			_loadingImage = null;
			_reconnectButton = UIFactory.destroyButton(_reconnectButton);
		}
	}
}
