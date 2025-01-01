package com.ui.alert
{
	import com.Application;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.adobe.utils.StringUtil;

	public class InputAlertView extends AlertView
	{
		private var _inputBG:Sprite;
		private var _inputText:Label;

		private var _onCloseUseBtnTwo:Boolean;

		override public function setUp( args:Array ):void
		{

			var restrict:String    = args[12];
			var frameBGClass:Class = Class(getDefinitionByName(('TextInputFieldMC')));
			_inputBG = Sprite(new frameBGClass());

			_inputText = new Label(20, 0xffffff, 200, 25);
			_inputText.constrictTextToSize = false;
			_inputText.letterSpacing = .8;
			_inputText.align = TextFormatAlign.LEFT;
			_inputText.addLabelColor(0xbdfefd, 0x000000);
			_inputText.maxChars = args[9];
			_inputText.text = args[10];
			_inputText.allowInput = true;
			_inputText.clearOnFocusIn = args[11];
			if (restrict != '')
				_inputText.restrict = restrict;
			_inputText.addEventListener(Event.CHANGE, onTextChanged, false, 0, true);
			_onCloseUseBtnTwo = args[8];

			super.setUp(args);
			addChild(_inputBG);
			addChild(_inputText);
		}

		override protected function layout():void
		{
			super.layout();

			var height:Number;
			if (_btnOne != null)
			{
				if (_btnTwo == null)
					_btnOne.x = 150;
				else
					_btnOne.x = 30;

				_btnOne.y = _bg.height - 60;
				height = _btnOne.y + _btnOne.height + 10
			} else
				height = _inputBG.y + _inputBG.height + 10

			if (_btnTwo != null)
			{
				_btnTwo.x = _bg.width - (_btnTwo.width + 20);
				_btnTwo.y = _bg.height - 60;
			}

			_inputBG.x = 20;
			_inputBG.y = _btnOne.y - _inputBG.height - 10;

			_inputText.width = _inputBG.width - 40;
			_inputText.x = _inputBG.x + 15;
			_inputText.y = _inputBG.y + 2;

			_bodyText.setSize(_bg.width - 40, _inputBG.y - (_viewName.y + _viewName.height));

			Application.STAGE.focus = _inputText;
			_inputText.setSelection(0, _inputText.length);
		}

		private function onTextChanged( e:Event ):void
		{
			var currentTextLen:uint = e.currentTarget.length;
			var btnToUse:BitmapButton;
			var btnFunctionToUse:Function;
			if (!_onCloseUseBtnTwo)
			{
				btnToUse = _btnOne;
				btnFunctionToUse = onBtnOneClick;
			} else
			{
				btnToUse = _btnTwo;
				btnFunctionToUse = onBtnTwoClick;
			}

			if (currentTextLen != 0 && !btnToUse.enabled)
			{
				btnToUse.enabled = true;
				btnToUse.addEventListener(MouseEvent.CLICK, btnFunctionToUse, false, 0, true);
			} else if (currentTextLen == 0 && btnToUse.enabled == true)
			{
				btnToUse.enabled = false;
				btnToUse.removeEventListener(MouseEvent.CLICK, btnFunctionToUse);
			}
		}

		override protected function onEnterPress( keyCode:uint ):void
		{
			onClose(null);
		}

		override protected function btnOnePress():void
		{
			var text:String = StringUtil.escapeHTML(_inputText.text);
			_btnOneArgs = new Array(text);
			super.btnOnePress();
		}

		override protected function btnTwoPress():void
		{
			var text:String = StringUtil.escapeHTML(_inputText.text);
			_btnTwoArgs = new Array(text);
			super.btnTwoPress();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function destroy():void
		{
			_inputBG = null;

			_inputText.removeEventListener(Event.CHANGE, onTextChanged);
			_inputText.destroy();
			_inputText = null;

			super.destroy()
		}
	}
}
