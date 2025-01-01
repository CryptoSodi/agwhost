package com.controller.command.state
{
	import com.Application;
	import com.controller.ChatController;
	import com.event.SectorEvent;
	import com.event.StateEvent;
	import com.event.TransitionEvent;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.sector.SectorModel;
	import com.model.starbase.StarbaseModel;

	import org.robotlegs.extensions.presenter.impl.Command;

	public class SectorCoreCommand extends Command
	{
		[Inject]
		public var event:SectorEvent;
		[Inject]
		public var fleetModel:FleetModel;
		[Inject]
		public var sectorModel:SectorModel;
		[Inject]
		public var starbaseModel:StarbaseModel;
		[Inject]
		public var chatController:ChatController;

		override public function execute():void
		{
			if (event.sector)
			{
				sectorModel.targetSector = event.sector;
			}
			if (event.focusFleetID)
			{
				var fleet:FleetVO = fleetModel.getFleet(event.focusFleetID);
				if (fleet)
				{
					sectorModel.targetSector = fleet.sector != "" ? fleet.sector : starbaseModel.getBaseByID(fleet.starbaseID).sectorID;
				}
				sectorModel.focusFleetID = event.focusFleetID;
			}
			if (sectorModel.targetSector == null || sectorModel.viewBase)
				sectorModel.targetSector = starbaseModel.currentBase.sectorID;
			sectorModel.focusLocation.setTo(event.focusX, event.focusY);
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
			transitionEvent.addEvents(new StateEvent(StateEvent.GAME_SECTOR_INIT, cleanupState), new StateEvent(cleanupState, StateEvent.GAME_SECTOR_INIT));
			dispatch(transitionEvent);
		}
	}
}


