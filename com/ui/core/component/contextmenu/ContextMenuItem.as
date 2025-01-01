package com.ui.core.component.contextmenu
{
	import com.enum.ui.ButtonEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.modal.ButtonFactory;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.osflash.signals.Signal;

	public class ContextMenuItem extends Sprite implements IContextMenuItem
	{
		public var onSelectionClicked:Signal;

		private var _btn:BitmapButton;
		private var _data:ContextMenuItemData;

		public function ContextMenuItem( displayName:String, callback:Function, args:Array, isEnabled:Boolean, tooltip:String, color:uint = 0xffffff )
		{
			onSelectionClicked = new Signal(Function, Array);

			_data = new ContextMenuItemData(displayName, callback, args, isEnabled, tooltip, color);

			_btn = UIFactory.getButton(ButtonEnum.BLUE_A, 129, 25, 0, 0, displayName);
			_btn.labelFormat = null;
			_btn.textColor = color;
			_btn.enabled = isEnabled;
			_btn.addEventListener(MouseEvent.MOUSE_DOWN, onKillMouseDown, false, 1, true);
			_btn.addEventListener(MouseEvent.CLICK, onBtnClick, false, 1, true);
			addChild(_btn);
		}

		public function get tooltip():String  { return _data.tooltip; }

		private function onBtnClick( e:MouseEvent ):void
		{
			e.stopPropagation();
			if (_data.callback != null)
				onSelectionClicked.dispatch(_data.callback, _data.args);
		}

		private function onKillMouseDown( e:MouseEvent ):void
		{
			e.stopPropagation();
		}

		public function destroy():void
		{
			onSelectionClicked.removeAll();
			onSelectionClicked = null;

			if (_btn)
			{
				_btn.removeEventListener(MouseEvent.MOUSE_DOWN, onKillMouseDown);
				_btn.removeEventListener(MouseEvent.MOUSE_UP, onBtnClick);
				_btn.destroy();
			}
			_btn = null;


			_data = null;
		}
	}
}
