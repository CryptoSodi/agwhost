package com.ui.core.component.button
{
	public class ButtonLabelFormat
	{
		private var _disabledBold:Boolean;
		private var _disabledColor:uint;
		
		private var _downBold:Boolean;
		private var _downColor:uint;
		
		private var _roBold:Boolean;
		private var _roColor:uint;
		
		private var _selectedBold:Boolean;
		private var _selectedColor:uint;
		
		private var _upBold:Boolean;
		private var _upColor:uint;
		
		public function ButtonLabelFormat( data:Object )
		{
			_upBold = data.upBold;
			_upColor = data.upColor;
			
			var a:Array = ["disabled", "down", "ro", "selected"];
			for (var i:int = 0; i < a.length; i++) 
			{
				this["_" + a[i] + "Bold"] = (data[a[i] + "Bold"]) != null ? (data[a[i] + "Bold"]) : _upBold;
				this["_" + a[i] + "Color"] = (data[a[i] + "Color"]) != null ? (data[a[i] + "Color"]) : _upColor;
			}
		}
		
		public function get disabledBold():Boolean { return _disabledBold; }
		public function get disabledColor():uint { return _disabledColor; }
		
		public function get downBold():Boolean { return _downBold; }
		public function get downColor():uint { return _downColor; }
		
		public function get roBold():Boolean { return _roBold; }
		public function get roColor():uint { return _roColor; }
		
		public function get selectedBold():Boolean { return _selectedBold; }
		public function get selectedColor():uint { return _selectedColor; }
		
		public function get upBold():Boolean { return _upBold; }
		public function get upColor():uint { return _upColor; }
	}
}