package com.ui
{
	import com.Application;
	import com.enum.TimeLogEnum;
	import com.event.ServerEvent;
	import com.model.player.CurrentUser;
	import com.presenter.preload.IPreloadPresenter;
	import com.ui.core.View;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.effects.EffectFactory;
	import com.ui.core.effects.GenericMoveEffect;
	import com.util.TimeLog;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.net.SharedObject;

	import org.parade.enum.ViewEnum;

	public class PreloadView extends View
	{
		[Embed(source="LoadingScreen.png")]
		public static var loadingScreen:Class;

		private var _loadBar:ProgressBar;
		private var _loadingImage:Bitmap;
		private var _loginResponse:Object;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			TimeLog.startTimeLog(TimeLogEnum.PRELOAD_SCREEN);
			_loadingImage = new loadingScreen();

			_loadBar = new ProgressBar();
			_loadBar.init(ProgressBar.HORIZONTAL, new Bitmap(new BitmapData(_loadingImage.width - 10, 30, false, 0x226622)), new Bitmap(new BitmapData(_loadingImage.width, 40, false, 0x222222)), 1);
			_loadBar.setMinMax(0, 1);
			_loadBar.amount = 0;

			addChild(_loadingImage);
			addChild(_loadBar);

			_loginResponse = root.loaderInfo.parameters.LoginResponse;

			presenter.beginSignal.add(onBegin);
			presenter.completeSignal.add(onComplete);
			presenter.addLoadCompleteListener(onLoadComplete);
			presenter.progressSignal.add(onProgress);
			presenter.beginLoad();

			addEffects();
			effectsIN();
			
			if(CONFIG::IS_MOBILE){
				_loadingImage.visible = _loadBar.visible = false;
			}
		}

		private function onBegin( total:int ):void
		{
			_loadBar.setMinMax(0, total + 1);
		}

		private function onProgress( loaded:int, total:int ):void
		{
			if (isNaN(loaded))
				return;
			_loadBar.amount = loaded;
		}

		private function onLoadComplete():void
		{
			presenter.removeLoadCompleteListener(onLoadComplete);

			if (Application.CONNECTION_STATE == ServerEvent.NOT_CONNECTED && Application.NETWORK != Application.NETWORK_KONGREGATE)
			{
				var savedName:SharedObject = SharedObject.getLocal("playerID");
				if (savedName.size > 0 && savedName.data.playerid != null)
				{
					showInputAlert('LOGIN', 'Please Enter Your Player Id', 'Accept', savePlayerInfo, null, null, null, null, false, 20, savedName.data.playerid);
				} else
				{
					showInputAlert('LOGIN', 'Please Enter Your Player Id', 'Accept', savePlayerInfo, null, null, null, null, false, 20, '1');
				}
			} else
				presenter.transitionToLoad();

			_loadBar.visible = false;
			_loadingImage.visible = false;
		}

		private function savePlayerInfo( id:String ):void
		{
			var savedName:SharedObject = SharedObject.getLocal("playerID");
			savedName.data.playerid = id;
			savedName.flush();
			CurrentUser.naid = id;
			presenter.transitionToLoad();
		}

		private function onResize():void
		{
			_loadingImage.x = 0;
			_loadingImage.y = 0;

			_loadBar.x = _loadingImage.x;
			_loadBar.y = _loadingImage.y + _loadingImage.height + 10;
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
			TimeLog.endTimeLog(TimeLogEnum.PRELOAD_SCREEN);
			super.destroy();

			_loadBar.destroy();
			_loadBar = null;

			_loadingImage.bitmapData.dispose();
			_loadingImage = null;
		}
	}
}
