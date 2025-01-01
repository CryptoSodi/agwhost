package com.ui.core.component.label 
{
	import com.ui.core.component.label.Label;
	import flash.filters.ColorMatrixFilter;
	
	/**
	 *  @author Keita
	 * labs.hellokeita.com
	 */
	
	public class LabelColor 
	{
		
		private static const byteToPerc:Number = 1 / 0xff;
		
		private var _textField:Label;
		private var _textColor:uint;
		private var _selectedColor:uint;
		private var _selectionColor:uint;
		private var colorMatrixFilter:ColorMatrixFilter;
		
		public function LabelColor( textField:Label, textColor:uint = 0x000000, selectionColor:uint = 0x000000, selectedColor: uint = 0x000000 ) 
		{
			_textField = textField;
			
			colorMatrixFilter = new ColorMatrixFilter();
			_textColor = textColor;
			_selectionColor = selectionColor;
			_selectedColor = selectedColor;
			updateFilter();
		}
		
		public function set textField( tf:Label ):void 
		{
			_textField = tf;
		}
		public function get textField():Label 
		{
			return _textField;
		}
		public function set textColor( c:uint ):void 
		{
			_textColor = c;
			updateFilter();
		}
		public function get textColor():uint 
		{
			return _textColor;
		}
		public function set selectionColor( c:uint ):void 
		{
			_selectionColor = c;
			updateFilter();
		}
		public function get selectionColor():uint 
		{
			return _selectionColor;
		}
		public function set selectedColor( c:uint ):void 
		{
			_selectedColor = c;
			updateFilter();
		}
		public function get selectedColor():uint
		{
			return _selectedColor;
		}
		
		private function updateFilter():void 
		{
			
			_textField.textColor = 0xff0000;
			
			var o:Array = splitRGB(_selectionColor);
			var r:Array = splitRGB(_textColor);
			var g:Array = splitRGB(_selectedColor);
			
			var ro:int = o[0];
			var go:int = o[1];
			var bo:int = o[2];
			
			var rr:Number = ((r[0] - 0xff) - o[0]) * byteToPerc + 1;
			var rg:Number = ((r[1] - 0xff) - o[1]) * byteToPerc + 1;
			var rb:Number = ((r[2] - 0xff) - o[2]) * byteToPerc + 1;
			
			var gr:Number = ((g[0] - 0xff) - o[0]) * byteToPerc + 1 - rr;
			var gg:Number = ((g[1] - 0xff) - o[1]) * byteToPerc + 1 - rg;
			var gb:Number = ((g[2] - 0xff) - o[2]) * byteToPerc + 1 - rb;
			
			colorMatrixFilter.matrix = [rr, gr, 0, 0, ro, rg, gg, 0, 0, go, rb, gb, 0, 0, bo, 0, 0, 0, 1, 0];
			
			_textField.filters = [colorMatrixFilter];
			
		}
		
		private static function splitRGB( color:uint ):Array 
		{
			return [color >> 16 & 0xff, color >> 8 & 0xff, color & 0xff];
		}
	}
}