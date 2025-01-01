package com.controller.command.state
{
	import com.Application;
	import com.controller.ServerController;
	import com.controller.fte.FTEController;
	import com.event.BattleEvent;
	import com.event.SectorEvent;
	import com.event.ServerEvent;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.model.asset.ISpriteSheet;
	import com.model.asset.SpriteSheet;
	import com.model.asset.SpriteSheetStarling;
	import com.model.starbase.StarbaseModel;
	import com.presenter.preload.IPreloadPresenter;
	import com.ui.GameView;
	import com.ui.PreloadView;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;

	import org.ash.integration.swiftsuspenders.NodeLookup;
	import org.parade.core.ViewEvent;
	import org.starling.text.BitmapFont;
	import org.starling.text.TextField;
	import org.starling.textures.Texture;

	public class PreloadCommand extends StateCommand
	{
		[Inject]
		public var fteController:FTEController;
		[Inject]
		public var preloadPresenter:IPreloadPresenter;
		[Inject]
		public var serverController:ServerController;
		[Inject]
		public var starbaseModel:StarbaseModel;

		override public function execute():void
		{
			if (event.type == StateEvent.PRELOAD)
				begin();
			else
				complete();
		}

		private function begin():void
		{
			var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
			viewEvent.targetClass = GameView;
			dispatch(viewEvent);

			viewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
			viewEvent.targetClass = PreloadView;
			dispatch(viewEvent);
		}

		private function complete():void
		{
			//Used by Ash to determine which node type to use
			NodeLookup.addLookup("IFleetNode", (!Application.STARLING_ENABLED) ? "com.game.entity.nodes.sector.fleet.FleetNode" : "com.game.entity.nodes.sector.fleet.FleetStarlingNode");
			NodeLookup.addLookup("IShipNode", (!Application.STARLING_ENABLED) ? "com.game.entity.nodes.battle.ship.ShipNode" : "com.game.entity.nodes.battle.ship.ShipStarlingNode");
			NodeLookup.addLookup("IVCNode", (!Application.STARLING_ENABLED) ? "com.game.entity.nodes.shared.visualComponent.VCNode" : "com.game.entity.nodes.shared.visualComponent.VCStarlingNode");
			NodeLookup.addLookup("IVCSpriteNode", (!Application.STARLING_ENABLED) ? "com.game.entity.nodes.shared.visualComponent.VCSpriteNode" : "com.game.entity.nodes.shared.visualComponent.VCSpriteStarlingNode");

			//set starling specific options
			if (Application.STARLING_ENABLED)
			{
				injector.map(ISpriteSheet).toType(SpriteSheetStarling);

				//set up the OpenSansBold bitmap font
				var ac:Class       = Class(getDefinitionByName('OpenSansBoldSpriteSheet'));
				var bmd:BitmapData = BitmapData(new ac());
				ac = Class(getDefinitionByName('FontsMain'))['OpenSansBoldXML'];
				var xml:XML        = XML(new ac());
				var bf:BitmapFont  = new BitmapFont(Texture.fromBitmapData(bmd, false), xml);
				TextField.registerBitmapFont(bf, 'OpenSansBoldBitmap');

			} else
			{
				injector.map(ISpriteSheet).toType(SpriteSheet);
			}

			preloadPresenter.completeSignal.dispatch();
			serverController.lockRead = false;

			if (Application.CONNECTION_STATE == ServerEvent.AUTHORIZED)
			{
				var event:Event;
				if (fteController.startInSector)
					event = new SectorEvent(SectorEvent.CHANGE_SECTOR, starbaseModel.homeBase.sectorID);
				else if (starbaseModel.homeBase.battleServerAddress != null)
					event = new BattleEvent(BattleEvent.BATTLE_JOIN, starbaseModel.homeBase.battleServerAddress);
				else if (starbaseModel.homeBase.instancedMissionAddress != null)
					event = new BattleEvent(BattleEvent.BATTLE_JOIN, starbaseModel.homeBase.instancedMissionAddress);
				else
					event = new StarbaseEvent(StarbaseEvent.ENTER_BASE);
				dispatch(event);
				return;
			}
		}
	}
}
