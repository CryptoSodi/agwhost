package com.ui.core.component.pulldown
{
	import com.ui.core.component.label.Label;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	public class PullDownComponent extends Sprite
	{
		private var _displayName:Label;
		private var _data:PullDownData;

		public function PullDownComponent( width:Number, height:Number, fontSize:int )
		{
			_displayName = new Label(fontSize, 0x94beda, width, height);
			_displayName.align = TextFormatAlign.CENTER;
			_displayName.y += 2;
			addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);


			addChild(_displayName);
		}

		public function set data( data:PullDownData ):void
		{
			_data = data;
			_displayName.textColor = _data.fontColor;
			_displayName.text = _data.displayName;
		}

		public function set displayName( displayName:String ):void
		{
			_displayName.text = displayName;
		}

		private function onRollOut( e:MouseEvent ):void
		{
			if (_data != null)
				_displayName.textColor = _data.fontColor;
		}

		private function onRollOver( e:MouseEvent ):void
		{
			_displayName.textColor = 0xc9e6f6;
		}

		public function get displayName():String  { return _displayName.text; }

		public function set fontSize( fontSize:int ):void  { _displayName.fontSize = fontSize; }

		public function get data():PullDownData  { return _data; }

		public function get index():uint  { return _data.index; }

		public function destroy():void
		{
			removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
			removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
			_displayName.destroy();
			_displayName = null;
			_data = null;
		}
	}
}
