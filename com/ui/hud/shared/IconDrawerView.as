package com.ui.hud.shared
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.PanelEnum;
	import com.event.StateEvent;
	import com.model.battle.BattleRerollVO;
	import com.model.player.CurrentUser;
	import com.model.warfrontModel.WarfrontVO;
	import com.presenter.shared.IUIPresenter;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.pulldown.DrawerComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.core.effects.EffectFactory;
	import com.ui.hud.shared.leaderboards.LeaderboardView;
	import com.ui.hud.shared.mail.MailBoxView;
	import com.ui.modal.PanelFactory;
	import com.ui.modal.alliances.alliance.AllianceView;
	import com.ui.modal.alliances.noalliance.NoAllianceView;
	import com.ui.modal.battle.chance.GameOfChanceListView;
	import com.ui.modal.battlelog.BattleLogListView;
	import com.ui.modal.warfront.WarfrontView;

	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.parade.core.IView;
	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;

	public class IconDrawerView extends View
	{
		private const MIN_Y_POS:Number       = 602;

		private var _btnAlliance:BitmapButton;
		private var _btnBattlelog:BitmapButton;
		private var _btnLeaderboard:BitmapButton;
		private var _btnMail:BitmapButton;
		private var _btnWarfront:BitmapButton;
		private var _btnChanceGame:BitmapButton;
		private var _drawer:DrawerComponent;
		private var _mailExclamation:Bitmap;
		private var _tooltip:Tooltips;
		private var _warfrontGlow:Bitmap;
		private var _warfrontPulseCount:uint;
		private var _rerollsGlow:Bitmap;
		private var _rerollsPulseCount:uint;


		private var _mailText:String         = 'CodeString.IconDrawer.MailTooltip'; //Mail
		private var _battlelogText:String    = 'CodeString.IconDrawer.BattleLogTooltip'; //Battle Log
		private var _leaderboardText:String  = 'CodeString.IconDrawer.LeaderboardTooltip'; //Leaderboard
		private var _warfrontText:String     = 'CodeString.IconDrawer.WarfrontTooltip'; //Warfront
		private var _allianceText:String     = 'CodeString.IconDrawer.AllianceTooltip'; //Alliance
		private var _pendingScansText:String = 'CodeString.IconDrawer.PendingScansTooltip'; //Pending Scans

		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addMailCountUpdateListener(onMailCountUpdated);
			presenter.addWarfrontUpdateListener(onWarfrontUpdated);
			presenter.addAvailableRerollUpdatedListener(onRerollsUpdated);

			var xpos:Number      = 17.5;
			var ypos:Number      = 1;
			_btnWarfront = UIFactory.getButton(ButtonEnum.ICON_WARFRONT, 0, 0, xpos, ypos);
			_btnMail = UIFactory.getButton(ButtonEnum.ICON_MAIL, 0, 0, xpos, ypos += 32);
			_btnBattlelog = UIFactory.getButton(ButtonEnum.ICON_BATTLE_LOG, 0, 0, xpos, ypos += 22);
			_btnLeaderboard = UIFactory.getButton(ButtonEnum.ICON_LEADERBOARD, 0, 0, xpos, ypos += 27);
			_btnAlliance = UIFactory.getButton(ButtonEnum.ICON_ALLIANCE, 0, 0, xpos, ypos += 22);
			_btnChanceGame = UIFactory.getButton(ButtonEnum.ICON_CHANCE, 0, 0, xpos, ypos += 27);

			addListener(_btnMail, MouseEvent.CLICK, onButtonClicked);
			addListener(_btnBattlelog, MouseEvent.CLICK, onButtonClicked);
			addListener(_btnLeaderboard, MouseEvent.CLICK, onButtonClicked);
			addListener(_btnWarfront, MouseEvent.CLICK, onButtonClicked);
			addListener(_btnAlliance, MouseEvent.CLICK, onButtonClicked);
			addListener(_btnChanceGame, MouseEvent.CLICK, onButtonClicked);

			//tooltips
			var loc:Localization = Localization.instance;
			_tooltip.addTooltip(_btnMail, this, null, loc.getString(_mailText));
			_tooltip.addTooltip(_btnBattlelog, this, null, loc.getString(_battlelogText));
			_tooltip.addTooltip(_btnLeaderboard, this, null, loc.getString(_leaderboardText));
			_tooltip.addTooltip(_btnWarfront, this, null, loc.getString(_warfrontText));
			_tooltip.addTooltip(_btnAlliance, this, null, loc.getString(_allianceText));
			_tooltip.addTooltip(_btnChanceGame, this, null, loc.getString(_pendingScansText));

			_drawer = new DrawerComponent();
			_drawer.init(PanelEnum.CONTAINER_DOUBLE_NOTCHED_ARROWS, 62, 32, DrawerComponent.EXPANDS_UP, 15, 35);
			_drawer.showInnerPanel = true;
			_drawer.addElement(_btnMail);
			_drawer.addElement(_btnBattlelog);
			_drawer.addElement(_btnLeaderboard);
			_drawer.addElement(_btnWarfront);
			_drawer.addElement(_btnAlliance);
			_drawer.addElement(_btnChanceGame);
			_drawer.y = _drawer.height;
			_drawer.maximize();

			addChild(_drawer);

			addHitArea();
			addEffects();
			effectsIN();
			onStageResized();

			visible = !presenter.inFTE;
		}

		private function onButtonClicked( e:MouseEvent ):void
		{
			if (!presenter.hudEnabled)
				return;

			var view:IView;
			switch (e.currentTarget)
			{
				//mail button
				case _btnMail:
					//var event:StateEvent = new StateEvent(StateEvent.SHUTDOWN_START);
					//presenter.dispatch(event);
					view = _viewFactory.createView(MailBoxView);
					showHideMailExclamation(false);
					break;

				//battle log
				case _btnBattlelog:
					view = _viewFactory.createView(BattleLogListView);
					break;

				//leaderboard button
				case _btnLeaderboard:
					view = _viewFactory.createView(LeaderboardView);
					break;

				//warfront button
				case _btnWarfront:
					view = _viewFactory.createView(WarfrontView);
					break;

				//alliance button
				case _btnAlliance:
					if (CurrentUser.alliance != '')
					{
						var allianceView:AllianceView = AllianceView(_viewFactory.createView(AllianceView));
						allianceView.allianceKey = CurrentUser.alliance;
						_viewFactory.notify(allianceView);
					} else
					{
						view = _viewFactory.createView(NoAllianceView);
					}
					break;

				//chance game button
				case _btnChanceGame:
					TweenLite.killTweensOf(_rerollsGlow);
					_drawer.removeElement(_rerollsGlow);
					_rerollsGlow = null;
					view = _viewFactory.createView(GameOfChanceListView);
					break;
			}

			if (view)
				_viewFactory.notify(view);
		}

		public function onMailCountUpdated( unread:uint, count:uint, serverUpdate:Boolean ):void
		{
			showHideMailExclamation(unread > 0);
		}

		private function showHideMailExclamation( show:Boolean = true ):void
		{
			if (show && !_mailExclamation)
			{
				_mailExclamation = UIFactory.getBitmap("ExclamationBMD");
				_mailExclamation.x = 18;
				_mailExclamation.y = -8;
				_btnMail.addChild(_mailExclamation);
			} else if (!show && _mailExclamation)
			{
				_btnMail.removeChild(_mailExclamation);
				ObjectPool.give(_mailExclamation);
				_mailExclamation = null;
			}
		}

		private function onWarfrontUpdated( battles:Vector.<WarfrontVO>, removed:Vector.<String> ):void
		{
			if (battles && battles.length > 0)
			{
				if (!_warfrontGlow)
				{
					_warfrontGlow = PanelFactory.getPanel('BtnIconWarfrontSelectedBMD');
					_warfrontGlow.x = _btnWarfront.x;
					_warfrontGlow.y = _btnWarfront.y;
					_drawer.addElement(_warfrontGlow);
				}
				TweenLite.killTweensOf(_warfrontGlow);
				_warfrontPulseCount = 0;
				onWarfrontGlowFadeOut();
			}
		}

		private function onWarfrontGlowFadeOut():void
		{
			if (_warfrontPulseCount < 4 && _warfrontGlow != null)
			{
				++_warfrontPulseCount;
				TweenLite.to(_warfrontGlow, 1.0, {alpha:1.0, ease:Quad.easeOut, onComplete:onWarfrontGlowFadeIn, overwrite:0});
			} else
			{
				_warfrontPulseCount = 0;
				if (_warfrontGlow)
				{
					TweenLite.killTweensOf(_warfrontGlow);
					_drawer.removeElement(_warfrontGlow);
				}
				_warfrontGlow = null;
			}
		}

		private function onWarfrontGlowFadeIn():void
		{
			if (_warfrontPulseCount < 4 && _warfrontGlow != null)
			{
				++_warfrontPulseCount;
				TweenLite.to(_warfrontGlow, 1.0, {alpha:0.0, ease:Quad.easeIn, onComplete:onWarfrontGlowFadeOut, overwrite:0});
			} else
			{
				_warfrontPulseCount = 0;
				if (_warfrontGlow)
				{
					TweenLite.killTweensOf(_warfrontGlow);
					_drawer.removeElement(_warfrontGlow);
				}
				_warfrontGlow = null;
			}
		}

		private function onRerollsUpdated( battleReroll:BattleRerollVO ):void
		{
			if (battleReroll)
			{
				if (!_rerollsGlow)
				{
					_rerollsGlow = PanelFactory.getPanel('ExclamationBMD');
					_rerollsGlow.x = _btnChanceGame.x + (_btnChanceGame.width * 0.5) - (_rerollsGlow.width * 0.5);
					_rerollsGlow.y = _btnChanceGame.y + (_btnChanceGame.height * 0.5) - (_rerollsGlow.height * 0.5);
					_drawer.addElement(_rerollsGlow);
				}
				TweenLite.killTweensOf(_rerollsGlow);
				_rerollsPulseCount = 0;
				onRerollsGlowFadeOut();
			}
		}

		private function onRerollsGlowFadeOut():void
		{
			TweenLite.to(_rerollsGlow, 1.0, {alpha:1.0, ease:Quad.easeOut, onComplete:onRerollsGlowFadeIn, overwrite:0});
		}

		private function onRerollsGlowFadeIn():void
		{
			TweenLite.to(_rerollsGlow, 1.0, {alpha:0.0, ease:Quad.easeIn, onComplete:onRerollsGlowFadeOut, overwrite:0});
		}

		override protected function onStateChange( state:String ):void
		{
			if (state == StateEvent.GAME_BATTLE)
				destroy();
		}

		override protected function addEffects():void  { _effects.addEffect(EffectFactory.repositionEffect(PositionEnum.LEFT, PositionEnum.BOTTOM, onStageResized)); }

		private function onStageResized( e:Event = null ):void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			x = 523 * Application.SCALE;
			y = DeviceMetrics.HEIGHT_PIXELS;
			y = (y < MIN_Y_POS) ? MIN_Y_POS : y;
		}

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		[Inject]
		public function set tooltip( value:Tooltips ):void  { _tooltip = value; }

		override public function get type():String  { return ViewEnum.UI }
		override public function get screenshotBlocker():Boolean {return true;}
		override public function destroy():void
		{
			presenter.removeMailCountUpdateListener(onMailCountUpdated);
			presenter.removeWarfrontUpdateListener(onWarfrontUpdated);
			presenter.removeAvailableRerollUpdatedListener(onRerollsUpdated);

			super.destroy();

			showHideMailExclamation(false);

			_btnAlliance = UIFactory.destroyButton(_btnAlliance);
			_btnBattlelog = UIFactory.destroyButton(_btnBattlelog);
			_btnLeaderboard = UIFactory.destroyButton(_btnLeaderboard);
			_btnMail = UIFactory.destroyButton(_btnMail);
			_btnWarfront = UIFactory.destroyButton(_btnWarfront);

			ObjectPool.give(_drawer);
			_drawer = null;

			if (_warfrontGlow)
				TweenLite.killTweensOf(_warfrontGlow);
			if (_rerollsGlow)
				TweenLite.killTweensOf(_rerollsGlow);
			_rerollsGlow = null;
			_tooltip.removeTooltip(null, this);
			_tooltip = null;
		}
	}
}
