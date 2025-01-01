package com.ui.core.component.pulldown
{
	public class PullDownData
	{
		private var _displayName:String;
		private var _index:uint;
		private var _fontColor:uint;
		private var _returnParams:Array;
		public function PullDownData()
		{
			_fontColor = 0xffffff;
			_returnParams = new Array();
		}
		
		public function set returnParams( returnParams:Array ):void {_returnParams = returnParams;}
		public function get returnParams():Array {return _returnParams;}
		public function set fontColor( fontColor:uint ):void {_fontColor = fontColor;}
		public function get fontColor():uint {return _fontColor;}
		public function set index( index:uint ):void {_index = index;}
		public function get index():uint {return _index;}
		public function set displayName( displayName:String ):void {_displayName = displayName;}
		public function get displayName():String {return _displayName;}
		
	}
}