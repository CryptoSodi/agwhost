package com.controller.command
{
	import com.Application;
	import com.controller.fte.FTEController;
	import com.controller.transaction.TransactionController;
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.TypeEnum;
	import com.event.TransactionEvent;
	import com.model.blueprint.BlueprintVO;
	import com.model.motd.MotDModel;
	import com.model.player.CurrentUser;
	import com.model.player.OfferVO;
	import com.model.prototype.IPrototype;
	import com.model.starbase.StarbaseModel;
	import com.model.starbase.TradeRouteVO;
	import com.presenter.starbase.IStarbasePresenter;
	import com.presenter.starbase.ITradePresenter;
	import com.ui.modal.building.RepairBaseView;
	import com.ui.modal.construction.ConstructionInfoView;
	import com.ui.modal.construction.ConstructionView;
	import com.ui.modal.fullscreenprompt.FullScreenPromptModal;
	import com.ui.modal.information.BaseActionPromptModal;
	import com.ui.modal.information.MessageOfTheDayView;

	import com.ui.modal.offers.OfferView;
	import org.parade.core.IView;
	import org.parade.core.IViewFactory;
	import org.parade.core.ViewEvent;
	import org.parade.util.DeviceMetrics;
	import org.robotlegs.extensions.presenter.impl.Command;
	
	import com.model.player.CurrentUser;

	import com.model.prototype.PrototypeModel;
	
	public class WelcomeBackCommand extends Command
	{
		public static var shownMOTD:Boolean                    = false;
		public static var shownPromptToAction:Boolean          = false;
		public static var shouldShowPromptToFullScreen:Boolean = false;
		public static var shownPromptToFullScreen:Boolean      = false;
		public static var shownDailyOffer:Boolean          = false;

		[Inject]
		public var fteController:FTEController;
		[Inject]
		public var motdModel:MotDModel;
		[Inject]
		public var starbaseModel:StarbaseModel;
		[Inject]
		public var starbasePresenter:IStarbasePresenter;
		[Inject]
		public var tradePresenter:ITradePresenter;
		[Inject]
		public var transactionController:TransactionController;
		[Inject]
		public var viewFactory:IViewFactory;

		override public function execute():void
		{
			shouldShowPromptToFullScreen = (DeviceMetrics.WIDTH_PIXELS < DeviceMetrics.MAX_WIDTH_PIXELS && DeviceMetrics.HEIGHT_PIXELS < DeviceMetrics.MAX_HEIGHT_PIXELS);

			if (fteController.running)
				return;

			if (starbaseModel.entryView)
				showEntryView();

			if (shouldShowPromptToFullScreen && !shownPromptToFullScreen)
				showPromptToFullScreen();
			else if (!shownMOTD)
				showMOTD();
			else if (!shownPromptToAction)
				showPromptToAction();
			
			//showBaseRepair();
			
			if (!shownDailyOffer)
				showDailyOffer();
		}

		private function showEntryView():void
		{
			var data:*     = starbaseModel.entryData;
			var view:IView = viewFactory.createView(starbaseModel.entryView);
			switch (starbaseModel.entryView)
			{
				case ConstructionInfoView:
					ConstructionInfoView(view).setup(data.type, data.proto);
					break;
				case ConstructionView:
					ConstructionView(view).openOn(data.type, data.groupID, data.subItemID);
					break;
			}
			starbaseModel.entryData = null;
			starbaseModel.entryView = null;
			viewFactory.notify(view);
		}

		private function showMOTD():void
		{
			if (motdModel.hasMessage)
			{
				shownMOTD = true;
				var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
				viewEvent.targetClass = MessageOfTheDayView;
				dispatch(viewEvent);
			} else if (!shownPromptToAction)
				showPromptToAction();
		}

		private function showPromptToAction():void
		{
			if (!shownPromptToAction)
			{
				shownPromptToAction = true;

				var debug:Boolean = false;
				if (debug || (CurrentUser.level <= 20 && !CurrentUser.hasPromptedForBuildAction))
				{
					CurrentUser.hasPromptedForBuildAction = true;

					var actionPrompts:uint;

					if (hasPendingBuilds())
						actionPrompts |= BaseActionPromptModal.BUILD_ACTION;

					if (hasPendingTrade())
						actionPrompts |= BaseActionPromptModal.TRADE_ACTION;

					var researchType:String        = getAvailResearchByType();

					if (researchType == TypeEnum.WEAPONS_FACILITY)
						actionPrompts |= BaseActionPromptModal.RESEARCH_WEAPONS_ACTION;

					else if (researchType == TypeEnum.DEFENSE_DESIGN)
						actionPrompts |= BaseActionPromptModal.RESEARCH_DEFENSE_ACTION;

					else if (researchType == TypeEnum.ADVANCED_TECH)
						actionPrompts |= BaseActionPromptModal.RESEARCH_TECH_ACTION;

					else if (researchType == TypeEnum.SHIPYARD)
						actionPrompts |= BaseActionPromptModal.RESEARCH_SHIPS_ACTION;

					if (actionPrompts == 0)
					{
						showPromptToFullScreen();
						return;
					}

					var view:BaseActionPromptModal = BaseActionPromptModal(viewFactory.createView(BaseActionPromptModal));
					view.actionTypes = actionPrompts;
					viewFactory.notify(view);
				} else
					showPromptToFullScreen();
			} else
				showPromptToFullScreen();
		}

		private function showPromptToFullScreen():void
		{
			if (shouldShowPromptToFullScreen && !shownPromptToFullScreen)
			{
				shownPromptToFullScreen = true;
				var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
				viewEvent.targetClass = FullScreenPromptModal;
				dispatch(viewEvent);
			}
		}

		private function showBaseRepair():void
		{
			if (starbaseModel.isBaseDamaged() && !RepairBaseView.PLAYER_KNOWS_ABOUT_REPAIR && transactionController.getBaseRepairTransaction() == null)
			{
				var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
				viewEvent.targetClass = RepairBaseView;
				dispatch(viewEvent);
			}
		}
		
		private function showDailyOffer():void
		{
			if (!shownDailyOffer)
			{
				shownDailyOffer = true;

				var offers:Vector.<OfferVO> = CurrentUser.offers;				
				if (offers.length > 0)
				{
					var currentOffer:OfferVO;
					currentOffer = offers[0];
					var offerDurationMS:Number = currentOffer.offerDuration * 3600 * 1000;
					if(!(currentOffer.offerPrototype == "BeginnerOffer" &&  (offerDurationMS - currentOffer.timeRemainingMS) < PrototypeModel.instance.getConstantPrototypeValueByName("WelcomeBackBeginnerOfferHideTimeMilliseconds")))
					{
						var offerView:OfferView = OfferView(viewFactory.createView(OfferView));
						offerView.offerProtoName = currentOffer;
						viewFactory.notify(offerView);
					}
				}
			}
		}

		private function hasPendingBuilds():Boolean
		{
			return transactionController.getAllStarbaseBuildingTransactions().length == 0;
		}

		private function hasPendingTrade():Boolean
		{
			var tradeVO:TradeRouteVO;
			var routes:Vector.<TradeRouteVO> = tradePresenter.tradeRoutes;
			var crntTradeRoutes:int;
			var maxTradeRoutes:int           = tradePresenter.maxUnlockedContracts;

			for (var i:int; i < routes.length; i++)
			{
				tradeVO = routes[i];

				if (tradeVO.end != 0)
					crntTradeRoutes++;
			}

			if (crntTradeRoutes < maxTradeRoutes)
				return true;

			return false;
		}

		private function getAvailResearchByType():String
		{
			var type:String;
			var src:Vector.<IPrototype> = starbasePresenter.researchPrototypes;
			var typeHash:Object         = {};

			for (var proto:IPrototype, rqmt:RequirementVO, bprt:BlueprintVO, i:int; i < src.length; i++)
			{
				proto = src[i];

				//filter
				if ((proto.getValue('requiredFaction') == CurrentUser.faction || proto.getValue('requiredFaction') == '') && !proto.getValue('hideWhileLocked'))
				{
					rqmt = starbasePresenter.getRequirements(TransactionEvent.STARBASE_RESEARCH, proto);
					bprt = starbasePresenter.getBlueprintByName(proto.name);

					if (rqmt.allMet || (bprt && !bprt.complete && bprt.partsCollected != 0))
					{
						if (rqmt.purchaseVO.canPurchase || rqmt.purchaseVO.canPurchaseResourcesWithPremium || rqmt.purchaseVO.canPurchaseWithPremium)
						{
							type = proto.getValue("requiredBuildingClass");

							if (type == TypeEnum.WEAPONS_FACILITY)
								typeHash[TypeEnum.WEAPONS_FACILITY] = true;

							else if (type == TypeEnum.DEFENSE_DESIGN)
								typeHash[TypeEnum.DEFENSE_DESIGN] = true;

							else if (type == TypeEnum.ADVANCED_TECH)
								typeHash[TypeEnum.ADVANCED_TECH] = true;

							else if (type == TypeEnum.SHIPYARD)
								typeHash[TypeEnum.SHIPYARD] = true;
						}
					}
				}
			}

			if (typeHash.hasOwnProperty(TypeEnum.WEAPONS_FACILITY))
				return TypeEnum.WEAPONS_FACILITY;

			else if (typeHash.hasOwnProperty(TypeEnum.DEFENSE_DESIGN))
				return TypeEnum.DEFENSE_DESIGN;

			else if (typeHash.hasOwnProperty(TypeEnum.ADVANCED_TECH))
				return TypeEnum.ADVANCED_TECH;

			else if (typeHash.hasOwnProperty(TypeEnum.SHIPYARD))
				return TypeEnum.SHIPYARD;

			else
				return "";
		}
	}
}
