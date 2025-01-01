package com.ui.core.effects
{
	import com.Application;
	import com.enum.PositionEnum;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.setTimeout;

	import org.parade.core.IView;

	public class StageRepositionEffect extends Effect
	{
		public static const NAME:String = "stageRepositionEffect";

		private var _callback:Function;
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _positionX:String;
		private var _positionY:String;
		private var _screen:IView;
		private var _stage:Stage;

		public function init( positionX:String, positionY:String, callback:Function = null, screenX:Number = 0, screenY:Number = 0 ):void
		{
			_callback = callback;
			_positionX = positionX;
			_positionY = positionY;
			_offsetX = screenX;
			_offsetY = screenY;
		}

		override internal function goIn( screen:IView ):void
		{
			super.goIn(screen);
			_screen = screen;
			_stage = Application.STAGE;
			_stage.removeEventListener(Event.RESIZE, resize);
			_stage.addEventListener(Event.RESIZE, resize, false, 0, true);
			setTimeout(getOffsets, 50);
			doneIn();
		}

		override internal function goOut( screen:IView ):void
		{
			super.goOut(screen);
			_stage.removeEventListener(Event.RESIZE, resize);
			doneOut();
		}

		protected function getOffsets():void
		{
			// @todo TK 1/31/13 Temporary hack fix to guard against null _screen
			if (!_screen)
				return;

			var x:Number = (_offsetX != 0) ? _offsetX : _screen.x;
			var y:Number = (_offsetY != 0) ? _offsetY : _screen.y;
			switch (_positionX)
			{
				case PositionEnum.LEFT:
					_offsetX = x;
					break;
				case PositionEnum.CENTER:
					_offsetX = x - (_stage.stageWidth / 2);
					break;
				default:
					_offsetX = _stage.stageWidth - x;
					break;
			}

			switch (_positionY)
			{
				case PositionEnum.TOP:
					_offsetY = y;
					break;
				case PositionEnum.CENTER:
					_offsetY = y - (_stage.stageHeight / 2);
					break;
				default:
					_offsetY = _stage.stageHeight - y;
					break;
			}
		}

		protected function resize( e:Event = null ):void
		{
			switch (_positionX)
			{
				case PositionEnum.LEFT:
					_screen.x = 0 + _offsetX;
					break;
				case PositionEnum.CENTER:
					_screen.x = (_stage.stageWidth / 2) + _offsetX;
					break;
				default:
					_screen.x = _stage.stageWidth - _offsetX;
					break;
			}

			switch (_positionY)
			{
				case PositionEnum.TOP:
					_screen.y = 0 + _offsetY;
					break;
				case PositionEnum.CENTER:
					_screen.y = (_stage.stageHeight / 2) + _offsetY;
					break;
				default:
					_screen.y = _stage.stageHeight - _offsetY;
					break;
			}
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
