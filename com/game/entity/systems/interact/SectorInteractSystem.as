package com.game.entity.systems.interact
{
	import com.Application;
	import com.controller.ChatController;
	import com.controller.GameController;
	import com.controller.keyboard.KeyboardKey;
	import com.enum.CategoryEnum;
	import com.enum.FleetStateEnum;
	import com.enum.TypeEnum;
	import com.game.entity.components.battle.Attack;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Enemy;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Owned;
	import com.game.entity.components.shared.Position;
	import com.game.entity.factory.IInteractFactory;
	import com.game.entity.nodes.sector.MissionNode;
	import com.game.entity.nodes.shared.EnemyNode;
	import com.game.entity.nodes.shared.OwnedNode;
	import com.game.entity.systems.interact.controls.BrowserScheme;
	import com.model.fleet.FleetVO;
	import com.model.sector.SectorModel;
	import com.presenter.sector.ISectorPresenter;
	import com.util.RouteLineBuilder;

	import flash.events.MouseEvent;
	import flash.geom.Point;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.osflash.signals.Signal;
	import org.parade.core.IViewStack;
	import org.parade.core.ViewController;
	import org.parade.enum.ViewEnum;

	public class SectorInteractSystem extends InteractSystem
	{
		[Inject(nodeType="com.game.entity.nodes.sector.MissionNode")]
		public var mission:NodeList;
		[Inject(nodeType="com.game.entity.nodes.shared.OwnedNode")]
		public var owned:NodeList;

		public var onCoordsUpdate:Signal;
		public var onSelectionChangeSignal:Signal;

		private var _chatController:ChatController;
		private var _destination:Entity;
		private var _game:Game;
		private var _gameController:GameController;
		private var _interactFactory:IInteractFactory;
		private var _missionEntities:Vector.<Entity>;
		private var _routeLine:Entity;
		private var _sectorModel:SectorModel;
		private var _selected:Entity;
		private var _selector:Entity;
		private var _selectedEnemy:Entity;
		private var _selectorEnemy:Entity;

		override public function addToGame( game:Game ):void
		{
			super.addToGame(game);
			owned.nodeRemoved.add(onNodeRemoved);
			owned.nodeAdded.add(onNodeAdded);
			onCoordsUpdate = new Signal(Number, Number);
			onSelectionChangeSignal = new Signal(Entity);

			_controlScheme = new BrowserScheme();
			_controlScheme.init(this, _layer, _keyboardController);
			_controlScheme.notifyOnMove = true;

			_game = game;
			_missionEntities = new Vector.<Entity>;
		}

		override public function update( time:Number ):void
		{
			super.update(time);
			if (_selected)
			{
				if (_selectedEnemy && !_selectedEnemy.id)
					removeTargetSelection();
				if (Move(_selected.get(Move)).moving)
				{
					if (_routeLine)
						RouteLineBuilder.updateRouteLine(_routeLine, _selected);
					if (_entityToFollow)
					{
						var position:Position = _selected.get(Position);
						onCoordsUpdate.dispatch(position.x, position.y);
					}
				} else
				{
					if (_destination)
						_destination = _interactFactory.destroyInteractEntity(_destination);
					if (_routeLine)
						_routeLine = _interactFactory.destroyInteractEntity(_routeLine);
				}
			}
		}

		override protected function onClick( dx:Number, dy:Number ):Vector.<Entity>
		{
			//see what the player is clicking on
			var attack:Attack;
			var interacts:Vector.<Entity> = super.onClick(dx, dy);
			var move:Move;
			var position:Position;
			var entity:Entity;
			if (interacts.length > 0)
			{
				interacts.sort(orderEntities);
				for (var i:int = 0; i < interacts.length; i++)
				{
					entity = interacts[i];
					if (entity.has(Owned) && entity.has(Move))
					{
						if (entity != _selected)
						{
							selectEntity(entity, false);
							onSelectionChangeSignal.dispatch(_selected);
						} else
						{
							presenter.onInteractionWithSectorEntity(dx, dy, entity, _selected);
							if (_inFTE)
								progressFTE();
						}
						break;
					} else
					{
						attack = entity.get(Attack);
						move = entity.get(Move);
						if (move && !_inFTE)
						{
							//if (!move.moving)
							presenter.onInteractionWithSectorEntity(dx, dy, entity, _selected);
						} else
						{
							if (_inFTE)
							{
								if (entity.has(Owned))
								{
									presenter.onInteractionWithSectorEntity(dx, dy, entity, _selected);
									progressFTE();
								}
							} else
								presenter.onInteractionWithSectorEntity(dx, dy, entity, _selected);
						}
						break;
					}
				}
			} else if (_selected)
			{
				// don't allow the player to command his fleet if it's recalling
				var selectedFleetVO:FleetVO = presenter.getFleetVO(_selected.id);
				if (selectedFleetVO && !selectedFleetVO.inBattle && selectedFleetVO.state != FleetStateEnum.FORCED_RECALLING)
				{
					//player is trying to move their ship
					move = _selected.get(Move);
					if (move)
					{
						position = Position(_selected.get(Position));
						var dest:Point = new Point(int(_sceneModel.viewArea.x + (dx / _sceneModel.zoom)), int(_sceneModel.viewArea.y + (dy / _sceneModel.zoom)));
						move.setDestination(dest.x, dest.y);
						_gameController.sectorMoveFleet(_selected.id, dest.x, dest.y);
						showDestination();
						showRouteLine();
					}
				}
			}
			return interacts;
		}

		override public function onInteraction( type:String, x:Number, y:Number ):void
		{
			super.onInteraction(type, x, y);
			if (type == MouseEvent.MOUSE_MOVE)
				onShowPosition(null, x, y);
		}

		override public function onKey( keyCode:uint, up:Boolean = true ):void
		{
			if (_chatController.chatHasFocus || _viewController.modalHasFocus)
				return;

			super.onKey(keyCode, up);

			switch (keyCode)
			{
				case KeyboardKey.A.keyCode:
				case KeyboardKey.D.keyCode:
				case KeyboardKey.LEFT.keyCode:
				case KeyboardKey.RIGHT.keyCode:
				{
					var cnt:int       = 0;
					var direction:int = (keyCode == KeyboardKey.A.keyCode || keyCode == KeyboardKey.LEFT.keyCode) ? 0 : 1;
					var node:OwnedNode;

					if (_selected)
					{
						for (node = owned.head; node; node = node.next)
						{
							//find the currently selected node
							if (node.entity == _selected)
								break;
						}
					}

					else if (owned.head)
						node = owned.head;

					var temp:Entity   = (_selected) ? _selected : (node) ? node.entity : null;

					while (node && cnt != 1)
					{
						if (direction == 0)
							node = (node.previous) ? node.previous : owned.tail;

						else
							node = (node.next) ? node.next : owned.head;

						if (node.entity == temp)
							cnt++;

						else if (node.detail.category == CategoryEnum.SHIP)
						{
							selectEntity(node.entity);
							onSelectionChangeSignal.dispatch(_selected);
							break;
						}
					}

					break;
				}
			}
		}

		public function showSelector():void
		{
			if (!_selected)
				return;
			_selector = _interactFactory.showSelection(_selected, _selector);
			if (presenter)
				presenter.onBattle();
			showDestination();
			showRouteLine();
			showEnemySelector();
		}

		private function showDestination():void
		{
			if (!_selected)
				return;
			var move:Move = _selected.get(Move);
			if (!move)
			{
				if (_destination)
				{
					_destination = _interactFactory.destroyInteractEntity(_destination);
				}
				return;
			}

			_destination = _interactFactory.showSelection(null, _destination, move.destination.x, move.destination.y);
		}

		private function showRouteLine():void
		{
			if (!_selected)
				return;

			var move:Move    = Move(_selected.get(Move));

			if (!move)
			{
				if (_routeLine)
				{
					_routeLine = _interactFactory.destroyInteractEntity(_routeLine);
				}
				return;
			}

			// The anim label changing indicates we have selected a new entity
			var label:String = _routeLine ? Animation(_routeLine.get(Animation)).label : "";
			if (label != (TypeEnum.ROUTE_LINE + _selected.id))
			{
				if (_routeLine)
				{
					_routeLine = _interactFactory.destroyInteractEntity(_routeLine);
				}
			}

			if (_routeLine)
			{
				RouteLineBuilder.adjustRotation(_routeLine, move.destination);
			} else
			{
				_routeLine = _interactFactory.createRouteLine(_selected, move.destination);
			}
		}

		private function showEnemySelector():void
		{
			if (!_selected)
				return;
			var attack:Attack = _selected.get(Attack);
			if (!attack || attack.targetID == null)
			{
				_interactFactory.destroyInteractEntity(_selectorEnemy);
				_selectorEnemy = _selectedEnemy = null;
				return;
			}
			_selectedEnemy = _game.getEntity(attack.targetID);
			if (!_selectedEnemy)
			{
				_interactFactory.destroyInteractEntity(_selectorEnemy);
				_selectorEnemy = _selectedEnemy = null;
				return;
			}
			_selectorEnemy = _interactFactory.showSelection(_selectedEnemy, _selectorEnemy);
			_destination = _interactFactory.destroyInteractEntity(_destination);
		}

		private function onShowPosition( e:MouseEvent = null, x:int = 0, y:int = 0 ):void
		{
			if (e)
			{
				x = e.stageX;
				y = e.stageY;
			}
			if (_sceneModel.viewArea && !_entityToFollow)
				onCoordsUpdate.dispatch(_sceneModel.viewArea.x + (x / _sceneModel.zoom), _sceneModel.viewArea.y + (y / _sceneModel.zoom));
		}

		private function onNodeRemoved( node:OwnedNode ):void
		{
			if (node.entity == _selected)
			{
				_interactFactory.destroyInteractEntity(_selectorEnemy);
				_interactFactory.destroyInteractEntity(_destination);
				_routeLine = _interactFactory.destroyInteractEntity(_routeLine);
				_interactFactory.destroyInteractEntity(_selector);
				_selected = _selectedEnemy = _selector = _selectorEnemy = null;
				_destination = null;
			}
		}

		private function onNodeAdded( node:OwnedNode ):void
		{
			if (_selected == null && _sectorModel.focusFleetID != '')
			{
				if (node.entity.id == _sectorModel.focusFleetID)
					selectEntity(node.entity, false);
			}
		}

		private function onEnemyRemoved( node:EnemyNode ):void
		{
			if (node.entity == _selectedEnemy)
			{
				_interactFactory.destroyInteractEntity(_selectorEnemy);
				_selectedEnemy = _selectorEnemy = null;
			}
		}

		private function orderEntities( entityA:Entity, entityB:Entity ):int
		{
			var detailA:Detail = entityA.get(Detail);
			var detailB:Detail = entityB.get(Detail);
			var enemyA:Boolean = entityA.has(Enemy);
			var enemyB:Boolean = entityB.has(Enemy);
			var ownedA:Boolean = entityA.has(Owned);
			var ownedB:Boolean = entityB.has(Owned);

			if (detailA.category == CategoryEnum.SECTOR)
				return 1;
			if (detailB.category == CategoryEnum.SECTOR)
				return -1;
			return 0;
		}

		public function selectEntity( entityToSelect:Entity, gotoLocation:Boolean = true ):void
		{
			_selected = entityToSelect;
			if (_selected)
			{
				_sectorModel.focusFleetID = _selected.id;
				if (gotoLocation)
				{
					var position:Position = _selected.get(Position);
					jumpToLocation(position.x, position.y);
					_entityToFollow = (Move(_selected.get(Move)).moving) ? _selected : null;
				}
				showSelector();
			}
		}

		public function removeTargetSelection():void
		{
			_selectedEnemy = null;
			if (_selected)
			{
				var attack:Attack = _selected.get(Attack);
				if (attack)
					attack.targetID = null;
			}
			showSelector();
		}

		public function get missionEntities():Vector.<Entity>
		{
			_missionEntities.length = 0;
			var node:MissionNode;
			for (node = mission.head; node; node = node.next)
			{
				_missionEntities.push(node.entity);
			}
			return _missionEntities;
		}

		[Inject]
		public function set chatController( value:ChatController ):void  { _chatController = value; }
		[Inject]
		public function set gameController( value:GameController ):void  { _gameController = value; }
		[Inject]
		public function set interactFactory( value:IInteractFactory ):void  { _interactFactory = value; }
		public function set presenter( v:ISectorPresenter ):void  { _presenter = v; }
		public function get presenter():ISectorPresenter  { return ISectorPresenter(_presenter); }
		[Inject]
		public function set sectorModel( value:SectorModel ):void  { _sectorModel = value; }
		public function get selected():Entity  { return _selected; }
		public function get selectedEnemy():Entity  { return _selectedEnemy; }

		override public function removeFromGame( game:Game ):void
		{
			owned.nodeRemoved.remove(onNodeRemoved);
			owned.nodeAdded.remove(onNodeAdded);
			owned = null;
			_interactFactory.destroyInteractEntity(_selectorEnemy);
			_interactFactory.destroyInteractEntity(_destination);
			_interactFactory.destroyInteractEntity(_selector);
			_destination = _selected = _selector = _selectedEnemy = _selectorEnemy = null;
			onCoordsUpdate.removeAll();
			onCoordsUpdate = null;
			onSelectionChangeSignal.removeAll();
			onSelectionChangeSignal = null;
			super.removeFromGame(game);
			_chatController = null;
			_game = null;
			_gameController = null;
			_interactFactory = null;
			_missionEntities = null;
			_sectorModel = null;
			_selected = null;
		}
	}
}

