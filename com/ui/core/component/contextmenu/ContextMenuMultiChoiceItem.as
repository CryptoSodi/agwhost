package com.ui.core.component.contextmenu
{
	import com.enum.ui.ButtonEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import org.osflash.signals.Signal;

	public class ContextMenuMultiChoiceItem extends Sprite implements IContextMenuItem
	{
		public var onSelectionClicked:Signal;
		public var onSelectedIndexUpdated:Signal;

		private var _btn:BitmapButton;
		private var _arrowLeft:BitmapButton;
		private var _arrowRight:BitmapButton;

		private var _data:Vector.<ContextMenuItemData>;

		private var _heldShift:uint;

		private var _selectedIndex:int;
		private var _heldCount:int;

		private var _heldTime:Number;

		private var _positive:Boolean;

		private var _indexChanged:Function;

		private var _timer:Timer;

		public function ContextMenuMultiChoiceItem( category:String, startingIndex:uint, indexChanged:Function, heldShift:uint, heldTime:Number )
		{
			onSelectionClicked = new Signal(Function, Array);
			onSelectedIndexUpdated = new Signal(Function, int);

			_data = new Vector.<ContextMenuItemData>;

			_selectedIndex = startingIndex;
			_heldShift = heldShift;
			_heldTime = heldTime;
			_indexChanged = indexChanged;

			_timer = new Timer(heldTime);
			_timer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);

			_arrowLeft = UIFactory.getButton(ButtonEnum.BACK_ARROW);
			_arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onShiftLeft, false, 0, true);
			_arrowLeft.addEventListener(MouseEvent.CLICK, onEndTimer, false, 0, true);

			_arrowRight = UIFactory.getButton(ButtonEnum.FORWARD_ARROW);
			_arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onShiftRight, false, 0, true);
			_arrowRight.addEventListener(MouseEvent.CLICK, onEndTimer, false, 0, true);

			_btn = UIFactory.getButton(ButtonEnum.BLUE_A, 129, 25);
			_btn.labelFormat = null;
			_btn.addEventListener(MouseEvent.MOUSE_DOWN, onKillMouseDown, false, 1, true);
			_btn.addEventListener(MouseEvent.CLICK, onBtnClick, false, 1, true);

			_btn.x = _arrowLeft.width + 3;

			_arrowLeft.y = _btn.y + (_btn.height - _arrowLeft.height) * 0.5;
			_arrowLeft.visible = false;

			_arrowRight.x = _btn.x + _btn.width + 3;
			_arrowRight.y = _btn.y + (_btn.height - _arrowRight.height) * 0.5;
			_arrowRight.visible = false;

			addChild(_btn);
			addChild(_arrowLeft);
			addChild(_arrowRight);
		}

		public function addChoiceItem( displayName:String, callback:Function, args:Array, isEnabled:Boolean, tooltip:String, color:uint = 0xffffff ):void
		{
			var data:ContextMenuItemData = new ContextMenuItemData(displayName, callback, args, isEnabled, tooltip, color)
			_data.push(data);

			if ((_data.length - 1) == _selectedIndex && _btn != null)
			{
				_btn.text = displayName;
				_btn.textColor = color;
				_btn.enabled = isEnabled;
			}

			if (!_arrowRight.visible && _data.length > 1)
				_arrowRight.visible = true;

			if (!_arrowLeft.visible && _data.length > 1)
				_arrowLeft.visible = true;
		}

		public function get tooltip():String  { return (_selectedIndex < _data.length) ? _data[_selectedIndex].tooltip : ''; }


		private function onBtnClick( e:MouseEvent ):void
		{
			if ((_selectedIndex < _data.length))
			{
				var data:ContextMenuItemData = _data[_selectedIndex];
				e.stopPropagation();
				if (data.callback != null)
					onSelectionClicked.dispatch(data.callback, data.args);
			}
		}

		private function onShiftLeft( e:MouseEvent ):void
		{
			updateSelectedIndex(_selectedIndex - 1);

			_positive = false;
			_heldCount = Math.floor(_selectedIndex / _heldShift) - 1;
			_timer.start();
		}

		private function onShiftRight( e:MouseEvent ):void
		{
			updateSelectedIndex(_selectedIndex + 1);

			_positive = true;
			_heldCount = Math.floor(_selectedIndex / _heldShift) + 1;
			_timer.start();
		}

		private function onTimerTick( e:TimerEvent ):void
		{
			var len:uint      = _data.length;
			var maxCount:uint = len / _heldShift;

			if (_heldCount > maxCount)
				_heldCount = 0;
			else if (_heldCount < 0)
				_heldCount = maxCount;

			updateSelectedIndex(_heldShift * _heldCount)

			if (_positive)
				++_heldCount;
			else
				--_heldCount;
		}

		private function onEndTimer( e:MouseEvent ):void
		{
			_heldCount = 0;
			_timer.stop();
			_timer.reset();
		}

		private function onKillMouseDown( e:MouseEvent ):void
		{
			e.stopPropagation();
		}

		private function updateSelectedIndex( index:uint ):void
		{
			_selectedIndex = index;
			var max:uint = _data.length - 1;
			if (_selectedIndex > max)
				_selectedIndex = 0;
			else if (_selectedIndex < 0)
				_selectedIndex = max;

			_btn.text = _data[_selectedIndex].displayName;

			if (_indexChanged != null)
				onSelectedIndexUpdated.dispatch(_indexChanged, _selectedIndex);
		}

		public function destroy():void
		{
			if (onSelectionClicked)
				onSelectionClicked.removeAll();

			onSelectionClicked = null;

			if (onSelectedIndexUpdated)
				onSelectedIndexUpdated.removeAll();

			onSelectedIndexUpdated = null;

			if (_timer)
			{
				if (_timer.running)
					_timer.stop();

				_timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
			}

			_timer = null;

			if (_btn)
			{
				_btn.removeEventListener(MouseEvent.MOUSE_DOWN, onKillMouseDown);
				_btn.removeEventListener(MouseEvent.MOUSE_UP, onBtnClick);
				_btn.destroy();
			}
			_btn = null;

			if (_arrowLeft)
			{
				_arrowLeft.removeEventListener(MouseEvent.MOUSE_UP, onShiftLeft);
				_arrowLeft.removeEventListener(MouseEvent.CLICK, onEndTimer);
				_arrowLeft.destroy();
			}
			_arrowLeft = null;

			if (_arrowRight)
			{
				_arrowRight.removeEventListener(MouseEvent.MOUSE_UP, onShiftRight);
				_arrowRight.removeEventListener(MouseEvent.CLICK, onEndTimer);
				_arrowRight.destroy();
			}
			_arrowRight = null;

			_data.length = 0;
		}
	}
}
