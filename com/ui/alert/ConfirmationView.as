package com.ui.alert
{
	import com.enum.ui.LabelEnum;
	import com.ui.UIFactory;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.events.MouseEvent;

	import org.shared.ObjectPool;

	public class ConfirmationView extends View
	{
		private const DIALOG_MARGIN:int        = 20;
		private const DIALOG_LEFT_MARGIN:int   = 30;
		private const DIALOG_RIGHT_MARGIN:int  = 19;
		private const DIALOG_BOTTOM_MARGIN:int = 50;

		// Button sizes
		protected const SIZE_LARGE:String      = 'Large';
		protected const SIZE_MEDIUM:String     = 'Medium';
		protected const SIZE_SMALL:String      = 'Small';

		private var _bg:DefaultWindowBG;
		private var _buttons:Vector.<BitmapButton>;
		private var _bodyText:Label;
		private var _buttonProtos:Vector.<ButtonPrototype>;

		[PostConstruct]
		public override function init():void
		{
			super.init();

			//build and layout the buttons
			_buttons = new Vector.<BitmapButton>;
			var button:BitmapButton;
			for (var i:int = 0; i < _buttonProtos.length; i++)
			{
				button = UIFactory.getButton(_buttonProtos[i].type, 180, 40, 0, _bg.height + 8, _buttonProtos[i].text);
				if (i == 0)
					button.x = _bg.width - button.width - 8;
				else
					button.x = _buttons[i - 1].x - button.width - 8;
				_buttons.push(button);
				addChild(button);
				addListener(button, MouseEvent.CLICK, onButtonClicked);
			}

			addEffects();
			effectsIN();
		}

		public function setup( title:String, body:String, buttons:Vector.<ButtonPrototype> ):void
		{
			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(500, 230);
			_bg.addTitle(title, 145);

			_bodyText = UIFactory.getLabel(LabelEnum.DEFAULT_OPEN_SANS, _bg.width - 60, _bg.height, 30, 120);
			_bodyText.fontSize = 20;
			_bodyText.multiline = true;
			_bodyText.htmlText = body;

			_buttonProtos = buttons;

			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			addChild(_bg);
			addChild(_bodyText);
		}

		protected function onButtonClicked( e:MouseEvent ):int
		{
			var idx:int               = _buttons.indexOf(BitmapButton(e.currentTarget));
			var proto:ButtonPrototype = _buttonProtos[idx];

			if (proto.callback != null)
				proto.callback.apply(null, proto.args);

			if (proto.doClose)
				destroy();

			return idx;
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function destroy():void
		{
			super.destroy();
		}
	}
}
