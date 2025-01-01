package com.ui.core.component.videoplayer
{
	import com.Application;
	import com.enum.ui.ButtonEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.modal.ButtonFactory;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.Timer;

	import org.greensock.TweenLite;
	import org.osflash.signals.Signal;

	public class YouTubeVideoPlayer extends Sprite
	{
		private var _hitArea:Sprite;
		private var _playBtn:BitmapButton;
		private var _pauseBtn:BitmapButton;
		private var _minimizeBtn:BitmapButton;
		private var _fullScreenBtn:BitmapButton;

		private var _vPlayer:Object;
		private var _vLoader:Loader;
		private var _vName:String;

		private var _vVolume:uint;

		private var _vCurrentState:int;

		private var _defaultWidth:Number;
		private var _defaultHeight:Number;

		private var _width:Number;
		private var _height:Number;

		private var _autoplay:Boolean;
		private var _fullScreen:Boolean;
		private var _isPlaying:Boolean;
		private var _isReady:Boolean;

		private var _onMouseInactivity:Timer;
		private var _onVideoEnd:Function;

		public var onFullScreenChanged:Signal;

		private var UNSTARTED:int  = -1;
		private var ENDED:int      = 0;
		private var PLAYING:int    = 1;
		private var PAUSED:int     = 2;
		private var BUFFERING:int  = 3;
		private var VIDEO_CUED:int = 4;

		public function YouTubeVideoPlayer( width:Number, height:Number, autoplay:Boolean = false )
		{
			
			if(CONFIG::IS_DESKTOP == 0)
				Security.allowDomain("www.youtube.com");
			
			

			onFullScreenChanged = new Signal(Boolean);

			_hitArea = new Sprite();
			_hitArea.alpha = 0;

			_autoplay = autoplay;

			_defaultWidth = _width = width;
			_defaultHeight = _height = height;

			drawHitArea();

			_vCurrentState = -1;

			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);

			//_vLoader = new Loader();
			//_vLoader.load(new URLRequest("https://www.youtube.com/apiplayer?version=3"), new LoaderContext(false, ApplicationDomain.currentDomain));
			//_vLoader.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit, false, 0, true);

			_onMouseInactivity = new Timer(2000, 1);
			_onMouseInactivity.addEventListener(TimerEvent.TIMER_COMPLETE, onMouseInactive, false, 0, true);

			_playBtn = ButtonFactory.getBitmapButton('VideoPlayerPlayBtnUpBMD', 0, 0, '', 0, 'VideoPlayerPlayBtnRollOverBMD', 'VideoPlayerPlayBtnDownBMD');
			_playBtn.addEventListener(MouseEvent.CLICK, onPlayVideoClick, false, 0, true);
			_playBtn.visible = !autoplay;

			_pauseBtn = ButtonFactory.getBitmapButton('VideoPlayerPauseBtnUpBMD', 0, 0, '', 0, 'VideoPlayerPauseBtnRollOverBMD', 'VideoPlayerPauseBtnDownBMD');
			_pauseBtn.addEventListener(MouseEvent.CLICK, onPauseVideoClicked, false, 0, true);
			_playBtn.visible = autoplay;
			_pauseBtn.alpha = 0;

			_fullScreenBtn = UIFactory.getButton(ButtonEnum.ICON_MAXIMIZE, 0, 0, 369, 5);
			_fullScreenBtn.addEventListener(MouseEvent.CLICK, onFullScreenClick, false, 0, true);
			_fullScreenBtn.alpha = 0;
			_fullScreenBtn.visible = true;

			_minimizeBtn = UIFactory.getButton(ButtonEnum.ICON_MINIMIZE, 0, 0, 369, 5);
			_minimizeBtn.addEventListener(MouseEvent.CLICK, onFullScreenClick, false, 0, true);
			_minimizeBtn.alpha = 0;
			_minimizeBtn.visible = false;

			Application.STAGE.addEventListener(Event.FULLSCREEN, onFullScreenSet, false, 0, true);
			addChild(_hitArea);
		}

		private function onLoaderInit( e:Event ):void
		{
			_vPlayer = _vLoader.content;
			_vPlayer.addEventListener('onReady', onPlayerReady, false, 0, true);
			_vPlayer.addEventListener('onStateChange', onStateChanged, false, 0, true);

			addChild(_vLoader);
			addChild(_hitArea);
			addChild(_fullScreenBtn);
			addChild(_minimizeBtn);
			addChild(_pauseBtn);
			addChild(_playBtn);
		}

		private function drawHitArea():void
		{
			if (_hitArea)
			{
				_hitArea.graphics.clear();
				_hitArea.graphics.beginFill(0xfffffff, 0.0);
				_hitArea.graphics.drawRect(0, 0, _width, _height);
				_hitArea.graphics.endFill();
			}
		}

		private function onPlayerReady( e:Event ):void
		{
			_isReady = true;
			_vPlayer.setVolume(_vVolume);
			resize();
			loadVideo();
		}

		public function resizeDefault( width:Number, height:Number ):void
		{
			_defaultWidth = _width = width;
			_defaultHeight = _height = height;
			resize();
		}

		private function resize():void
		{
			drawHitArea();
			_vPlayer.setSize(_width, _height);

			_playBtn.x = (_width - _playBtn.width) * 0.5;
			_playBtn.y = (_height - _playBtn.height) * 0.5;

			_pauseBtn.x = (_width - _pauseBtn.width) * 0.5;
			_pauseBtn.y = (_height - _pauseBtn.height) * 0.5;

			_fullScreenBtn.x = _minimizeBtn.x = _fullScreenBtn.width;
			_fullScreenBtn.y = _minimizeBtn.y = _height - _fullScreenBtn.height - 10;
		}

		private function loadVideo():void
		{
			if (_vName != '' && _isReady)
			{
				if (!_autoplay)
					_vPlayer.cueVideoById(_vName, 0);
				else
					_vPlayer.loadVideoById(_vName, 0);
			}
		}

		private function onFullScreen( fullScreen:Boolean ):void
		{
			if (fullScreen)
				Application.STAGE.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			else
				Application.STAGE.displayState = StageDisplayState.NORMAL;
		}

		private function onFullScreenSet( e:FullScreenEvent ):void
		{
			_fullScreen = e.fullScreen;

			if (e.fullScreen)
			{
				_width = Application.STAGE.fullScreenWidth;
				_height = Application.STAGE.fullScreenHeight;
				_fullScreenBtn.visible = false;
				_minimizeBtn.visible = true;
			} else
			{
				_width = _defaultWidth;
				_height = _defaultHeight;
				_fullScreenBtn.visible = true;
				_minimizeBtn.visible = false;
			}

			onFullScreenChanged.dispatch(_fullScreen);
			resize();
		}

		private function onMouseMove( e:MouseEvent ):void
		{
			TweenLite.to(_fullScreenBtn, 1, {alpha:1});
			TweenLite.to(_minimizeBtn, 1, {alpha:1});

			if (_isPlaying)
				TweenLite.to(_pauseBtn, 1, {alpha:1});

			_onMouseInactivity.reset();
			_onMouseInactivity.start();
		}

		private function onMouseInactive( e:TimerEvent ):void
		{
			TweenLite.to(_fullScreenBtn, 1, {alpha:0});
			TweenLite.to(_minimizeBtn, 1, {alpha:0});

			if (_pauseBtn.alpha > 0)
				TweenLite.to(_pauseBtn, 1, {alpha:0});
		}

		private function onStateChanged( e:Event ):void
		{
			_vCurrentState = _vPlayer.getPlayerState();
			switch (_vCurrentState)
			{
				case UNSTARTED:
					_isPlaying = false;
					_playBtn.visible = !_isPlaying;
					break;
				case ENDED:
					_isPlaying = false;
					if (_onVideoEnd != null)
						_onVideoEnd();
					break;
				case PLAYING:
					_isPlaying = true;
					_pauseBtn.visible = true;
					_playBtn.visible = !_isPlaying;
					break;
				case PAUSED:
					_isPlaying = false;
					_pauseBtn.visible = _isPlaying;
					_playBtn.visible = !_isPlaying;
					break;
				case BUFFERING:
					_isPlaying = false;
					_playBtn.visible = !_isPlaying;
					break;
				case VIDEO_CUED:
					_isPlaying = false;
					_playBtn.visible = !_isPlaying;
					break;
			}
		}

		public function updateVideo( v:String ):void
		{
			if (_vPlayer)
				_vPlayer.stopVideo();

			_vName = v;

			loadVideo();
		}

		public function stopVideo():void
		{
			_vPlayer.stopVideo();
		}

		public function onFullScreenClick( e:MouseEvent ):void
		{
			onFullScreen(!_fullScreen)
		}

		public function onPlayVideoClick( e:MouseEvent ):void
		{
			_vPlayer.playVideo();
		}

		private function onPauseVideoClicked( e:MouseEvent ):void
		{
			_vPlayer.pauseVideo();
		}

		public function set onVideoEnd( v:Function ):void  { _onVideoEnd = v; }

		public function set volume( v:uint ):void
		{
			_vVolume = v;

			if (_isReady)
				_vPlayer.setVolume(_vVolume);
		}

		public function destroy():void
		{
			this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Application.STAGE.removeEventListener(Event.FULLSCREEN, onFullScreenSet);
			if (_vCurrentState == PLAYING || _vCurrentState == BUFFERING)
				_vPlayer.stopVideo();

			if (onFullScreenChanged)
				onFullScreenChanged.removeAll();
			onFullScreenChanged = null;

			if (_playBtn)
			{
				_playBtn.removeEventListener(MouseEvent.CLICK, onPlayVideoClick);
				_playBtn.destroy();
			}

			_playBtn = null;

			if (_pauseBtn)
			{
				_pauseBtn.removeEventListener(MouseEvent.CLICK, onPauseVideoClicked);
				_pauseBtn.destroy();
			}

			_pauseBtn = null;

			_fullScreenBtn.removeEventListener(MouseEvent.CLICK, onFullScreenClick);
			_minimizeBtn.removeEventListener(MouseEvent.CLICK, onFullScreenClick);
			_fullScreenBtn = UIFactory.destroyButton(_fullScreenBtn);
			_minimizeBtn = UIFactory.destroyButton(_minimizeBtn);

			if (_vPlayer)
			{
				_vPlayer.removeEventListener('onReady', onPlayerReady);
				_vPlayer.removeEventListener('onStateChange', onStateChanged);
			}

			_vPlayer = null;

			if (_vLoader)
				_vLoader.contentLoaderInfo.removeEventListener(Event.INIT, onLoaderInit);

			_vLoader = null;

			_vName = null;

			if (_onMouseInactivity)
			{
				if (_onMouseInactivity.running)
					_onMouseInactivity.stop();

				_onMouseInactivity.removeEventListener(TimerEvent.TIMER_COMPLETE, onMouseInactive);
			}
			_onMouseInactivity = null;

			_onVideoEnd = null;

			_hitArea = null;
		}

	}
}
