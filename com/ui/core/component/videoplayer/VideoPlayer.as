package com.ui.core.component.videoplayer
{
	import com.Application;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	import org.greensock.TweenLite;
	import org.starling.core.Starling;

	public class VideoPlayer extends Sprite
	{
		private var _videoHolder:Sprite;
		private var _bufferingImageContainer:Sprite;

		private var _fullPlayBtn:BitmapButton;

		private var _controlPanel:ControlPanel;

		private var _video:Video;
		private var _stageVideo:StageVideo;
		private var _videoConnection:NetConnection;

		private var _netStream:NetStream;

		private var _videoURL:String;
		private var _server:String;

		private var _defaultWidth:Number;
		private var _defaultHeight:Number;

		private var _width:Number;
		private var _height:Number;
		private var _duration:Number;

		private var _onMouseInactivity:Timer;

		private var _init:Boolean;
		private var _startVideoImmediately:Boolean;
		private var _loop:Boolean;
		private var _fullScreen:Boolean;

		private var _nonFullScreenX:int;
		private var _nonFullScreenY:int;

		private var _bufferingImage:Bitmap;

		private var _stageVideoAvailability:String;

		private var _frameToPauseOn:Number;

		public var onVideoEnd:Function;
		public var onVideoFullScreen:Function;

		private var _volume:Number;

		public function VideoPlayer( server:String, videoURL:String, vidWidth:Number = 0, vidHeight:Number = 0, startVideoImmediately:Boolean = false, loop:Boolean = false, frameToPauseOn:Number = 0, volume:Number =
									 1 )
		{
			_volume = volume;
			_loop = loop;
			_videoURL = videoURL;
			_server = server;
			_defaultWidth = _width = vidWidth;
			_defaultHeight = _height = vidHeight;
			_startVideoImmediately = startVideoImmediately;
			_frameToPauseOn = frameToPauseOn;

			_fullPlayBtn = ButtonFactory.getBitmapButton('VideoPlayerPlayBtnUpBMD', 0, 0, '', 0, 'VideoPlayerPlayBtnRollOverBMD', 'VideoPlayerPlayBtnDownBMD');
			_fullPlayBtn.addEventListener(MouseEvent.CLICK, onPlayBtnClicked, false, 0, true);
			_fullPlayBtn.visible = false;

			_controlPanel = new ControlPanel();
			_controlPanel.alpha = 0;
			_controlPanel.startFunction = start;
			_controlPanel.pauseFunction = pause;
			_controlPanel.resumeFunction = resume;
			if (Application.STAGE.hasOwnProperty('displayState'))
			{
				_controlPanel.fullScreenFunction = onFullScreen;
				Application.STAGE.addEventListener(Event.FULLSCREEN, onFullScreenSet, false, 0, true);
			}

			Application.STAGE.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoAvailability);

			_controlPanel.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);

			_onMouseInactivity = new Timer(2000, 1);
			_onMouseInactivity.addEventListener(TimerEvent.TIMER_COMPLETE, onMouseInactive, false, 0, true);

			_videoHolder = new Sprite();
			_videoHolder.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);

			var bufferingBMD:Class = Class(getDefinitionByName(('VideoPlayerBufferIconBMD')));
			_bufferingImage = new Bitmap(BitmapData(new bufferingBMD()));
			_bufferingImage.x = -_bufferingImage.width * 0.5;
			_bufferingImage.y = -_bufferingImage.height * 0.5;
			_bufferingImage.smoothing = true;

			_bufferingImageContainer = new Sprite();
			_bufferingImageContainer.x = vidWidth * 0.5;
			_bufferingImageContainer.y = vidHeight * 0.5;
			_bufferingImageContainer.addChild(_bufferingImage);
			_bufferingImageContainer.visible = false;

			_fullPlayBtn.x = (vidWidth - _fullPlayBtn.width) * 0.5;
			_fullPlayBtn.y = (vidHeight - _fullPlayBtn.height) * 0.5;

			_videoConnection = new NetConnection();
			_videoConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			_videoConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			if (server != '')
				_videoConnection.connect(server);
			else
				_videoConnection.connect(null);

			onBuffering(true);
		}

		private function onPlayBtnClicked( e:MouseEvent ):void
		{
			_controlPanel.play();
		}

		private function onNetStatus( event:Object ):void
		{
			switch (event.info.code)
			{
				case "NetConnection.Connect.Success":
					connectStream();
					break;
				case "NetStream.Buffer.Empty":
					onBuffering(true);
					break;
				case "NetStream.Buffer.Full":
					onBuffering(false);
					break;
				case "NetStream.Play.StreamNotFound":
					trace("Stream not found: " + _videoURL);
					break;
				case "NetStream.Unpause.Notify":
					_fullPlayBtn.visible = false;
					break;
				case "NetStream.Play.Start":
					_fullPlayBtn.visible = false;
					if (!_startVideoImmediately)
						_netStream.pause();
					break;
				case "NetStream.Pause.Notify":
					_fullPlayBtn.visible = true;
					break;
				case "NetStream.Play.Stop":
					_fullPlayBtn.visible = true;
					videoPlayComplete();
					break;
			}
		}

		private function onBuffering( buffering:Boolean ):void
		{
			if (buffering)
			{
				TweenLite.to(_bufferingImageContainer, 300, {rotation:'54000'});
			} else
			{
				TweenLite.killTweensOf(_bufferingImageContainer);
			}

			_bufferingImageContainer.visible = buffering;
		}

		private function connectStream():void
		{
			var soundTransform:SoundTransform = new SoundTransform();
			soundTransform.volume = _volume;

			_netStream = new NetStream(_videoConnection);
			_netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler, false, 0, true);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			_netStream.bufferTime = Application.AVG_LOAD_TIME;
			_netStream.soundTransform = soundTransform;


			var custom_obj:Object             = new Object();
			custom_obj.onMetaData = onMetaDataHandler;
			custom_obj.onCuePoint = onCuePointHandler;
			custom_obj.onPlayStatus = playStatus;
			_netStream.client = custom_obj;

			_video = new Video();

			addChild(_videoHolder);
			addChild(_bufferingImageContainer);
			addChild(_fullPlayBtn);
			addChild(_controlPanel);
			setVideoInit();
		}

		private function disableStageVideo():void
		{
			_video.attachNetStream(_netStream);
			addChildAt(_video, 0);
		}

		private function enableStageVideo():void
		{

			if (_stageVideo == null)
			{
				_stageVideo = Application.STAGE.stageVideos[0];
				_stageVideo.viewPort = new Rectangle(x, y, _width, _height);

				if (Application.STARLING_ENABLED)
					Starling.current.stage3D.visible = false;
			}

			if (_video && _video.parent)
				removeChild(_video);

			_stageVideo.attachNetStream(_netStream);
		}

		override public function set x( value:Number ):void
		{
			if (_stageVideo != null)
				_stageVideo.viewPort = new Rectangle(value, y, _width, _height);

			super.x = value;
		}

		override public function set y( value:Number ):void
		{
			if (_stageVideo != null)
				_stageVideo.viewPort = new Rectangle(x, value, _width, _height);
			super.y = value;
		}


		private function onStageVideoAvailability( e:StageVideoAvailabilityEvent ):void
		{
			_stageVideoAvailability = e.availability;
			if (_stageVideoAvailability && Application.STAGE.stageVideos.length > 0)
				enableStageVideo();
			else
				disableStageVideo();
		}


		public function updateVideo( videoURL:String, frameToPauseOn:Number = 0, volume:Number = 1 ):void
		{
			if (_videoURL != videoURL)
			{
				_videoURL = videoURL;
				_frameToPauseOn = frameToPauseOn;
				_volume = volume;
				TweenLite.killTweensOf(_controlPanel);
				_controlPanel.alpha = 0;
				cleanUpOldVideo();
				connectStream();

				if (_stageVideoAvailability && Application.STAGE.stageVideos.length > 0)
					enableStageVideo();
				else
					disableStageVideo();
			}
		}

		private function cleanUpOldVideo():void
		{
			_init = false;
			if (_video.parent)
				removeChild(_video);

			_stageVideo = null;
			_video.clear();
			_video = null;

			_netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			_netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_netStream.close();
			_netStream = null;
		}

		private function onMouseInactive( e:TimerEvent ):void
		{
			TweenLite.to(_controlPanel, 1, {y:(_video.height), alpha:0});
		}

		private function onMouseMove( e:MouseEvent ):void
		{
			TweenLite.to(_controlPanel, 1, {y:(_video.height - _controlPanel.height), alpha:1});

			_onMouseInactivity.reset();
			_onMouseInactivity.start();
		}

		private function onMetaDataHandler( metadata:Object ):void
		{
			if (!_init)
			{
				_init = true;
				if (_width == 0)
				{
					_defaultWidth = metadata.width;
				}

				if (_height == 0)
				{
					_defaultHeight = metadata.height;
				}

				resize(_defaultWidth, _defaultHeight);
				_duration = metadata.duration;

				_controlPanel.isPlaying = _startVideoImmediately;

				if (!_startVideoImmediately)
					_netStream.seek(_frameToPauseOn);
			}

		}

		public function resize( width:Number, height:Number ):void
		{
			if (_stageVideo != null)
				_stageVideo.viewPort = new Rectangle(x, y, width, height);

			_videoHolder.graphics.clear();
			_videoHolder.graphics.lineStyle(2, 0xffffff, 0);
			_videoHolder.graphics.beginFill(0xffffff, 0);
			_videoHolder.graphics.moveTo(0, 0);
			_videoHolder.graphics.lineTo(width, 0);
			_videoHolder.graphics.lineTo(width, height);
			_videoHolder.graphics.lineTo(0, height);
			_videoHolder.graphics.lineTo(0, 0);
			_videoHolder.graphics.endFill();

			_video.width = width;
			_video.height = height;

			setUpControlPanel(width, height);
		}

		private function setUpControlPanel( width:Number, height:Number ):void
		{
			_controlPanel.init(width, height);

			TweenLite.killTweensOf(_controlPanel);
			if (_onMouseInactivity.running)
				_controlPanel.y = height - _controlPanel.height;
			else
				_controlPanel.y = height;
		}


		override public function get height():Number
		{
			return _height;
		}

		override public function get width():Number
		{
			return _width;
		}


		private function securityErrorHandler( event:SecurityErrorEvent ):void
		{
			trace("securityErrorHandler: " + event);
		}
		private function asyncErrorHandler( event:AsyncErrorEvent ):void
		{
			trace(event.text);
		}

		private function onCuePointHandler( cueInfoObj:Object ):void
		{

		}

		private function videoPlayComplete():void
		{
			_init = false;

			_netStream.seek(_frameToPauseOn);

			if (!_loop)
				_netStream.pause();

			if (_controlPanel)
				_controlPanel.isPlaying = _loop;

			if (onVideoEnd != null)
				onVideoEnd();
		}

		private function setVideoInit():void
		{
			_netStream.play(_videoURL);
		}

		private function playStatus( event:Object ):void
		{
			switch (event.code)
			{
				case "NetStream.Play.Complete":
					videoPlayComplete();
					break;
			}
		}

		private function onPlay( e:MouseEvent ):void
		{
			play();
		}

		private function onPause( e:MouseEvent ):void
		{
			pause();
		}

		private function onResume( e:MouseEvent ):void
		{
			resume();
		}

		private function start():void
		{
			_netStream.seek(0);
		}

		public function play():void
		{
			_netStream.resume();
		}

		public function pause():void
		{
			_netStream.pause();
		}

		public function resume():void
		{
			_netStream.resume();
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
			var xPos:Number;
			var yPos:Number;
			_fullScreen = e.fullScreen;
			if (e.fullScreen)
			{
				_nonFullScreenX = x;
				_nonFullScreenY = y;

				xPos = 0;
				yPos = 0;

				_width = Application.STAGE.fullScreenWidth;
				_height = Application.STAGE.fullScreenHeight;

			} else
			{
				xPos = _nonFullScreenX;
				yPos = _nonFullScreenY;

				_width = _defaultWidth;
				_height = _defaultHeight;

			}

			x = xPos;
			y = yPos;

			_controlPanel.fullScreen = e.fullScreen;
			resize(_width, _height);

			_fullPlayBtn.x = (_width - _fullPlayBtn.width) * 0.5;
			_fullPlayBtn.y = (_height - _fullPlayBtn.height) * 0.5;

			if (onVideoFullScreen != null)
				onVideoFullScreen(_fullScreen);
		}

		public function destroy():void
		{
			Application.STAGE.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoAvailability);

			if (Application.STAGE.hasOwnProperty('displayState'))
				Application.STAGE.removeEventListener(Event.FULLSCREEN, onFullScreenSet);

			if (_fullScreen)
			{
				Application.STAGE.displayState = StageDisplayState.NORMAL;
			}

			TweenLite.killTweensOf(_controlPanel);
			//_controlPanel.alpha = 0;
			_controlPanel.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_controlPanel.destroy();
			_controlPanel = null;
			if (_onMouseInactivity.running)
				_onMouseInactivity.stop();

			_onMouseInactivity.removeEventListener(TimerEvent.TIMER_COMPLETE, onMouseInactive);

			_videoHolder.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

			_stageVideo = null;

			_video.clear();
			_video = null;

			_netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			_netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_netStream.close();
			_netStream.dispose();
			_netStream = null;

			_videoConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_videoConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_videoConnection.close();
			_videoConnection = null;

			_fullPlayBtn.removeEventListener(MouseEvent.CLICK, onPlayBtnClicked);
			_fullPlayBtn.destroy();
			_fullPlayBtn = null;

			_videoHolder = null;

			_bufferingImage = null;

			_bufferingImageContainer = null;

			if (Application.STARLING_ENABLED)
				Starling.current.stage3D.visible = true;
		}
	}
}
