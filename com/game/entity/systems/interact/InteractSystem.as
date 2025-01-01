package com.game.entity.systems.interact
{
	import com.Application;
	import com.controller.fte.FTEController;
	import com.controller.keyboard.KeyboardController;
	import com.controller.keyboard.KeyboardKey;
	import com.enum.CategoryEnum;
	import com.event.signal.InteractSignal;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Interactable;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.starbase.Building;
	import com.game.entity.components.starbase.Platform;
	import com.game.entity.systems.interact.controls.IControlScheme;
	import com.game.entity.systems.shared.grid.GridSystem;
	import com.model.asset.AssetVO;
	import com.model.scene.SceneModel;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.System;
	import org.parade.core.IViewStack;
	import org.parade.core.ViewController;
	import org.parade.core.ViewEvent;
	import org.parade.enum.ViewEnum;
	import org.robotlegs.extensions.presenter.api.IPresenter;

	public class InteractSystem extends System
	{
		private static const DECAY:Number  = .9;
		private static const THRESHOLD:int = 5;

		protected var _bbox:Rectangle;
		protected var _begunInteraction:Boolean;
		protected var _controlScheme:IControlScheme;
		protected var _dragging:Boolean;
		protected var _entityToFollow:Entity;
		protected var _eventDispatcher:IEventDispatcher;
		protected var _fteController:FTEController;
		protected var _gridSystem:GridSystem;
		protected var _inFTE:Boolean;
		protected var _interactSignal:InteractSignal;
		protected var _isRightMouseDown:Boolean;
		protected var _keyboardController:KeyboardController;
		protected var _layer:*;
		protected var _minZoom:Number;
		protected var _maxZoom:Number;
		protected var _point:Point;
		protected var _presenter:IPresenter;
		protected var _residualScroll:Boolean;
		protected var _sceneModel:SceneModel;
		protected var _scrollDelta:Point;
		protected var _scrollDeltaStart:Point;
		protected var _starbaseModel:StarbaseModel;
		protected var _startDrag:Point;
		protected var _stopScroll:Boolean;
		protected var _targetViewArea:Boolean;
		protected var _targetViewAreaDelta:Point;
		protected var _targetViewAreaStart:Point;
		protected var _targetViewAreaTime:Number;
		protected var _targetViewAreaTotalTime:Number;
		protected var _tempPoint:Point;
		protected var _viewStack:IViewStack;


		override public function addToGame( game:Game ):void
		{
			_begunInteraction = _dragging = _residualScroll = false;
			_bbox = new Rectangle();
			_gridSystem = GridSystem(game.getSystem(GridSystem));
			_inFTE = false;
			_layer = _viewStack.getLayer(ViewEnum.GAME);
			_minZoom = 0.5;
			_maxZoom = 1.2;
			_point = new Point();
			_scrollDelta = new Point();
			_scrollDeltaStart = new Point();
			_startDrag = new Point();
			_stopScroll = false;
			_targetViewArea = false;
			_targetViewAreaDelta = new Point();
			_targetViewAreaStart = new Point();
			_tempPoint = new Point();

			_eventDispatcher.addEventListener(ViewEvent.SHOW_VIEW, onShowView);
		}

		override public function update( time:Number ):void
		{
			//residual scroll
			if (_residualScroll)
			{
				adjustLocation(_scrollDelta.x, _scrollDelta.y);
				_scrollDelta.x *= DECAY;
				_scrollDelta.y *= DECAY;
				if (Math.abs(_scrollDelta.x) < .4 && Math.abs(_scrollDelta.y) < .4)
					_residualScroll = false;
			} else if (_targetViewArea)
			{
				_targetViewAreaTime += time;
				var ratio:Number = Math.min(_targetViewAreaTotalTime, _targetViewAreaTime) / _targetViewAreaTotalTime;
				jumpToLocation(_targetViewAreaStart.x + ratio * _targetViewAreaDelta.x, _targetViewAreaStart.y + ratio * _targetViewAreaDelta.y);
				if (ratio >= 1)
					_targetViewArea = false;
			} else if (_entityToFollow)
			{
				if (_entityToFollow.has(Move))
				{
					var position:Position = _entityToFollow.get(Position);
					jumpToLocation(position.x, position.y);
				} else
					_entityToFollow = null;
			}
		}

		public function moveToLocation( lx:Number, ly:Number, time:Number = 1 ):void
		{
			if (_sceneModel.ready)
			{
				_targetViewArea = true;
				_targetViewAreaStart.setTo(_sceneModel.focus.x, _sceneModel.focus.y);
				_targetViewAreaDelta.setTo(lx - _targetViewAreaStart.x, ly - _targetViewAreaStart.y);
				_targetViewAreaTime = 0;
				_targetViewAreaTotalTime = time;
			} else
				jumpToLocation(lx, ly);
		}

		public function jumpToLocation( lx:Number, ly:Number ):void
		{
			if (_sceneModel.ready)
			{
				_sceneModel.setFocus(lx, ly);
				_interactSignal.scroll(lx, ly);
			}
		}

		public function adjustLocation( lx:Number, ly:Number ):void
		{
			if (_sceneModel.ready)
			{
				_sceneModel.adjustFocus(lx, ly);
				_interactSignal.scroll(lx, ly);
			}
		}

		public function updateScenePt( dx:Number, dy:Number, pt:Point = null ):Point
		{
			if (!pt)
				pt = new Point();

			pt.x = int(_sceneModel.viewArea.x + (dx / _sceneModel.zoom));
			pt.y = int(_sceneModel.viewArea.y + (dy / _sceneModel.zoom));

			return pt;
		}

		protected function onInteraction_mouseDown( x:Number, y:Number, isRightMouse:Boolean = false ):void
		{
			_begunInteraction = true;
			_entityToFollow = null;
			_startDrag.x = x;
			_startDrag.y = y;
			_residualScroll = false;
			_targetViewArea = false;

			if (isRightMouse)
				_isRightMouseDown = true;
		}

		protected function hasDragStarted( x:Number, y:Number ):Boolean
		{
			var isDrag:Boolean;

			if (!_stopScroll && (_begunInteraction && (Math.abs(x - _startDrag.x) > THRESHOLD || Math.abs(y - _startDrag.y) > THRESHOLD)))
				isDrag = true;

			return isDrag;
		}

		protected function onInteraction_mouseMove( x:Number, y:Number ):void
		{
			if (!_dragging)
			{
				//only start dragging after the player has reached a drag threshold
				//				if (!_stopScroll && (_begunInteraction && (Math.abs(x - _startDrag.x) > THRESHOLD || Math.abs(y - _startDrag.y) > THRESHOLD)))
				//					_dragging = true;
				if (hasDragStarted(x, y))
					_dragging = true;

				else
					return;
			}

			_scrollDeltaStart.x = _startDrag.x;
			_scrollDeltaStart.y = _startDrag.y;
			var dx:Number = (_startDrag.x - x) / _sceneModel.zoom;
			var dy:Number = (_startDrag.y - y) / _sceneModel.zoom;
			adjustLocation(dx, dy);
			_startDrag.x = x;
			_startDrag.y = y;
		}

		protected function onInteraction_mouseUp( x:Number, y:Number, isRightMouse:Boolean = false ):void
		{
			if (_begunInteraction)
			{
				if (!_dragging)
					onClick(x, y);

				else
				{
					_scrollDelta.x = _scrollDeltaStart.x - _startDrag.x;
					_scrollDelta.y = _scrollDeltaStart.y - _startDrag.y;

					if (Math.abs(_scrollDelta.x) > 10 || Math.abs(_scrollDelta.y) > 10)
						_residualScroll = true;
				}
			}

			_begunInteraction = _dragging = false;

			if (isRightMouse)
				_isRightMouseDown = false;
		}

		public function onInteraction( type:String, x:Number, y:Number ):void
		{
			var isRightMouseBtn:Boolean = type == MouseEvent.RIGHT_MOUSE_DOWN || type == MouseEvent.RIGHT_MOUSE_UP;

			switch (type)
			{
				case MouseEvent.RIGHT_MOUSE_DOWN:
				case MouseEvent.MOUSE_DOWN:
				{
					onInteraction_mouseDown(x, y, isRightMouseBtn);
					break;
				}

				case MouseEvent.MOUSE_MOVE:
				{
					onInteraction_mouseMove(x, y);
					break;
				}

				case MouseEvent.RIGHT_MOUSE_UP:
				case MouseEvent.MOUSE_UP:
				{
					onInteraction_mouseUp(x, y, isRightMouseBtn);
					break;
				}
			}
		}

		public function onKey( keyCode:uint, up:Boolean = true ):void
		{
			switch (keyCode)
			{
				case KeyboardKey.SUBTRACT.keyCode:
				case KeyboardKey.MINUS.keyCode:
					onZoom(-.1, Application.STAGE.mouseX, Application.STAGE.mouseY);
					break;
				case KeyboardKey.ADD.keyCode:
				case KeyboardKey.PLUS.keyCode:
					onZoom(.1, Application.STAGE.mouseX, Application.STAGE.mouseY);
					break;
			}
		}

		protected var _viewController:ViewController;

		[Inject]
		public function set viewController( value:ViewController ):void  { _viewController = value; }
		public function get viewController():ViewController  { return _viewController; }

		public function onZoom( delta:Number, x:Number, y:Number ):void
		{
			if (_fteController.running || _viewController.modalHasFocus)
				return;

			var oldZoom:Number      = _sceneModel.zoom;
			var newZoom:Number      = _sceneModel.zoom + delta;

			newZoom = Math.round(newZoom * 10) / 10;
			newZoom = newZoom > _maxZoom ? _maxZoom : newZoom;
			newZoom = newZoom < _minZoom ? _minZoom : newZoom;

			if (newZoom == oldZoom)
				return;

			var oldDistanceX:Number = _sceneModel.viewArea.x + x / oldZoom;
			var oldDistanceY:Number = _sceneModel.viewArea.y + y / oldZoom;
			_sceneModel.zoom = newZoom;
			var newDistanceX:Number = _sceneModel.viewArea.x + x / newZoom;
			var newDistanceY:Number = _sceneModel.viewArea.y + y / newZoom;

			adjustLocation(oldDistanceX - newDistanceX, oldDistanceY - newDistanceY);
			_interactSignal.zoom(_sceneModel.zoom);
		}

		protected function onClick( dx:Number, dy:Number ):Vector.<Entity>
		{
			//see what the player is clicking on
			var interacts:Vector.<Entity> = new Vector.<Entity>;
			if (_sceneModel.ready)
			{
				var zoomPoint:Point = new Point(dx / _sceneModel.zoom, dy / _sceneModel.zoom);
				var entities:Array  = _gridSystem.getEntitiesAt(_sceneModel.viewArea.x + zoomPoint.x, _sceneModel.viewArea.y + zoomPoint.y);
				if (!entities)
					return interacts;
				var entity:Entity;
				var animation:Animation;
				_point.setTo(_sceneModel.viewArea.x + zoomPoint.x, _sceneModel.viewArea.y + zoomPoint.y);
				_starbaseModel.grid.convertIsoToGrid(_point);
				for (var i:int = 0; i < entities.length; i++)
				{
					entity = Entity(entities[i].entity);
					if (entity.has(Interactable))
					{
						animation = entity.get(Animation);
						if (!animation.visible)
							continue;
						hitTest(interacts, entity, animation, zoomPoint.x, zoomPoint.y);
					}
				}
			}
			return interacts;
		}

		protected function hitTest( interacts:Vector.<Entity>, entity:Entity, animation:Animation, dx:Number, dy:Number ):void
		{
			var detail:Detail   = entity.get(Detail);
			var assetVO:AssetVO = detail.assetVO;
			switch (detail.category)
			{
				case CategoryEnum.BUILDING:
				case CategoryEnum.STARBASE:
					//check if point is within grid bounds of the building
					var building:BuildingVO = (entity.has(Building)) ? Building(entity.get(Building)).buildingVO : Platform(entity.get(Platform)).buildingVO;
					_bbox.setTo(building.baseX, building.baseY, building.sizeX, building.sizeY);
					if (_bbox.containsPoint(_point))
						interacts.push(entity);
					break;
				default:
					_tempPoint.setTo(animation.render.x + animation.offsetX, animation.render.y + animation.offsetY);
					if (assetVO.bbox)
					{
						//rectangle / point collision
						_bbox.setTo(_tempPoint.x + assetVO.bbox.x, _tempPoint.y + assetVO.bbox.y, assetVO.bbox.width, assetVO.bbox.height);
						if (_bbox.contains(dx, dy))
							interacts.push(entity);
					} else
					{
						//radius / point collision
						_tempPoint.x -= dx;
						_tempPoint.y -= dy;
						if (((_tempPoint.x * _tempPoint.x) + (_tempPoint.y * _tempPoint.y)) <= (assetVO.radius * assetVO.radius))
							interacts.push(entity);
					}
					break;
			}
		}

		protected function dispatch( e:Event ):void  { _eventDispatcher.dispatchEvent(e); }

		protected function progressFTE():void
		{
			inFTE = false;
			_fteController.nextStep();
		}

		/** Doesn't actually tell you if you are in the FTE; this is a flag set by some steps in the FTE to tell us to do something */
		public function get inFTE():Boolean  { return _inFTE; }
		public function set inFTE( v:Boolean ):void  { _inFTE = v; _stopScroll = v; }

		[Inject]
		public function set eventDispatcher( v:IEventDispatcher ):void  { _eventDispatcher = v; }
		public function set followEntity( entity:Entity ):void  { _entityToFollow = entity; }
		[Inject]
		public function set fteController( value:FTEController ):void  { _fteController = value; }
		[Inject]
		public function set interactSignal( v:InteractSignal ):void  { _interactSignal = v; }
		[Inject]
		public function set keyboardController( v:KeyboardController ):void  { _keyboardController = v; }
		[Inject]
		public function set sceneModel( value:SceneModel ):void  { _sceneModel = value; }
		public function get sceneX():Number  { return (_sceneModel.ready) ? _sceneModel.focus.x : 0; }
		public function get sceneY():Number  { return (_sceneModel.ready) ? _sceneModel.focus.y : 0; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set viewStack( v:IViewStack ):void  { _viewStack = v; }

		override public function removeFromGame( game:Game ):void
		{
			_bbox = null;
			if (_controlScheme)
				_controlScheme.destroy();
			_controlScheme = null;
			_entityToFollow = null;

			_eventDispatcher.removeEventListener(ViewEvent.SHOW_VIEW, onShowView);
			_eventDispatcher = null;

			_gridSystem = null;
			_interactSignal = null;
			_keyboardController = null;
			_layer = null;
			_point = null;
			_presenter = null;
			_sceneModel = null;
			_startDrag = null;
			_targetViewAreaStart = null;
			_targetViewAreaDelta = null;
			_tempPoint = null;
			_viewStack = null;
			_viewController = null;
		}

		private function onShowView( event:ViewEvent ):void
		{
			if (_dragging)
				onInteraction_mouseUp(_startDrag.x, _startDrag.y);
		}
	}
}

