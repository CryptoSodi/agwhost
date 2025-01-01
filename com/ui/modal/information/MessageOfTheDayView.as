package com.ui.modal.information
{

	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.model.motd.MotDDailyRewardModel;
	import com.model.motd.MotDVO;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.IUIPresenter;
	import com.service.server.incoming.starbase.StarbaseDailyRewardResponse;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.pips.PipComponent;
	import com.ui.core.component.pips.PipEvent;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.shared.ObjectPool;

	public class MessageOfTheDayView extends View
	{
		public static const MAX_MESSAGES:int       = 7;
		private static const MAX_DAILY_REWARDS:int = 7;
		private static var _isClaimed:Boolean      = false;

		private var _bg:Sprite;
		private var _closeBtn:BitmapButton;
		private var _image:ImageComponent;
		private var _messageBG:Bitmap;
		private var _currentDayImage:Bitmap;
		private var _currentChestGlow:Bitmap;
		private var _dailyBtn:BitmapButton;
		private var _dailyIcons:Vector.<Bitmap>;
		private var _dailyCheckbox:Vector.<Bitmap>;

		private var _message:Label;
		private var _windowTitle:Label;
		private var _messageTitle:Label;
		private var _dailyHeader:Label;
		private var _dailySideMessage:Label;

		private var _dailyLbls:Vector.<Label>;

		private var _scrollbar:VScrollbar;
		private var _scrollRect:Rectangle;

		private var _messageVOs:Vector.<MotDVO>;

		private var _pipComponent:PipComponent;

		private var _dailyRewardModel:MotDDailyRewardModel;
		private var _loginBonusProto:IPrototype;

		private var _claimDay:int;
		private var _claimTimer:Timer;

		private var _closeWindowBtn:BitmapButton;

		private var _windowTitleString:String      = 'CodeString.MotD.Title';
		private var _DailyRewardString:String      = 'CodeString.MotD.RewardTitle'; //DAILY LOGIN REWARD
		private var _DailySideMessageString:String = 'CodeString.MotD.RewardSideTitle'; //Play Everday for Better Rewards!
		private var _DailyClaimedString:String     = 'CodeString.MotD.Claimed'; //CLAIMED
		private var _closeWindowBtnText:String     = 'CodeString.MotD.CloseWindow'; // CLOSE WINDOW
		private var _dayText:String                = 'CodeString.MotD.Day'; // DAY [[Number.Day]]
		private var _todayText:String              = 'CodeString.MotD.Today'; // TODAY

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_messageVOs = presenter.motdModel.motd;
			_dailyRewardModel = presenter.motdDailyModel;

			if (_messageVOs.length == 0)
				return;

			_dailyLbls = new Vector.<Label>;
			_dailyIcons = new Vector.<Bitmap>;
			_dailyCheckbox = new Vector.<Bitmap>;

			if (_dailyRewardModel.canClaimDelta <= 0)
				_claimDay = _dailyRewardModel.escalation;
			else
			{
				_claimDay = _dailyRewardModel.escalation > 0 ? _dailyRewardModel.escalation - 1 : 6;
				_isClaimed = true;
				_claimTimer = new Timer(_dailyRewardModel.timeRemainingMS, 1);
				addListener(_claimTimer, TimerEvent.TIMER_COMPLETE, update);
				_claimTimer.start();
			}

			presenter.addDailyRewardListener(showRewardView);

			var mcBGClass:Class         = Class(getDefinitionByName('MotDMC'));
			_bg = Sprite(new mcBGClass());

			_pipComponent = new PipComponent();
			_pipComponent.init(true, true);
			_pipComponent.totalPips = _messageVOs.length <= MAX_MESSAGES ? _messageVOs.length : MAX_MESSAGES;
			_pipComponent.x = 243;
			_pipComponent.y = 253;
			_pipComponent.selected = 0;

			addListener(_pipComponent, PipEvent.PIP_CLICKED, onPipClicked);

			var i:int;
			if (_messageVOs.length > 1)
			{
				_pipComponent.visible = true;
				for (i = 0; i < _messageVOs.length; i++)
					_pipComponent.setPipState(i, _messageVOs[i].isRead);
			} else
			{
				_pipComponent.visible = false;
			}

			_closeBtn = ButtonFactory.getCloseButton(560, 19);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			var messageBG:Class         = Class(getDefinitionByName(('MotDTextBGBMD')));
			var bgRect:Rectangle        = new Rectangle(0, 50, 569, 10);
			_messageBG = new ScaleBitmap(BitmapData(new messageBG));
			_messageBG.scale9Grid = bgRect;
			_messageBG.x = 26;
			_messageBG.y = 165;
			//			addChild(_messageBG);

			_windowTitle = new Label(30, 0xd1e5f7, 383, 5, true);
			_windowTitle.x = 34;
			_windowTitle.y = 5; //14;
			_windowTitle.constrictTextToSize = false;
			_windowTitle.align = TextFormatAlign.LEFT;
			_windowTitle.autoSize = TextFieldAutoSize.LEFT;
			_windowTitle.text = _windowTitleString;
			_windowTitle.letterSpacing = 1.5;

			_messageTitle = new Label(22, 0xd1e5f7, 383, 29, true);
			_messageTitle.x = 34;
			_messageTitle.y = 47;
			_messageTitle.constrictTextToSize = false;
			_messageTitle.align = TextFormatAlign.LEFT;
			_messageTitle.text = _messageVOs[0].title;
			_messageTitle.letterSpacing = 1.5;

			_message = new Label(12, 0xd1e5f7, 532, 500, true, 1);
			_message.x = 32;
			_message.y = 210;
			_message.constrictTextToSize = false;
			_message.multiline = true;
			_message.autoSize = TextFieldAutoSize.LEFT;
			_message.align = TextFormatAlign.LEFT;
			_message.htmlText = _messageVOs[0].message;
			_message.letterSpacing = 1.5;
			_message.mouseEnabled = true;

			var style:StyleSheet        = new StyleSheet();
			var hover:Object            = new Object();
			hover.fontWeight = "bold";
			hover.color = "#4CACF0";
			var link:Object             = new Object();
			link.fontWeight = "bold";
			link.textDecoration = "underline";
			link.color = "#4CACF0";
			var active:Object           = new Object();
			active.fontWeight = "bold";
			active.color = "#4CACF0";
			var visited:Object          = new Object();
			visited.fontWeight = "bold";
			visited.color = "#4CACF0";
			visited.textDecoration = "underline";

			style.setStyle("a:link", link);
			style.setStyle("a:hover", hover);
			style.setStyle("a:active", active);
			style.setStyle(".visited", visited);

			_message.styleSheet = style;

			_messageBG.height = _message.textHeight + 20 < 217 ? _message.textHeight + 20 : 217;
			_scrollRect = new Rectangle(0, 0, _messageBG.width - 37, _messageBG.height - 15);
			_message.scrollRect = _scrollRect;

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 5, 5, 2);
			var scrollbarXPos:Number    = _messageBG.width - 1;
			var scrollbarYPos:Number    = _messageBG.y + 10;
			_scrollbar.init(7, _scrollRect.height - 10, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.updateScrollableHeight(_message.textHeight);
			_scrollbar.maxScroll = 16.3;

			_dailyHeader = new Label(22, 0xd1e5f7, 30, 29, true);
			_dailyHeader.x = 32;
			_dailyHeader.y = 284;
			_dailyHeader.constrictTextToSize = false;
			_dailyHeader.align = TextFormatAlign.LEFT;
			_dailyHeader.autoSize = TextFieldAutoSize.LEFT;
			_dailyHeader.text = _DailyRewardString;
			_dailyHeader.letterSpacing = 1.5;

			_dailySideMessage = new Label(22, 0xffcf4f, 30, 29, true);
			_dailySideMessage.x = _dailyHeader.x + _dailyHeader.textWidth + 15;
			_dailySideMessage.y = _dailyHeader.y;
			_dailySideMessage.constrictTextToSize = false;
			_dailySideMessage.align = TextFormatAlign.LEFT;
			_dailySideMessage.autoSize = TextFieldAutoSize.LEFT;
			_dailySideMessage.text = _DailySideMessageString;
			_dailySideMessage.letterSpacing = 1.5;

			_image = ObjectPool.get(ImageComponent);
			_image.init(579, 120);
			_image.x = 27;
			_image.y = 81;

			_closeWindowBtn = ButtonFactory.getBitmapButton('BtnRewardUpBMD', _bg.x + _bg.width - 250, _bg.y + _bg.height + 2, _closeWindowBtnText, 0xacd1ff, 'BtnRewardROBMD', 'BtnRewardDownBMD');
			_closeWindowBtn.fontSize = 28;
			addListener(_closeWindowBtn, MouseEvent.CLICK, onClose);

			addChild(_bg);
			addChild(_closeBtn);
			addChild(_pipComponent);
			addChild(_windowTitle);
			addChild(_messageTitle);
			addChild(_message);
			addChild(_scrollbar);
			addChild(_dailyHeader);
			addChild(_dailySideMessage);
			addChild(_image);
			addChild(_closeWindowBtn);

			setUpRewards();
			layoutRewards();
			showMessageByIdx(0);

			addEffects();
			effectsIN();
		}

		private function setUpRewards():void
		{
			var chestBitmapName:String;
			var checkboxBitmapName:String;
			var bitmap:Bitmap;
			var alpha:Number;

			_currentChestGlow = UIFactory.getBitmap('LoginCrate' + _claimDay + 'GlowBMD');
			_currentChestGlow.alpha = 0;
			addChild(_currentChestGlow);

			for (var i:uint = 0; i < MAX_DAILY_REWARDS; ++i)
			{


				if (i > _claimDay)
				{
					chestBitmapName = 'LoginCrate' + i + 'ClosedBMD';
					checkboxBitmapName = 'BtnCheckBoxUpBMD';
					alpha = 1.0;
				} else if (i < _claimDay)
				{
					chestBitmapName = 'LoginCrate' + i + 'EmptyBMD';
					checkboxBitmapName = 'BtnCheckBoxSelectedBMD';
					alpha = 0.5;
				} else
				{
					if (!_isClaimed)
					{
						chestBitmapName = 'LoginCrate' + i + 'ClaimBMD'
						checkboxBitmapName = 'BtnCheckBoxUpBMD';
						alpha = 1.0;
					} else
					{
						chestBitmapName = 'LoginCrate' + i + 'EmptyBMD';
						checkboxBitmapName = 'BtnCheckBoxSelectedBMD';
						alpha = 0.5;
					}
				}
				bitmap = addBitmap(chestBitmapName);
				bitmap.alpha = alpha;
				bitmap.smoothing = true;

				_dailyIcons.push(bitmap);
				_dailyCheckbox.push(addBitmap(checkboxBitmapName));
				_dailyLbls.push(addDayLabel(i + 1));
			}

			var btn:BitmapData = new BitmapData(71, 73, true, 0xf0f0f0);
			_dailyBtn = new BitmapButton()
			_dailyBtn.init(btn, btn, btn, btn, btn);
			_dailyBtn.enabled = false;
			addChild(_dailyBtn);

			if (!_isClaimed)
			{
				_dailyBtn.enabled = true;
				addListener(_dailyBtn, MouseEvent.CLICK, claimReward);
				addListener(_dailyBtn, MouseEvent.ROLL_OVER, onChestRollOver);
				addListener(_dailyBtn, MouseEvent.ROLL_OUT, onChestRollOut);
				onFadeOut(_currentChestGlow);
			}

		}

		private function layoutRewards():void
		{
			var chestBitmap:Bitmap;
			var checkboxBitmap:Bitmap;
			var label:Label;

			var bitmapXPos:Number = 43;
			var labelXPos:Number  = 43;
			for (var i:uint = 0; i < MAX_DAILY_REWARDS; ++i)
			{
				chestBitmap = _dailyIcons[i];

				chestBitmap.x = bitmapXPos;
				if (i != _claimDay || _isClaimed)
				{
					chestBitmap.y = 398 - chestBitmap.height;
				} else
				{
					chestBitmap.y = 411 - chestBitmap.height;
					_currentChestGlow.x = chestBitmap.x;
					_currentChestGlow.y = chestBitmap.y;
				}

				checkboxBitmap = _dailyCheckbox[i];
				checkboxBitmap.x = chestBitmap.x - 9;
				checkboxBitmap.y = 406 - checkboxBitmap.height;

				label = _dailyLbls[i];
				label.x = labelXPos;
				label.y = 406;

				if ((i + 1) != _claimDay || _isClaimed)
					bitmapXPos += 81;
				else
					bitmapXPos += 70;

				labelXPos += 82;
			}

			_dailyBtn.x = 43 + _claimDay * 81;
			_dailyBtn.y = 398 - _dailyBtn.height;
		}

		private function update( e:TimerEvent ):void
		{
			_isClaimed = false;
			_claimDay++;
			if (_dailyRewardModel.resetTimeRemainingMS <= 0 || _claimDay > 6)
				_claimDay = 0;

			var chestBitmap:Bitmap;
			var checkboxBitmap:Bitmap;
			var dayLabel:Label;
			var chestBitmapName:String;
			var checkboxBitmapName:String;
			for (var i:uint = 0; i < MAX_DAILY_REWARDS; ++i)
			{
				chestBitmap = _dailyIcons[i];
				checkboxBitmap = _dailyCheckbox[i];
				dayLabel = _dailyLbls[i];

				if (i > _claimDay)
				{
					chestBitmapName = 'LoginCrate' + i + 'ClosedBMD';
					checkboxBitmapName = 'BtnCheckBoxUpBMD';
					chestBitmap.alpha = 1.0;
					dayLabel.textColor = 0xd1e5f7;
					dayLabel.setTextWithTokens(_dayText, {'[[Number.Day]]':i});
				} else if (i < _claimDay)
				{
					chestBitmapName = 'LoginCrate' + i + 'EmptyBMD';
					checkboxBitmapName = 'BtnCheckBoxSelectedBMD';
					chestBitmap.alpha = 0.5;
					dayLabel.textColor = 0x213745;
					dayLabel.setTextWithTokens(_dayText, {'[[Number.Day]]':i});
				} else
				{
					if (!_isClaimed)
					{
						chestBitmapName = 'LoginCrate' + i + 'ClaimBMD'
						checkboxBitmapName = 'BtnCheckBoxUpBMD';
						chestBitmap.alpha = 1.0;
						dayLabel.textColor = 0xffcf4f;
						dayLabel.text = _todayText;
					} else
					{
						chestBitmapName = 'LoginCrate' + i + 'EmptyBMD';
						checkboxBitmapName = 'BtnCheckBoxSelectedBMD';
						chestBitmap.alpha = 0.5;
						dayLabel.textColor = 0x213745;
						dayLabel.setTextWithTokens(_dayText, {'[[Number.Day]]':i});
					}
				}

				chestBitmap.bitmapData = UIFactory.getBitmapData(chestBitmapName);
				checkboxBitmap.bitmapData = UIFactory.getBitmapData(checkboxBitmapName);
			}

			_currentChestGlow.bitmapData = UIFactory.getBitmapData('LoginCrate' + _claimDay + 'GlowBMD');
			_currentChestGlow.alpha = 0;

			if (!_isClaimed)
			{
				_dailyBtn.enabled = true;
				addListener(_dailyBtn, MouseEvent.CLICK, claimReward);
				addListener(_dailyBtn, MouseEvent.ROLL_OVER, onChestRollOver);
				addListener(_dailyBtn, MouseEvent.ROLL_OUT, onChestRollOut);
				onFadeOut(_currentChestGlow);
			}

			layoutRewards();
		}

		private function onChestRollOver( e:MouseEvent = null ):void
		{
			if (_currentChestGlow)
			{
				TweenLite.killTweensOf(_currentChestGlow);
				_currentChestGlow.alpha = 1;
			}
		}

		private function onChestRollOut( e:MouseEvent = null ):void
		{
			if (_currentChestGlow)
			{
				_currentChestGlow.alpha = 0;
				onFadeOut(_currentChestGlow);
			}
		}

		private function onFadeOut( fadeBitmap:Bitmap ):void
		{
			TweenLite.to(fadeBitmap, 0.65, {alpha:0.8, ease:Quad.easeOut, onComplete:onFadeIn, onCompleteParams:[fadeBitmap], overwrite:0});
		}

		private function onFadeIn( fadeBitmap:Bitmap ):void
		{
			TweenLite.to(fadeBitmap, 0.65, {alpha:0.4, ease:Quad.easeIn, onComplete:onFadeOut, onCompleteParams:[fadeBitmap], overwrite:0});
		}

		private function onPipClicked( p:PipEvent ):void
		{
			showMessageByIdx(p.index);
		}

		private function showMessageByIdx( idx:int ):void
		{
			_messageTitle.text = _messageVOs[idx].title;
			_message.htmlText = _messageVOs[idx].message;

			presenter.loadIcon(_messageVOs[idx].imageURL, _image.onImageLoaded);
			_messageBG.y = 286;
			_message.y = 210;
			_messageBG.height = _message.textHeight + 20 < 73 ? _message.textHeight + 20 : 73;

			_scrollRect.height = _messageBG.height - 15;
			_scrollbar.updateScrollbarHeight(_scrollRect.height);
			_scrollbar.updateScrollableHeight(_message.textHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.y = _messageBG.y + 10;
			_scrollbar.resetScroll();

			if (!_messageVOs[idx].isRead)
			{
				_messageVOs[idx].isRead = true;
				presenter.sendMotDMessageRead(_messageVOs[idx].key);
			}

			if (_pipComponent.visible)
				_pipComponent.setPipState(idx, _messageVOs[idx].isRead);
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_message.textHeight - _scrollRect.height) * percent;
			_message.scrollRect = _scrollRect;
		}

		private function claimReward( e:MouseEvent ):void
		{
			_isClaimed = true;
			removeListener(_dailyBtn, MouseEvent.CLICK, claimReward);
			removeListener(_dailyBtn, MouseEvent.ROLL_OVER, onChestRollOver);
			removeListener(_dailyBtn, MouseEvent.ROLL_OUT, onChestRollOut);

			presenter.sendDailyClaimRequest(_dailyRewardModel.header, _dailyRewardModel.protocolID);
		}

		private function showRewardView( rewards:StarbaseDailyRewardResponse ):void
		{
			var view:DailyRewardView = DailyRewardView(_viewFactory.createView(DailyRewardView));
			view.rewards = rewards;
			_viewFactory.notify(view);

			destroy();
		}

		private function addBitmap( className:String ):Bitmap
		{
			var newBmp:Bitmap = UIFactory.getBitmap(className);
			addChild(newBmp);
			return newBmp;
		}

		private function addDayLabel( day:int ):Label
		{
			var dayLbl:Label = new Label(22, 0xd1e5f7, 60, 30, true);
			dayLbl.constrictTextToSize = false;
			dayLbl.align = TextFormatAlign.CENTER;
			if (_claimDay > (day - 1))
			{
				dayLbl.textColor = 0x213745;
				dayLbl.setTextWithTokens(_dayText, {'[[Number.Day]]':day});
			} else if (_claimDay < (day - 1))
			{
				dayLbl.textColor = 0xd1e5f7;
				dayLbl.setTextWithTokens(_dayText, {'[[Number.Day]]':day});
			} else
			{
				dayLbl.textColor = 0xffcf4f;
				dayLbl.text = _todayText;
			}
			addChild(dayLbl);

			return dayLbl;
		}

		override protected function onClose( e:MouseEvent = null ):void
		{
			if (presenter.currentGameState == StateEvent.GAME_STARBASE)
				presenter.dispatch(new StarbaseEvent(StarbaseEvent.WELCOME_BACK));

			super.onClose(e);
		}

		[Inject]
		public function set presenter( v:IUIPresenter ):void  { _presenter = v; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function destroy():void
		{
			presenter.removeDailyRewardListener(showRewardView);
			super.destroy();

			_bg = null;
			_messageBG = null;
			_scrollRect = null;
			_messageVOs = null;

			if (_currentChestGlow)
				TweenLite.killTweensOf(_currentChestGlow);

			_currentChestGlow = null;

			if (_image)
				ObjectPool.give(_image);
			_image = null;

			if (_message)
				_message.destroy();
			_message = null;

			if (_windowTitle)
				_windowTitle.destroy();
			_windowTitle = null;

			if (_messageTitle)
				_messageTitle.destroy();
			_messageTitle = null;

			if (_dailyHeader)
				_dailyHeader.destroy();
			_dailyHeader = null;

			if (_scrollbar)
				_scrollbar.destroy();
			_scrollbar = null;


			if (_pipComponent)
				_pipComponent.destroy();
			_pipComponent = null;

			if (_dailyBtn)
				_dailyBtn.destroy();
			_dailyBtn = null;


			if (_dailyIcons)
			{
				var chestBitmap:Bitmap = _dailyIcons[_claimDay];
				if (chestBitmap)
					TweenLite.killTweensOf(chestBitmap);
				_dailyIcons.length = 0;
			}
			_dailyIcons = null;

			if (_dailyCheckbox)
				_dailyCheckbox.length = 0;

			_dailyCheckbox = null;

			if (_dailyLbls)
				_dailyLbls.length = 0;

			_dailyLbls = null;

			if (_dailySideMessage)
				_dailySideMessage.destroy();

			_dailySideMessage = null;

			_loginBonusProto = null;

			if (_claimTimer)
				_claimTimer.stop();

			_claimTimer = null;
		}
	}
}
