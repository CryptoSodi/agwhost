package com.game.entity.systems.interact.controls
{
	import com.Application;
	import com.controller.keyboard.KeyboardController;
	import com.controller.keyboard.KeyboardKey;
	import com.event.StateEvent;
	import com.game.entity.systems.interact.InteractSystem;

	import flash.events.MouseEvent;
	import flash.geom.Point;

	import org.parade.util.DeviceMetrics;
	import org.starling.events.Touch;
	import org.starling.events.TouchEvent;
	import org.starling.events.TouchPhase;

	public class MobileScheme implements IControlScheme
	{
		public static const ALLOW_ALL:int      = 0;
		public static const LIMITED_ACCESS:int = 1;

		private var _distance:Number           = 0;
		private var _interactSystem:InteractSystem;
		private var _keyboardController:KeyboardController;
		private var _layer:*;
		private var _notifyOnMove:Boolean      = false;
		private var _p1:Point;
		private var _p2:Point;
		private var _state:String;
		private var _touches:Vector.<Touch>;
		private var _zooming:Boolean           = false;

		public function init( interactSystem:InteractSystem, layer:*, keyController:KeyboardController ):void
		{
			_interactSystem = interactSystem;
			_keyboardController = keyController;
			_layer = layer;
			_p1 = new Point();
			_p2 = new Point();
			_state = Application.STATE;
			_touches = new Vector.<Touch>;
			addListeners();

			if (Application.STATE == StateEvent.GAME_BATTLE_INIT || Application.STATE == StateEvent.GAME_BATTLE)
			{
				addUpKey(KeyboardKey.ONE.keyCode);
				addUpKey(KeyboardKey.TWO.keyCode);
				addUpKey(KeyboardKey.THREE.keyCode);
				addUpKey(KeyboardKey.FOUR.keyCode);
				addUpKey(KeyboardKey.FIVE.keyCode);
				addUpKey(KeyboardKey.SIX.keyCode);
				addUpKey(KeyboardKey.SEVEN.keyCode);
				addUpKey(KeyboardKey.EIGHT.keyCode);
				addUpKey(KeyboardKey.NINE.keyCode);
				addUpKey(KeyboardKey.ZERO.keyCode);

				addUpKey(KeyboardKey.F1.keyCode);
				addUpKey(KeyboardKey.F2.keyCode);
				addUpKey(KeyboardKey.F3.keyCode);
				addUpKey(KeyboardKey.F4.keyCode);
				addUpKey(KeyboardKey.F5.keyCode);
				addUpKey(KeyboardKey.F6.keyCode);

				addUpKey(KeyboardKey.A.keyCode);
				addUpKey(KeyboardKey.D.keyCode);
				addUpKey(KeyboardKey.DOWN.keyCode);
				addUpKey(KeyboardKey.LEFT.keyCode);
				addUpKey(KeyboardKey.RIGHT.keyCode);
				addUpKey(KeyboardKey.Q.keyCode);
				addUpKey(KeyboardKey.S.keyCode);
				addUpKey(KeyboardKey.UP.keyCode);
				addUpKey(KeyboardKey.W.keyCode);
				addUpKey(KeyboardKey.F.keyCode);
				addUpKey(KeyboardKey.G.keyCode);
				addUpKey(KeyboardKey.T.keyCode);
				addUpKey(KeyboardKey.R.keyCode);

				addUpKey(KeyboardKey.ESCAPE.keyCode);
				addDownKey(KeyboardKey.CONTROL.keyCode);
				addUpKey(KeyboardKey.CONTROL.keyCode);
				addDownKey(KeyboardKey.SHIFT.keyCode);
				addUpKey(KeyboardKey.SHIFT.keyCode);
			} else if (Application.STATE == StateEvent.GAME_SECTOR_INIT)
			{
				addUpKey(KeyboardKey.A.keyCode);
				addUpKey(KeyboardKey.D.keyCode);
				addUpKey(KeyboardKey.LEFT.keyCode);
				addUpKey(KeyboardKey.RIGHT.keyCode);
			} else
			{
				addDownKey(KeyboardKey.SHIFT.keyCode);
				addUpKey(KeyboardKey.SHIFT.keyCode);
				addUpKey(KeyboardKey.ESCAPE.keyCode);
			}
		}

		public function addDownKey( keyCode:uint ):void  { _keyboardController.addKeyDownListener(onDownKey, keyCode); }
		public function removeDownKey( keyCode:uint ):void  { _keyboardController.removeKeyDownListener(onDownKey, keyCode); }
		public function addUpKey( keyCode:uint ):void  { _keyboardController.addKeyUpListener(onUpKey, keyCode); }
		public function removeUpKey( keyCode:uint ):void  { _keyboardController.removeKeyUpListener(onUpKey, keyCode); }

		protected function onDownKey( keyCode:uint ):void  { _interactSystem.onKey(keyCode, false); }
		protected function onUpKey( keyCode:uint ):void  { _interactSystem.onKey(keyCode, true); }

		protected function onTouch( e:TouchEvent ):void
		{
			var touch:Touch = e.getTouch(_layer);
			if (!touch)
				return;
			_touches.length = 0;
			e.getTouches(_layer, null, _touches);
			switch (touch.phase)
			{
				case TouchPhase.BEGAN:
					if (_touches.length == 2)
					{
						_zooming = false;
						_p1.setTo(_touches[0].globalX, _touches[0].globalY);
						_p2.setTo(_touches[1].globalX, _touches[1].globalY);
						_distance = Point.distance(_p1, _p2);
					} else if (_touches.length == 1)
						_interactSystem.onInteraction(MouseEvent.MOUSE_DOWN, touch.globalX, touch.globalY);
					break;
				case TouchPhase.HOVER:
					if (_notifyOnMove && _touches.length == 1)
						_interactSystem.onInteraction(MouseEvent.MOUSE_MOVE, touch.globalX, touch.globalY);
					break;
				case TouchPhase.MOVED:
					if (_touches.length == 2)
					{
						_p1.setTo(_touches[0].globalX, _touches[0].globalY);
						_p2.setTo(_touches[1].globalX, _touches[1].globalY);
						var newDis:Number = Point.distance(_p1, _p2);
						if (Math.abs(newDis - _distance) >= 35 * DeviceMetrics.DENSITY)
						{
							_zooming = true;
							_interactSystem.onZoom(newDis > _distance ? .1 : -.1, touch.globalX, touch.globalY);
							_distance = newDis;
						}
					} else if (_touches.length == 1)
						_interactSystem.onInteraction(MouseEvent.MOUSE_MOVE, touch.globalX, touch.globalY);
					break;
				case TouchPhase.ENDED:
					if (_touches.length == 4)
						_interactSystem.onKey(KeyboardKey.Q.keyCode, true);
					else if (_touches.length == 3)
					{
						if (touch.globalX > DeviceMetrics.WIDTH_PIXELS * .5)
							_interactSystem.onKey(KeyboardKey.W.keyCode, true);
						else
							_interactSystem.onKey(KeyboardKey.S.keyCode, true);
					} else if (_touches.length == 2 && !_zooming)
					{
						if (touch.globalX > DeviceMetrics.WIDTH_PIXELS * .5)
							_interactSystem.onKey(KeyboardKey.D.keyCode, true);
						else
							_interactSystem.onKey(KeyboardKey.A.keyCode, true);
					} else
						_interactSystem.onInteraction(MouseEvent.MOUSE_UP, touch.globalX, touch.globalY);
					break;
			}
		}

		protected function onMouse( e:MouseEvent ):void
		{
			switch (e.type)
			{
				case MouseEvent.MOUSE_DOWN:
				case MouseEvent.RIGHT_MOUSE_DOWN:
					Application.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, onMouse);
					Application.STAGE.addEventListener(MouseEvent.MOUSE_UP, onMouse);
					_interactSystem.onInteraction(MouseEvent.MOUSE_DOWN, e.stageX, e.stageY);
					break;
				case MouseEvent.MOUSE_MOVE:
					_interactSystem.onInteraction(MouseEvent.MOUSE_MOVE, e.stageX, e.stageY);
					break;
				case MouseEvent.MOUSE_UP:
				case MouseEvent.RIGHT_MOUSE_UP:
					Application.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, onMouse);
					Application.STAGE.removeEventListener(MouseEvent.MOUSE_UP, onMouse);
					_interactSystem.onInteraction(MouseEvent.MOUSE_UP, e.stageX, e.stageY);
					break;
			}
		}

		protected function onMouseWheel( e:MouseEvent ):void  { _interactSystem.onZoom(e.delta > 0 ? .1 : -.1, e.stageX, e.stageY); }

		protected function addListeners():void
		{
			if (Application.STARLING_ENABLED)
				_layer.addEventListener(TouchEvent.TOUCH, onTouch);
			else
			{
				_layer.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
				_layer.addEventListener(MouseEvent.MOUSE_UP, onMouse);
			}
			Application.STAGE.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouse);
			Application.STAGE.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouse);
			Application.STAGE.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		protected function removeListeners():void
		{
			if (Application.STARLING_ENABLED)
				_layer.removeEventListener(TouchEvent.TOUCH, onTouch);
			else
			{
				_layer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouse);
				_layer.removeEventListener(MouseEvent.MOUSE_UP, onMouse);
			}

			Application.STAGE.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouse);
			Application.STAGE.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouse);
			Application.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, onMouse);
			Application.STAGE.removeEventListener(MouseEvent.MOUSE_UP, onMouse);
			Application.STAGE.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		public function set notifyOnMove( v:Boolean ):void
		{
			_notifyOnMove = v;
			if (!Application.STARLING_ENABLED)
			{
				Application.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, onMouse);
				if (v)
					Application.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, onMouse);
			}
		}

		public function destroy():void
		{
			if (_state == StateEvent.GAME_BATTLE_INIT || _state == StateEvent.GAME_BATTLE || _state == StateEvent.GAME_BATTLE_CLEANUP)
			{
				removeUpKey(KeyboardKey.ONE.keyCode);
				removeUpKey(KeyboardKey.TWO.keyCode);
				removeUpKey(KeyboardKey.THREE.keyCode);
				removeUpKey(KeyboardKey.FOUR.keyCode);
				removeUpKey(KeyboardKey.FIVE.keyCode);
				removeUpKey(KeyboardKey.SIX.keyCode);
				removeUpKey(KeyboardKey.SEVEN.keyCode);
				removeUpKey(KeyboardKey.EIGHT.keyCode);
				removeUpKey(KeyboardKey.NINE.keyCode);
				removeUpKey(KeyboardKey.ZERO.keyCode);

				removeUpKey(KeyboardKey.F1.keyCode);
				removeUpKey(KeyboardKey.F2.keyCode);
				removeUpKey(KeyboardKey.F3.keyCode);
				removeUpKey(KeyboardKey.F4.keyCode);
				removeUpKey(KeyboardKey.F5.keyCode);
				removeUpKey(KeyboardKey.F6.keyCode);

				removeUpKey(KeyboardKey.A.keyCode);
				removeUpKey(KeyboardKey.D.keyCode);
				removeUpKey(KeyboardKey.DOWN.keyCode);
				removeUpKey(KeyboardKey.LEFT.keyCode);
				removeUpKey(KeyboardKey.RIGHT.keyCode);
				removeUpKey(KeyboardKey.Q.keyCode);
				removeUpKey(KeyboardKey.S.keyCode);
				removeUpKey(KeyboardKey.UP.keyCode);
				removeUpKey(KeyboardKey.W.keyCode);
				removeUpKey(KeyboardKey.F.keyCode);
				removeUpKey(KeyboardKey.G.keyCode);
				removeUpKey(KeyboardKey.T.keyCode);
				removeUpKey(KeyboardKey.R.keyCode);

				removeUpKey(KeyboardKey.ESCAPE.keyCode);
				removeDownKey(KeyboardKey.CONTROL.keyCode);
				removeUpKey(KeyboardKey.CONTROL.keyCode);
				removeDownKey(KeyboardKey.SHIFT.keyCode);
				removeUpKey(KeyboardKey.SHIFT.keyCode);
			} else if (_state == StateEvent.GAME_SECTOR_INIT || _state == StateEvent.GAME_SECTOR || _state == StateEvent.GAME_SECTOR_CLEANUP)
			{
				removeUpKey(KeyboardKey.A.keyCode);
				removeUpKey(KeyboardKey.D.keyCode);
				removeUpKey(KeyboardKey.LEFT.keyCode);
				removeUpKey(KeyboardKey.RIGHT.keyCode);
			} else
			{
				removeDownKey(KeyboardKey.SHIFT.keyCode);
				removeUpKey(KeyboardKey.SHIFT.keyCode);
				removeUpKey(KeyboardKey.ESCAPE.keyCode);
			}

			removeListeners();
			_interactSystem = null;
			_keyboardController = null;
			_layer = null;
			_notifyOnMove = false;
			_p1 = _p2 = null;
			_touches.length = 0;
			_touches = null;
		}
	}
}

