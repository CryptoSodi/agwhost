package com.ui.core.component.contextmenu
{
	public class ContextMenuItemData
	{
		private var _displayName:String
		private var _callback:Function;
		private var _args:Array;
		private var _isEnabled:Boolean;
		private var _tooltip:String
		private var _color:uint;

		public function ContextMenuItemData( displayName:String, callback:Function, args:Array, isEnabled:Boolean, tooltip:String, color:uint = 0xffffff )
		{
			_displayName = displayName;
			_callback = callback;
			_args = args;
			_isEnabled = isEnabled;
			_tooltip = tooltip;
			_color = color;
		}

		public function get displayName():String  { return _displayName; }
		public function get callback():Function  { return _callback; }
		public function get args():Array  { return _args; }
		public function get isEnabled():Boolean  { return _isEnabled; }
		public function get tooltip():String  { return _tooltip; }
		public function get color():uint  { return _color; }
	}
}
