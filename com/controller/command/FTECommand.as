package com.controller.command
{
	import com.Application;
	import com.controller.GameController;
	import com.controller.ServerController;
	import com.controller.fte.FTEController;
	import com.controller.sound.SoundController;
	import com.controller.toast.ToastController;
	import com.controller.transaction.TransactionController;
	import com.enum.AudioEnum;
	import com.enum.CategoryEnum;
	import com.enum.ToastEnum;
	import com.enum.TypeEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.FTEEvent;
	import com.event.StateEvent;
	import com.event.ToastEvent;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.game.entity.nodes.shared.grid.GridNode;
	import com.game.entity.systems.interact.BattleInteractSystem;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.game.entity.systems.interact.StarbaseInteractSystem;
	import com.game.entity.systems.shared.grid.GridSystem;
	import com.model.asset.AssetModel;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.mission.MissionInfoVO;
	import com.model.mission.MissionModel;
	import com.model.mission.MissionVO;
	import com.model.scene.SceneModel;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.presenter.shared.IUIPresenter;
	import com.service.ExternalInterfaceAPI;
	import com.service.server.outgoing.battle.BattlePauseRequest;
	import com.ui.alert.FTEOverlayView;
	import com.ui.core.component.contextmenu.ContextMenu;
	import com.ui.hud.shared.PlayerView;
	import com.ui.modal.battle.BattleEndView;
	import com.ui.modal.intro.FTETipView;
	import com.ui.modal.intro.PulseScaleEffect;
	import com.ui.modal.mission.FTEDialogueView;
	import com.ui.modal.shipyard.ComponentSelection;
	import com.ui.modal.shipyard.ShipyardView;

	import flash.display.DisplayObject;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.Node;
	import org.ash.core.NodeList;
	import org.parade.core.IView;
	import org.parade.core.IViewFactory;
	import org.parade.core.ViewController;
	import org.parade.core.ViewEvent;
	import org.parade.util.DeviceMetrics;
	import org.robotlegs.extensions.presenter.impl.Command;
	import org.shared.ObjectPool;

	public class FTECommand extends Command
	{
		private static const GLOW_FILTER:GlowFilter = new GlowFilter(0xffff00, 0.8, 5, 5, 4, BitmapFilterQuality.HIGH);
		private static const NEUTRAL:int            = 0;
		private static const SERIOUS:int            = 1;
		private static const SMILE:int              = 2;
		private static const SURPRISED:int          = 3;

		private static var _glowEntity:Entity;
		private static var _glowUI:DisplayObject;
		private static var _scaleUI:PulseScaleEffect;

		[Inject]
		public var assetModel:AssetModel;
		[Inject]
		public var event:FTEEvent;
		[Inject]
		public var fleetModel:FleetModel;
		[Inject]
		public var fteController:FTEController;
		[Inject]
		public var game:Game;
		[Inject]
		public var gameController:GameController;
		[Inject]
		public var missionModel:MissionModel;
		[Inject]
		public var sceneModel:SceneModel;
		[Inject]
		public var serverController:ServerController;
		[Inject]
		public var soundController:SoundController;
		[Inject]
		public var starbaseModel:StarbaseModel;
		[Inject]
		public var toastController:ToastController;
		[Inject]
		public var transactionController:TransactionController;
		[Inject]
		public var uiPresenter:IUIPresenter;
		[Inject]
		public var viewController:ViewController;
		[Inject]
		public var viewFactory:IViewFactory;

		private var _dialogueView:FTEDialogueView;
		private var _overlayView:FTEOverlayView;

		override public function execute():void
		{
			//if we added a glow to an entity last step, remove it
			_glowEntity && removeGlowFromEntity(_glowEntity);
			removeGlowFromUI();
			removeScaleFromUI();

			//determine which type of fte event this is and act accordingly
			switch (event.type)
			{
				case FTEEvent.FTE_COMPLETE:
					ExternalInterfaceAPI.popPixel(2)
					showHideOverlay(false);
					showHideDialog(false);
					break;
				case FTEEvent.FTE_STEP:
					showHideOverlay(true);
					showHideDialog(true);
					addCodeTrigger();
					break;
			}
		}

		private function showHideOverlay( show:Boolean = true ):void
		{
			_overlayView = FTEOverlayView(viewController.getView(FTEOverlayView));
			if (_overlayView)
			{
				if (_overlayView.presenter != null)
					_overlayView.destroy();
				else
					viewController.removeFromQueue(FTEOverlayView);
			}

			if (show)
			{
				var view:IView;
				var viewAlreadyExisted:Boolean = true;
				if (event.step.viewClass != null)
				{
					view = viewController.getView(event.step.viewClass);
					if (!view)
					{
						viewAlreadyExisted = false;
						view = viewFactory.createView(event.step.viewClass);
						viewFactory.notify(view);
					}
				}

				_overlayView = FTEOverlayView(viewFactory.createView(FTEOverlayView));
				_overlayView.clickToContinue = event.step.cutout == null;
				_overlayView.fteStepVO = event.step;
				_overlayView.view = view;
				_overlayView.viewAlreadyExisted = viewAlreadyExisted;
				viewFactory.notify(_overlayView);
			}
		}

		private function showHideDialog( show:Boolean = true ):void
		{
			//show / hide the dialogue view. see if the view already exists before making a new one
			_dialogueView = FTEDialogueView(viewController.getView(FTEDialogueView));
			if (!show && _dialogueView)
				_dialogueView.destroy();
			else if (_dialogueView || (event.step.dialog != null && event.step.dialog != ""))
			{
				var dialogueAlreadyExisted:Boolean = true;
				if (!_dialogueView)
				{
					dialogueAlreadyExisted = false;
					_dialogueView = FTEDialogueView(viewFactory.createView(FTEDialogueView));
				} else if (_dialogueView.parent)
					_dialogueView.parent.addChild(_dialogueView);
				var info:MissionInfoVO             = ObjectPool.get(MissionInfoVO);
				if (event.step.dialog != null && event.step.dialog != "")
				{
					info.addDialog(event.step.dialog);
					info.addTitle(event.step.titleText.toLocaleUpperCase(), 0xffb128);
				}

				switch (event.step.mood)
				{
					case NEUTRAL:
						info.addImages("AITS_new.png", "AITS_new.png", "AITS_new.png");
						break;
					case SERIOUS:
						info.addImages("AITS_Flirty.png", "AITS_Flirty.png", "AITS_Flirty.png");
						break;
					case SMILE:
						info.addImages("AITS_Smile.png", "AITS_Smile.png", "AITS_Smile.png");
						break;
					case SURPRISED:
						info.addImages("AITS_Surprised.png", "AITS_Surprised.png", "AITS_Surprised.png");
						break;
				}
				info.currentProgress = event.step.currentStep;
				info.progressRequired = event.step.totalSteps;
				_dialogueView.nextButtonEnabled = event.step.cutout == null;
				_dialogueView.info = info;
				_dialogueView.hideViews();
				_dialogueView.unhideViews();
				if (event.step.voiceOver && event.step.voiceOver != "")
					soundController.playSound(event.step.voiceOver, .47);

				if (!dialogueAlreadyExisted)
					viewFactory.notify(_dialogueView);

				if (_overlayView)
					_overlayView.dialogueView = _dialogueView;
			}
		}

		private function addCodeTrigger():void
		{
			//hide or show the leftside bridge
			var view:*;

			if (!event.step.trigger)
				return;
			var entity:Entity;
			var mission:MissionVO;
			var p:Point, p2:Point, p3:Point;
			var params:Array;
			var position:Position;
			var pauseRequest:BattlePauseRequest;
			var triggers:Array = event.step.trigger.split(',');
			var haltCommands:Boolean;
			var anim:Animation;

			for (var a:int = 0; a < triggers.length; a++)
			{
				if (haltCommands)
					break;

				params = triggers[a].split('|');
				switch (params[0])
				{
					// Moves the view to the center point between the player and enemy fleets
					case "centerOnFleets":
						entity = findFleet(true);
						p = (entity.get(Position) as Position).position;
						entity = findFleet(false);
						p2 = (entity.get(Position) as Position).position;
						p3 = Point.interpolate(p, p2, 0.5);
						BattleInteractSystem(game.getSystem(BattleInteractSystem)).moveToLocation(p3.x, p3.y, .5);
						break;

					case "centerOnTransgate":
						entity = findTransgate();

						if (entity)
						{
							position = entity.get(Position);
							SectorInteractSystem(game.getSystem(SectorInteractSystem)).moveToLocation(position.x, position.y, 0.5);

							p = new Point(DeviceMetrics.WIDTH_PIXELS * .5, DeviceMetrics.HEIGHT_PIXELS * .5);
							anim = entity.get(Animation);
							if (anim)
							{
								p.x += anim.offsetX * 0.5;
							}

							event.step.arrowPosition = p;
							event.step.arrowRotation = 180;
							if (_overlayView && _overlayView.parent)
								_overlayView.showArrow();
						}
						break;

					//checks to see if the fleet is in battle, if not it notifies gamecontroller that the fte is waiting on it
					case "checkFleetInBattle":
						var inBattle:Boolean        = false;
						var fleets:Vector.<FleetVO> = fleetModel.fleets;
						for (var i:int = 0; i < fleets.length; i++)
						{
							if (fleets[i].inBattle)
							{
								inBattle = true;
								break;
							}
						}
						if (!inBattle)
						{
							//fleet is not yet in battle. let the gamecontroller know
							//when the fleet enters battle the gamecontroller will progress the fte
							if (_dialogueView)
								_dialogueView.nextButtonEnabled = false;
							if (_overlayView)
								_overlayView.clickToContinue = false;
							gameController.inFTE = true;
						}
						break;

					//check to see if the player is on the mission needed for the next step
					case "checkForMission":
						mission = missionModel.currentMission;
						var names:Array             = event.step.missionName.split(',');
						var index:int               = names.indexOf(mission.name);
						if (index > -1)
						{
							fteController.nextStep();
						}
						break;

					//closes a view specified in the parameters
					case "closeView":
						var viewClass:Class         = Class(getDefinitionByName(params[1]));
						view = viewController.getView(viewClass);
						if (view)
							view.destroy();
						break;

					//disables the next button in the fte
					case "disableNext":
						if (_dialogueView)
							_dialogueView.nextButtonEnabled = false;
						if (_overlayView)
							_overlayView.clickToContinue = false;
						break;

					case "disableHUD":
						uiPresenter.hudEnabled = false;
						break;

					case "enableHUD":
						uiPresenter.hudEnabled = true;
						break;

					//a few missions need the client to progress them. use this trigger to do so
					case "forceMissionComplete":
						mission = missionModel.currentMission;
						if (mission)
						{
							transactionController.missionStepRequest(mission.name, 1);
						}
						break;

					//call this to have the game follow a fleet as it moves on the screen
					case "followFleet":
						entity = findFleet(true);
						if (Application.STATE == StateEvent.GAME_BATTLE)
						{
							BattleInteractSystem(game.getSystem(BattleInteractSystem)).inFTE = true;
							BattleInteractSystem(game.getSystem(BattleInteractSystem)).followEntity = entity;
						} else
						{
							SectorInteractSystem(game.getSystem(SectorInteractSystem)).inFTE = true;
							SectorInteractSystem(game.getSystem(SectorInteractSystem)).followEntity = entity;
						}
						break;

					//sometimes an fte step needs to be forced onto the next step without any user interaction
					case "forceNextStep":
						fteController.nextStep();
						break;

					case "hideOverlay":
						showHideOverlay(false);
						break;
					case "hideDialogue":
						showHideDialog(false);
						break;

					case "highlightUI":
						highlightUI(params[1]);
						break;

					//call this to have the game follow a fleet as it moves on the screen
					case "ignoreStoreOffset":
						if (_overlayView)
							_overlayView.ignoreStoreOffset = true;
						break;

					//closes a view specified in the parameters
					case "killToast":
						toastController.killCurrentToast();
						break;

					case "moveToEnemyFleet":
						entity = findFleet(false);
						position = entity.get(Position);
						BattleInteractSystem(game.getSystem(BattleInteractSystem)).moveToLocation(position.x, position.y, .5);
						break;
					case "moveToFleet":
						if (Application.STATE == StateEvent.GAME_BATTLE)
						{
							entity = findFleet(true);
							position = entity.get(Position);
							BattleInteractSystem(game.getSystem(BattleInteractSystem)).moveToLocation(position.x, position.y, .5);
						} else
						{
							entity = findFleet(true);
							if (entity)
							{
								SectorInteractSystem(game.getSystem(SectorInteractSystem)).selectEntity(entity);
							} else
							{
								fleets = fleetModel.fleets;
								for (i = 0; i < fleets.length; i++)
								{
									if (fleets[i].sector != '')
									{
										SectorInteractSystem(game.getSystem(SectorInteractSystem)).jumpToLocation(fleets[i].sectorLocationX, fleets[i].sectorLocationY);
										break;
									}
								}
							}
						}
						break;
					case "notifyOnBattleEnd":
						gameController.inFTE = true;
						break;
					case "pauseBattle":
						pauseRequest = BattlePauseRequest(serverController.getRequest(ProtocolEnum.BATTLE_CLIENT, RequestEnum.BATTLE_PAUSE));
						pauseRequest.pause = true;
						serverController.send(pauseRequest);
						break;

					//let StarbaseInteractSystem know that the fte is running and the player is placing a building
					case "placeBuilding":
						StarbaseInteractSystem(game.getSystem(StarbaseInteractSystem)).inFTE = true;
						//destroy the overlay so the player can click
						showHideOverlay(false);
						break;

					case "playThemeMusic":
						soundController.playSound(AudioEnum.AFX_BG_MAIN_THEME, 0.07, 0, 100);
						break;

					//points to a specific building. pass the itemClass in as a parameter ie. pointToBuilding|CommandCenter
					case "pointToBuilding":
						entity = findBuilding(params[1]);
						if (entity)
						{
							position = entity.get(Position);
							StarbaseInteractSystem(game.getSystem(StarbaseInteractSystem)).moveToLocation(position.x, position.y, .5);
							p = new Point(DeviceMetrics.WIDTH_PIXELS * .5, DeviceMetrics.HEIGHT_PIXELS * .5);
							p2 = p.clone();
							anim = entity.get(Animation);
							if (anim)
							{
								p2.x += anim.offsetX * 0.5;
							}

							event.step.arrowPosition = p2;
							event.step.arrowRotation = 180;
							if (_overlayView && _overlayView.parent)
								_overlayView.showArrow();
						}
						break;

					case "pointToCenterOfScreen":
						pointToCenterOfScreen();
						break;

					case "pressWASD":
						BattleInteractSystem(game.getSystem(BattleInteractSystem)).inFTE = true;
						break;

					//when Application.STATE changes the fte will progress to the next step
					case "progressOnStateChange":
						fteController.progressStepOnStateChange = true;
						break;

					case "rolloverTrigger":
						if (_overlayView)
							_overlayView.rolloverTrigger();
						break;

					//called to select the first item in a context menu. TODO: Add the index of the item to select in the parameters
					case "selectContextMenu":
						var contextMenu:ContextMenu = ContextMenu(viewController.getView(ContextMenu));
						if (contextMenu)
						{
							contextMenu.destroyOnRollout = false;
							fteController.closeContext = contextMenu;
						}
						break;

					//selects the players starbase
					case "selectBase":
						selectEntity(findBase(), 100, 100, 0);
						SectorInteractSystem(game.getSystem(SectorInteractSystem)).inFTE = true;
						break;

					//selects a specific building. pass the itemClass in as a parameter ie. selectBuilding|CommandCenter
					case "selectBuilding":
						entity = findBuilding(params[1]);
						if (entity)
						{
							position = entity.get(Position);
							StarbaseInteractSystem(game.getSystem(StarbaseInteractSystem)).moveToLocation(position.x, position.y, .5);
							selectEntity(entity, 200, 200);
							StarbaseInteractSystem(game.getSystem(StarbaseInteractSystem)).inFTE = true;
						}
						if (_dialogueView)
							_dialogueView.nextButtonEnabled = false;
						if (_overlayView)
							_overlayView.clickToContinue = false;
						break;

					//selects a fleet
					case "selectEnemyFleet":
					case "selectFleet":
						selectEntity(findFleet(params[0] == "selectFleet"), 100, 100);
						if (Application.STATE == StateEvent.GAME_BATTLE)
							BattleInteractSystem(game.getSystem(BattleInteractSystem)).inFTE = true;
						else
							SectorInteractSystem(game.getSystem(SectorInteractSystem)).inFTE = true;
						break;

					//ship slots differ for each faction so we can't rely on the normal way we do cutouts and arrows.
					//this trigger will find a slot of the specified type and highlight it
					case "selectShipSlot":
						var shipyard:ShipyardView   = ShipyardView(viewController.getView(ShipyardView));
						if (shipyard.components[0].parent.x == 0 && shipyard.components[0].parent.y == 0)
							shipyard.addLoadCallback(onShipyardLoad);
						else
							onShipyardLoad();
						break;

					case "showTipModal":
						var viewEvent:ViewEvent     = new ViewEvent(ViewEvent.SHOW_VIEW);
						viewEvent.targetClass = FTETipView;
						dispatch(viewEvent);
						
						uiPresenter.playSound("sounds/vo/fte/FTE_001.mp3");
						break;

					case "toastImage":
						var asset:String            = "assets/" + params[1];
						var text:String             = params[2];
						var toastEvent:ToastEvent   = new ToastEvent();
						toastEvent.data = {url:asset, text:text};
						toastEvent.toastType = ToastEnum.FTE_REWARD;
						dispatch(toastEvent);
						break;

					case "unpauseBattle":
						pauseRequest = BattlePauseRequest(serverController.getRequest(ProtocolEnum.BATTLE_CLIENT, RequestEnum.BATTLE_PAUSE));
						pauseRequest.pause = false;
						serverController.send(pauseRequest);
						break;

					case "waitForMove":
						BattleInteractSystem(game.getSystem(BattleInteractSystem)).toggleFTEProgressOnMove();
						break;

					default:
						throw new Error("No such FTE command: " + triggers[a]);
				}
			}
		}

		private function findBase():Entity
		{
			var entity:Entity;
			var nodes:NodeList;
			var sectorInteractSystem:SectorInteractSystem = SectorInteractSystem(game.getSystem(SectorInteractSystem));
			nodes = sectorInteractSystem.owned;
			for (var node:Node = nodes.head; node; node = node.next)
			{
				if (Detail(node.entity.get(Detail)).category == CategoryEnum.SECTOR)
				{
					entity = node.entity;
					break;
				}
			}
			return entity;
		}

		private function findBuilding( type:String ):Entity
		{
			var buildings:Vector.<BuildingVO> = starbaseModel.buildings;
			var entity:Entity;
			for (var i:int = 0; i < buildings.length; i++)
			{
				if (buildings[i].itemClass == type)
				{
					entity = game.getEntity(buildings[i].id);
					break;
				}
			}
			return entity;
		}

		private function findFleet( owned:Boolean ):Entity
		{
			var entity:Entity;
			var node:Node;
			var nodes:NodeList;
			if (Application.STATE == StateEvent.GAME_BATTLE)
			{
				var battleSystem:BattleInteractSystem = BattleInteractSystem(game.getSystem(BattleInteractSystem));
				nodes = owned ? battleSystem.owned : battleSystem.enemy;
				for (node = nodes.head; node; node = node.next)
				{
					if (Detail(node.entity.get(Detail)).category == CategoryEnum.SHIP)
					{
						entity = node.entity;
						break;
					}
				}
			} else if (owned)
			{
				var sectorInteractSystem:SectorInteractSystem = SectorInteractSystem(game.getSystem(SectorInteractSystem));
				nodes = sectorInteractSystem.owned;
				for (node = nodes.head; node; node = node.next)
				{
					if (Detail(node.entity.get(Detail)).category == CategoryEnum.SHIP)
					{
						entity = node.entity;
						break;
					}
				}
			}
			return entity;
		}

		private function findTransgate():Entity
		{
			var entity:Entity;

			// This will only work in sector mode, because it's the only place transgates are found, naturally.
			var gridSystem:GridSystem = GridSystem(game.getSystem(GridSystem));
			for (var node:GridNode = gridSystem.nodes.head; node; node = node.next)
			{
				var detail:Detail = node.entity.get(Detail)

				switch (detail.type)
				{
					case TypeEnum.TRANSGATE_IGA:
					case TypeEnum.TRANSGATE_SOVEREIGNTY:
					case TypeEnum.TRANSGATE_TYRANNAR:
						entity = node.entity;
						break;
				}

				if (entity)
					break;
			}

			return entity;
		}

		private function onShipyardLoad():void
		{
			var shipyard:ShipyardView = ShipyardView(viewController.getView(ShipyardView));
			var triggers:Array        = event.step.trigger.split(',');
			var params:Array          = triggers[0].split('|');
			var p:Point;
			for each (var component:ComponentSelection in shipyard.components)
			{
				if (component.slotType == params[1])
				{
					// These coords are reversed because the view is rotated 90 degrees
					p = new Point(component.parent.x - component.y - component.height, component.parent.y + component.x);
					var ap:Point = p.clone();
					ap.y += component.width * .5;
					event.step.arrowPosition = ap;
					event.step.arrowRotation = 0;
					event.step.cutout = new Rectangle(p.x, p.y, component.height, component.width);
					if (_overlayView && _overlayView.parent)
					{
						_overlayView.showArrow();
						if (params.length == 2)
							_overlayView.showCutout();
						else
						{
							addGlowToUI(component);
							event.step.arrowPosition = null;
						}
						_overlayView.clickToContinue = params.length == 3;
						_dialogueView.nextButtonEnabled = params.length == 3;
					}
					break;
				}
			}
			shipyard.addLoadCallback(null);
		}

		private function pointToCenterOfScreen():void
		{
			var width:Number  = DeviceMetrics.WIDTH_PIXELS * .5;
			var height:Number = DeviceMetrics.HEIGHT_PIXELS * .5;
			var p:Point       = new Point(width, height);
			event.step.arrowPosition = p;
			event.step.arrowRotation = 90;

			event.step.cutout = new Rectangle(p.x - width, p.y - height, width * 2, height * 2);
			if (_overlayView && _overlayView.parent)
			{
				_overlayView.showArrow();
				_overlayView.showCutout();
				_overlayView.mouseChildren = _overlayView.mouseEnabled = false;
			}
		}

		private function selectEntity( entity:Entity, width:int, height:int, yOffset:int = 0 ):void
		{
			if (entity)
			{
				var position:Position = entity.get(Position);
				var p:Point           = new Point(DeviceMetrics.WIDTH_PIXELS * .5, DeviceMetrics.HEIGHT_PIXELS * .5);

				var p2:Point          = p.clone();
				var anim:Animation    = entity.get(Animation);
				if (anim)
				{
					p2.x += anim.offsetX * 0.5;
				}

				p2.y += yOffset;

				event.step.arrowPosition = p2;
				event.step.arrowRotation = 180;

				event.step.cutout = new Rectangle(p.x - (width / 2), p.y - (height / 2), width, height);
				if (_overlayView && _overlayView.parent)
				{
					_overlayView.showArrow();
					_overlayView.showCutout();
				}
				addClickGlowToEntity(entity);
			}
		}

		private function highlightUI( ui:String ):void
		{
			var uiObj:DisplayObject;
			var view:IView;
			switch (ui)
			{
				case "lootHolder":
					view = viewController.getView(BattleEndView);
					if (view && view is BattleEndView)
						uiObj = (view as BattleEndView).lootHolder;
					if (uiObj)
						addGlowToUI(uiObj);
					break;

				case "HardCurrency":
					view = viewController.getView(PlayerView);
					if (view && view is PlayerView)
						uiObj = (view as PlayerView).premiumBg;
					if (uiObj)
						addScaleToUI(uiObj);
					break;
			}
		}

		private function addGlowToUI( ui:DisplayObject ):void
		{
			removeGlowFromUI();
			_glowUI = ui;
			_glowUI.filters = [GLOW_FILTER];
		}

		private function removeGlowFromUI():void
		{
			if (_glowUI)
			{
				_glowUI.filters = [];
				_glowUI = null;
			}
		}

		private function addScaleToUI( ui:DisplayObject ):void
		{
			removeScaleFromUI();
			_scaleUI = new PulseScaleEffect(ui, 1, 1.7, .4);
		}

		private function removeScaleFromUI():void
		{
			if (_scaleUI)
			{
				_scaleUI.destroy();
				_scaleUI = null;
			}
		}

		private function addClickGlowToEntity( entity:Entity ):void
		{
			_glowEntity = entity;
			var animation:Animation = entity.get(Animation);
			if (animation && animation.render)
				animation.render.addGlow(0xf9da54, 6, 8, 1);
		}

		private function addGlowToEntity( entity:Entity ):void
		{
			_glowEntity = entity;
			var animation:Animation = entity.get(Animation);
			if (animation && animation.render)
				animation.render.addGlow(0xffff00, 20, 1, 1);
		}

		private function removeGlowFromEntity( entity:Entity ):void
		{
			_glowEntity = null;
			var animation:Animation = entity.get(Animation);
			if (animation && animation.render)
				animation.render.removeGlow();
		}
	}
}
