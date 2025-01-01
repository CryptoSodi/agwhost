package com.ui.core.component.pulldown
{
	import com.ui.core.component.IComponent;
	import com.ui.modal.PanelFactory;
	import com.ui.core.ScaleBitmap;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.osflash.signals.Signal;

	public class PullDown extends Sprite implements IComponent
	{
		private var _bg:ScaleBitmap;
		private var _selections:Array;
		private var _selected:PullDownComponent;
		private var _isExpanded:Boolean;
		private var _isEnabled:Boolean;
		private var _growDown:Boolean;
		private var _defaultSelectedIndex:int;
		private var _defaultXPos:int;
		private var _defaultYPos:int;
		private var _width:Number;
		private var _height:Number;
		private var _fontSize:int;
		private var _padding:Number;
		public var onChangedSelected:Signal;

		private var _nothingSelected:String = 'CodeString.PullDown.NothingSelected'; // Please Select

		public function init( width:Number, height:Number, padding:Number, pullDownBG:String, rect:Rectangle, xPos:Number = 0, yPos:Number = 0, defaultSelectedIndex:int = -1, fontSize:int = 14, growDown:Boolean =
							  true ):void
		{
			_selections = new Array()
			_defaultXPos = x = xPos;
			_defaultYPos = y = yPos;

			_width = width;
			_height = height;
			_growDown = growDown;
			_fontSize = fontSize;

			_defaultSelectedIndex = defaultSelectedIndex;

			_padding = padding;

			onChangedSelected = new Signal(Array);
			_bg = PanelFactory.getScaleBitmapPanel(pullDownBG, width, height, rect);

			_selected = new PullDownComponent(_width, _height, _fontSize);

			_bg.width = _selected.width + _padding;
			_bg.height = _selected.height + _padding;
			_bg.x = -10;
			_bg.y = 0;

			_selected.x = _bg.x + (_bg.width - _selected.width) * 0.5
			_selected.y = _bg.y + (_bg.height - _selected.height) * 0.5;

			addChildAt(_bg, 0);
			addChild(_selected);
			enabled = true;
		}

		private function onSelectedClick( e:MouseEvent ):void
		{
			if (!_isExpanded)
				expandPullDown();
			else
				contractPullDown();
		}

		private function onRollOut( e:MouseEvent ):void
		{
			if (_isExpanded)
				contractPullDown();
		}

		private function onClicked( e:MouseEvent ):void
		{
			var clickedPullDownComponent:PullDownComponent;
			if (e.target is PullDownComponent)
			{
				clickedPullDownComponent = PullDownComponent(e.target);
			} else if (e.target.parent is PullDownComponent)
			{
				clickedPullDownComponent = (e.target.parent);
			}

			if (clickedPullDownComponent && clickedPullDownComponent != _selected)
			{
				select(clickedPullDownComponent);
			}
		}

		private function select( selectedComponent:PullDownComponent ):void
		{
			contractPullDown();

			var dataHolder:PullDownData = _selected.data;
			_selected.data = selectedComponent.data

			if (dataHolder != null)
				selectedComponent.data = dataHolder;
			else
			{
				var index:uint = _selections.indexOf(selectedComponent, 0);
				if (index != -1)
					_selections.splice(index, 1);
			}

			onChangedSelected.dispatch(_selected.data.returnParams);
			_selections.sortOn('index', Array.NUMERIC);
		}

		public function selectByIndex( index:int ):void
		{
			var len:uint = _selections.length;
			var currentSelection:PullDownComponent;
			for (var i:uint = 0; i < len; ++i)
			{
				currentSelection = _selections[i];
				if (currentSelection.index == index)
				{
					select(currentSelection);
					break;
				}
			}
		}

		public function selectByDisplayName( displayName:String ):void
		{
			var len:uint = _selections.length;
			var currentSelection:PullDownComponent;
			for (var i:uint = 0; i < len; ++i)
			{
				currentSelection = _selections[i];
				if (currentSelection.displayName == displayName)
				{
					select(currentSelection);
					break;
				}
			}
		}

		private function expandPullDown():void
		{

			_isExpanded = true;
			var len:uint    = _selections.length;
			var newY:Number = _selected.y;
			var currentSelection:PullDownComponent;
			if (len < 1)
				return;

			for (var i:uint = 0; i < len; ++i)
			{
				currentSelection = _selections[i];
				if (_growDown)
					newY += _height;
				else
					newY -= _height;

				TweenLite.to(currentSelection, .5, {y:newY, ease:Quad.easeOut});
				currentSelection.visible = true;
			}

			var bgHeight:int;
			if (!_growDown)
			{
				_bg.y = newY - 10;
				bgHeight = Math.abs(_bg.y) + _selected.y + _selected.height + _padding * 0.5;
			} else
				bgHeight = newY + _height + _padding;

			_bg.height = bgHeight;
		}

		private function contractPullDown():void
		{
			_isExpanded = false;
			var len:uint    = _selections.length;
			var currentSelection:PullDownComponent;
			var newY:Number = _selected.y;
			for (var i:int = (len - 1); i >= 0; --i)
			{
				currentSelection = _selections[i];
				currentSelection.visible = false;
				TweenLite.to(currentSelection, .2, {y:newY, ease:Quad.easeIn});
			}

			_bg.height = _selected.height + _padding;
			_bg.y = 0;
		}

		public function addPullDownData( data:Array ):void
		{
			var len:uint = data.length;
			var currentData:PullDownData;
			var selection:PullDownComponent;

			if (_defaultSelectedIndex == -1)
				_selected.displayName = _nothingSelected;

			for (var i:uint = 0; i < _selections.length; ++i)
			{
				removeChild(_selections[i]);
				_selections[i].destroy();
			}
			_selections.length = 0;

			for (i = 0; i < len; ++i)
			{
				currentData = data[i];
				if (_defaultSelectedIndex == currentData.index)
				{
					_selected.data = currentData;
					onChangedSelected.dispatch(_selected.data.returnParams);
				} else
				{
					selection = new PullDownComponent(_width, _height, _fontSize);
					selection.data = currentData;
					selection.x = _selected.x;
					selection.y = _selected.y;
					selection.visible = false;
					addChild(selection);
					_selections.push(selection)
				}
			}
			_selections.sortOn('index', Array.NUMERIC);
		}

		override public function get height():Number
		{
			return _height;
		}

		override public function get width():Number
		{
			return _width;
		}


		public function get enabled():Boolean
		{
			return _isEnabled;
		}

		private function addListeners():void
		{
			_selected.addEventListener(MouseEvent.CLICK, onSelectedClick, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			addEventListener(MouseEvent.CLICK, onClicked, false, 0, true);
		}

		private function removeListeners():void
		{
			_selected.removeEventListener(MouseEvent.CLICK, onSelectedClick);
			removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
			removeEventListener(MouseEvent.CLICK, onClicked);
		}

		public function set enabled( value:Boolean ):void
		{
			if (_isEnabled != value)
			{
				_isEnabled = value;

				if (_isEnabled)
					addListeners();
				else
				{
					removeListeners();
					if (_isExpanded)
						contractPullDown();
				}
			}
		}

		public function set defaultSelectedIndex( defaultSelectedIndex:uint ):void
		{
			_defaultSelectedIndex = defaultSelectedIndex;
		}

		public function destroy():void
		{
			if (_isEnabled)
				removeListeners();

			while (numChildren > 0)
				removeChildAt(0);

			_selected.destroy();
			_selected = null;

			onChangedSelected.removeAll();
			onChangedSelected = null;

			var len:uint = _selections.length;
			var currentSelection:PullDownComponent;
			for (var i:uint = 0; i < len; ++i)
			{
				currentSelection = _selections[i];
				currentSelection.destroy();
				currentSelection = null;
			}
			_selections = null;
		}
	}
}
