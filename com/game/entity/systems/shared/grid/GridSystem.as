package com.game.entity.systems.shared.grid
{
	import com.Application;
	import com.controller.ServerController;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.StateEvent;
	import com.event.signal.InteractSignal;
	import com.event.signal.QuadrantSignal;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Grid;
	import com.game.entity.components.shared.Position;
	import com.game.entity.nodes.shared.grid.GridMoveNode;
	import com.game.entity.nodes.shared.grid.GridNode;
	import com.game.entity.nodes.shared.grid.IGridNode;
	import com.model.scene.SceneModel;
	import com.presenter.sector.IMiniMapPresenter;
	import com.service.server.outgoing.sector.SectorSetViewLocationRequest;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class GridSystem extends System
	{
		/** Number of grid cells to look in each direction. Not exactly a "radius," but close enough. */
		private const QUADRANT_RADIUS:int = 3;

		[Inject]
		public var interactSignal:InteractSignal;
		[Inject(nodeType="com.game.entity.nodes.shared.grid.GridNode")]
		public var nodes:NodeList;
		[Inject(nodeType="com.game.entity.nodes.shared.grid.GridMoveNode")]
		public var movingNodes:NodeList;
		[Inject]
		public var quadrantSignal:QuadrantSignal;
		[Inject]
		public var sceneModel:SceneModel;

		private var _game:Game;
		private var _grid:GridField;
		private var _miniMapPresenter:IMiniMapPresenter;
		private var _newColumnSpan:Point;
		private var _newRowSpan:Point;
		private var _oldColumnSpan:Point;
		private var _oldRowSpan:Point;
		private var _point:Point;
		private var _queue:Vector.<IGridNode>;

		/** Tracks the hashes of the bounding cells of the quadrant. x = TL, y = BR */
		private var _quadrantHash:Point;

		/** The actual coordinate bounds of the quadrant. */
		private var _quadrantBounds:Rectangle;

		private var _serverController:ServerController;
		private var _testRect:Rectangle;
		private var _visibleHash:Point;
		private var _visibleBounds:Rectangle;

		public function GridSystem()  {}

		override public function addToGame( game:Game ):void
		{
			_game = game;
			_newColumnSpan = new Point();
			_newRowSpan = new Point();
			_oldColumnSpan = new Point();
			_oldRowSpan = new Point();
			_point = new Point();
			_queue = new Vector.<IGridNode>;
			_quadrantHash = new Point();
			_quadrantBounds = new Rectangle(-100, -100, 1, 1);
			_testRect = new Rectangle();
			_visibleHash = new Point();
			_visibleBounds = new Rectangle(-100, -100, 1, 1);
			interactSignal.add(onScroll);
			//add any entities that exist into their correct quadrants
			for (var node:GridNode = nodes.head; node; node = node.next)
				onEntityCreated(node);
			for (var moveNode:GridMoveNode = movingNodes.head; moveNode; moveNode = moveNode.next)
				onEntityCreated(moveNode);

			//listen for new entities
			nodes.nodeAdded.add(onEntityCreated);
			nodes.nodeRemoved.add(onEntityRemoved);
		}

		override public function update( time:Number ):void
		{
			if (!sceneModel.ready)
				return;
			//we must know the width and height of entities before adding them to quadrants
			//check to see if any in the queue now have a width and height that we can use
			if (_queue.length > 0)
			{
				for (var i:int = _queue.length - 1; i > -1; i--)
				{
					if (_queue[i].animation.width > 0)
					{
						onEntityCreated(_queue[i]);
						_queue.splice(i, 1);
					}
				}
			}

			var newHashTL:int;
			var newHashBR:int;
			for (var node:GridMoveNode = movingNodes.head; node; node = node.next)
			{
				if (node.move.moving && node.animation.ready)
				{
					newHashTL = _grid.getHash(node.position.x - node.animation.offsetX, node.position.y - node.animation.offsetY);
					newHashBR = _grid.getHash(node.position.x - node.animation.offsetX + node.animation.width, node.position.y - node.animation.offsetY + node.animation.height);
					if (newHashTL != node.grid.hashTL || newHashBR != node.grid.hashBR)
					{
						onEntityRemoved(node);
						onEntityCreated(node);
					}
				}
			}
		}

		public function getEntitiesAt( x:Number, y:Number ):Array
		{
			var hash:int = _grid.getHash(x, y);
			return _grid.getObjects(hash);
		}

		public function forceGridCheck( entity:Entity ):void
		{
			var grid:Grid           = entity.get(Grid);
			var position:Position   = entity.get(Position);
			var animation:Animation = entity.get(Animation);
			if (!grid || !animation.ready)
				return;
			var newHashTL:int       = _grid.getHash(position.x - animation.offsetX, position.y - animation.offsetY);
			var newHashBR:int       = _grid.getHash(position.x - animation.offsetX + animation.width, position.y - animation.offsetY + animation.height);
			if (newHashTL != grid.hashTL || newHashBR != grid.hashBR)
			{
				for (var node:GridNode = nodes.head; node; node = node.next)
				{
					if (node.entity == entity)
					{
						onEntityRemoved(node);
						onEntityCreated(node);
						break;
					}
				}
			}
		}

		/**
		 * A new entity has been created. Add it to the cells it belongs to
		 * @param node The entity that was created
		 */
		private function onEntityCreated( node:IGridNode ):void
		{
			if (node.animation.width > 0 && sceneModel.ready)
			{
				var hashTL:int = _grid.getHash(node.position.x - node.animation.offsetX, node.position.y - node.animation.offsetY);
				var hashBR:int = _grid.getHash(node.position.x - node.animation.offsetX + node.animation.width,
											   node.position.y - node.animation.offsetY + node.animation.height);
				node.grid.hashTL = hashTL;
				node.grid.hashBR = hashBR;
				var len:int    = hashBR % _grid.COLUMNS;
				var i:int      = hashTL;
				while (i <= hashBR)
				{
					_grid.addToCell(node, i);

					//check to see if it is visible
					if (!node.animation.visible && _grid.withinBounds(i, _visibleHash.x, _visibleHash.y))
						node.animation.visible = true;
					if (i % _grid.COLUMNS == len)
					{
						hashTL += _grid.COLUMNS;
						i = hashTL;
					} else
						i++;
				}

				_miniMapPresenter.addToMiniMapSignal.dispatch(node.ientity, _quadrantBounds);
			} else
			{
				//not ready so queue up or remove from the queue if needed
				_queue.push(node);
			}
		}

		/**
		 * A new entity has been destroyed. Remove it from the quadrants it belongs too
		 * @param node The entity that was destroyed
		 */
		private function onEntityRemoved( node:IGridNode ):void
		{
			if (node.animation.width > 0 && sceneModel.ready)
			{
				_grid.removeFromAllCells(node);
				_miniMapPresenter.removeFromMiniMapSignal.dispatch(node.ientity);
			} else
			{
				var index:int = _queue.indexOf(GridNode(node));
				if (index > -1)
					_queue.splice(index, 1);
			}
		}

		/**
		 * Called whenever the player scrolls the screen
		 * @param type The type of signal being dispatched.
		 * @param dx The distance along the x axis that the screen scrolled
		 * @param dy The distance along the y axis that the screen scrolled
		 */
		private function onScroll( type:String, dx:Number, dy:Number ):void
		{
			if (!sceneModel.ready)
				return;
			if (!_grid)
				onBackgroundReady()
			if (type == InteractSignal.SCROLL || type == InteractSignal.ZOOM)
			{
				var oldHash:Point;
				if (!_visibleBounds.containsRect(sceneModel.viewArea))
				{
					oldHash = _visibleHash.clone();
					updateVisibleQuadrantArea();
					updateVisibleQuadrants(oldHash);
				}

				if (type == InteractSignal.ZOOM)
					_miniMapPresenter.updateScale();

				if (Application.STATE == StateEvent.GAME_SECTOR)
				{
					if (!_quadrantBounds.contains(sceneModel.focus.x, sceneModel.focus.y))
					{
						var setView:SectorSetViewLocationRequest = SectorSetViewLocationRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_SET_VIEW_LOCATION));
						setView.x = sceneModel.focus.x;
						setView.y = sceneModel.focus.y;
						_serverController.send(setView);
						updateQuadrantArea();
					}
				}
				_miniMapPresenter.scrollMiniMapSignal.dispatch();
			} else if (type == InteractSignal.RESOLUTION_CHANGE)
			{
				oldHash = _visibleHash.clone();
				updateVisibleQuadrantArea();
				updateVisibleQuadrants(oldHash);
			}
		}

		/**
		 * Quadrant is the area we can observe; we inform the server of this so it will send us updates within those bounds.
		 * This is 3 grid cells in each direction from our focal point.
		 */
		private function updateQuadrantArea():void
		{
			var focusHash:int = _grid.getHash(sceneModel.focus.x, sceneModel.focus.y);
			_grid.getKey(focusHash, _point);

			// Get the top left cell
			_quadrantHash.x = _grid.getClampedCellByOffset(focusHash, -QUADRANT_RADIUS, -QUADRANT_RADIUS);

			// And the bottom right
			_quadrantHash.y = _grid.getClampedCellByOffset(focusHash, +QUADRANT_RADIUS, +QUADRANT_RADIUS);

			var tlKey:Point   = new Point();
			var brKey:Point   = new Point();
			_grid.getKey(_quadrantHash.x, tlKey);
			_grid.getKey(_quadrantHash.y, brKey);
			brKey.x += _grid.CELL_SIZE;
			brKey.y += _grid.CELL_SIZE;
			_quadrantBounds.setTo(tlKey.x, tlKey.y, brKey.x - tlKey.x, brKey.y - tlKey.y);
		}

		/**
		 * Sets the visibility of the quadrants
		 */
		private function updateVisibleQuadrants( oldHash:Point ):void
		{
			var oldColumnSpan:Point = new Point(oldHash.x % _grid.COLUMNS, oldHash.y % _grid.COLUMNS);
			var newColumnSpan:Point = new Point(_visibleHash.x % _grid.COLUMNS, _visibleHash.y % _grid.COLUMNS);
			var oldRowSpan:Point    = new Point((oldHash.x / _grid.COLUMNS) | 0, (oldHash.y / _grid.COLUMNS) | 0);
			var newRowSpan:Point    = new Point((_visibleHash.x / _grid.COLUMNS) | 0, (_visibleHash.y / _grid.COLUMNS) | 0);

			for (var i:int = oldRowSpan.x; i <= oldRowSpan.y; i++)
			{
				for (var j:int = oldColumnSpan.x; j <= oldColumnSpan.y; j++)
				{
					if (i < newRowSpan.x || i > newRowSpan.y || j < newColumnSpan.x || j > newColumnSpan.y)
					{
						adjustAnimations(_grid.getObjects(j + i * _grid.COLUMNS), false);
					}
				}
			}

			for (i = newRowSpan.x; i <= newRowSpan.y; i++)
			{
				for (j = newColumnSpan.x; j <= newColumnSpan.y; j++)
				{
					if (i < oldRowSpan.x || i > oldRowSpan.y || j < oldColumnSpan.x || j > oldColumnSpan.y)
					{
						adjustAnimations(_grid.getObjects(j + i * _grid.COLUMNS), true);
					}
				}
			}
		}

		private function updateVisibleQuadrantArea():void
		{
			var viewArea:Rectangle = sceneModel.viewArea;
			_visibleHash.x = _grid.getHash(viewArea.x, viewArea.y);
			_visibleHash.y = _grid.getHash(viewArea.right, viewArea.bottom);
			_grid.getKey(_visibleHash.x, _point);
			_visibleBounds.setTo(_point.x, _point.y, 0, 0);
			_grid.getKey(_visibleHash.y, _point);
			_visibleBounds.setTo(_visibleBounds.x, _visibleBounds.y,
								 _point.x - _visibleBounds.x + _grid.CELL_SIZE,
								 _point.y - _visibleBounds.y + _grid.CELL_SIZE);
			quadrantSignal.visibleHashChanged(_visibleBounds);
		}

		private function adjustAnimations( nodes:Array, visible:Boolean ):void
		{
			if (!nodes)
				return;
			for each (var node:IGridNode in nodes)
			{
				if (!visible)
				{
					//ensure that this object is actually not visible anymore
					_testRect.setTo(node.position.x - node.animation.offsetX, node.position.y - node.animation.offsetY, node.animation.width, node.animation.height);
					if (!_visibleBounds.intersects(_testRect))
						node.animation.visible = false;
				} else
					node.animation.visible = true;
			}
		}

		public function onBackgroundReady():void
		{
			_grid = new GridField(500, sceneModel.bounds);

			updateQuadrantArea();
			updateVisibleQuadrantArea();
			_miniMapPresenter.mapWidth = quadrantSize;

			for (var node:GridNode = nodes.head; node; node = node.next)
			{
				onEntityCreated(node);
			}
			quadrantSignal.visibleHashChanged(_visibleBounds);
		}

		/**
		 * The size of each axis of the quadrant. The quadrant is assumed square.
		 * Note that it can actually be smaller than this if we are close to the sector edge.
		 * We mainly use this for scaling the minimap.
		 *
		 * @return	The coordinate size of the quadrant.
		 */
		public function get quadrantSize():int  { return (QUADRANT_RADIUS * 2) * _grid.CELL_SIZE; }

		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		[Inject]
		public function set minimapPresenter( value:IMiniMapPresenter ):void  { _miniMapPresenter = value; }

		override public function removeFromGame( game:Game ):void
		{
			_miniMapPresenter.clearMiniMapSignal.dispatch();

			_game = null;
			_newColumnSpan = null;
			_newRowSpan = null;
			_oldColumnSpan = null;
			_oldRowSpan = null;
			_point = null;
			_quadrantHash = null;
			_quadrantBounds = null;
			_queue = null;
			_visibleHash = null;
			_visibleBounds = null;

			if (_grid)
				_grid.destroy();
			_grid = null;

			interactSignal.remove(onScroll);
			interactSignal = null;
			quadrantSignal = null;
			sceneModel = null;
			nodes.nodeAdded.remove(onEntityCreated);
			nodes.nodeRemoved.remove(onEntityRemoved);
			nodes = null;
			movingNodes = null;
		}
	}
}
