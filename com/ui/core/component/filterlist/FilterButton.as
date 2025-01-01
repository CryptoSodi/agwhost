package com.ui.core.component.filterlist
{
	import com.ui.core.component.button.BitmapButton;

	import flash.display.Sprite;

	public class FilterButton extends Sprite
	{
		private var _btn:BitmapButton;
		private var _filter:*;
		private var _index:int;
		private var _padding:Number;

		public function FilterButton( filter:*, index:int, btn:BitmapButton, padding:Number )
		{
			_filter = filter
			_index = index;
			_btn = btn;
			_padding = padding;
			_btn.selectable = true;

			addChild(_btn);
		}

		override public function get height():Number
		{
			return _btn.height;
		}

		override public function get width():Number
		{
			return _btn.width;
		}
		
		public function get filter():* { return _filter; }
		public function get index():int { return _index; }
		public function get padding():Number { return _padding; }
		
		public function set selected( value:Boolean ):void { _btn.selected = value; }
		public function get selected():Boolean { return _btn.selected; }
		
		public function set enabled( value:Boolean ):void { _btn.enabled = value; }
		public function get enabled():Boolean { return _btn.enabled; }
		
		public function destroy():void
		{
			_btn.destroy();
		}
	}
}
