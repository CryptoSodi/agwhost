package com.ui.core.component.filterlist
{
	import com.ui.core.component.IComponent;
	import com.ui.core.component.button.BitmapButton;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;

	import org.adobe.utils.StringUtil;
	import org.osflash.signals.Signal;

	public class FilterList extends Sprite implements IComponent
	{
		private var _padding:Number;
		private var _filterBtns:Vector.<FilterButton>
		private var _selectedFilterBtns:Vector.<FilterButton>;
		private var _filter:Array;

		private var _onlyOneFilterSelected:Boolean;
		private var _unselectOnReclick:Boolean;
		private var _isHorizontal:Boolean;

		public var onSelectionChanged:Signal;

		public function FilterList()
		{
			_filterBtns = new Vector.<FilterButton>;
			_selectedFilterBtns = new Vector.<FilterButton>;
			_filter = new Array;
			onSelectionChanged = new Signal(Array);
			super();
		}

		public function init( bg:String = '', onlyOneFilterSelected:Boolean = true, unselectOnReclick:Boolean = true, isHorizontal:Boolean = true ):void
		{
			_onlyOneFilterSelected = onlyOneFilterSelected;
			_unselectOnReclick = unselectOnReclick;
			_isHorizontal = isHorizontal;
		}

		public function addFilterBtn( filter:*, btn:BitmapButton, padding:Number = 0, index:int = -1 ):void
		{
			if (index == -1)
				index = _filterBtns.length;

			var newFilterBtn:FilterButton = new FilterButton(filter, index, btn, padding);
			newFilterBtn.addEventListener(MouseEvent.CLICK, onFilterClicked, false, 0, true);
			addChild(newFilterBtn);
			_filterBtns.push(newFilterBtn);
			_filterBtns.sort(orderItems);

			layout();
		}

		public function selectFilterByIndex( index:int ):void
		{
			if (index < _filterBtns.length)
			{
				selectFilterBtn(_filterBtns[index]);
				_filterBtns[index].selected = true;
			}
		}

		public function selectFilterByFilter( v:Array ):void
		{
			if (v)
			{
				var len:uint = _filterBtns.length;
				var currentFilterBtn:FilterButton;
				for (var i:uint = 0; i < len; ++i)
				{
					currentFilterBtn = _filterBtns[i];
					if (v.toString().toLowerCase() == currentFilterBtn.filter.toString().toLowerCase())
					{
						selectFilterBtn(_filterBtns[i]);
						_filterBtns[i].selected = true;
					}
				}
			}
		}

		private function orderItems( itemOne:FilterButton, itemTwo:FilterButton ):int
		{
			var sortOrderOne:Number = itemOne.index;
			var sortOrderTwo:Number = itemTwo.index;

			if (sortOrderOne < sortOrderTwo)
			{
				return -1;
			} else if (sortOrderOne > sortOrderTwo)
			{
				return 1;
			} else
			{
				return 0;
			}
		}

		protected function layout():void
		{
			var len:uint    = _filterBtns.length;
			var currentFilterBtn:FilterButton;
			var xPos:Number = 0;
			var yPos:Number = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				currentFilterBtn = _filterBtns[i];
				currentFilterBtn.x = xPos;
				currentFilterBtn.y = yPos;

				if (_isHorizontal)
					xPos += currentFilterBtn.width + currentFilterBtn.padding;
				else
					yPos += currentFilterBtn.height + currentFilterBtn.padding;
			}
		}

		private function selectFilterBtn( filterBtn:FilterButton ):void
		{
			var index:int = _selectedFilterBtns.indexOf(filterBtn);

			if (_onlyOneFilterSelected && _selectedFilterBtns.length > 0)
			{
				if (index == -1 && _unselectOnReclick == false)
					clearSelections();
			}

			if (index == -1)
			{
				_selectedFilterBtns.push(filterBtn);
				_filter.push(filterBtn.filter);
			} else if (!_unselectOnReclick)
			{
				_selectedFilterBtns[index].selected = true;
			} else
			{
				_selectedFilterBtns.splice(index, 1);
				_filter.splice(index, 1);
			}

			if (index == -1 || _unselectOnReclick)
				onSelectionChanged.dispatch(_filter);
		}

		public function clearSelections():void
		{
			if (_selectedFilterBtns.length > 0)
			{
				_selectedFilterBtns[0].selected = false;
				_selectedFilterBtns.length = 0;
				_filter.length = 0;
			}
		}

		protected function onFilterClicked( e:MouseEvent ):void
		{
			var selected:FilterButton;
			if (e.target is FilterButton)
				selected = FilterButton(e.target);
			else
				selected = FilterButton(e.target.parent);

			selectFilterBtn(selected);
		}

		public function get enabled():Boolean  { return enabled; }
		public function set enabled( value:Boolean ):void  { enabled = value; }

		public function clearFilters():void
		{
			_selectedFilterBtns.length = 0;
			_filter.length = 0;
			var len:uint = _filterBtns.length;
			for (var i:uint = 0; i < len; ++i)
			{
				_filterBtns[i].removeEventListener(MouseEvent.CLICK, onFilterClicked);
				_filterBtns[i].destroy();
				_filterBtns[i] = null;
			}
			_filterBtns.length = 0;
		}

		public function destroy():void
		{
			clearFilters();
		}

	}
}
