package com.ui.core.component.tooltips
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.shared.ObjectPool;

	public class TooltipHandler
	{
		private const logger:ILogger = getLogger('display.core.component.tooltips');

		private var _callback:Function;
		private var _layer:Sprite;
		private var _showTimer:Timer;
		private var _target:InteractiveObject;
		private var _text:String;
		private var _tip:Tooltip;
		private var _width:Number;
		private var _fontSize:int;
		private var _multiline:Boolean;

		public function init( layer:Sprite, target:InteractiveObject, callback:Function = null, text:String = null, delay:int = 500, width:Number = 200, fontSize:int = 18, multiline:Boolean = false ):void
		{
			_layer = layer;
			_target = target;
			_target.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			_target.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
			_target.addEventListener(MouseEvent.MOUSE_DOWN, onMouseOut, false, 0, true);
			if (!_showTimer)
			{
				_showTimer = new Timer(500, 1);
				_showTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showTooltip);
			}
			_showTimer.delay = delay;
			_callback = callback;
			_text = text;
			_width = width;
			_fontSize = fontSize;
			_multiline = multiline;
		}

		private function onMouseOver( e:MouseEvent ):void
		{
			_showTimer.start();
		}

		private function onMouseOut( e:MouseEvent = null ):void
		{
			if (_showTimer)
				_showTimer.reset();

			if (_tip)
			{
				ObjectPool.give(_tip);
				_tip = null;
			}
		}

		private function showTooltip( e:TimerEvent ):void
		{
			/*try
			   {*/
			var str:String;
			if (_callback != null)
			{
				//				str = _callback();
				str = _callback.apply(_target);
			}

			else if (_text)
				str = _text;

			if (str && str != "")
			{
				_tip = ObjectPool.get(Tooltip);
				_tip.init(_layer, str, _width, _fontSize, _multiline);
			}
		/*} catch ( e:Error )
		   {
		   logger.error("Tooltip failed to initialize.")
		   }*/

		}

		public function get target():*  { return _target; }

		public function destroy():void
		{
			onMouseOut();
			if (_target)
			{
				_target.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				_target.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				_target.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseOut);
				_showTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, showTooltip);
				_layer = null;
				_target = null;
				_callback = null;
				_showTimer = null;
			}
		}
	}
}
