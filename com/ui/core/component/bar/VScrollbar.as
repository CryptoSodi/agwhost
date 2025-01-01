package com.ui.core.component.bar
{
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.IComponent;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	import org.osflash.signals.Signal;

	public class VScrollbar extends Sprite implements IComponent
	{
		private static const DRAG_THRESHOLD:int = 15;
		private static const MIN_DRAGGER_SIZE:int = 17;
		private static const PADDING:int = 4;
		
		private var _dragBar:Sprite;
		private var _dragBarBG:ScaleBitmap;
		private var _scrollBG:Sprite;
		private var _parent:DisplayObjectContainer;

		private var _offsetY:int;
		private var _top:int;
		private var _bottom:int;
		private var _dragging:Boolean;
		private var _position:Number;
		private var _scrollRange:int;
		private var _maxDraggerSize:int;

		private var _totalVisibleHeight:Number;
		private var _totalScrollableHeight:Number;
		private var _scrollPercent:Number;
		private var _scrollableHeightRatio:Number;

		private var _dragBarUp:BitmapData
		private var _dragBarRollOver:BitmapData

		private var _scrollableObject:DisplayObject;

		private var _startFullyScrolled:Boolean;

		private var _isEnabled:Boolean;
		private var _alreadyMovedThisFrame:Boolean;

		private var _lastScroll:Number;

		private var _maxScroll:Number     = 0;
		private var _minScroll:Number     = 0;
		private var _totalDelta:Number    = 0;
		private var _delta:Number         = 0;

		// This signal is dispatched when scrolling occurs.
		public var onScrollSignal:Signal;

		public function init( width:Number, height:Number, xPos:Number, yPos:Number, dragBarRect:Rectangle, dragBarMCName:String = 'DragBarBGMC', dragBarName:String = 'DragBarUpBMD', dragBarRollOverName:String =
							  'DragBarRollOverBMD', startFullyScrolled:Boolean = false, parent:DisplayObjectContainer = null, scrollableObject:DisplayObject = null ):void
		{
			x = xPos;
			y = yPos;
			_dragging = false;
			_parent = parent;
			_position = 0;
			if (dragBarMCName != '')
			{
				var dragBarBGClass:Class = Class(getDefinitionByName(dragBarMCName));
				_scrollBG = Sprite(new dragBarBGClass());
				_scrollBG.x = 0;
				_scrollBG.y = 0;
				_scrollBG.height = height;
				_scrollBG.width = width;
			} else
			{
				_scrollBG = new Sprite();
				_scrollBG.alpha = 0;
				_scrollBG.graphics.drawRect(0, 0, width, height);
			}
			addChild(_scrollBG);

			if (dragBarRollOverName != '')
			{
				var dragBarRollOverBMD:Class = Class(getDefinitionByName(dragBarRollOverName));
				_dragBarRollOver = BitmapData(new dragBarRollOverBMD());
			}

			var dragBarUpBMD:Class = Class(getDefinitionByName(dragBarName));
			_dragBarUp = BitmapData(new dragBarUpBMD());

			_dragBarBG = new ScaleBitmap(_dragBarUp);
			_dragBarBG.scale9Grid = dragBarRect;
			_dragBarBG.smoothing = true;

			_dragBar = new Sprite();
			_dragBar.x = 0 + 3;
			_dragBar.y = 0 + _scrollBG.height - _dragBar.height;
			_dragBar.addChild(_dragBarBG);
			addChild(_dragBar);

			_top = _scrollBG.y + 2;
			_maxDraggerSize = height - PADDING;
			_scrollRange = height - _dragBar.height - PADDING;
			_bottom = _top + _scrollRange;

			_dragBarBG.width = width;

			_maxScroll = height;

			onScrollSignal = new Signal(Number);

			_scrollableObject = scrollableObject;

			_totalScrollableHeight = 0;

			_startFullyScrolled = startFullyScrolled;

			if (_startFullyScrolled)
				_scrollPercent = 1;
			else
				_scrollPercent = 0;

			if (_scrollRange > 0)
				addListeners();
		}

		public function updateScrollbarHeight( newHeight:Number ):void
		{
			_scrollBG.height = newHeight;
			_maxDraggerSize = _scrollBG.height - PADDING;
		}

		public function updateDisplayedHeight( newHeight:Number ):void
		{
			if (!isNaN(newHeight))
			{
				_totalVisibleHeight = newHeight;
				updateScrollableHeightRatio();
			}
		}

		public function updateScrollableHeight( updatedScrollableHeight:Number ):void
		{
			if (!isNaN(updatedScrollableHeight))
			{
				_totalScrollableHeight = updatedScrollableHeight;
				updateScrollableHeightRatio();
			}
		}

		private function updateScrollableHeightRatio():void
		{
			_scrollableHeightRatio = _totalScrollableHeight / _totalVisibleHeight;
			if (_scrollableHeightRatio <= 1 || isNaN(_scrollableHeightRatio))
			{
				_scrollableHeightRatio = 1;
				enabled = false;
			} else
			{
				if (enabled == false)
					enabled = true;
			}

			_dragBarBG.height = Math.max(_maxDraggerSize / _scrollableHeightRatio, MIN_DRAGGER_SIZE);

			_scrollRange = _scrollBG.height - _dragBar.height - PADDING;

			if (_scrollRange > 0)
				addListeners();
			else
				removeListeners();

			_bottom = _top + _scrollRange;
			var y:Number = _scrollPercent * _scrollRange + _top;
			y = y < _top ? _top : y > _bottom ? _bottom : y;
			_dragBar.y = y;
		}

		public function updateScrollY( y:Number ):void
		{
			y = y < _top ? _top : y > _bottom ? _bottom : y;
			_scrollPercent = (_scrollRange > 0) ? (y - _top) / _scrollRange : 0;
			_dragBar.y = y;

			onScrollSignal.dispatch(_scrollPercent);
		}

		public function updateScrollPercent( percent:Number ):void
		{
			_scrollPercent = percent;
			_scrollPercent = _scrollPercent > 1 ? 1 : _scrollPercent < 0 ? 0 : _scrollPercent;
			var y:Number = _scrollPercent * _scrollRange + _top;
			y = y < _top ? _top : y > _bottom ? _bottom : y;
			_dragBar.y = y;

			onScrollSignal.dispatch(_scrollPercent);
		}

		private function addListeners():void
		{
			_dragBar.useHandCursor = true;
			_dragBar.buttonMode = true;

			_scrollBG.buttonMode = true;
			_scrollBG.useHandCursor = true;

			_dragBar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			_scrollBG.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);

			if (_scrollableObject)
				_scrollableObject.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel, false, 0, true);
			else if (_parent)
			{
				_parent.addEventListener(MouseEvent.CLICK, onParentClick, false, 0, true);
				_parent.addEventListener(MouseEvent.MOUSE_DOWN, onDragScrollAreaDown);
				_parent.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel, false, 0, true);
			}
		}

		private function removeListeners():void
		{
			_dragBar.useHandCursor = false;
			_dragBar.buttonMode = false;

			_scrollBG.buttonMode = false;
			_scrollBG.useHandCursor = false;

			_scrollBG.removeEventListener(MouseEvent.CLICK, onMouseClick);
			_dragBar.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			if (_parent)
			{
				_parent.removeEventListener(MouseEvent.CLICK, onParentClick);
				_parent.removeEventListener(MouseEvent.ROLL_OUT, onMouseUp);
				_parent.removeEventListener(MouseEvent.MOUSE_DOWN, onDragScrollAreaDown);
				_parent.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				_parent.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}

			if (_scrollableObject)
				_scrollableObject.removeEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
			else if (_parent)
				_parent.removeEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
		}

		private function onMouseDown( event:MouseEvent ):void
		{
			_offsetY = mouseY - _dragBar.y;
			_dragging = true;
			if (_parent)
			{
				_parent.addEventListener(MouseEvent.ROLL_OUT, onMouseUp, false, 0, true);
				_parent.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
				_parent.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			}
			event.stopPropagation();
		}
		
		private function onDragScrollAreaDown( event:MouseEvent ):void
		{
			_offsetY = mouseY;
			_position = _dragBar.y;
			if (_parent)
			{
				_parent.addEventListener(MouseEvent.ROLL_OUT, onMouseUp, false, 0, true);
				_parent.addEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag, false, 0, true);
				_parent.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			}
			event.stopPropagation();
		}

		private function onMouseDrag( event:MouseEvent ):void
		{
			var y:Number = _offsetY - mouseY + _position;
			if (_dragging || Math.abs(y) > DRAG_THRESHOLD)
			{
				_dragging = true;
				updateScrollY(y);
			}
			event.stopPropagation();
		}
		
		private function onMouseMove( event:MouseEvent ):void
		{
			var y:Number = mouseY - _offsetY;
			updateScrollY(y);
			event.stopPropagation();
		}

		private function onMouseUp( event:MouseEvent ):void
		{
			_offsetY = mouseY - _dragBar.y;
			_dragging = false;
			if (_parent)
			{
				_parent.removeEventListener(MouseEvent.ROLL_OUT, onMouseUp);
				_parent.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				_parent.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
				_parent.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			event.stopPropagation();
		}

		private function onMouseClick( event:MouseEvent ):void
		{
			updateScrollY(mouseY);
			event.stopPropagation();
		}
		
		private function onParentClick( event:MouseEvent ):void
		{
			if (_dragging)
				event.stopPropagation();
		}

		public function handleMouseWheel( event:MouseEvent ):void
		{
			if (!_alreadyMovedThisFrame)
			{
				_alreadyMovedThisFrame = true;
				addEventListener(Event.EXIT_FRAME, onExitFrame, false, 0, true);
				_delta = event.delta;
			}
			_totalDelta += event.delta;
			event.stopImmediatePropagation();
			event.stopPropagation();
		}

		private function onExitFrame( e:Event ):void
		{
			removeEventListener(Event.EXIT_FRAME, onExitFrame);
			_alreadyMovedThisFrame = false;

			var scrollCount:Number = Math.abs(_totalDelta / _delta);
			if (_totalDelta > 0)
				scrollUp(scrollCount);
			else
				scrollDown(scrollCount);

			_totalDelta = 0;
		}

		public function set enabled( value:Boolean ):void
		{
			_isEnabled = value;
			_dragBar.visible = _isEnabled;
			_scrollBG.visible = _isEnabled;
			if (_isEnabled && _scrollRange > 0)
				addListeners();
			else
				removeListeners();
		}

		public function scrollUp( scrollCount:Number = 1 ):void
		{
			var percent:Number = (_maxScroll * scrollCount) / (_totalScrollableHeight - _totalVisibleHeight);
			updateScrollY(_dragBar.y - _scrollRange * percent);
		}

		public function scrollDown( scrollCount:Number = 1 ):void
		{
			var percent:Number = (_maxScroll * scrollCount) / (_totalScrollableHeight - _totalVisibleHeight);
			updateScrollY(_dragBar.y + (_scrollRange * percent));
		}

		public function resetScroll():void
		{
			if (_startFullyScrolled)
			{
				_scrollPercent = 1;
				_dragBar.y = _bottom;
			} else
			{
				_scrollPercent = 0;
				_dragBar.y = _top;
			}

			onScrollSignal.dispatch(_scrollPercent);
		}

		public function get enabled():Boolean { return _isEnabled; }
		
		public function set maxScroll( v:Number ):void { _maxScroll = v; }
		public function set minScroll( v:Number ):void { _minScroll = v; }
		
		public function get percent():Number { return _scrollPercent; }

		public function destroy():void
		{
			removeListeners();
			_dragBar = null;
			_parent = null;
			_scrollableObject = null;
			_scrollBG = null;
			onScrollSignal.removeAll();
			onScrollSignal = null;
		}
	}
}
