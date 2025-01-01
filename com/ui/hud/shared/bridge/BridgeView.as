package com.ui.hud.shared.bridge
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.event.StateEvent;
	import com.model.event.EventVO;
	import com.model.player.CurrentUser;
	import com.model.player.OfferVO;
	import com.presenter.shared.IUIPresenter;
	import com.ui.core.View;
	import com.ui.core.effects.EffectFactory;
	import com.ui.modal.achievements.AchievementView;
	import com.ui.modal.event.EventView;
	import com.ui.modal.information.MessageOfTheDayView;
	import com.ui.modal.intro.FAQView;
	import com.ui.modal.offers.OfferView;

	import flash.events.Event;
	import flash.geom.Rectangle;

	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;
	//import flash.external.ExternalInterface;
	
	public class BridgeView extends View
	{
		private var _offerBtn:OfferRiverButton;
		private var _missionRiver:MissionRiver;
		private var _achievementRiverBtn:AchievementRiverButton;
		private var _eventRiverBtn:EventRiverButton;
		private var _faqRiverBtn:FAQRiverButton;
		//private var _discordBtn:DiscordButton;

		private var _offers:Vector.<OfferVO>;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			var bgRect:Rectangle = new Rectangle(14, 133, 40, 2);
			x = 3;
			y = 155;
			_offers = CurrentUser.offers;
			CurrentUser.onPlayerOffersUpdated.add(onOffersUpdated);
			presenter.addEventUpdatedListener(onEventUpdated);

			setUpBridge();
			addHitArea();
			addEffects();
			effectsIN();
			onStageResized();

			visible = !presenter.inFTE;
		}

		private function setUpBridge():void
		{
			_offerBtn = ObjectPool.get(OfferRiverButton);
			_offerBtn.offers = _offers;
			_offerBtn.onClick.add(onOfferClicked);
			addChild(_offerBtn);

			//mission river
			_missionRiver = ObjectPool.get(MissionRiver);
			presenter.injectObject(_missionRiver);
			addChild(_missionRiver);

			_achievementRiverBtn = ObjectPool.get(AchievementRiverButton);
			_achievementRiverBtn.onClick.add(onAchievementRiverClick);
			addChild(_achievementRiverBtn);

			_eventRiverBtn = ObjectPool.get(EventRiverButton);
			_eventRiverBtn.updatedEvents(presenter.currentActiveEvent, presenter.activeEvents, presenter.upcomingEvents);
			_eventRiverBtn.onClick.add(onEventRiverClick);
			_eventRiverBtn.onUpdated.add(layout);
			addChild(_eventRiverBtn);

			_faqRiverBtn = ObjectPool.get(FAQRiverButton);
			_faqRiverBtn.onClick.add(onFAQRiverClick);
			addChild(_faqRiverBtn);

			//_discordBtn = ObjectPool.get(DiscordButton);
			//_discordBtn.onClick.add(onDiscordClick);
			//addChild(_discordBtn);
			
			layout();
		}

		private function onEventUpdated( currentActiveEvent:EventVO, activeEvents:Vector.<EventVO>, upcomingEvents:Vector.<EventVO> ):void
		{
			if (_eventRiverBtn)
				_eventRiverBtn.updatedEvents(currentActiveEvent, activeEvents, upcomingEvents);
		}

		private function onOffersUpdated( v:Vector.<OfferVO> ):void
		{
			if (_offerBtn)
				_offerBtn.offers = v;
		}

		private function onOfferClicked( currentOffer:OfferVO ):void
		{
			if (currentOffer && presenter.hudEnabled)
			{
				var offerView:OfferView = OfferView(_viewFactory.createView(OfferView));
				offerView.offerProtoName = currentOffer;
				_viewFactory.notify(offerView);
			}
		}

		private function onEventRiverClick():void
		{
			var view:*;
			if (_eventRiverBtn.hasScore())
			{
				view = EventView(_viewFactory.createView(EventView));
			} else
			{
				view = MessageOfTheDayView(_viewFactory.createView(MessageOfTheDayView));
			}

			_viewFactory.notify(view);
		}

		private function onAchievementRiverClick():void
		{
			if (!presenter.hudEnabled)
				return;
			var achievementView:AchievementView = AchievementView(_viewFactory.createView(AchievementView));
			_viewFactory.notify(achievementView);
		}

		private function onFAQRiverClick():void
		{
			if (!presenter.hudEnabled)
				return;
			var faqView:FAQView = FAQView(_viewFactory.createView(FAQView));
			_viewFactory.notify(faqView);
		}
		
		// private function onDiscordClick():void
		// {
			// if (!presenter.hudEnabled)
				// return;
			// ExternalInterface.call("window.open", "https://discord.gg/igw", "_blank"); //Open Discord
		// }

		override protected function onStateChange( state:String ):void
		{
			if (state == StateEvent.GAME_BATTLE)
				destroy();
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.LEFT, PositionEnum.CENTER, onStageResized));
		}

		private function onStageResized( e:Event = null ):void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			x = 3;
			y = 166 * Application.SCALE;
			layout();
		}

		private function layout():void
		{
			var xPos:uint     = 12;
			var yPos:uint     = 15;

			var height:Number = 0;

			if (_offerBtn)
			{
				_offerBtn.x = xPos - 22;
				_offerBtn.y = yPos;
				yPos += _offerBtn.height + 4;
			}

			//to not break the fte we can't do a visibility check
			if (_missionRiver)
			{
				_missionRiver.x = xPos;
				_missionRiver.y = yPos;
				yPos += _missionRiver.height - 3;
			}

			if (_achievementRiverBtn)
			{
				_achievementRiverBtn.x = xPos;
				_achievementRiverBtn.y = yPos;
				yPos += _achievementRiverBtn.height + 3;
			}

			if (_eventRiverBtn && _eventRiverBtn.visible)
			{
				_eventRiverBtn.x = xPos;
				_eventRiverBtn.y = yPos;
				yPos += _eventRiverBtn.height + 3;
			}

			if (_faqRiverBtn)
			{
				if (DeviceMetrics.HEIGHT_PIXELS < 890 && (_eventRiverBtn && _eventRiverBtn.visible))
				{
					_faqRiverBtn.x = _offerBtn.x + _offerBtn.width - 50;
					_faqRiverBtn.y = _eventRiverBtn.y;
				} else
				{
					_faqRiverBtn.x = xPos;
					_faqRiverBtn.y = yPos;
				}
			}
			
			// if (_discordBtn)
			// {
				// if (DeviceMetrics.HEIGHT_PIXELS < 890 && (_eventRiverBtn && _eventRiverBtn.visible))
				// {
					// _discordBtn.x = _offerBtn.x + _offerBtn.width - 50;
					// _discordBtn.y = _achievementRiverBtn.y;
				// } else
				// {
					// yPos += _faqRiverBtn.height + 3;
					// _discordBtn.x = xPos;
					// _discordBtn.y = yPos;
					
				// }
			// }
		}

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function get type():String  { return ViewEnum.UI }
		
		override public function get screenshotBlocker():Boolean {return true;}
		
		override public function destroy():void
		{
			CurrentUser.onPlayerOffersUpdated.remove(onOffersUpdated);
			presenter.removeEventUpdatedListener(onEventUpdated);

			//Offer River
			if (_offerBtn)
				ObjectPool.give(_offerBtn);

			_offerBtn = null;

			//Mission river
			if (_missionRiver)
				ObjectPool.give(_missionRiver);

			_missionRiver = null;

			//Achievement River
			if (_achievementRiverBtn)
				ObjectPool.give(_achievementRiverBtn);

			_achievementRiverBtn = null;

			//Event River
			if (_eventRiverBtn)
				ObjectPool.give(_eventRiverBtn);

			_eventRiverBtn = null;

			//FAQ River
			if (_faqRiverBtn)
				ObjectPool.give(_faqRiverBtn);

			_faqRiverBtn = null;
			
			//Discord Button
			// if (_discordBtn)
				// ObjectPool.give(_discordBtn);
			
			// _discordBtn = null;


			super.destroy();
		}
	}
}
