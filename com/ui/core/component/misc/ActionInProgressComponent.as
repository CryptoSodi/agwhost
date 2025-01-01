package com.ui.core.component.misc
{
	import com.enum.ui.ButtonEnum;
	import com.ui.UIFactory;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	public class ActionInProgressComponent extends Sprite implements IComponent
	{
		private var _cancelBtn:BitmapButton;
		private var _speedUpBtn:BitmapButton;

		private var _cancelBtnProto:ButtonPrototype;
		private var _speedUpBtnProto:ButtonPrototype;

		private var _timeRemainingBG:Bitmap;

		private var _timeRemaining:Label;

		private var _enabled:Boolean;

		private var _pendingText:String = 'CodeString.Shared.Pending';

		public function ActionInProgressComponent( cancelButton:ButtonPrototype, speedUpButton:ButtonPrototype, timeRemaining:int = 0 )
		{
			super();

			var timeRemainingBGClass:Class = Class(getDefinitionByName('BuildRepairTimerBGBMD'));

			_cancelBtnProto = cancelButton;
			_speedUpBtnProto = speedUpButton;

			_speedUpBtn = UIFactory.getButton(ButtonEnum.GOLD_A, 126, 55, 0, 0, _speedUpBtnProto.text);
			_speedUpBtn.label.y += 4;
			_speedUpBtn.addEventListener(MouseEvent.CLICK, _speedUpBtnProto.callback, false, 0, true);

			_cancelBtn = UIFactory.getButton(ButtonEnum.RED_A, 134, 29, _speedUpBtn.width + 5, 27, _cancelBtnProto.text);

			if (_cancelBtnProto.callback != null)
				_cancelBtn.addEventListener(MouseEvent.CLICK, _cancelBtnProto.callback, false, 0, true);

			_timeRemainingBG = UIFactory.getScaleBitmap('InputBoxBMD');
			_timeRemainingBG.width = 134;
			_timeRemainingBG.height = 23;
			_timeRemainingBG.y = 1;
			_timeRemainingBG.x = _speedUpBtn.width + 5;

			_timeRemaining = new Label(16, 0xffffff, _timeRemainingBG.width, _timeRemainingBG.height);
			_timeRemaining.align = TextFormatAlign.CENTER;
			_timeRemaining.x = _timeRemainingBG.x;
			_timeRemaining.y = _timeRemainingBG.y;
			_timeRemaining.setBuildTime(timeRemaining);

			addChild(_cancelBtn);
			addChild(_speedUpBtn);

			addChild(_timeRemainingBG);
			addChild(_timeRemaining);
		}

		public function addCancelBtnCallback( callback:Function ):void
		{
			_cancelBtn.addEventListener(MouseEvent.CLICK, callback, false, 0, true);
		}

		public function set timeRemaining( time:int ):void
		{
			_cancelBtn.enabled = time > 0;
			_speedUpBtn.enabled = time > 0;
			if (time > 0)
			{
				_cancelBtn.filters = []
				_speedUpBtn.filters = [];
			} else
			{
				_cancelBtn.filters = [CommonFunctionUtil.getGreyScaleFilter()];
				_speedUpBtn.filters = [CommonFunctionUtil.getGreyScaleFilter()];
			}
			if (time < 0)
				_timeRemaining.text = _pendingText;
			else
				_timeRemaining.setBuildTime(time / 1000);
		}

		public function set enabled( value:Boolean ):void
		{
			_enabled = value;
			_cancelBtn.enabled = _enabled;
			_speedUpBtn.enabled = _enabled;
		}

		public function get enabled():Boolean  { return _enabled; }

		public function destroy():void
		{
			if (_cancelBtnProto.callback != null)
				_cancelBtn.removeEventListener(MouseEvent.CLICK, _cancelBtnProto.callback);

			_cancelBtn.destroy();
			_cancelBtn = null;
			_cancelBtnProto = null;

			if (_speedUpBtnProto.callback != null)
				_speedUpBtn.removeEventListener(MouseEvent.CLICK, _speedUpBtnProto.callback);

			_speedUpBtn.destroy();
			_speedUpBtn = null;
			_speedUpBtnProto = null;

			_timeRemaining.destroy();
			_timeRemaining = null;

			_timeRemainingBG = null;
		}

	}
}
