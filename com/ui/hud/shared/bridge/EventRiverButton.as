package com.ui.hud.shared.bridge
{
	import com.enum.ui.ButtonEnum;
	import com.model.event.EventVO;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	import org.osflash.signals.Signal;

	public class EventRiverButton extends Sprite
	{
		public var onClick:Signal;
		public var onUpdated:Signal;

		private var _eventIcon:Bitmap;
		private var _eventBtn:BitmapButton;
		private var _btnText:Label;

		private var _eventTimeRemaining:Label;

		private var _timer:Timer;

		private var _currentEvent:EventVO;

		private var _eventText:String         = 'CodeString.EventRiver.IncursionEvent'; //INCURSION
		private var _eventUpcomingText:String = 'CodeString.EventRiver.StartIncursionEvent'; //INCURSION STARTS

		public function EventRiverButton()
		{
			onClick = new Signal();
			onUpdated = new Signal();

			_eventIcon = UIFactory.getBitmap('IconEventBMD');

			_eventBtn = UIFactory.getButton(ButtonEnum.ICON_FRAME, 60, 60);
			_eventBtn.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);

			_btnText = new Label(20, 0xd1e5f7, 100);
			_btnText.constrictTextToSize = false;
			_btnText.autoSize = TextFieldAutoSize.CENTER;
			_btnText.align = TextFormatAlign.CENTER;
			_btnText.multiline = true;
			_btnText.text = _eventText;

			_eventTimeRemaining = new Label(14, 0xd1e5f7, 150, 25);
			_eventTimeRemaining.constrictTextToSize = false;
			_eventTimeRemaining.align = TextFormatAlign.CENTER;

			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);

			addChild(_eventBtn);
			addChild(_eventIcon);
			addChild(_btnText);
			addChild(_eventTimeRemaining);

			layout();
		}

		public function updatedEvents( currentActiveEvent:EventVO, activeEvents:Vector.<EventVO>, upcomingEvents:Vector.<EventVO> ):void
		{
			var active:Boolean;
			_currentEvent = currentActiveEvent;

			if (_currentEvent)
			{
				active = (activeEvents.indexOf(_currentEvent) != -1);

				_btnText.text = (active) ? _eventText : _eventUpcomingText;
				visible = true;
				_timer.start();

				onUpdated.dispatch();

			} else
			{
				_btnText.text = _eventText;
				visible = false;
				if (_timer)
					_timer.stop();

				onUpdated.dispatch();
			}

			layout();
		}

		private function onTimerTick( e:TimerEvent ):void
		{
			if (_currentEvent == null)
			{
				if (_timer)
					_timer.stop();

				return;
			}
			var timeRemaining:Number = _currentEvent.timeRemainingMS;

			if (timeRemaining <= 0)
			{
				_timer.stop();
				_currentEvent = null;
			} else
			{
				if (_eventTimeRemaining)
					_eventTimeRemaining.setBuildTime(timeRemaining / 1000);
			}
		}

		private function onMouseClick( e:MouseEvent ):void
		{
			if (onClick)
				onClick.dispatch();
			e.stopPropagation();
		}

		public function uiTracked():Boolean
		{
			if (_currentEvent)
				return _currentEvent.isUiTracking;

			return false;
		}

		public function hasScore():Boolean
		{
			if (_currentEvent)
				return _currentEvent.hasScore;

			return false;
		}

		private function layout():void
		{
			_eventIcon.x = _eventBtn.x + (_eventBtn.defaultSkinWidth - _eventIcon.width) * 0.5;
			_eventIcon.y = _eventBtn.y + (_eventBtn.defaultSkinHeight - _eventIcon.height) * 0.5;

			_btnText.x = _eventBtn.x + (_eventBtn.width - _btnText.width) * 0.5;
			_btnText.y = _eventBtn.height - 1;

			_eventTimeRemaining.x = _eventBtn.x + (_eventBtn.width - _eventTimeRemaining.width) * 0.5;
			_eventTimeRemaining.y = _btnText.y + _btnText.textHeight;
		}

		override public function get height():Number
		{
			if (_eventTimeRemaining.visible)
				return (_eventTimeRemaining.y + _eventTimeRemaining.height);
			else
				return (_btnText.y + _btnText.height);
		}

		public function destroy():void
		{
			if (onClick)
				onClick.removeAll();

			onClick = null;

			if (onUpdated)
				onUpdated.removeAll();

			onUpdated = null;

			if (_eventBtn)
			{
				_eventBtn.removeEventListener(MouseEvent.CLICK, onMouseClick);
				_eventBtn.destroy();
			}

			_eventBtn = null;

			if (_timer)
			{
				_timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
				if (_timer.running)
					_timer.stop();
			}
			_timer = null;

			if (_eventTimeRemaining)
				_eventTimeRemaining.destroy();

			_eventTimeRemaining = null;

			if (_btnText)
				_btnText.destroy();

			_btnText = null;

			_eventIcon = null;
		}
	}
}

