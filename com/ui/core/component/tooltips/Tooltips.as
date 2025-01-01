package com.ui.core.component.tooltips
{
	import flash.utils.Dictionary;

	import org.parade.core.IViewStack;
	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class Tooltips
	{
		private static const TOOLTIP_SHOW_DELAY:int = 250;
		private static const DEFAULT_WIDTH:int      = 180;
		private static const DEFAULT_FONT_SIZE:int  = 18;

		private var _tooltips:Dictionary            = new Dictionary(true);

		[Inject]
		public var viewStack:IViewStack;

		public function addTooltip( target:*,
									parent:* = null,
									callback:Function = null,
									text:String = "",
									delay:int = TOOLTIP_SHOW_DELAY,
									width:Number = DEFAULT_WIDTH,
									fontSize:int = DEFAULT_FONT_SIZE,
									multiline:Boolean = false ):void
		{
			if (_tooltips.hasOwnProperty(target))
				return;

			var handler:TooltipHandler = ObjectPool.get(TooltipHandler);
			handler.init(viewStack.getLayer(ViewEnum.HOVER), target, callback, text, delay, width, fontSize, multiline);
			_tooltips[target] = handler;
			if (parent)
			{
				if (_tooltips[parent] == null)
					_tooltips[parent] = [];
				if (_tooltips[parent] is Array)
					_tooltips[parent].push(handler);
			}
		}

		public function removeTooltip( target:*, parent:* = null ):void
		{
			if (parent && _tooltips[parent] != null && _tooltips[parent] is Array)
			{
				var handlers:Array = _tooltips[parent];
				var handler:TooltipHandler;
				for (var i:int = 0; i < handlers.length; i++)
				{
					handler = handlers[i];
					if (_tooltips.hasOwnProperty(handler.target))
						delete _tooltips[handler.target];
					ObjectPool.give(handler);
				}
				_tooltips[parent] = null;
				delete _tooltips[parent];

			} else if (_tooltips[target])
			{
				ObjectPool.give(_tooltips[target]);
				_tooltips[target] = null;
				delete _tooltips[target];
			}
		}
	}
}
