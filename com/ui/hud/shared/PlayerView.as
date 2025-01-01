package com.ui.hud.shared
{
	import com.Application;
	import com.enum.PlayerUpdateEnum;
	import com.enum.PositionEnum;
	import com.enum.ToastEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.event.StateEvent;
	import com.event.signal.TransactionSignal;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BuffVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.shared.IUIPresenter;
	import com.service.ExternalInterfaceAPI;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.core.effects.EffectFactory;
	import com.ui.hud.shared.engineering.BuffButton;
	import com.ui.modal.playerinfo.PlayerProfileView;
	import com.ui.modal.store.StoreView;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	import org.adobe.utils.StringUtil;
	import org.parade.enum.PlatformEnum;
	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;

	public class PlayerView extends View
	{
		private var _addMoreBtn:BitmapButton;
		private var _avatar:ImageComponent;
		private var _avatarFrame:ScaleBitmap;
		private var _bg:ScaleBitmap;
		private var _buffIcons:Vector.<BuffButton>;
		private var _buffLookup:Dictionary;
		private var _levelLbl:Label;
		private var _nameLbl:Label;
		private var _palladiumBG:Sprite;
		private var _palladiumSymbol:Bitmap;
		private var _premiumLbl:Label;
		private var _starbaseRating:Label;
		private var _storeBtn:BitmapButton;
		private var _timer:Timer;
		private var _tooltip:Tooltips;
		private var _xpBar:ProgressBar;

		private var _store:String                    = 'CodeString.Controls.Store'; //STORE
		private var _level:String                    = 'CodeString.UserView.Level'; //<FONT COLOR="#d1e5f7">LEVEL </FONT><FONT COLOR="#ecffff"><b>[[Number.Level]]</b></FONT>
		private var _starbaseRatingText:String       = 'CodeString.UserView.StarbaseRating'; //<FONT COLOR="#d1e5f7">STARBASE RATING </FONT><FONT COLOR="#ecffff"><b>[[Number.Level]]</b></FONT>
		private var _palladiumText:String            = 'CodeString.Shared.Palladium'; //PALLADIUM
		private var _xpTooltipStr:String             = 'CodeString.UserView.XpTooltip'; //Experience Points: <br>Current: [[Number.CurrentXp]]<br>Next Lvl: [[Number.NextLevelXp]]
		private var _palladiumTooltipText:String     = 'CodeString.UserView.GetMorePaladiumTooltip'; //Get More Palladium
		private var _playerProfileTooltipText:String = 'CodeString.UserView.PlayerProfileTooltip'; //Player Profile

		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addTransactionListener(TransactionSignal.DATA_IMPORTED, onBuffsImported);

			_buffIcons = new Vector.<BuffButton>;
			_buffLookup = new Dictionary();

			_bg = UIFactory.getPanel(PanelEnum.PLAYER_CONTAINER_NOTCHED, 367, 136);

			_avatarFrame = UIFactory.getPanel(PanelEnum.CHARACTER_FRAME, 125, 125, 6, 5);
			_avatar = ObjectPool.get(ImageComponent);
			_avatar.init(125, 125);
			_avatar.x = 7;
			_avatar.y = 5;
			_avatar.center = true;
			_avatar.buttonMode = true;
			presenter.loadPortraitMedium(CurrentUser.avatarName, _avatar.onImageLoaded);

			_nameLbl = UIFactory.getLabel(LabelEnum.H4, 190, 33, 132);
			_nameLbl.textColor = 0xecffff;
			_nameLbl.useLocalization = false;
			_nameLbl.align = TextFormatAlign.LEFT;
			_nameLbl.text = CurrentUser.name;

			_levelLbl = UIFactory.getLabel(LabelEnum.H4, 132, 19, 132, 19);
			_levelLbl.align = TextFormatAlign.LEFT;
			_levelLbl.bold = false;
			_levelLbl.setHtmlTextWithTokens(_level, {'[[Number.Level]]':CurrentUser.level});

			_xpBar = UIFactory.getProgressBar(UIFactory.getPanel(PanelEnum.STATBAR, 217, 21), UIFactory.getPanel(PanelEnum.STATBAR_CONTAINER, 226, 29), 0, 1, 0, 134, 44);

			_storeBtn = UIFactory.getButton(ButtonEnum.GOLD_A, 126, 53, 235, 77, _store, LabelEnum.H3);
			_storeBtn.label.y += 4;

			_palladiumBG = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED_RIGHT_SMALL, PanelEnum.HEADER_NOTCHED, 96, 35, 18, 135, 77, _palladiumText, LabelEnum.H5);
			_palladiumSymbol = UIFactory.getBitmap('IconPalladiumBMD');
			_palladiumSymbol.x = 6;
			_palladiumSymbol.y = 21;

			_premiumLbl = new Label(16, 0xf0f0f0, 41, 25);
			_premiumLbl.constrictTextToSize = false;
			_premiumLbl.align = TextFormatAlign.RIGHT;
			_premiumLbl.text = String(CurrentUser.wallet.premium);
			_premiumLbl.x = 26;
			_premiumLbl.y = 26;
			_premiumLbl.mouseEnabled = true;

			_addMoreBtn = UIFactory.getButton(ButtonEnum.PLUS, 0, 0, 74, 28);
			_addMoreBtn.hitArea = _palladiumBG;

			_palladiumBG.addChild(_palladiumSymbol);
			_palladiumBG.addChild(_premiumLbl);
			_palladiumBG.addChild(_addMoreBtn);

			_starbaseRating = UIFactory.getLabel(LabelEnum.H4, 145, 25, 367 - 155, _levelLbl.y);
			_starbaseRating.align = TextFormatAlign.RIGHT;
			_starbaseRating.bold = false;
			_starbaseRating.setHtmlTextWithTokens(_starbaseRatingText, {'[[Number.Level]]':CurrentUser.baseRating});

			//transaction update timer
			_timer = new Timer(1000);
			addListener(_timer, TimerEvent.TIMER, onTimer);
			_timer.start();

			var loc:Localization = Localization.instance;
			_tooltip.addTooltip(_avatar, this, null, loc.getString(_playerProfileTooltipText));
			_tooltip.addTooltip(_palladiumBG, this, null, loc.getString(_palladiumTooltipText));
			_tooltip.addTooltip(_xpBar, this, getXpTooltip, '', 250, 180, 18, true);

			addListener(_addMoreBtn, MouseEvent.CLICK, onAddMoreClick);
			addListener(_avatar, MouseEvent.CLICK, onPortraitClick);
			addListener(_storeBtn, MouseEvent.CLICK, onStoreClick);

			addChild(_bg);
			addChild(_avatar);
			addChild(_avatarFrame);
			addChild(_storeBtn);
			addChild(_palladiumBG);
			addChild(_nameLbl);
			addChild(_levelLbl);
			addChild(_starbaseRating);
			addChild(_xpBar);

			x = y = 4;

			addEffects();
			effectsIN();

			CurrentUser.onPlayerUpdate.add(onPlayerUpdated);
			CurrentUser.wallet.onPremiumChange.add(updatePremiumUI);
			addHitArea();
			updateXP(0, CurrentUser.xp);
			onBuffsImported();
			onStageResize();

			visible = !presenter.inFTE;
		}

		private function loadIcon( prototype:IPrototype, callback:Function ):void
		{
			var icon:String = presenter.getPrototypeUIIcon(prototype);
			presenter.loadIcon(icon, callback);
		}

		private function onPlayerUpdated( updateType:int, oldValue:String, newValue:String ):void
		{
			if (oldValue != newValue)
			{
				switch (updateType)
				{
					case PlayerUpdateEnum.TYPE_XP:
						updateXP(int(oldValue), int(newValue));
						break;
					case PlayerUpdateEnum.TYPE_NAME:
						if (_nameLbl)
							_nameLbl.text = newValue;
						break;
					case PlayerUpdateEnum.TYPE_BASERATING:
						if (_starbaseRating)
							_starbaseRating.setHtmlTextWithTokens(_starbaseRatingText, {'[[Number.Level]]':CurrentUser.baseRating});

						ExternalInterfaceAPI.shareLevelUp(CurrentUser.name, CurrentUser.baseRating, true);
						break;
				}
			}
		}

		private function updateXP( oldValue:int, newValue:int ):void
		{
			var currentXP:int       = CurrentUser.xp;
			var nextLevelMinExp:int = PrototypeModel.instance.getConstantPrototypeValueByName(CommonFunctionUtil.getLevelProtoName(CurrentUser.level + 1));
			if (nextLevelMinExp <= currentXP)
			{
				CurrentUser.level = CommonFunctionUtil.findPlayerLevel(currentXP);
				if (_levelLbl)
					_levelLbl.setHtmlTextWithTokens(_level, {'[[Number.Level]]':CurrentUser.level});
				if (CurrentUser.level > 1 && oldValue != 0 && oldValue != newValue)
				{
					showToast(ToastEnum.LEVEL_UP);
					if (DeviceMetrics.PLATFORM == PlatformEnum.BROWSER)
					{
						ExternalInterfaceAPI.shareLevelUp(CurrentUser.name, CurrentUser.level, false);
					}
					if (Application.STATE == StateEvent.GAME_STARBASE)
						presenter.updateStarbasePlatform();
				}
			}
			currentXP = PrototypeModel.instance.getConstantPrototypeValueByName(CommonFunctionUtil.getLevelProtoName(CurrentUser.level));
			nextLevelMinExp = PrototypeModel.instance.getConstantPrototypeValueByName(CommonFunctionUtil.getLevelProtoName(CurrentUser.level + 1));
			if (_xpBar)
				_xpBar.amount = (CurrentUser.xp - currentXP) / (nextLevelMinExp - currentXP);
		}

		private function onBuffsImported( data:TransactionVO = null ):void
		{
			var buff:BuffVO;
			var buffButton:BuffButton;

			//base bubble
			if (presenter.bubbleTimeRemaining > 0 && !_buffLookup.hasOwnProperty("Protection"))
			{
				buffButton = ObjectPool.get(BuffButton);
				buffButton.init(null, presenter);
				_buffIcons.push(buffButton);
				_buffLookup['Protection'] = buffButton;
				addChild(buffButton);
				layoutBuffs();
				addListener(buffButton, MouseEvent.CLICK, onBuffClicked);
				_tooltip.addTooltip(buffButton, this, buffButton.getTooltip);
			}

			//normal buffs
			var buffs:Vector.<BuffVO> = presenter.buffs;
			for (var i:int = 0; i < buffs.length; i++)
			{
				buff = buffs[i];
				if (!_buffLookup.hasOwnProperty(buff.buffType))
				{
					buffButton = ObjectPool.get(BuffButton);
					buffButton.init(buff, presenter);
					_buffIcons.push(buffButton);
					_buffLookup[buff.buffType] = buffButton;
					addChild(buffButton);
					layoutBuffs();
					addListener(buffButton, MouseEvent.CLICK, onBuffClicked);
					_tooltip.addTooltip(buffButton, this, buffButton.getTooltip);
				}
			}
		}

		private function layoutBuffs():void
		{
			var buffButton:BuffButton;
			for (var i:int = 0; i < _buffIcons.length; i++)
			{
				buffButton = _buffIcons[i];
				buffButton.x = _bg.width - 30 - ((i % 6) * 34);
				buffButton.y = _bg.height + 4 + (Math.floor(i / 6) * 54);
			}
		}

		private function onBuffClicked( e:MouseEvent ):void
		{
			if (!presenter.hudEnabled)
				return;
			var storeView:StoreView = StoreView(showView(StoreView));
			if (e.currentTarget is BuffButton)
			{
				var button:BuffButton = BuffButton(e.currentTarget);
				if (button.buff)
					storeView.openToBuffsAndFilter(StoreView.FILTER_ALL);
				else
					storeView.openToProtectionAndFilter(StoreView.FILTER_ALL);
			} else
				storeView.openToBuffsAndFilter(StoreView.FILTER_ALL);
		}

		private function onTimer( e:TimerEvent ):void
		{
			//update buff timers
			var buffButton:BuffButton;
			for (var i:int = 0; i < _buffIcons.length; i++)
			{
				if (!_buffIcons[i].updateTime())
				{
					//time expired. remove buff
					buffButton = _buffIcons[i];
					delete _buffLookup[buffButton.buffType];
					if (buffButton.buff != null)
						presenter.removeBuff(buffButton.buff);
					removeListener(buffButton, MouseEvent.CLICK, onBuffClicked);
					_tooltip.removeTooltip(buffButton);
					ObjectPool.give(buffButton);
					_buffIcons.splice(i, 1);
					i--;
					layoutBuffs();
				}
			}
		}

		override protected function onStateChange( state:String ):void
		{
			switch (state)
			{
				case StateEvent.GAME_BATTLE:
					destroy();
					break;
			}
		}

		private function onPortraitClick( e:MouseEvent ):void
		{
			if (!presenter.hudEnabled)
				return;
			var playerProfileView:PlayerProfileView = PlayerProfileView(_viewFactory.createView(PlayerProfileView));
			playerProfileView.playerKey = CurrentUser.id;
			_viewFactory.notify(playerProfileView);
			e.stopPropagation();
		}

		private function onAddMoreClick( e:MouseEvent ):void
		{
			if (!presenter.hudEnabled)
				return;
			
			CommonFunctionUtil.popPaywall();
			
			//if (Application.NETWORK != Application.NETWORK_KONGREGATE)
			//{
				//CommonFunctionUtil.popPaywall();
			//}
			//else
			//{
				//_viewFactory.openPayment();
			//}
			
			e.stopPropagation();
		}

		private function updatePremiumUI( isAdded:Boolean ):void
		{
			if (_premiumLbl)
				_premiumLbl.text = String(CurrentUser.wallet.premium);

			if (isAdded)
				showToast(ToastEnum.PALLADIUM_ADDED);
		}

		private function premiumUITooltip():String
		{
			return String(CurrentUser.wallet.premium);
		}

		private function onStoreClick( e:Event ):void
		{
			if (!presenter.hudEnabled)
				return;
			if (presenter.hudEnabled)
				showView(StoreView);
			e.stopPropagation();
		}

		private function getXpTooltip():String
		{
			var currentXP:Number         = CurrentUser.xp;
			var nextLevelMinExp:Number   = presenter.getConstantPrototypeValueByName(CommonFunctionUtil.getLevelProtoName(CurrentUser.level + 1));

			var xpTooltipDict:Dictionary = new Dictionary();
			xpTooltipDict['[[Number.CurrentXp]]'] = StringUtil.commaFormatNumber(currentXP);
			xpTooltipDict['[[Number.NextLevelXp]]'] = StringUtil.commaFormatNumber(nextLevelMinExp);

			return Localization.instance.getStringWithTokens(_xpTooltipStr, xpTooltipDict);
		}

		override protected function addEffects():void  { _effects.addEffect(EffectFactory.repositionEffect(PositionEnum.LEFT, PositionEnum.TOP, onStageResize)); }

		private function onStageResize( e:Event = null ):void
		{
			this.scaleX = this.scaleY = Application.SCALE;
		}

		public function get premiumBg():Sprite  { return _palladiumBG; }

		[Inject]
		public function set presenter( v:IUIPresenter ):void  { _presenter = v; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }
		
		override public function get screenshotBlocker():Boolean {return true;}

		[Inject]
		public function set tooltip( v:Tooltips ):void  { _tooltip = v; }

		override public function get type():String  { return ViewEnum.UI; }

		override public function destroy():void
		{
			CurrentUser.onPlayerUpdate.remove(onPlayerUpdated);
			presenter.removeTransactionListener(onBuffsImported);
			CurrentUser.wallet.onPremiumChange.remove(updatePremiumUI);
			super.destroy();

			_addMoreBtn = UIFactory.destroyButton(_addMoreBtn);
			_avatar.destroy();
			_avatar = null;
			_avatarFrame = UIFactory.destroyPanel(_avatarFrame);
			_bg = UIFactory.destroyPanel(_bg);

			//destroy the buffs
			for (var i:int = 0; i < _buffIcons.length; i++)
				ObjectPool.give(_buffIcons[i]);
			_buffIcons.length = 0;
			_buffIcons = null;
			_buffLookup = null;

			_levelLbl = UIFactory.destroyLabel(_levelLbl);
			_nameLbl = UIFactory.destroyLabel(_nameLbl);
			_palladiumBG = null;
			_palladiumSymbol = null;
			_premiumLbl = UIFactory.destroyLabel(_premiumLbl);
			_storeBtn = UIFactory.destroyButton(_storeBtn);

			_timer.reset();
			_timer = null;

			_tooltip.removeTooltip(null, this);
			_tooltip = null;

			_xpBar.destroy();
			_xpBar = null;
		}
	}
}
