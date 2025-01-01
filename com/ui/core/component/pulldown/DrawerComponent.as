package com.ui.core.component.pulldown
{
	import com.Application;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.PanelEnum;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.button.BitmapButton;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import org.osflash.signals.Signal;

	/**
	 *
	 *
	 */
	public class DrawerComponent extends Sprite implements IComponent
	{
		public static const EXPANDS_DOWN:int  = 0;
		public static const EXPANDS_LEFT:int  = 1;
		public static const EXPANDS_RIGHT:int = 2;
		public static const EXPANDS_UP:int    = 3;

		private static const SPEED:int        = 20;

		protected var _arrow:Bitmap;

		protected var _clickPos:Point;

		protected var _elementHolder:Sprite;
		protected var _holder:Sprite;

		protected var _elements:Vector.<*>;

		protected var _canDragExpand:Boolean  = true;
		protected var _dragging:Boolean;
		protected var _enabled:Boolean;
		protected var _expanded:Boolean;
		protected var _expanding:Boolean;
		protected var _clickedOn:Boolean;

		protected var _expansionDirection:int;
		protected var _maxExpansion:int;

		protected var _innerPanel:ScaleBitmap;
		protected var _panel:ScaleBitmap;

		protected var _marginTab:Number;
		protected var _marginTail:Number;
		protected var _originalHeight:Number;

		protected var _scrollRect:Rectangle;

		protected var _tab:BitmapButton;

		protected var _updateSignal:Signal;

		/**
		 *
		 * @param panelType
		 * @param panelSize
		 * @param tabSize
		 * @param expansionDirection
		 * @param marginTab
		 * @param marginTail
		 */
		public function init( panelType:String, panelSize:int, tabSize:int, expansionDirection:int, marginTab:Number = 10, marginTail:Number = 10 ):void
		{
			_clickPos = new Point();
			_expansionDirection = expansionDirection;
			_marginTab = marginTab;
			_marginTail = marginTail;
			_maxExpansion = 0;
			_updateSignal = new Signal();

			_holder = new Sprite();
			_panel = UIFactory.getPanel(panelType, panelSize, 0);

			//create the tab
			_tab = UIFactory.getButton(ButtonEnum.DROP_TAB, tabSize, 0);
			_arrow = UIFactory.getBitmap("ArrowBMD");
			_arrow.x = (tabSize - _arrow.width) * .5;
			_tab.x = (panelSize - tabSize) * .5 + .5;
			_tab.y = _panel.height - 1;

			//elements
			_elementHolder = new Sprite();
			_elements = new Vector.<*>;

			//orient
			switch (_expansionDirection)
			{
				case EXPANDS_DOWN:
					break;
				case EXPANDS_LEFT:
					_holder.rotation = 90;
					break;
				case EXPANDS_RIGHT:
					_holder.rotation = -90;
					_holder.y += panelSize;
					break;
				case EXPANDS_UP:
					_holder.scaleY = -1;
					break;
			}

			_dragging = _expanding = false;
			expanded = false;
			enabled = true;

			//add the elements
			_tab.addChild(_arrow);
			_holder.addChild(_panel);
			_holder.addChild(_tab);
			addChild(_holder);
			addChild(_elementHolder);
		}

		public function addElement( element:* ):void
		{
			var index:int = _elements.indexOf(element);
			if (index == -1)
			{
				_elements.push(element);
				_elementHolder.addChild(element);
				findMaxExpansion();
				positionHolder();
				if (_panel.height > _panel.src.height)
				{
					maximize(false);
				}
			}
		}

		public function removeAllElements():void
		{
			while (_elements.length > 0)
			{
				removeChild(_elements[0]);
				_elements.shift();
			}
			_maxExpansion = 0;
			positionHolder();
		}

		public function removeElement( element:* ):void
		{
			var index:int = _elements.indexOf(element);
			if (index != -1)
			{
				_elements.splice(index, 1);
				_elementHolder.removeChild(element);
				positionHolder();
			}
			findMaxExpansion();
		}

		protected function onMouseDown( e:MouseEvent ):void
		{
			removeEventListener(Event.ENTER_FRAME, onUpdate);
			_clickedOn = true;
			_clickPos.setTo(Application.STAGE.mouseX, Application.STAGE.mouseY);
			_originalHeight = _panel.height;
			Application.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Application.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
		}

		protected function onMouseUp( e:MouseEvent ):void
		{
			if (e.type == MouseEvent.RELEASE_OUTSIDE && !_canDragExpand)
				return;

			if (!_clickedOn)
				return;

			_clickedOn = false;
			removeEventListener(Event.ENTER_FRAME, onUpdate);
			Application.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			if (_dragging)
			{
				_dragging = false;
			} else if (!hasEventListener(Event.ENTER_FRAME) && _maxExpansion > 0)
			{
				if (!_expanded)
				{
					expanded = !_expanded;
					_expanding = _expanded;
				} else
					_expanding = !_expanded;
				addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
				Application.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}

		protected function onMouseMove( e:MouseEvent ):void
		{
			if (!_canDragExpand)
				return;
			var panelHeight:Number = 0;
			switch (_expansionDirection)
			{
				case EXPANDS_DOWN:
					panelHeight = Application.STAGE.mouseY - _clickPos.y;
					break;
				case EXPANDS_LEFT:
					panelHeight = _clickPos.x - Application.STAGE.mouseX;
					break;
				case EXPANDS_RIGHT:
					panelHeight = Application.STAGE.mouseX - _clickPos.x;
					break;
				case EXPANDS_UP:
					panelHeight = _clickPos.y - Application.STAGE.mouseY;
					break;
			}
			if (Math.abs(panelHeight) > 5)
				_dragging = true;
			panelHeight = _originalHeight + panelHeight;
			panelHeight = panelHeight < 0 ? 0 : panelHeight > _maxExpansion ? _maxExpansion : panelHeight;
			expanded = panelHeight > _panel.src.height;
			_panel.height = panelHeight;
			if (_innerPanel)
				_innerPanel.height = _panel.height - 4;
			_tab.y = _panel.height - 1;
			positionHolder();
			_updateSignal.dispatch();
		}

		/**
		 *
		 *
		 */
		protected function onUpdate( e:Event ):void
		{
			if (_expanding)
			{
				_panel.height += SPEED;
				if (_panel.height >= _maxExpansion)
				{
					_panel.height = _maxExpansion;
					removeEventListener(Event.ENTER_FRAME, onUpdate);
				}
			} else
			{
				_panel.height -= SPEED;
				if (_panel.height <= _panel.src.height)
				{
					_panel.height = 0;
					removeEventListener(Event.ENTER_FRAME, onUpdate);
					expanded = !_expanded;
				}
			}
			if (_innerPanel)
				_innerPanel.height = _panel.height - 4;
			_tab.y = _panel.height - 1;
			positionHolder();
			_updateSignal.dispatch();
		}

		/**
		 *
		 *
		 */
		protected function positionHolder():void
		{
			switch (_expansionDirection)
			{
				case EXPANDS_DOWN:
					_elementHolder.y = (_scrollRect) ? 0 : _panel.height - _elementHolder.height - _marginTab;
					break;
				case EXPANDS_LEFT:
					_elementHolder.x = -_panel.height + _marginTab;
					break;
				case EXPANDS_RIGHT:
					_elementHolder.x = (_scrollRect) ? 0 : _panel.height - int(_elementHolder.width) - _marginTab;
					break;
				case EXPANDS_UP:
					_elementHolder.y = -_panel.height + _marginTab;
					break;
			}
			if (_scrollRect)
				useMask = true;
		}

		/**
		 *
		 *
		 */
		public function maximize( instant:Boolean = true ):void
		{
			_expanding = true;
			expanded = true;
			if (instant)
				_panel.height = _maxExpansion;
			else
				addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
			onUpdate(null);
		}

		/**
		 *
		 *
		 */
		public function minimize( instant:Boolean = true ):void
		{
			_expanding = false;
			expanded = false;
			if (instant)
				_panel.height = 0;
			else
				addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
			onUpdate(null);
		}

		/**
		 *
		 *
		 */
		protected function findMaxExpansion():void
		{
			if (!_scrollRect)
				_maxExpansion = ((_expansionDirection == EXPANDS_DOWN || _expansionDirection == EXPANDS_UP) ? _elementHolder.height : _elementHolder.width) + _marginTab + _marginTail;
			else
			{
				var maxSize:Number = 0;
				for (var i:int = 0; i < _elements.length; i++)
				{
					if (_expansionDirection == EXPANDS_DOWN || _expansionDirection == EXPANDS_UP)
					{
						if (_elements[i].y + _elements[i].height > maxSize)
							maxSize = _elements[i].y + _elements[i].height;
					} else
					{
						if (_elements[i].x + _elements[i].width > maxSize)
							maxSize = _elements[i].x + _elements[i].width;
					}
				}
				_maxExpansion = (_elements.length > 0) ? maxSize + _marginTab + _marginTail : 0;
			}
		}

		public function addUpdateListener( listener:Function ):void  { _updateSignal.add(listener); }
		public function removeUpdateListener( listener:Function ):void  { _updateSignal.remove(listener); }

		public function get canDragExpand():Boolean  { return _canDragExpand; }
		public function set canDragExpand( v:Boolean ):void  { _canDragExpand = v; }

		public function set dirty( v:Boolean ):void  { positionHolder(); findMaxExpansion(); }

		public function get enabled():Boolean  { return _enabled; }
		public function set enabled( value:Boolean ):void
		{
			_tab.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_tab.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_tab.removeEventListener(MouseEvent.RELEASE_OUTSIDE, onMouseUp);
			_enabled = value;
			if (_enabled)
			{
				_tab.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
				_tab.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
				_tab.addEventListener(MouseEvent.RELEASE_OUTSIDE, onMouseUp, false, 0, true);
			}
		}

		protected function set expanded( value:Boolean ):void
		{
			_expanded = value;
			_arrow.scaleY = (_expanded) ? 1 : -1;
			_arrow.y = (_expanded) ? 4 : 14;

			if (!_expanded)
			{
				_panel.visible = false;
				_elementHolder.visible = false;
				if (_innerPanel)
					_innerPanel.visible = false;
			} else if (_expanded && !_panel.visible)
			{
				_panel.visible = true;
				_elementHolder.visible = true;
				if (_innerPanel)
					_innerPanel.visible = true;
			}
		}

		public function set marginTab( v:Number ):void  { _marginTab = v; ; }
		public function set marginTail( v:Number ):void  { _marginTail = v; ; }

		public function set showInnerPanel( value:Boolean ):void
		{
			if (value && !_innerPanel)
			{
				_innerPanel = UIFactory.getPanel(PanelEnum.CONTAINER_DOUBLE_NOTCHED, _panel.width - 10, _panel.height - 4, 5);
				_holder.addChild(_innerPanel);
			} else if (!value && _innerPanel)
			{
				_holder.removeChild(_innerPanel);
				_innerPanel = UIFactory.destroyPanel(_innerPanel);
			}
			expanded = _expanded;
		}

		public function set useMask( v:Boolean ):void
		{
			if (!_scrollRect)
				_scrollRect = new Rectangle();
			switch (_expansionDirection)
			{
				case EXPANDS_DOWN:
					_scrollRect.setTo(0, (_maxExpansion - _marginTab - _marginTail) - (_panel.height - _marginTab), _panel.width, _panel.height + _marginTab);
					break;
				case EXPANDS_LEFT:
					_scrollRect.setTo(0, 0, _panel.height - _marginTab, _panel.width);
					break;
				case EXPANDS_RIGHT:
					_scrollRect.setTo((_maxExpansion - _marginTab - _marginTail) - (_panel.height - _marginTab), 0, _panel.height + _marginTab, _panel.width);
					break;
				case EXPANDS_UP:
					_scrollRect.setTo(0, 0, _panel.width, _panel.height - _marginTab);
					break;
			}
			_elementHolder.scrollRect = _scrollRect;
		}

		override public function get width():Number  { return (_expansionDirection == EXPANDS_DOWN || _expansionDirection == EXPANDS_UP) ? _panel.width : _panel.height; }
		override public function get height():Number  { return (_expansionDirection == EXPANDS_DOWN || _expansionDirection == EXPANDS_UP) ? _panel.height : _panel.width; }

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);
			removeEventListener(Event.ENTER_FRAME, onUpdate);
			Application.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_dragging = false;
			enabled = false;
			showInnerPanel = false;

			_arrow = null;
			_clickPos = null;
			_elementHolder = UIFactory.destroyPanel(_elementHolder);
			_elements.length = 0;
			_elements = null;
			_holder = UIFactory.destroyPanel(_holder);
			_panel = UIFactory.destroyPanel(_panel);
			_scrollRect = null;
			_tab = UIFactory.destroyButton(_tab);

			_updateSignal.removeAll();
			_updateSignal = null;
		}
	}
}

