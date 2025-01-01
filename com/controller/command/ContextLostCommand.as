package com.controller.command
{
	import com.Application;
	import com.enum.TypeEnum;
	import com.event.StateEvent;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.fsm.FSM;
	import com.game.entity.components.shared.fsm.Forcefield;
	import com.game.entity.systems.interact.BattleInteractSystem;
	import com.game.entity.systems.interact.StarbaseInteractSystem;
	import com.game.entity.systems.shared.background.BackgroundSystem;
	import com.model.asset.AssetModel;
	import com.util.RangeBuilder;
	import com.util.RouteLineBuilder;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.robotlegs.extensions.presenter.impl.Command;
	import org.starling.text.BitmapFont;
	import org.starling.text.TextField;
	import org.starling.textures.Texture;

	public class ContextLostCommand extends Command
	{
		[Inject]
		public var assetModel:AssetModel;
		[Inject]
		public var rangeBuilder:RangeBuilder;
		[Inject]
		public var routeBuilder:RouteLineBuilder;
		[Inject]
		public var game:Game;

		/**
		 * Stage3D context was lost and all textures were lost with it.
		 * We need to reload and rebuild everything to account for this
		 */
		override public function execute():void
		{
			//set up the OpenSansBold bitmap font
			var ac:Class                           = Class(getDefinitionByName('OpenSansBoldSpriteSheet'));
			var bmd:BitmapData                     = BitmapData(new ac());
			ac = Class(getDefinitionByName('FontsMain'))['OpenSansBoldXML'];
			var xml:XML                            = XML(new ac());
			var bf:BitmapFont                      = new BitmapFont(Texture.fromBitmapData(bmd, false), xml);
			TextField.registerBitmapFont(bf, 'OpenSansBoldBitmap');

			//set the ready flag of all entity animations to false so that spritesheets will be reloaded
			var entities:Dictionary                = game.allEntities;
			for each (var entity:Entity in entities)
			{
				if (entity.has(Animation))
					Animation(entity.get(Animation)).deviceLostContext();
				if (entity.has(FSM))
				{
					var fsm:FSM = FSM(entity.get(FSM));
					if (fsm.component is Forcefield)
						Forcefield(fsm.component).state = Forcefield.POWER_OFF;
				}
			}

			//remove all the current spritepacks which will force them to be recreated
			assetModel.removeAllSpritePacks();

			//force the starfield to be recreated
			var _backgroundSystem:BackgroundSystem = BackgroundSystem(game.getSystem(BackgroundSystem));
			if (_backgroundSystem)
				_backgroundSystem.uninitialize();

			//clear and rebuild ship and building ranges
			rangeBuilder.cleanup();
			if (Application.STATE == StateEvent.GAME_BATTLE || Application.STATE == StateEvent.GAME_BATTLE_INIT)
				BattleInteractSystem(game.getSystem(BattleInteractSystem)).buildRanges();
			else if (Application.STATE == StateEvent.GAME_STARBASE)
				StarbaseInteractSystem(game.getSystem(StarbaseInteractSystem)).updateRanges();

			//clear the data for the routeline so that it gets rebuilt
			assetModel.removeGameAssetData(TypeEnum.ROUTE_LINE);
			if (Application.STATE == StateEvent.GAME_SECTOR)
				routeBuilder.drawRouteLine();
		}

	}
}
