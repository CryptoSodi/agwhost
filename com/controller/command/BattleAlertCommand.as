package com.controller.command
{
	import com.controller.ServerController;
	import com.event.BattleEvent;
	import com.presenter.battle.IBattlePresenter;
	import com.service.server.incoming.battle.BattleDataResponse;
	import com.service.server.incoming.battle.BattleHasEndedResponse;
	import com.service.server.incoming.data.BattleData;
	import com.ui.modal.battle.BattleEndView;
	import com.ui.modal.battle.BattleStartView;
	
	import org.parade.core.IViewFactory;
	import org.parade.core.ViewController;
	import org.parade.core.ViewEvent;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class BattleAlertCommand extends Command
	{
		[Inject]
		public var event:BattleEvent;
		[Inject]
		public var viewController:ViewController;
		[Inject]
		public var viewFactory:IViewFactory;
		[Inject]
		public var presenter:IBattlePresenter;

		override public function execute():void
		{
			var viewEvent:ViewEvent
			switch (event.type)
			{
				case BattleEvent.BATTLE_COUNTDOWN:
					var battleStartResponse:BattleData = BattleData(event.response);
					var battleStart:BattleStartView;
					if (viewController.getView(BattleStartView))
					{
						battleStart = BattleStartView(viewController.getView(BattleStartView));
						battleStart.update(ServerController.SIMULATED_TICK, battleStartResponse.battleStartTick);
					} else
					{
						battleStart = BattleStartView(viewFactory.createView(BattleStartView));
						battleStart.update(ServerController.SIMULATED_TICK, battleStartResponse.battleStartTick);
						viewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
						viewEvent.targetView = battleStart;
						dispatch(viewEvent);
					}
					break;
				case BattleEvent.BATTLE_STARTED:
					presenter.onBattleStarted();
					break;
				case BattleEvent.BATTLE_ENDED:
					presenter.onBattleEnded();
					var response:BattleHasEndedResponse             = BattleHasEndedResponse(event.response);
					var battleEnd:BattleEndView                     = BattleEndView(viewFactory.createView(BattleEndView));
					battleEnd.battleID = response.battleKey;
					battleEnd.victors = response.victors;
					battleEnd.lootedAlloyAmount = response.alloyLoot;
					battleEnd.lootedCreditsAmount = response.creditBounty;
					battleEnd.lootedEnergyAmount = response.energyLoot;
					battleEnd.lootedSyntheticsAmount = response.syntheticLoot;
					battleEnd.blueprintProtoName = response.blueprintReward;
					battleEnd.cargoFull = response.cargoFull;
					viewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
					viewEvent.targetView = battleEnd;
					dispatch(viewEvent);
					break;
			}
		}
	}
}
