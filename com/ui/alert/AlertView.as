package com.ui.alert
{
	import com.controller.keyboard.KeyboardKey;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.parade.enum.ViewEnum;

	public class AlertView extends View
	{
		protected var _bg:Sprite;
		protected var _closeBtn:BitmapButton;
		protected var _closeCallback:Function;

		protected var _viewName:Label;
		protected var _bodyText:Label;

		protected var _btnOne:BitmapButton;
		protected var _btnOneArgs:Array;
		protected var _btnOneCallback:Function;

		protected var _btnTwo:BitmapButton;
		protected var _btnTwoArgs:Array;
		protected var _btnTwoCallback:Function;

		protected var _MAX_WIDTH:int = 300;

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_closeBtn = ButtonFactory.getCloseButton(0, 0);
			_closeBtn.scaleX = _closeBtn.scaleY = .75;
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			_keyboard.addKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);

			layout();

			addEffects();
			effectsIN();
		}

		public function setUp( args:Array ):void
		{
			var btnOneText:String = args[2];
			var btnTwoText:String = args[5];
			_btnOneArgs = new Array();
			_btnTwoArgs = new Array();

			var windowBG:Class    = Class(getDefinitionByName(('WindowContextMenuMC')));
			_bg = Sprite(new windowBG());
			addChild(_bg);

			_viewName = new Label(18, 0xffffff, _bg.width - 60, 30);
			_viewName.align = TextFormatAlign.LEFT;
			_viewName.text = args[0];
			addChild(_viewName);

			_bodyText = new Label(18, 0xffffff);
			_bodyText.x = 25;
			_bodyText.align = TextFormatAlign.CENTER;
			_bodyText.constrictTextToSize = false;
			_bodyText.multiline = true;
			_bodyText.htmlText = args[1];
			_bodyText.setSize(_bg.width - 60, _bodyText.textHeight);
			addChild(_bodyText);

			if (btnOneText != '' && btnOneText != null)
			{
				_btnOne = ButtonFactory.getBitmapButton('LeftBtnUpBMD', 0, 0, btnOneText, 0xFFFFFF, 'LeftBtnRollOverBMD', 'LeftBtnDownBMD', 'LeftBtnDownBMD', null, 10);
				_btnOne.addEventListener(MouseEvent.CLICK, onBtnOneClick, false, 0, true);
				_btnOneCallback = args[3];
				_btnOneArgs = args[4];
				addChild(_btnOne);
			}

			if (btnTwoText != '' && btnTwoText != null)
			{
				_btnTwo = ButtonFactory.getBitmapButton('RightBtnUpBMD', 0, 0, btnTwoText, 0xFFFFFF, 'RightBtnRollOverBMD', 'RightBtnDownBMD', 'RightBtnDownBMD', null, 10);
				_btnTwo.addEventListener(MouseEvent.CLICK, onBtnTwoClick, false, 0, true);
				_btnTwoCallback = args[6];
				_btnTwoArgs = args[7];
				addChild(_btnTwo);
			}

			if (args[8])
				_closeCallback = btnTwoPress;
			else
				_closeCallback = btnOnePress;
		}

		protected function onEnterPress( keyCode:uint ):void
		{
		}

		protected function layout():void
		{
			_viewName.x = 28;
			_viewName.y = 14;

			_closeBtn.x = _bg.width - 33;
			_closeBtn.y = _viewName.y + 5;

			_bodyText.y = _viewName.y + _viewName.height + 20;

			var height:Number;
			if (_btnOne != null)
			{
				_btnOne.x = 30;
				_btnOne.y = _bg.height - 60;
				height = _btnOne.y + _btnOne.height + 5
			} else
				height = _bodyText.y + _bodyText.height + 5

			if (_btnTwo != null)
			{
				_btnTwo.x = _bg.width - (_btnTwo.width + 20);
				_btnTwo.y = _bg.height - 60;
			} else if (_btnOne)
				_btnOne.x = (_bg.width - _btnOne.width) / 2;
			addChild(_closeBtn);
		}

		protected function onBtnOneClick( e:MouseEvent ):void
		{
			btnOnePress();
			destroy();
		}

		protected function btnOnePress():void
		{
			if (_btnOneCallback != null)
			{
				if (_btnOneArgs != null)
					_btnOneCallback(_btnOneArgs);
				else
					_btnOneCallback();
			}
		}

		protected function onBtnTwoClick( e:MouseEvent ):void
		{
			btnTwoPress();
			destroy();
		}

		protected function btnTwoPress():void
		{
			if (_btnTwoCallback != null)
			{
				if (_btnTwoArgs != null)
					_btnTwoCallback(_btnTwoArgs);
				else
					_btnTwoCallback();
			}
		}

		override protected function onClose( e:MouseEvent = null ):void
		{
			if (_closeCallback != null)
				_closeCallback();
			super.onClose(e);
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function get type():String  { return ViewEnum.ALERT; }
		override public function get typeUnique():Boolean  { return true; }

		override public function destroy():void
		{

			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;
			_closeCallback = null;

			if (_btnOne)
			{
				_btnOne.removeEventListener(MouseEvent.CLICK, onBtnOneClick);
				_btnOne.destroy();
				_btnOne = null;
			}

			if (_btnTwo)
			{
				_btnTwo.removeEventListener(MouseEvent.CLICK, onBtnTwoClick);
				_btnTwo.destroy();
				_btnTwo = null;
			}

			_viewName.destroy();
			_viewName = null;

			_bodyText.destroy();
			_bodyText = null;

			_keyboard.removeKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);
			super.destroy()
		}
	}
}
