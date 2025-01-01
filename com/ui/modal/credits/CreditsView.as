package com.ui.modal.credits
{
	import com.presenter.shared.IUIPresenter;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.label.Label;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	import org.greensock.TweenLite;
	import org.greensock.easing.Linear;
	import org.shared.ObjectPool;

	public class CreditsView extends View
	{
		private var _bg:DefaultWindowBG;

		private var _creditsTitleText:Label;
		private var _creditsBodyText:Label;

		private var _textHolder:Sprite;

		private var _scrollRect:Rectangle;

		private var _credits:Array;

		private var currentCredit:Object;

		private var _creditsText:String = 'CodeString.SettingsView.Credits'; //CREDITS

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(722, 475);
			_bg.addTitle(_creditsText, 239);
			_bg.x -= 21;
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_textHolder = new Sprite();
			_textHolder.x = 1;
			_textHolder.y = 43;
			_textHolder.graphics.beginFill(0xf0f0f0, 0.0);
			_textHolder.graphics.drawRect(0, 0, 696, 472);
			_textHolder.graphics.endFill();

			_scrollRect = new Rectangle(0, 0, 696, 472);
			_scrollRect.y = 0;
			_textHolder.scrollRect = _scrollRect;

			_creditsTitleText = new Label(50, 0xf0f0f0, 722, 100, false);
			_creditsTitleText.align = TextFormatAlign.CENTER;

			_creditsBodyText = new Label(36, 0xf0f0f0, 722, 475, false);
			_creditsBodyText.constrictTextToSize = false;
			_creditsBodyText.multiline = true;
			_creditsBodyText.autoSize = TextFieldAutoSize.CENTER;
			_creditsBodyText.align = TextFormatAlign.CENTER;

			_textHolder.addChild(_creditsTitleText);
			_textHolder.addChild(_creditsBodyText);

			addChild(_bg);
			addChild(_textHolder);

			addEffects();
			effectsIN();

			presenter.getFromCache('data/Credits.txt', onCreditsLoaded);
		}

		private function onCreditsLoaded( credits:Object ):void
		{
			_credits = credits.Credits.slice();
			creditsBegin();
		}

		private function creditsBegin():void
		{
			if (_credits != null && _credits.length > 0)
			{
				currentCredit = _credits.shift();
				var duration:Number = currentCredit.duration;
				_creditsTitleText.text = currentCredit.title;
				_creditsBodyText.text = currentCredit.body;

				switch (currentCredit.type)
				{
					case 'Scrolling':
						_creditsTitleText.y = _textHolder.y + _scrollRect.height;
						_creditsBodyText.y = _creditsTitleText.y + _creditsTitleText.textHeight + 50;
						_creditsTitleText.alpha = 1;
						_creditsBodyText.alpha = 1;
						TweenLite.to(_creditsBodyText, duration, {y:(_textHolder.y - (_creditsBodyText.height + 30)), onUpdate:onScrollingUpdate, onComplete:creditsEnd, ease:Linear.easeNone})
						break;
					case 'Fade':
						_creditsTitleText.alpha = 0;
						_creditsBodyText.alpha = 0;
						_creditsTitleText.y = (_textHolder.y + (_textHolder.height - _creditsTitleText.textHeight) * 0.5) - 25;
						_creditsBodyText.y = _creditsTitleText.y + _creditsTitleText.textHeight + 10;
						duration *= 0.5;
						TweenLite.to(_creditsTitleText, duration, {alpha:1})
						TweenLite.to(_creditsBodyText, duration, {alpha:1, onComplete:onAlphaInComplete})
						break;
				}
			} else
				destroy();
		}

		private function onScrollingUpdate():void
		{
			if (_creditsTitleText && _creditsBodyText)
				_creditsTitleText.y = _creditsBodyText.y - 60;
		}

		private function onAlphaInComplete():void
		{
			if (currentCredit)
			{
				var duration:Number = currentCredit.duration * 0.5;
				TweenLite.to(_creditsTitleText, duration, {alpha:0})
				TweenLite.to(_creditsBodyText, duration, {alpha:0, onComplete:creditsEnd})
			}
		}

		private function creditsEnd():void
		{
			if (_credits && _credits.length > 0)
			{
				creditsBegin();
			} else
				destroy();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			super.destroy();

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;


			if (_creditsTitleText)
				_creditsTitleText.destroy();

			_creditsTitleText = null;

			if (_creditsBodyText)
			{
				TweenLite.killTweensOf(_creditsBodyText);
				_creditsBodyText.destroy();
			}

			_creditsBodyText = null;

			_textHolder = null;
			_scrollRect = null;
			_credits = null;

			currentCredit = null;
		}
	}
}
