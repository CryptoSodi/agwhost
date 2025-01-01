package com.ui.core.component.filterlist
{
	import com.ui.core.component.label.Label;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	
	public class FilterHeader extends Sprite
	{
		private var _text:Label;
		private var _bg:Bitmap;
		private var _index:int;
		private var _headerPadding:Number;
		private var _padding:Number;
		private var _filterBtns:Vector.<FilterButton>;
		
		public function FilterHeader( text:Label, bg:String, index:int, padding:Number, headerPadding:Number)
		{
			super();
			var filterHeaderBG:Class                     = Class(getDefinitionByName((bg)));
			
			_filterBtns = new Vector.<FilterButton>;
			
			_text = text;
			_index = index;
			_headerPadding = headerPadding;
			_padding = padding;
			
			_bg =  new Bitmap(BitmapData(new filterHeaderBG()));
			
			_text.x = _bg.x + (_bg.width - _text.width) * 0.5;
			_text.y = _bg.y + (_bg.height - _text.height) * 0.5;
			
			addChild(_bg);
			addChild(_text);
		}
		
		public function addFilter( filterBtn:FilterButton ):void
		{
			_filterBtns.push(filterBtn);
		}
		
		public function sortFilters( sort:Function ):void
		{
			_filterBtns.sort(sort);
		}
		
		public function get index():int { return _index; }
		public function get filterBtns():Vector.<FilterButton> { return _filterBtns; }
		public function get filterCount():uint { return _filterBtns.length; }
		public function get padding():Number { return _padding; }
		public function get headerPadding():Number { return _headerPadding; }
	}
}