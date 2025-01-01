package com.controller.command
{
	import com.Application;
	import com.controller.fte.FTEController;
	import com.controller.transaction.TransactionController;
	import com.event.BattleEvent;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.model.fleet.FleetModel;
	import com.model.motd.MotDModel;
	import com.model.starbase.StarbaseModel;
	import com.ui.alert.AttackAlert;

	import org.parade.core.IViewFactory;
	import org.parade.core.ViewEvent;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseCommand extends Command
	{
		[Inject]
		public var event:StarbaseEvent;
		[Inject]
		public var fleetModel:FleetModel;
		[Inject]
		public var fteController:FTEController;
		[Inject]
		public var motdModel:MotDModel;
		[Inject]
		public var starbaseModel:StarbaseModel;
		[Inject]
		public var transactionController:TransactionController;
		[Inject]
		public var viewFactory:IViewFactory;

		override public function execute():void
		{
			var battleEvent:BattleEvent;
			var alert:AttackAlert;
			var viewEvent:ViewEvent
			switch (event.type)
			{
				case StarbaseEvent.ALERT_FLEET_BATTLE:
					//inform the player that their fleet is under attack and ask if they want to defend it
					alert = AttackAlert(viewFactory.createView(AttackAlert));
					alert.battleServerAddress = event.battleServerAddress;
					alert.fleetID = event.fleetID;
					alert.fleetName = fleetModel.getFleet(event.fleetID).name;
					viewFactory.notify(alert);
					break;
				case StarbaseEvent.ALERT_STARBASE_BATTLE:
					if (Application.STATE == StateEvent.GAME_STARBASE && event.baseID == starbaseModel.currentBase.id)
					{
						//attack is happening on a base the player is currently viewing. 
						//player cannot make starbase changes while in battle so send straight in
						battleEvent = new BattleEvent(BattleEvent.BATTLE_JOIN, event.battleServerAddress);
						dispatch(battleEvent);
					} else
					{
						//popup up a notification asking the player if they want to defend their base
						alert = AttackAlert(viewFactory.createView(AttackAlert));
						alert.battleServerAddress = event.battleServerAddress;
						viewFactory.notify(alert);
					}
					break;
				case StarbaseEvent.ALERT_INSTANCED_MISSION_BATTLE:
					battleEvent = new BattleEvent(BattleEvent.BATTLE_JOIN, event.battleServerAddress);
					dispatch(battleEvent);
					break;
			}
		}
	}
}
