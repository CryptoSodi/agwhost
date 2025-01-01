package com.controller.keyboard
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;

	public class KeyboardController
	{
		[Inject]
		public var stage:Stage;

		protected var _keyStateDown:Dictionary = new Dictionary();
		protected var _keyStateUp:Dictionary = new Dictionary();

		[PostConstruct]
		public function init():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		public function addKeyDownListener( callback:Function, keyCode:uint ):void
		{
			if (!_keyStateDown[keyCode])
				_keyStateDown[keyCode] = new Signal(uint);
			_keyStateDown[keyCode].add(callback);
		}
		
		public function removeKeyDownListener( callback:Function, keyCode:uint ):void
		{
			if (!_keyStateDown.hasOwnProperty(keyCode))
				return;
			_keyStateDown[keyCode].remove(callback);
		}
		
		public function addKeyUpListener( callback:Function, keyCode:uint ):void
		{
			if (!_keyStateUp[keyCode])
				_keyStateUp[keyCode] = new Signal(uint);
			_keyStateUp[keyCode].add(callback);
		}

		public function removeKeyUpListener( callback:Function, keyCode:uint ):void
		{
			if (!_keyStateUp.hasOwnProperty(keyCode))
				return;
			_keyStateUp[keyCode].remove(callback);
		}

		protected function onKeyDown( ke:KeyboardEvent ):void
		{
			if (!_keyStateDown.hasOwnProperty(ke.keyCode))
				return;
			if (_keyStateDown[ke.keyCode].numListeners > 0)
				_keyStateDown[ke.keyCode].dispatch(ke.keyCode);
		}
		
		protected function onKeyUp( ke:KeyboardEvent ):void
		{
			if (!_keyStateUp.hasOwnProperty(ke.keyCode))
				return;
			if (_keyStateUp[ke.keyCode].numListeners > 0)
				_keyStateUp[ke.keyCode].dispatch(ke.keyCode);
		}

		public function destroy():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
	}
}
