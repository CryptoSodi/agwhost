package com.controller.command.state
{
	import com.Application;
	import com.event.BattleEvent;
	import com.event.StateEvent;
	import com.event.TransitionEvent;
	import com.model.battle.BattleModel;
	import com.model.scene.SceneModel;
	import com.model.sector.SectorModel;

	import org.parade.core.ViewEvent;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class BattleCoreCommand extends Command
	{
		[Inject]
		public var battleModel:BattleModel;
		[Inject]
		public var event:BattleEvent;
		[Inject]
		public var sceneModel:SceneModel;
		[Inject]
		public var sectorModel:SectorModel;

		override public function execute():void
		{
			var viewEvent:ViewEvent;
			switch (event.type)
			{
				case BattleEvent.BATTLE_JOIN:
				case BattleEvent.BATTLE_REPLAY:
					battleModel.isReplay = (event.type == BattleEvent.BATTLE_REPLAY); 
					battleModel.finished = false;
					battleModel.battleServerAddress = event.battleServerAddress;
					if (Application.STATE != StateEvent.GAME_BATTLE)
					{
						battleModel.oldGameState = Application.STATE;
						//save the view location so we can center on the correct spot again once the battle is over
						if (Application.STATE == StateEvent.GAME_SECTOR)
						{
							battleModel.oldSector = sectorModel.sectorID;
							battleModel.focusLocation.setTo(sceneModel.focus.x, sceneModel.focus.y);
						} else
							battleModel.focusLocation.setTo(0, 0);
					}
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
					transitionEvent.addEvents(new StateEvent(StateEvent.GAME_BATTLE_INIT, cleanupState), new StateEvent(cleanupState, StateEvent.GAME_BATTLE_INIT));
					dispatch(transitionEvent);
					break;
			}
		}
	}
}


