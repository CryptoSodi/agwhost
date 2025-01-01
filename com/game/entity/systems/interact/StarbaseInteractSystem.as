package com.game.entity.systems.interact
{
	import com.Application;
	import com.controller.ChatController;
	import com.controller.keyboard.KeyboardKey;
	import com.controller.transaction.TransactionController;
	import com.controller.transaction.requirements.RequirementVO;
	import com.controller.transaction.requirements.UnderMaxCountRequirement;
	import com.enum.CategoryEnum;
	import com.enum.FactionEnum;
	import com.enum.StarbaseConstructionEnum;
	import com.enum.TypeEnum;
	import com.enum.server.PurchaseTypeEnum;
	import com.event.TransactionEvent;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.VCList;
	import com.game.entity.components.starbase.Platform;
	import com.game.entity.factory.IInteractFactory;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.nodes.starbase.BuildingNode;
	import com.game.entity.systems.interact.controls.BrowserScheme;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseGrid;
	import com.presenter.shared.IUIPresenter;
	import com.presenter.starbase.IStarbasePresenter;

	import flash.events.MouseEvent;
	import flash.geom.Point;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.parade.enum.PlatformEnum;
	import org.parade.util.DeviceMetrics;

	public class StarbaseInteractSystem extends InteractSystem
	{
		public static const BASE_STATE:int                 = 0;
		public static const BUILD_STATE:int                = 2;
		public static const MOVE_STATE:int                 = 1;
		private static const MAX_FAILED_BUILD_ATTEMPTS:int = 2;

		[Inject(nodeType="com.game.entity.nodes.starbase.BuildingNode")]
		public var nodes:NodeList;

		private static var _buildingID:int                 = 1;

		private var _chatController:ChatController;
		private var _crntFailedBuildAttempts:int;
		private var _game:Game;
		private var _interactFactory:IInteractFactory;
		private var _isShiftKeyPressed:Boolean;
		private var _purchaseType:uint;
		private var _selected:Entity;
		private var _starbaseFactory:IStarbaseFactory;
		private var _starbaseSystem:StarbaseSystem;
		private var _state:int;
		private var _tempBaseX:int;
		private var _tempBaseY:int;
		private var _tempBuildingVO:BuildingVO;
		private var _transactionController:TransactionController;
		private var _uiPresenter:IUIPresenter;

		override public function addToGame( game:Game ):void
		{
			super.addToGame(game);

			_controlScheme = new BrowserScheme();
			_controlScheme.init(this, _layer, _keyboardController);
			_minZoom = 0.383

			_game = game;
			_starbaseSystem = StarbaseSystem(_game.getSystem(StarbaseSystem));
			nodes.nodeRemoved.add(onNodeRemoved);

			//left bounding line
			_starbaseFactory.createBoundingLine(StarbaseGrid.PLAY_SPACE_NOBUILD_WIDTH, StarbaseGrid.PLAY_SPACE_NOBUILD_HEIGHT,
												StarbaseGrid.PLAY_SPACE_NOBUILD_WIDTH, StarbaseGrid.PLAY_SPACE_HEIGHT - StarbaseGrid.PLAY_SPACE_NOBUILD_HEIGHT);
			//top bounding line
			_starbaseFactory.createBoundingLine(StarbaseGrid.PLAY_SPACE_NOBUILD_WIDTH, StarbaseGrid.PLAY_SPACE_NOBUILD_HEIGHT,
												StarbaseGrid.PLAY_SPACE_WIDTH - StarbaseGrid.PLAY_SPACE_NOBUILD_WIDTH, StarbaseGrid.PLAY_SPACE_NOBUILD_HEIGHT);
			//right bound line
			_starbaseFactory.createBoundingLine(StarbaseGrid.PLAY_SPACE_WIDTH - StarbaseGrid.PLAY_SPACE_NOBUILD_WIDTH, StarbaseGrid.PLAY_SPACE_NOBUILD_HEIGHT,
												StarbaseGrid.PLAY_SPACE_WIDTH - StarbaseGrid.PLAY_SPACE_NOBUILD_WIDTH, StarbaseGrid.PLAY_SPACE_HEIGHT - StarbaseGrid.PLAY_SPACE_NOBUILD_HEIGHT);
			//bottom bounding line
			_starbaseFactory.createBoundingLine(StarbaseGrid.PLAY_SPACE_NOBUILD_WIDTH, StarbaseGrid.PLAY_SPACE_HEIGHT - StarbaseGrid.PLAY_SPACE_NOBUILD_HEIGHT,
												StarbaseGrid.PLAY_SPACE_WIDTH - StarbaseGrid.PLAY_SPACE_NOBUILD_WIDTH, StarbaseGrid.PLAY_SPACE_HEIGHT - StarbaseGrid.PLAY_SPACE_NOBUILD_HEIGHT);
		}

		override public function onInteraction( type:String, x:Number, y:Number ):void
		{
			super.onInteraction(type, x, y);

			if (!_selected || !_sceneModel.ready || type != MouseEvent.MOUSE_MOVE)
				return;

			onMoveBuildingComponent(null, x, y);
		}

		override public function onKey( keyCode:uint, up:Boolean = true ):void
		{
			if (_chatController.chatHasFocus || _viewController.modalHasFocus)
				return;

			super.onKey(keyCode, up);

			if (keyCode == KeyboardKey.ESCAPE.keyCode && (_state == BUILD_STATE || _state == MOVE_STATE) && !_inFTE)
				resolveBuilding(false);

			if (keyCode == KeyboardKey.SHIFT.keyCode)
				_isShiftKeyPressed = !up;
		}

		override protected function onClick( dx:Number, dy:Number ):Vector.<Entity>
		{
			//see what the player is clicking on
			var interacts:Vector.<Entity> = super.onClick(dx, dy);
			var len:uint                  = interacts.length;
			var detail:Detail;
			var wasPlaced:Boolean;

			switch (_state)
			{
				case BASE_STATE:
					_selected = null;
					if (len > 0)
					{
						var currentEntity:Entity;
						for (var i:uint = 0; i < len; ++i)
						{
							currentEntity = interacts[i];
							detail = currentEntity.get(Detail);
							//determine if the player is clicking a building or a starbase platform
							if (detail.prototypeVO.getValue('constructionCategory') == StarbaseConstructionEnum.PLATFORM)
							{
								//only move the platform if there is not a building sitting atop of it
								if (_starbaseModel.grid.canMovePlatform(Platform(currentEntity.get(Platform)).buildingVO))
									_selected = currentEntity;
							} else
							{
								//Set the new selected
								_selected = currentEntity;
								break;
							}
						}

						if (_selected && _selected.id.indexOf('clientside_') == -1)
						{
							presenter.onInteractionWithBaseEntity(dx, dy, _selected);
							if (_inFTE)
								progressFTE();
							updateRanges();
						}
					}
					break;
				case MOVE_STATE:
				case BUILD_STATE:
					if (_selected)
					{
						var failed:Boolean;
						wasPlaced = placeBuilding(_selected);
						if (!wasPlaced)
						{
							if (_crntFailedBuildAttempts < MAX_FAILED_BUILD_ATTEMPTS)
							{
								//do we want to do this during FTE?
								if (!_inFTE)
									_crntFailedBuildAttempts++;
							} else //abort build logic for too many failed attempts
								failed = true;
						}

						if (wasPlaced || failed)
						{
							if (wasPlaced && _inFTE)
								progressFTE();
							resolveBuilding(wasPlaced);
						}

						if (wasPlaced && _isShiftKeyPressed)
						{
							//determine if the previous build requesst is a platform, since this is the only type we're allowing shift-click building for mutil units
							var isPlatform:Boolean;

							if (!_tempBuildingVO || !_tempBuildingVO.prototype)
								isPlatform = false;
							else
								isPlatform = _tempBuildingVO.constructionCategory == StarbaseConstructionEnum.PLATFORM;

							if (isPlatform)
							{
								var requirements:RequirementVO = _transactionController.canBuild(_tempBuildingVO.prototype);
								if (requirements.purchaseVO.alloyAmountShort == 0 &&
									requirements.purchaseVO.creditsAmountShort == 0 &&
									requirements.purchaseVO.energyAmountShort == 0 &&
									requirements.purchaseVO.syntheticAmountShort == 0 &&
									requirements.getRequirementOfType(UnderMaxCountRequirement).isMet)
								{
									presenter.performTransaction(TransactionEvent.STARBASE_BUILDING_BUILD, _tempBuildingVO.prototype, _purchaseType);
									onMoveBuildingComponent(null, Application.STAGE.mouseX, Application.STAGE.mouseY);
								}
							}
						}
					}

					break;
			}
			if (_selected == null)
				updateRanges();
			return interacts;
		}

		private function onNodeRemoved( node:BuildingNode ):void
		{
			if (_selected == node.entity)
			{
				_selected = null;
				updateRanges();
			}
		}

		private function resolveBuilding( placed:Boolean ):void
		{
			if (!_selected)
				return;

			if (_selected.get(Platform))
				Animation(_selected.get(Animation)).render.color = 0xffffff;

			if (placed)
				_gridSystem.forceGridCheck(_selected);
			else
			{
				var position:Position = _selected.get(Position);
				var vo:BuildingVO     = _starbaseModel.getBuildingByID(_selected.id);

				if (_state == BUILD_STATE)
					_starbaseFactory.destroyStarbaseItem(_selected);
				else
				{
					//player was trying to move the building
					//put the building back where it was before we started the move process
					vo = _starbaseModel.getBuildingByID(_selected.id);
					vo.baseX = _tempBaseX;
					vo.baseY = _tempBaseY;
					position = _selected.get(Position);
					_starbaseModel.grid.convertBuildingGridToIso(position.position, vo);
					//have to do this to update followers
					position.x = position.position.x;
					position.y = position.position.y;
					_starbaseModel.grid.addToGrid(vo);
					_starbaseSystem.depthSort(StarbaseSystem.DEPTH_SORT_ALL);
					_gridSystem.forceGridCheck(_selected);

					if (vo.itemClass == TypeEnum.PYLON)
					{
						_starbaseSystem.positionPylonBase(_selected);
						_starbaseSystem.findPylonConnections(_selected);
					}
				}
			}

			//reset everythings
			_crntFailedBuildAttempts = 0;
			_selected = null;
			_starbaseSystem.showShields(true);
			setState(BASE_STATE);
			updateRanges();
		}

		//============================================================================================================
		//************************************************************************************************************
		//										 		Building and Moving
		//************************************************************************************************************
		//============================================================================================================

		private function placeBuilding( entity:Entity ):Boolean
		{
			/*var selectedPosition:Position = entity.get(Position);
			   var p:Point                   = new Point(selectedPosition.x, selectedPosition.y);
			   _starbaseModel.grid.convertIsoToGrid(p);
			   trace(p.toString());
			   trace(_tempBuildingVO.baseX, _tempBuildingVO.baseY);*/

			var placed:Boolean = false;
			var result:int     = _starbaseModel.grid.confirmAddToGrid(_tempBuildingVO);
			if (result == StarbaseGrid.ALL_CLEAR)
			{
				//update the buildingVO with the new position
				var buildingVO:BuildingVO = _tempBuildingVO;
				if (entity.id.indexOf('clientside_') == -1)
				{
					_starbaseModel.grid.addToGrid(buildingVO);
					_transactionController.starbaseMoveBuilding(buildingVO, _tempBaseX, _tempBaseY);
				} else
				{
					buildingVO.popuplateFromEntity(entity);
					buildingVO.baseID = _starbaseModel.currentBaseID;

					_transactionController.starbaseBuild(buildingVO, _purchaseType);
					_starbaseModel.addBuilding(buildingVO);
					_purchaseType = PurchaseTypeEnum.NORMAL;
				}
				_starbaseSystem.findPylonConnections();
				placed = true;
			}
			//update the buildingVO of the entity
			if (placed)
			{
				if (entity.get(Platform))
					Animation(entity.get(Animation)).render.color = 0xffffff;
				_starbaseSystem.depthSort(StarbaseSystem.DEPTH_SORT_ALL);
			}
			return placed;
		}

		private function onMoveBuildingComponent( e:MouseEvent = null, x:int = 0, y:int = 0 ):void
		{
			if (e)
			{
				x = e.stageX;
				y = e.stageY;
			}
			if ((_state == MOVE_STATE || _state == BUILD_STATE) && _selected)
			{
				var result:int           = StarbaseGrid.GRID_OCCUPIED;
				var animation:Animation;
				var position:Position    = _selected.get(Position);
				var currentDetail:Detail = _selected.get(Detail);

				var px:Number            = position.x;
				var py:Number            = position.y;
				position.x = _sceneModel.viewArea.x + x / _sceneModel.zoom;
				position.y = _sceneModel.viewArea.y + y / _sceneModel.zoom;
				_starbaseModel.grid.snapToGrid(position.position, _tempBuildingVO, currentDetail.category == CategoryEnum.BUILDING && currentDetail.prototypeVO.itemClass != TypeEnum.PYLON);

				//exit out if the grid position of this entity did not change to avoid depth sorting and all that other expensive stuff
				if (position.x == px && position.y == py)
				{
					//need to do this so other entities attached to this position component are updated
					position.x = position.position.x;
					position.y = position.position.y;
					return;
				}

				if (currentDetail.category == CategoryEnum.STARBASE)
				{
					animation = _selected.get(Animation);
					if (animation.render)
					{
						result = _starbaseModel.grid.confirmAddToGrid(_tempBuildingVO);
						animation.render.color = (result == StarbaseGrid.ALL_CLEAR) ? 0x00ff00 : 0xff0000;
					}
				} else
				{
					//see if the selected item can be placed. update the iso square to reflect
					var iso:Entity = VCList(_selected.get(VCList)).getComponent(getIsoSquareType(_tempBuildingVO.prototype));
					if (iso)
					{
						animation = iso.get(Animation);
						if (animation.render)
						{
							result = _starbaseModel.grid.confirmAddToGrid(_tempBuildingVO);
							animation.render.color = (result == StarbaseGrid.ALL_CLEAR) ? 0x00ff00 : 0xff0000;
						}
					}
				}
				if (result == StarbaseGrid.ALL_CLEAR)
				{
					_starbaseSystem.depthSort((currentDetail.category == CategoryEnum.STARBASE) ? StarbaseSystem.DEPTH_SORT_PLATFORMS : StarbaseSystem.DEPTH_SORT_BUILDINGS);
				} else
					Position(_selected.get(Position)).depth = 9000;

				switch (currentDetail.type)
				{
					case TypeEnum.POINT_DEFENSE_PLATFORM:
						_starbaseSystem.findPylonConnections(null);
						break;
					case TypeEnum.SHIELD_GENERATOR:
						_starbaseSystem.findPylonConnections(null);
						_starbaseSystem.showShields(false, _selected);
						break;
					case TypeEnum.PYLON:
						_starbaseSystem.positionPylonBase(_selected);
						_starbaseSystem.findPylonConnections(_selected);
						break;
					default:
						_starbaseSystem.findPylonConnections();
						_starbaseSystem.showShields();
						break;
				}

				//need to do this so other entities attached to this position component are updated
				position.x = position.position.x;
				position.y = position.position.y;
			}
		}

		public function buildFromPrototype( buildingPrototype:IPrototype, purchaseType:uint ):void
		{
			// note that the server will reply with the ACTUAL name of the building
			_purchaseType = purchaseType;
			_tempBuildingVO = new BuildingVO();
			_tempBuildingVO.prototype = buildingPrototype;
			var id:String = buildingID;
			var p:Point   = new Point(_sceneModel.focus.x, _sceneModel.focus.y);
			switch (_tempBuildingVO.constructionCategory)
			{
				case StarbaseConstructionEnum.PLATFORM:
					_starbaseModel.grid.snapToGrid(p, _tempBuildingVO, false);
					_selected = _starbaseFactory.createBaseItem(id, _tempBuildingVO);
					break;
				default:
					_starbaseModel.grid.snapToGrid(p, _tempBuildingVO);
					_selected = _starbaseFactory.createBuilding(id, _tempBuildingVO);
					break;
			}
			Position(_selected.get(Position)).depth = -1;
			setState(BUILD_STATE);
		}

		public function setState( newState:int ):void
		{
			if (newState == MOVE_STATE && _selected == null)
				return;
			_state = newState;
			_controlScheme.notifyOnMove = false;
			switch (_state)
			{
				case BASE_STATE:
					_uiPresenter.hudEnabled = true;
					break;

				case MOVE_STATE:
					//if we're moving then remove the building from the grid
					if (_selected)
					{
						_tempBuildingVO = _starbaseModel.getBuildingByID(_selected.id);
						_tempBaseX = _tempBuildingVO.baseX;
						_tempBaseY = _tempBuildingVO.baseY;
						_starbaseModel.grid.removeFromGrid(_tempBuildingVO);
					}

				// Intentional fallthrough

				case BUILD_STATE:
					if (_selected)
					{
						_controlScheme.notifyOnMove = true;
						Position(_selected.get(Position)).depth = -1;
						_uiPresenter.hudEnabled = false;
						//Remove any previous ranges and display all ranges during the move
						updateRanges();
					}
					break;
			}

			//cycle through the existing buildings and add or remove the iso squares from beneath them
			var node:BuildingNode;
			var selectedDetail:Detail = (_selected) ? _selected.get(Detail) : null;
			var type:String;
			var vcList:VCList;
			for (node = nodes.head; node; node = node.next)
			{
				vcList = node.entity.get(VCList);
				if (vcList)
				{
					type = getIsoSquareType(node.detail.prototypeVO);
					if (_state == BASE_STATE)
						vcList.removeComponentType(type);
					else if (_selected)
					{
						if ((selectedDetail.type != TypeEnum.PYLON && Detail(node.entity.get(Detail)).type != TypeEnum.PYLON) ||
							(selectedDetail.type == TypeEnum.PYLON && Detail(node.entity.get(Detail)).type == TypeEnum.PYLON))
							vcList.addComponentType(type);
					}
				}
			}
		}

		public function updateRanges():void
		{
			if (_selected)
			{
				var detail:Detail = _selected.get(Detail);
				//cycle through the existing buildings and add ranges to those that need
				if (_state != MOVE_STATE)
				{
					_starbaseSystem.showPylonRanges(null, false);
					_starbaseSystem.showShieldRanges(null, false);
					_starbaseSystem.showTurretRanges(null, false);
					_starbaseSystem.showShields(true);
					switch (detail.type)
					{
						case TypeEnum.POINT_DEFENSE_PLATFORM:
							_starbaseSystem.showTurretRanges(_selected, true);
							break;
						case TypeEnum.PYLON:
							_starbaseSystem.showPylonRanges(_selected, true);
							break;
						case TypeEnum.SHIELD_GENERATOR:
							_starbaseSystem.showShieldRanges(_selected, true);
							_starbaseSystem.showShields(false, _selected);
							break;
					}
				} else
				{
					switch (detail.type)
					{
						case TypeEnum.POINT_DEFENSE_PLATFORM:
							_starbaseSystem.showTurretRanges(null, true);
							break;
						case TypeEnum.PYLON:
							_starbaseSystem.showPylonRanges(null, true);
							break;
						case TypeEnum.SHIELD_GENERATOR:
							_starbaseSystem.showShieldRanges(null, true);
							_starbaseSystem.showShields();
							break;
						default:
							_starbaseSystem.showShieldRanges(null, true);
							_starbaseSystem.showTurretRanges(null, true);
							_starbaseSystem.showShields();
							break;
					}
				}
			} else
			{
				_starbaseSystem.showPylonRanges(null, false);
				_starbaseSystem.showShieldRanges(null, false);
				_starbaseSystem.showTurretRanges(null, false);
				_starbaseSystem.showShields(true);
			}
		}

		private function getIsoSquareType( prototypeVO:IPrototype ):String
		{
			switch (prototypeVO.getValue('sizeX'))
			{
				case 5:
					if (CurrentUser.faction == FactionEnum.IGA)
						return TypeEnum.ISO_1x1_IGA;
					else if (CurrentUser.faction == FactionEnum.SOVEREIGNTY)
						return TypeEnum.ISO_1x1_SOVEREIGNTY;
					return TypeEnum.ISO_1x1_TYRANNAR;
				case 10:
					if (CurrentUser.faction == FactionEnum.IGA)
						return TypeEnum.ISO_2x2_IGA;
					else if (CurrentUser.faction == FactionEnum.SOVEREIGNTY)
						return TypeEnum.ISO_2x2_SOVEREIGNTY;
					return TypeEnum.ISO_2x2_TYRANNAR;
			}
			if (CurrentUser.faction == FactionEnum.IGA)
				return TypeEnum.ISO_3x3_IGA;
			else if (CurrentUser.faction == FactionEnum.SOVEREIGNTY)
				return TypeEnum.ISO_3x3_SOVEREIGNTY;
			return TypeEnum.ISO_3x3_TYRANNAR;
		}

		public function get buildingID():String  { ++_buildingID; return CurrentUser.name + '.clientside_building.' + String(_buildingID); }
		[Inject]
		public function set chatController( v:ChatController ):void  { _chatController = v; }
		[Inject]
		public function set interactFactory( v:IInteractFactory ):void  { _interactFactory = v; }
		public function set presenter( v:IStarbasePresenter ):void  { _presenter = v; }
		public function get presenter():IStarbasePresenter  { return IStarbasePresenter(_presenter); }
		[Inject]
		public function set starbaseFactory( v:IStarbaseFactory ):void  { _starbaseFactory = v }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
		[Inject]
		public function set uiPresenter( value:IUIPresenter ):void  { _uiPresenter = value; }

		override public function removeFromGame( game:Game ):void
		{
			nodes.nodeRemoved.remove(onNodeRemoved);
			super.removeFromGame(game);

			_chatController = null;
			_selected = null;
			_interactFactory.clearRanges();
			_interactFactory = null;
			_game = null;
			_starbaseFactory = null;
			_starbaseSystem = null;
			_tempBuildingVO = null;
			_transactionController = null;
			_uiPresenter = null;
		}
	}
}

