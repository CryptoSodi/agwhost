package com.game.entity.systems.interact
{
	import com.Application;
	import com.controller.ChatController;
	import com.controller.GameController;
	import com.controller.ServerController;
	import com.controller.SettingsController;
	import com.controller.keyboard.KeyboardKey;
	import com.enum.CategoryEnum;
	import com.enum.TypeEnum;
	import com.game.entity.components.battle.Attack;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Enemy;
	import com.game.entity.components.shared.Interactable;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Owned;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.starbase.Building;
	import com.game.entity.factory.IInteractFactory;
	import com.game.entity.nodes.shared.EnemyNode;
	import com.game.entity.nodes.shared.OwnedNode;
	import com.game.entity.systems.interact.controls.BrowserScheme;
	import com.game.entity.systems.interact.controls.ControlledEntity;
	import com.game.entity.systems.interact.controls.SelectorEntity;
	import com.model.battle.BattleModel;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.player.CurrentUser;
	import com.presenter.battle.IBattlePresenter;
	import com.util.RangeBuilder;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class BattleInteractSystem extends InteractSystem
	{
		[Inject(nodeType="com.game.entity.nodes.shared.OwnedNode")]
		public var owned:NodeList;

		[Inject(nodeType="com.game.entity.nodes.shared.EnemyNode")]
		public var enemy:NodeList;

		public var onControlledUpdated:Signal;

		private var _battleModel:BattleModel;
		private var _chatController:ChatController;
		private var _controlled:Vector.<ControlledEntity>;
		private var _ctrlKeyDown:Boolean;
		private var _drawSelector:Boolean;
		private var _fleetModel:FleetModel;
		private var _fleetVO:FleetVO;
		private var _futureTargetID:String;
		private var _futureTargetTime:Number;
		private var _game:Game;
		private var _gameController:GameController;
		private var _i:int;
		private var _interactFactory:IInteractFactory;
		private var _isDragSelecting:Boolean;
		private var _lastClickTime:Number        = 0;
		private var _lastEntityClicked:Entity;
		private var _lastGroupSelected:int       = KeyboardKey.ONE.keyCode;
		private var _lastTypeSelected:int        = 100;
		private var _loopI:int;
		private var _progressFTEOnMove:Boolean;
		private var _rangeBuilder:RangeBuilder;
		private var _settingsController:SettingsController;
		private var _shiftKeyDown:Boolean;
		private var _shipSelectionEntity:Entity;
		private var _shipSelectionRect:Rectangle = new Rectangle();
		private var _shipTypes:Array             = [TypeEnum.FIGHTER, TypeEnum.HEAVY_FIGHTER, TypeEnum.CORVETTE, TypeEnum.DESTROYER, TypeEnum.BATTLESHIP, TypeEnum.DREADNOUGHT, TypeEnum.TRANSPORT];
		private var _tempControlled:ControlledEntity;

		override public function addToGame( game:Game ):void
		{
			super.addToGame(game);
			owned.nodeAdded.add(onNodeAdded);
			owned.nodeRemoved.add(onNodeRemoved);
			enemy.nodeRemoved.add(onEnemyRemoved);
			buildRanges();

			_ctrlKeyDown = _shiftKeyDown = false;
			_game = game;
			_controlled = new Vector.<ControlledEntity>;
			onControlledUpdated = new Signal(Vector.<ControlledEntity>);
		}

		public function init():void
		{
			_controlScheme = new BrowserScheme();
			_controlScheme.init(this, _layer, _keyboardController);
			//find the players fleet that is in the battle
			if (_battleModel.participants.indexOf(CurrentUser.id) > -1)
			{
				_fleetVO = _fleetModel.getFleetByBattleAddress(_battleModel.battleServerAddress);
				controlAllEntities();
			}
		}

		private function onNodeAdded( node:OwnedNode ):void
		{
			if(_battleModel.isInstancedMission)
				_rangeBuilder.buildRangeFromNodeOnly(node);
			else
				_rangeBuilder.buildRangeFromNode(node);
		}

		override public function update( time:Number ):void
		{
			super.update(time);
			if (_controlled.length > 0)
			{
				_drawSelector = false;
				for (_i = 0; _i < _controlled.length; _i++)
				{
					_tempControlled = _controlled[_i];
					if (_tempControlled.destination)
					{
						if (!Move(_tempControlled.entity.get(Move)).moving)
							_tempControlled.destination = null;
					}
					//if the ship has a target but no selector is shown then we need to draw the selector
					if (!_tempControlled.selectorEnemy && enemy.head != null && Attack(_tempControlled.entity.get(Attack)).targetID != null)
						_drawSelector = true;
				}
				if (_drawSelector)
					showEnemySelector();

				if (_futureTargetID)
				{
					_futureTargetTime += time;
					if (_futureTargetTime >= .15)
						assignTarget(_futureTargetID);
				}
			}
		}

		override protected function onInteraction_mouseMove( x:Number, y:Number ):void
		{
			if ((_ctrlKeyDown || _shiftKeyDown) && hasDragStarted(x, y))
			{
				_isDragSelecting = true;

				var startPt:Point = updateScenePt(_startDrag.x, _startDrag.y);
				var crntPt:Point  = updateScenePt(x, y);

				_shipSelectionRect.x = crntPt.x > startPt.x ? startPt.x : crntPt.x;
				_shipSelectionRect.y = crntPt.y > startPt.y ? startPt.y : crntPt.y;
				_shipSelectionRect.width = Math.abs(crntPt.x - startPt.x); //sizePt.x;
				_shipSelectionRect.height = Math.abs(crntPt.y - startPt.y); //sizePt.y;
				_shipSelectionEntity = _interactFactory.showMultiShipSelection(_shipSelectionEntity, _shipSelectionRect);
			} else
			{
				_isDragSelecting = false;
				super.onInteraction_mouseMove(x, y);
			}
		}

		override protected function onInteraction_mouseUp( x:Number, y:Number, isRightMouse:Boolean = false ):void
		{
			if (!_isDragSelecting)
				super.onInteraction_mouseUp(x, y, isRightMouse);
			else
			{
				if (!_shiftKeyDown)
					uncontrolAllEntities();

				var selectedShips:Vector.<Entity> = Vector.<Entity>([]);
				if (owned && owned.head)
				{
					var node:OwnedNode = owned.head;
					var pos:Position;
					var type:String;

					while (node)
					{
						type = node.detail.category;
						pos = node.position;

						if (_shipSelectionRect.contains(pos.x, pos.y))
							selectedShips.push(node.entity);

						node = node.next;
					}
				}

				if (selectedShips.length > 0)
				{
					for each (var entity:Entity in selectedShips)
						controlEntity(entity);
				}

				//cleanup
				_interactFactory.destroyInteractEntity(_shipSelectionEntity);
				_shipSelectionEntity = null;
			}

			_isDragSelecting = false;

			if (isRightMouse)
				_isRightMouseDown = false; //for now we're going to say that only one mouse can be down at a time..
		}

		override protected function onClick( dx:Number, dy:Number ):Vector.<Entity>
		{
			if( _battleModel.isReplay )
			{
				return null;
			}
			//see what the player is clicking on
			var interacts:Vector.<Entity> = super.onClick(dx, dy);
			var move:Move;
			var position:Position;
			var tempTime:Number           = getTimer();

			if (interacts.length > 0)
			{
				for (_loopI = 0; _loopI < interacts.length; _loopI++)
				{
					if (_controlled.length != 0 && interacts[_loopI].get(Enemy))
					{
						assignTarget(interacts[_loopI].id, true);
						updateControlled();

						if (_inFTE)
							progressFTE();

						break;
					} else if (interacts[_loopI].get(Owned))
					{
						//switch to this entity owned by the player if we cannot find an enemy
						if (!interacts[_loopI].has(Building) || Building(interacts[_loopI].get(Building)).buildingVO.itemClass == TypeEnum.POINT_DEFENSE_PLATFORM)
						{
							if (interacts[_loopI] == _lastEntityClicked && tempTime - _lastClickTime < 250)
							{
								if (!_shiftKeyDown)
									uncontrolAllEntities();

								controlAllEntitiesOfType(interacts[_loopI]);
							} else if (Interactable(interacts[_loopI].get(Interactable)).selected && _shiftKeyDown)
							{
								uncontrolEntity(interacts[_loopI]);
								break;
							} else if (!Interactable(interacts[_loopI].get(Interactable)).selected || !_shiftKeyDown)
							{
								//get rid of all the controlled entities except the one that we want if shift is not down
								if (!_shiftKeyDown && (_controlled.length != 1 || _controlled[0].entity != interacts[_loopI]))
									uncontrolAllEntities();

								assignTarget(_futureTargetID, true);
								controlEntity(interacts[_loopI]);
								_lastEntityClicked = interacts[_loopI];

								if (tempTime - _lastClickTime < 150)
									controlAllEntitiesOfType(interacts[_loopI]);

								else
									updateControlled();

								if (_inFTE)
									progressFTE();

								break;
							}
						}
					}
				}
			} else if (_controlled)
			{
				//player is trying to move their ship
				moveControlledToLocation(dx, dy);
			}

			_lastClickTime = tempTime;

			return interacts;
		}

		override public function onKey( keyCode:uint, up:Boolean = true ):void
		{
			if (!_fteController.running && (_chatController.chatHasFocus || _viewController.modalHasFocus))
				return;

			var cnt:int = 0;
			var direction:int;
			var eSelected:Entity;
			var num:int;
			var temp:Entity;

			super.onKey(keyCode, up);
			switch (keyCode)
			{
				//left / right
				case KeyboardKey.A.keyCode:
				{
					if (_ctrlKeyDown)
					{
						controlAllEntities();
						break;
					}
				}

				case KeyboardKey.D.keyCode:
				case KeyboardKey.LEFT.keyCode:
				case KeyboardKey.RIGHT.keyCode:
				{
					if (_shiftKeyDown && _controlled.length == 6)
						return;

					eSelected = _controlled.length > 0 ? _controlled[0].entity : null;
					direction = (keyCode == KeyboardKey.A.keyCode || keyCode == KeyboardKey.LEFT.keyCode) ? 0 : 1;

					var node:OwnedNode;
					if (eSelected)
					{
						for (node = owned.head; node; node = node.next)
						{
							//find the currently selected node
							if (node.entity == eSelected)
								break;
						}
					} else if (owned.head)
						node = owned.head;

					temp = (eSelected) ? eSelected : (node) ? node.entity : null;

					while (node && cnt != 1)
					{
						if (direction == 0)
							node = (node.previous) ? node.previous : owned.tail;
						else
							node = (node.next) ? node.next : owned.head;

						if (node.entity == temp)
							cnt++;
						else
						{
							if (!node.interactable.selected || !_shiftKeyDown)
							{
								if (!_shiftKeyDown)
								{
									assignTarget(_futureTargetID);
									uncontrolAllEntities();
								}

								controlEntity(node.entity);
								break;
							}
						}
					}

					if (cnt == 1 && node != null && !eSelected && node.detail.category == CategoryEnum.SHIP)
					{
						if (!node.interactable.selected || !_shiftKeyDown)
						{
							if (!_shiftKeyDown)
							{
								assignTarget(_futureTargetID);
								uncontrolAllEntities();
							}
							controlEntity(node.entity);
						}
					}

					updateControlled();
					if (_inFTE)
						progressFTE();

					break;
				}

				//up / down
				case KeyboardKey.DOWN.keyCode:
				case KeyboardKey.S.keyCode:
				case KeyboardKey.UP.keyCode:
				case KeyboardKey.W.keyCode:
				{
					if (_controlled.length > 0)
					{
						eSelected = _controlled[0].selectedEnemy;
						direction = (keyCode == KeyboardKey.S.keyCode || keyCode == KeyboardKey.DOWN.keyCode) ? 0 : 1;

						var eNode:EnemyNode;

						if (eSelected)
						{
							for (eNode = enemy.head; eNode; eNode = eNode.next)
							{
								//find the currently selected node
								if (eNode.entity == eSelected)
									break;
							}
						} else if (enemy.head)
							eNode = enemy.head;

						temp = (eSelected) ? eSelected : (eNode) ? eNode.entity : null;

						while (eNode && cnt != 1)
						{
							if (direction == 0)
								eNode = (eNode.previous) ? eNode.previous : enemy.tail;
							else
								eNode = (eNode.next) ? eNode.next : enemy.head;

							if (eNode.entity == temp)
								cnt++;
							else
							{
								_futureTargetID = eNode.entity.id;
								_futureTargetTime = 0;
								setEnemy(eNode.entity.id);
								break;
							}
						}

						if (cnt == 1 && eNode != null && !eSelected)
						{
							_futureTargetID = eNode.entity.id;
							_futureTargetTime = 0;
							setEnemy(eNode.entity.id);
						}
						showEnemySelector();
					}

					if (_inFTE)
						progressFTE();

					break;
				}

				//shift
				case KeyboardKey.CONTROL.keyCode:
				{
					_ctrlKeyDown = !up;
					if (up && _shipSelectionEntity)
					{
						_startDrag.setTo(Application.STAGE.mouseX, Application.STAGE.mouseY);
						_interactFactory.destroyInteractEntity(_shipSelectionEntity);
						_shipSelectionEntity = null;
					}
					break;
				}

				//control
				case KeyboardKey.SHIFT.keyCode:
				{
					_shiftKeyDown = !up;
					if (up && _shipSelectionEntity)
					{
						_startDrag.setTo(Application.STAGE.mouseX, Application.STAGE.mouseY);
						_interactFactory.destroyInteractEntity(_shipSelectionEntity);
						_shipSelectionEntity = null;
					}
					break;
				}

				//Q key, select all
				case KeyboardKey.Q.keyCode:
				{
					controlAllEntities();
					break;
				}

				//deselect all entities
				case KeyboardKey.ESCAPE.keyCode:
				{
					uncontrolAllEntities();
					break;
				}

				//function keys
				case KeyboardKey.F1.keyCode:
				case KeyboardKey.F2.keyCode:
				case KeyboardKey.F3.keyCode:
				case KeyboardKey.F4.keyCode:
				case KeyboardKey.F5.keyCode:
				case KeyboardKey.F6.keyCode:
				{
					if (_fleetVO)
					{
						var tempTime:Number = getTimer();
						num = keyCode - 112;
						eSelected = _game.getEntity(_fleetVO.getShipIDByIndex(num));

						if (eSelected)
						{
							if (eSelected == _lastEntityClicked && tempTime - _lastClickTime < 250)
							{
								if (!_shiftKeyDown)
									uncontrolAllEntities();
								controlAllEntitiesOfType(eSelected);
							} else if (Interactable(eSelected.get(Interactable)).selected && _shiftKeyDown)
							{
								uncontrolEntity(eSelected);
								break;
							} else if (!Interactable(eSelected.get(Interactable)).selected || !_shiftKeyDown)
							{
								//get rid of all the controlled entities except the one that we want if shift is not down
								if (!_shiftKeyDown && (_controlled.length != 1 || _controlled[0].entity != eSelected))
									uncontrolAllEntities();
								assignTarget(_futureTargetID, true);
								controlEntity(eSelected);
								_lastEntityClicked = eSelected;
								updateControlled();
								_lastClickTime = tempTime;
								break;
							}
						}
					}

					break;
				}

				//number keys
				case KeyboardKey.ONE.keyCode:
				case KeyboardKey.TWO.keyCode:
				case KeyboardKey.THREE.keyCode:
				case KeyboardKey.FOUR.keyCode:
				case KeyboardKey.FIVE.keyCode:
				case KeyboardKey.SIX.keyCode:
				case KeyboardKey.SEVEN.keyCode:
				case KeyboardKey.EIGHT.keyCode:
				case KeyboardKey.NINE.keyCode:
				case KeyboardKey.ZERO.keyCode:
				{
					if (_fleetVO)
					{
						//assign group
						if (_ctrlKeyDown)
						{
							var a:String = '';
							for each (var ctrlEntity:ControlledEntity in _controlled)
								a += _fleetVO.getShipIndexByID(ctrlEntity.entity.id);
							_fleetVO.fleetGroupData[keyCode] = a;
							_settingsController.save();
						}
						//select group
						else
						{
							a = _fleetVO.fleetGroupData[keyCode];
							if (a && a.length > 0)
							{
								uncontrolAllEntities();
								var entity:Entity;
								var id:String;
								var index:int;
								for (var idx:int = 0; idx < a.length; idx++)
								{
									index = int(a.charAt(idx));
									id = _fleetVO.getShipIDByIndex(index);
									if (id)
									{
										entity = _game.getEntity(id);
										if (entity)
											controlEntity(entity);
									}
								}
							} else if (keyCode < KeyboardKey.SEVEN.keyCode)
								onKey(KeyboardKey.F1.keyCode + (keyCode - KeyboardKey.ONE.keyCode));
						}
						_lastGroupSelected = keyCode;
					}

					break;
				}

				case KeyboardKey.T.keyCode:
				case KeyboardKey.R.keyCode:
				{
					cnt = 0;
					var found:Boolean;
					var dir:int                       = 1; //keyCode == KeyboardKey.T.keyCode ? 1 : -1;
					var shipType:String               = getNextShipType(dir);
					while (!found && cnt <= 6)
					{
						if (checkOwnedForShipType(shipType))
							found = true;
						shipType = getNextShipType(dir);
						cnt++;
					}

					var detail:Detail;
					var selectedShips:Vector.<Entity> = Vector.<Entity>([]);
					node = owned.head;
					while (node)
					{
						detail = node.entity.get(Detail);

						if (detail)
						{
							var split:Array    = detail.type.split("_");
							var trimmed:String = split.length > 0 ? split[0] : "";
							if (trimmed && trimmed.toLowerCase() == shipType.toLowerCase())
								selectedShips.push(node.entity);
						}
						node = node.next;
					}

					if (selectedShips.length > 0)
					{
						uncontrolAllEntities();
						for each (entity in selectedShips)
							controlEntity(entity);
					}
					break;
				}

				case KeyboardKey.F.keyCode:
				case KeyboardKey.G.keyCode:
				{
					if (_fleetVO)
					{
						if (_lastGroupSelected < 0)
							break;
						cnt = 0;
						found = false;
						var tmpGroupKeyCode:int = _lastGroupSelected;
						var i:int               = keyCode == KeyboardKey.F.keyCode ? -1 : 1;
						while (!found && cnt <= 10)
						{
							//advance the numeric group assignment
							tmpGroupKeyCode += i;

							if (tmpGroupKeyCode < KeyboardKey.ZERO.keyCode)
								tmpGroupKeyCode = KeyboardKey.NINE.keyCode;
							else if (tmpGroupKeyCode > KeyboardKey.NINE.keyCode)
								tmpGroupKeyCode = KeyboardKey.ZERO.keyCode;

							if (_fleetVO.fleetGroupData.hasOwnProperty(tmpGroupKeyCode))
							{
								found = true;
							}
							cnt++;
						}
						if (found)
							onKey(tmpGroupKeyCode);
					}
					break;
				}
			}
		}

		private function checkOwnedForShipType( type:String ):Boolean
		{
			var found:Boolean;
			var detail:Detail;
			var node:OwnedNode = owned.head;

			while (!found && node)
			{
				detail = node.entity.get(Detail);

				if (detail && detail.type.indexOf(type) > -1)
					found = true;

				node = node.next;
			}

			return found;
		}

		private function getNextShipType( direction:int = 1 ):String
		{
			var idx:int = _lastTypeSelected + direction;

			if (idx < 0)
				idx = _shipTypes.length - 1;

			if (idx > _shipTypes.length - 1)
				idx = 0;

			_lastTypeSelected = idx;

			return _shipTypes[idx];
		}

		public function selectOwnedShipByID( id:String ):void
		{
			//get the index of the id
			if (_fleetVO)
			{
				//call onkey with the keycode of a function key to select the ship
				var index:int = _fleetVO.getShipIndexByID(id);
				if (index > -1)
					onKey(KeyboardKey.F1.keyCode + index, true);
			}
		}

		public function updateControlled():void
		{
			if (presenter)
			{
				if (_controlled.length > 0)
				{
					showDestination();
					showEnemySelector();
				}
			}
		}

		private function showDestination():void
		{
			var index:int;
			var key:String;
			var move:Move;

			for (_i = 0; _i < _controlled.length; _i++)
			{
				_tempControlled = _controlled[_i];
				if (_tempControlled.entity.has(Building))
					continue;
				move = _tempControlled.entity.get(Move);

				if (!move)
				{
					if (_tempControlled.destination)
						_tempControlled.destination = null;

					continue;
				}

				key = int(move.destination.x) + "-" + int(move.destination.y);

				if (SelectorEntity.getSelectorEntity(key))
					_tempControlled.destination = SelectorEntity.getSelectorEntity(key);

				else
					_tempControlled.destination = createSelectorEntity(key, _interactFactory.showSelection(null, null, move.destination.x, move.destination.y, true));
			}
		}

		private function showEnemySelector():void
		{
			var attack:Attack;
			for (_i = 0; _i < _controlled.length; _i++)
			{
				_tempControlled = _controlled[_i];
				attack = _tempControlled.entity.get(Attack);

				if (!attack || attack.targetID == null)
				{
					_tempControlled.selectorEnemy = null;
					_tempControlled.selectedEnemy = null;
					continue;
				} else
				{
					_tempControlled.selectedEnemy = _game.getEntity(attack.targetID);

					if (!_tempControlled.selectedEnemy)
					{
						_tempControlled.selectorEnemy = null;
						_tempControlled.selectedEnemy = null;
					} else
					{
						if (SelectorEntity.getSelectorEntity(attack.targetID))
							_tempControlled.selectorEnemy = SelectorEntity.getSelectorEntity(attack.targetID);
						else
							_tempControlled.selectorEnemy = createSelectorEntity(attack.targetID, _interactFactory.showSelection(_tempControlled.selectedEnemy, null,0,0,true));
					}
				}
			}
		}

		private function setEnemy( enemyID:String ):void
		{
			var attack:Attack;

			for (_i = 0; _i < _controlled.length; _i++)
			{
				_tempControlled = _controlled[_i];
				attack = _tempControlled.entity.get(Attack);
				attack.targetID = enemyID;
			}
		}

		private function controlEntity( entity:Entity ):void
		{
			if( _battleModel.isReplay )
			{
				return;
			}
			var attack:Attack             = entity.get(Attack);
			var interactable:Interactable = entity.get(Interactable);

			if (!interactable.selected)
			{
				interactable.selected = true;

				var controlled:ControlledEntity = ObjectPool.get(ControlledEntity);
				controlled.entity = entity;
				controlled.selectedEnemy = _game.getEntity(attack.targetID);
				controlled.selector = _interactFactory.showSelection(controlled.entity, controlled.selector,0,0,true);
				if (entity.has(Building))
					controlled.range = _interactFactory.createRange(controlled.entity);
				else
					controlled.range = _interactFactory.createShipRange(controlled.entity);
				_controlled.push(controlled);
				onControlledUpdated.dispatch(_controlled);
			}
		}

		private function controlAllEntitiesOfType( entity:Entity ):void
		{
			var added:Boolean = false;
			var detail:Detail = entity.get(Detail);

			for (var node:OwnedNode = owned.head; node; node = node.next)
			{
				if (!node.interactable.selected && Detail(node.entity.get(Detail)).type == detail.type)
				{
					controlEntity(node.entity);
					added = true;
				}
			}

			if (added)
				updateControlled();
		}

		private function controlAllEntities():void
		{
			var added:Boolean = false;

			for (var node:OwnedNode = owned.head; node; node = node.next)
			{
				if (!node.interactable.selected)
				{
					controlEntity(node.entity);
					added = true;
				}
			}

			if (added)
				updateControlled();
		}

		private function uncontrolEntity( entity:Entity ):void
		{
			for (_i = 0; _i < _controlled.length; _i++)
			{
				if (_controlled[_i].entity == entity)
				{
					_tempControlled = _controlled[_i];
					if (entity.has(Interactable))
						Interactable(entity.get(Interactable)).selected = false;
					_tempControlled.selectedEnemy = null;
					_tempControlled.destination = null;
					_interactFactory.destroyInteractEntity(_tempControlled.range);
					_interactFactory.destroyInteractEntity(_tempControlled.selector);
					ObjectPool.give(_tempControlled);
					_controlled.splice(_i, 1);
					break;
				}
			}
		}

		private function uncontrolAllEntities():void
		{
			for (_i = 0; _i < _controlled.length; _i++)
			{
				_tempControlled = _controlled[_i];
				Interactable(_tempControlled.entity.get(Interactable)).selected = false;
				_tempControlled.selectedEnemy = null;
				_tempControlled.destination = null;
				_interactFactory.destroyInteractEntity(_tempControlled.range);
				_interactFactory.destroyInteractEntity(_tempControlled.selector);
				ObjectPool.give(_tempControlled);
			}

			_controlled.length = 0;
		}

		private function moveControlledToLocation( dx:Number, dy:Number ):void
		{
			var move:Move;
			var position:Position;

			for (_i = 0; _i < _controlled.length; _i++)
			{
				_tempControlled = _controlled[_i];
				if (_tempControlled.entity.has(Building))
					continue;
				move = _tempControlled.entity.get(Move);

				if (move)
				{
					position = Position(_tempControlled.entity.get(Position));
					var dest:Point = updateScenePt(dx, dy);
					//only send the message to move if the destination is far enough away from their last destination

					if (Math.abs(move.destination.x - dest.x) > 10 || Math.abs(move.destination.y - dest.y) > 10)
					{
						move.setDestination(dest.x, dest.y);
						_gameController.battleMoveShip(_tempControlled.entity.id, dest.x, dest.y, ServerController.SIMULATED_TICK);
					}
				}
			}
			showDestination();
			if (_progressFTEOnMove)
			{
				_progressFTEOnMove = false;
				progressFTE();
			}
		}

		private function assignTarget( target:String, moveToTarget:Boolean = false ):void
		{
			if (_controlled.length > 0 && target)
			{
				for (_i = 0; _i < _controlled.length; _i++)
				{
					Attack(_controlled[_i].entity.get(Attack)).targetID = target;
					_gameController.battleAttackShip(_controlled[_i].entity.id, target, moveToTarget);
				}
			}

			_futureTargetID = null;
			_futureTargetTime = 0;
		}

		private function onNodeRemoved( node:OwnedNode ):void
		{
			uncontrolEntity(node.entity);
		}

		private function onEnemyRemoved( node:EnemyNode ):void
		{
			for (_i = 0; _i < _controlled.length; _i++)
			{
				if (_controlled[_i].selectedEnemy == node.entity)
				{
					_tempControlled = _controlled[_i];
					_tempControlled.selectorEnemy = null;
					_tempControlled.selectedEnemy = null;
					Attack(_tempControlled.entity.get(Attack)).targetID = null;

				}
			}
		}

		private function createSelectorEntity( id:String, entity:Entity ):SelectorEntity
		{
			if (entity == null)
				return null;
			var selector:SelectorEntity = ObjectPool.get(SelectorEntity);
			selector.init(id, entity, _interactFactory);
			return selector;
		}

		public function buildRanges():void
		{
			for (var on:OwnedNode = owned.head; on; on = on.next)
			{
				if(_battleModel.isInstancedMission)
					_rangeBuilder.buildRangeFromNodeOnly(on);
				else
					_rangeBuilder.buildRangeFromNode(on);
			}
		}

		public function toggleFTEProgressOnMove():void  { _progressFTEOnMove = true; }

		[Inject]
		public function set battleModel( value:BattleModel ):void  { _battleModel = value; }
		[Inject]
		public function set chatController( value:ChatController ):void  { _chatController = value; }
		[Inject]
		public function set fleetModel( value:FleetModel ):void  { _fleetModel = value; }
		[Inject]
		public function set gameController( value:GameController ):void  { _gameController = value; }
		[Inject]
		public function set interactFactory( value:IInteractFactory ):void  { _interactFactory = value; }
		public function set presenter( v:IBattlePresenter ):void  { _presenter = v; }
		public function get presenter():IBattlePresenter  { return IBattlePresenter(_presenter); }
		[Inject]
		public function set rangeBuilder( v:RangeBuilder ):void  { _rangeBuilder = v; }
		[Inject]
		public function set settingsController( v:SettingsController ):void  { _settingsController = v; }

		override public function removeFromGame( game:Game ):void
		{
			super.removeFromGame(game);
			enemy.nodeRemoved.remove(onEnemyRemoved);
			enemy = null;
			owned.nodeAdded.remove(onNodeAdded);
			owned.nodeRemoved.remove(onNodeRemoved);
			owned = null;

			onControlledUpdated.removeAll();
			onControlledUpdated = null;

			uncontrolAllEntities();
			_chatController = null;
			_game = null;
			_gameController = null;
			_interactFactory.clearRanges();
			_interactFactory = null;
			_rangeBuilder = null;
			_controlled = null;
			_settingsController = null;
			_shipSelectionEntity = null;
			_tempControlled = null;
		}
	}
}
