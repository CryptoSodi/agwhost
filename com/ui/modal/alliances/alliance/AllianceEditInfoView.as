package com.ui.modal.alliances.alliance
{
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.ui.core.ScaleBitmap;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;

	public class AllianceEditInfoView extends View
	{
		private var _acceptChangesBtn:BitmapButton;
		private var _bg:ScaleBitmap;
		private var _bodyText:Label;
		private var _bodyTextBG:ScaleBitmap;
		private var _bodyTextHolder:Sprite;
		private var _callback:Function;
		private var _closeBtn:BitmapButton;
		private var _defaultBodyText:String;
		private var _maxChars:uint;
		private var _scrollbar:VScrollbar;
		private var _scrollRect:Rectangle;
		private var _title:Label;
		private var _titleText:String;

		private var _acceptText:String = 'CodeString.Shared.Accept'; //ACCEPT
		private var _enterText:String  = 'CodeString.Shared.EnterText'; //Enter Text...

		[PostConstruct]
		public override function init():void
		{
			super.init();

			_bg = PanelFactory.getScaleBitmapPanel('WindowContextMenuBMD', 549, 300, new Rectangle(190, 120, 5, 5))
			addChild(_bg);

			_bodyTextBG = PanelFactory.getScaleBitmapPanel('AllianceTextboxBMD', 500, 107, new Rectangle(15, 11, 2, 2));
			_bodyTextBG.x = 22;
			_bodyTextBG.y = 85;

			_title = new Label(22, 0xf0f0f0, 150, 30);
			_title.allCaps = true;
			_title.align = TextFormatAlign.LEFT;
			_title.x = 25;
			_title.y = 12;
			_title.text = _titleText;

			_bodyText = new Label(18, 0xa9dcff, 450, 235, true);
			_bodyText.align = TextFormatAlign.LEFT;
			_bodyText.maxChars = _maxChars;
			_bodyText.multiline = true;
			_bodyText.allowInput = true;
			_bodyText.clearOnFocusIn = true;
			_bodyText.letterSpacing = .8;
			_bodyText.addLabelColor(0xbdfefd, 0x000000);
			_bodyText.updateInputText(_enterText);
			if (_defaultBodyText != '')
				_bodyText.text = _defaultBodyText;
			_bodyText.addEventListener(Event.CHANGE, onTextUpdated, false, 0, true);

			_bodyTextHolder = new Sprite();
			_bodyTextHolder.x = _bodyTextBG.x + 5;
			_bodyTextHolder.y = _bodyTextBG.y + 3;
			_bodyTextHolder.addChild(_bodyText);

			_scrollRect = new Rectangle(0, 0, _bodyTextHolder.width, _bodyTextBG.height - 5);
			_scrollRect.y = 0;
			_bodyTextHolder.scrollRect = _scrollRect;

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = _bodyTextBG.x + _bodyTextBG.width - 1;
			var scrollbarYPos:Number    = _bodyTextBG.y;
			_scrollbar.init(7, _scrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this, _bodyTextHolder);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_bodyText.textHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 7;

			_acceptChangesBtn = ButtonFactory.getBitmapButton('BlueBtnCNeutralBMD', 0, 0, _acceptText, 0xf0f0f0, 'BlueBtnCRollOverBMD', 'BlueBtnCSelectedBMD', null, 'BlueBtnCSelectedBMD');
			_acceptChangesBtn.x = _bodyTextBG.x + (_bodyTextBG.width - _acceptChangesBtn.width) * 0.5;
			_acceptChangesBtn.y = 240;
			_acceptChangesBtn.addEventListener(MouseEvent.CLICK, onAcceptChanges, false, 0, true);

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 36, 13);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			addChild(_bg);
			addChild(_closeBtn);
			addChild(_bodyTextBG);
			addChild(_title);
			addChild(_bodyTextHolder);
			addChild(_scrollbar);
			addChild(_acceptChangesBtn)

			addEffects();
			effectsIN();
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_bodyText.textHeight - _scrollRect.height) * percent;
			_bodyTextHolder.scrollRect = _scrollRect;
		}

		private function onTextUpdated( e:Event ):void
		{
			_scrollbar.updateScrollableHeight(_bodyText.textHeight);

			var car:int        = _bodyText.caretIndex;
			var rect:Rectangle = _bodyText.getCharBoundaries(car - 1);

			if (rect != null)
			{
				if (rect.y + rect.height > _scrollRect.height)
				{
					var percent:Number = ((rect.y + rect.height) / _bodyText.textHeight)
					_scrollbar.updateScrollPercent(percent);
				} else if (rect.y + rect.height < _scrollRect.height && _scrollbar.percent != 0)
					_scrollbar.updateScrollPercent(0);
			}
		}

		private function onAcceptChanges( e:MouseEvent ):void
		{
			var newText:String = _bodyText.text;
			if ((_defaultBodyText == '' || _defaultBodyText != '' && newText != _defaultBodyText) && _callback != null)
			{
				_callback(newText);
				destroy();
			}
		}

		public function set bodyText( v:String ):void  { _defaultBodyText = v; }
		public function set callback( v:Function ):void  { _callback = v; }
		public function set maxChars( v:uint ):void  { _maxChars = v; }
		public function set titleText( v:String ):void  { _titleText = v; }

		override public function destroy():void
		{
			super.destroy();
		}
	}
}
