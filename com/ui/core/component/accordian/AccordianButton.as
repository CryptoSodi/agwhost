package com.ui.core.component.accordian
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.button.ButtonLabelFormat;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.osflash.signals.Signal;

	public class AccordianButton extends Sprite
	{
		public static const NORMAL:int        = 0;
		public static const LOCKED:int        = 1;
		public static const NOT_COMPLETED:int = 2;
		public static const COMPLETED:int     = 3;

		private var _actionSignal:Signal;
		private var _button:BitmapButton;
		private var _checkbox:BitmapButton;
		private var _data:*;
		private var _groupID:String;
		private var _height:Number;
		private var _id:String;
		private var _lock:Bitmap;
		private var _state:int;

		public function init( groupID:String, id:String, title:String, state:int, actionSignal:Signal, buttonType:String, width:Number, height:Number, data:* = null ):void
		{
			_actionSignal = actionSignal;
			_button = UIFactory.getButton(buttonType, width, height, 0, 0, title, id == null ? LabelEnum.TITLE : LabelEnum.SUBTITLE);
			_button.selectable = true;
			addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			addChild(_button);

			_data = data;
			_groupID = groupID;
			_height = height;
			_id = id;

			this.state = state;
		}

		private function onClick( e:MouseEvent ):void
		{
			if (!_lock)
				_actionSignal.dispatch(_groupID, _id, _data);
		}

		public function set labelFormat( v:ButtonLabelFormat ):void  { _button.labelFormat = v; }

		public function get id():String  { return _id; }

		override public function get height():Number  { return _height; }

		public function get selected():Boolean  { return _button.selected; }
		public function set selected( v:Boolean ):void  { _button.selected = v; }

		public function set state( v:int ):void
		{
			if (_checkbox && contains(_checkbox))
				removeChild(_checkbox);
			if (_lock && contains(_lock))
				removeChild(_lock);
			_state = v;
			switch (_state)
			{
				case NORMAL:
					_checkbox = UIFactory.destroyButton(_checkbox);
					_lock = UIFactory.destroyPanel(_lock);
					_button.enabled = true;
					break;
				case LOCKED:
					_checkbox = UIFactory.destroyButton(_checkbox);
					if (!_lock)
						_lock = UIFactory.getBitmap("IconLockMiniBMD");
					_lock.x = 18;
					_lock.y = 4.5;
					addChild(_lock);
					_button.enabled = false;
					break;
				case NOT_COMPLETED:
					_checkbox = UIFactory.destroyButton(_checkbox);
					if (!_checkbox)
						_checkbox = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 18, 4);
					_checkbox.enabled = true;
					_checkbox.enabled = _checkbox.selected = false;
					addChild(_checkbox);
					_lock = UIFactory.destroyPanel(_lock);
					_button.enabled = true;
					break;
				case COMPLETED:
					_checkbox = UIFactory.destroyButton(_checkbox);
					if (!_checkbox)
						_checkbox = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 18, 4);
					_checkbox.enabled = true;
					_checkbox.selected = true;
					_checkbox.enabled = false;
					addChild(_checkbox);
					_lock = UIFactory.destroyPanel(_lock);
					_button.enabled = true;
					break;
			}
		}

		public function get text():String  { if (_button) return _button.text;  else return ''; }
		public function set text( v:String ):void  { if (_button) _button.text = v; }

		public function destroy():void
		{
			x = y = 0;
			state = NORMAL;
			_actionSignal = null;
			removeEventListener(MouseEvent.CLICK, onClick);
			_button = UIFactory.destroyButton(_button);
			_data = null;
		}
	}
}
