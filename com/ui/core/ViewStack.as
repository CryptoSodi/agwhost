package com.ui.core
{
	import com.Application;
	import com.event.StateEvent;
	import com.presenter.shared.IUIPresenter;
	import com.util.TimeLog;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;

	import org.ash.tick.ITickProvider;
	import org.console.Cc;
	import org.parade.core.IView;
	import org.parade.core.IViewStack;
	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.starling.core.Starling;
	import org.starling.display.DisplayObject;
	import org.starling.display.Sprite;
	import org.starling.events.Event;

	public class ViewStack implements IViewStack
	{
		protected const _alert:flash.display.Sprite         = new flash.display.Sprite();
		protected const _console:flash.display.Sprite       = new flash.display.Sprite();
		protected const _error:flash.display.Sprite         = new flash.display.Sprite();
		protected const _hover:flash.display.Sprite         = new flash.display.Sprite();
		protected const _modal:flash.display.Sprite         = new flash.display.Sprite();
		protected const _ui:flash.display.Sprite            = new flash.display.Sprite();
		protected const _game:flash.display.Sprite          = new flash.display.Sprite();
		protected const _game3D:org.starling.display.Sprite = new org.starling.display.Sprite();
		protected const _maxAmplitude:int                   = 10;

		protected var _contextView:flash.display.DisplayObjectContainer;
		protected var _backgroundLayer:flash.display.Sprite;
		protected var _background3DLayer:org.starling.display.Sprite;
		protected var _gameLayer:flash.display.Sprite;
		protected var _game3DLayer:org.starling.display.Sprite;
		protected var _presenter:IUIPresenter;

		protected var _amplitude:Number;
		protected var _direction:int;
		protected var _eventDispatcher:IEventDispatcher;
		protected var _frameTickProvider:ITickProvider;
		protected var _initialAmplitude:Number;
		protected var _speed:Number;
		protected var _starling:Starling;
		protected var _time:Number;
		protected var _totalTime:Number;
		protected var _wave:int;

		[PostConstruct]
		public function init():void
		{
			_contextView.stage.addEventListener(flash.events.Event.RESIZE, onResize);
			_contextView.addChild(_ui);
			_contextView.addChild(_modal);
			_contextView.addChild(_alert);
			_contextView.addChild(_hover);
			_contextView.addChild(_error);
			_contextView.addChild(_console);

			Cc.config.commandLineAutoCompleteEnabled = true;
			Cc.config.commandLineAllowed = true;
			Cc.commandLine = true;
			Cc.startOnStage(_console, "~");

			onResize(null);
		}

		private function onResize( e:flash.events.Event ):void
		{
			//need a check here because in IE stagewidth / stageheight may be 0. wait for a resize event to tell us width / height is available
			if (DeviceMetrics.WIDTH_PIXELS > 0)
			{
				_contextView.stage.removeEventListener(flash.events.Event.RESIZE, onResize);
				_starling = new Starling(org.starling.display.Sprite, _contextView.stage, new Rectangle(0, 0, DeviceMetrics.WIDTH_PIXELS, DeviceMetrics.HEIGHT_PIXELS)); //, null, "auto", Context3DProfile.BASELINE); //, null, "software");
				//_starling = new Starling(org.starling.display.Sprite, _contextView.stage, new Rectangle(0, 0, DeviceMetrics.WIDTH_PIXELS, DeviceMetrics.HEIGHT_PIXELS, null, "auto", "baselineExtended"); //, null, "software");
				_starling.addEventListener(org.starling.events.Event.ROOT_CREATED, addStage3DLayers);
				_starling.start();

				clearValues();
			}
		}

		public function addView( view:IView ):void
		{
			addToLayer(view, view.type);
		}

		public function addToLayer( object:Object, layer:String ):void
		{
			switch (layer)
			{
				case ViewEnum.ALERT:
					_alert.addChild(flash.display.DisplayObject(object));
					break;
				case ViewEnum.ERROR:
					_error.addChild(flash.display.DisplayObject(object));
					break;
				case ViewEnum.HOVER:
					_hover.addChild(flash.display.DisplayObject(object));
					break;
				case ViewEnum.MODAL:
					_modal.addChild(flash.display.DisplayObject(object));
					break;
				case ViewEnum.UI:
					_ui.addChild(flash.display.DisplayObject(object));
					break;
				case ViewEnum.GAME:
					if (Application.STARLING_ENABLED)
						_game3D.addChildAt(org.starling.display.DisplayObject(object), 0);
					else
						_game.addChildAt(flash.display.DisplayObject(object), 0);
					break;
				case ViewEnum.BACKGROUND_LAYER:
					if (Application.STARLING_ENABLED)
						_background3DLayer.addChild(org.starling.display.DisplayObject(object));
					else
						_backgroundLayer.addChild(flash.display.DisplayObject(object));
					break;
				case ViewEnum.GAME_LAYER:
					if (Application.STARLING_ENABLED)
						_game3DLayer.addChild(org.starling.display.DisplayObject(object));
					else
						_gameLayer.addChild(flash.display.DisplayObject(object));
					break;
			}
		}

		public function getLayer( layer:String ):*
		{
			switch (layer)
			{
				case ViewEnum.ALERT:
					return _alert;
					break;
				case ViewEnum.ERROR:
					return _error;
					break;
				case ViewEnum.HOVER:
					return _hover;
					break;
				case ViewEnum.MODAL:
					return _modal;
					break;
				case ViewEnum.UI:
					return _ui;
					break;
				case ViewEnum.GAME:
					if (Application.STARLING_ENABLED)
						return _game3D;
					else
						return _game;
					break;
				case ViewEnum.BACKGROUND_LAYER:
					if (Application.STARLING_ENABLED)
						return _background3DLayer;
					else
						return _backgroundLayer;
					break;
				case ViewEnum.GAME_LAYER:
					if (Application.STARLING_ENABLED)
						return _game3DLayer;
					else
						return _gameLayer;
					break;
			}
		}

		public function shake( amplitude:Number = 1, time:int = 1, speed:int = 10, direction:int = 3 ):void
		{
			_wave = 0;

			if (amplitude < 0)
				amplitude = 0;
			_amplitude += amplitude;
			if (_amplitude > _maxAmplitude)
				_amplitude = _maxAmplitude;

			_initialAmplitude = _amplitude;
			_time = 0;
			_totalTime = time;
			_speed = speed;
			_direction = direction;
		}

		public function update( time:Number ):void
		{
			if (_totalTime == 0)
				return;

			_wave += _speed / _maxAmplitude;
			_amplitude = _initialAmplitude - _initialAmplitude / _totalTime * _time;

			if (_time < _totalTime)
			{

				switch (_direction)
				{
					case 1:
						_game3D.x = Math.cos(_wave) * _amplitude;
						break;

					case 2:
						_game3D.y = Math.sin(_wave / 1.5) * _amplitude;
						break;

					case 3:
						_game3D.x = Math.cos(_wave) * _amplitude;
						_game3D.y = Math.sin(_wave / 1.5) * _amplitude;
						break;
				}
			} else
			{
				_game3D.x = _game3D.y = 0;
				clearValues();
			}

			_time += time;
		}

		public function clearLayer( layer:String ):void
		{
			var viewLayer:*;
			switch (layer)
			{
				case ViewEnum.ALERT:
				case ViewEnum.ERROR:
				case ViewEnum.HOVER:
				case ViewEnum.MODAL:
				case ViewEnum.UI:
					break;
				case ViewEnum.GAME:
					if (Application.STARLING_ENABLED)
						viewLayer = _game3D;
					else
						viewLayer = _game;
					break;
				case ViewEnum.BACKGROUND_LAYER:
					if (Application.STARLING_ENABLED)
						viewLayer = _background3DLayer;
					else
						viewLayer = _backgroundLayer;
					break;
				case ViewEnum.GAME_LAYER:
					if (Application.STARLING_ENABLED)
						viewLayer = _game3DLayer;
					else
						viewLayer = _gameLayer;
					break;
			}
			while (viewLayer.numChildren > 0)
				viewLayer.removeChildAt(0);
		}

		public function clearValues():void
		{
			_wave = _amplitude = _time = _speed = _direction = _totalTime = 0;
		}

		private function addStage3DLayers( e:org.starling.events.Event ):void
		{
			Application.STARLING_ENABLED = Starling.context.driverInfo.toLowerCase().indexOf("software") == -1;
			if (Application.STARLING_ENABLED)
			{
				_starling.stage.addChild(_game3D);
				_background3DLayer = new org.starling.display.Sprite();
				_background3DLayer.touchable = false;
				_game3DLayer = new org.starling.display.Sprite();
				_game3DLayer.touchable = false;
				_game3D.addChild(_background3DLayer);
				_game3D.addChild(_game3DLayer);
				_game3D.alpha = 0.999;
				_starling.addEventListener(org.starling.events.Event.CONTEXT3D_CREATE, onContextCreated);
				//if (CONFIG::DEBUG == true)
					//_starling.showStatsAt("center", "bottom");
			} else
			{
				_starling.stop();
				_starling.dispose();
				_starling = null;
				_contextView.addChildAt(_game, 0);
				_backgroundLayer = new flash.display.Sprite();
				_backgroundLayer.mouseChildren = _backgroundLayer.mouseEnabled = false;
				_gameLayer = new flash.display.Sprite();
				_gameLayer.mouseChildren = _gameLayer.mouseEnabled = false;
				_game.addChild(_backgroundLayer);
				_game.addChild(_gameLayer);
			}
			logSpecs();
		}

		private function onContextCreated( e:org.starling.events.Event ):void
		{
			_eventDispatcher.dispatchEvent(new StateEvent(StateEvent.LOST_CONTEXT));
		}

		private static function logSpecs():void
		{
			// Get the player’s version by using the flash.system.Capabilities class.
			var versionNumber:String     = Capabilities.version;
			var log:String               = "[SPECS] CPU:" + Capabilities.cpuArchitecture + " -- OS:" + Capabilities.os;
			var versionArray:Array       = versionNumber.split(",");
			var platformAndVersion:Array = versionArray[0].split(" ");

			log += " -- FLASH_PLAYER:" + (int(platformAndVersion[1]) + "." + int(versionArray[1]));
			log += " -- RESOLUTION:" + Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY;
			log += " -- GPU:" + (Application.STARLING_ENABLED ? "true" : "false");
			TimeLog.addLog(log);
		}

		[Inject]
		public function set contextView( value:flash.display.DisplayObjectContainer ):void  { _contextView = value; }
		[Inject]
		public function set eventDispatcher( value:IEventDispatcher ):void  { _eventDispatcher = value; }
		[Inject]
		public function set frameTickProvider( value:ITickProvider ):void  { _frameTickProvider = value; }
	}
}


