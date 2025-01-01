package com.controller.command.state
{
	import com.Application;
	import com.event.BattleEvent;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.event.TransitionEvent;
	import com.model.starbase.StarbaseModel;

	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseCoreCommand extends Command
	{
		[Inject]
		public var event:StarbaseEvent;
		[Inject]
		public var starbaseModel:StarbaseModel;

		override public function execute():void
		{
			switch (event.type)
			{
				case StarbaseEvent.ENTER_INSTANCED_MISSION:
					if(starbaseModel.homeBase.instancedMissionAddress != null)
					{
						var battleEvent:BattleEvent = new BattleEvent(BattleEvent.BATTLE_JOIN, starbaseModel.homeBase.instancedMissionAddress);
						dispatch(battleEvent);
					}
					break;
				case StarbaseEvent.ENTER_BASE:
					if (event.baseID)
						starbaseModel.switchBase(event.baseID);
					//ensure that the player's base is not under attack
					if (starbaseModel.currentBase.battleServerAddress == null)
					{
						starbaseModel.entryData = event.viewData;
						starbaseModel.entryView = event.view;
						var transitionEvent:TransitionEvent = new TransitionEvent(TransitionEvent.TRANSITION_BEGIN);
						var cleanupState:String;
						switch (Application.STATE)
						{
							case StateEvent.GAME_BATTLE_INIT:
							case StateEvent.GAME_BATTLE:
								cleanupState = StateEvent.GAME_BATTLE_CLEANUP;
								break;
							case StateEvent.GAME_SECTOR_INIT:
							case StateEvent.GAME_SECTOR:
								cleanupState = StateEvent.GAME_SECTOR_CLEANUP;
								break;
							case StateEvent.GAME_STARBASE:
								cleanupState = StateEvent.GAME_STARBASE_CLEANUP;
								break;
							case null:
							case StateEvent.PRELOAD:
								cleanupState = "";
								break;
							default:
								cleanupState = StateEvent.DEFAULT_CLEANUP;
								break;
						}
						transitionEvent.addEvents(new StateEvent(StateEvent.GAME_STARBASE, cleanupState), new StateEvent(cleanupState, StateEvent.GAME_STARBASE));
						dispatch(transitionEvent);
					} else
					{
						//player's base is under attack so go into the battle
						var battleEvent:BattleEvent = new BattleEvent(BattleEvent.BATTLE_JOIN, starbaseModel.currentBase.battleServerAddress);
						dispatch(battleEvent);
					}
					break;
			}
		}
	}
}
