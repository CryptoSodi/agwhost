package com.ui.core.component.filterlist
{
	import com.ui.core.component.IComponent;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;

	public class FilterListWithHeaders extends Sprite implements IComponent
	{
		private var _headers:Vector.<FilterHeader>;
		
		private var _padding:Number;
		private var _headerLessBtns:Vector.<FilterButton>;
		private var _filterBtns:Vector.<FilterButton>
		private var _selectedFilterBtns:Vector.<FilterButton>;
		private var _filter:Array;
		
		private var _onlyOneFilterSelected:Boolean;
		private var _unselectOnReclick:Boolean;
		private var _isHorizontal:Boolean;
		private var _enabled:Boolean;
		public var onSelectionChanged:Signal;
		
		
		public function FilterListWithHeaders()
		{
			_headers = new Vector.<FilterHeader>;
			_headerLessBtns = new Vector.<FilterButton>;
			_filterBtns = new Vector.<FilterButton>;
			_selectedFilterBtns = new Vector.<FilterButton>;
			_filter = new Array;
			onSelectionChanged = new Signal(Array);
			super();
		}
		
		public function init( bg:String = '', onlyOneFilterSelected:Boolean = true, unselectOnReclick:Boolean = true):void
		{
			_onlyOneFilterSelected = onlyOneFilterSelected;
			_unselectOnReclick = unselectOnReclick;
		}
		
		public function addFilterBtn( filter:*, btn:BitmapButton, padding:Number = 0, index:int = -1, headerIndex:int = -1 ):void
		{
			if(index == -1)
				index = _filterBtns.length;

			var newFilterBtn:FilterButton = new FilterButton(filter, index, btn, padding);
			newFilterBtn.addEventListener(MouseEvent.CLICK, onFilterClicked, false, 0, true);
			_filterBtns.push(newFilterBtn);
			addChild(newFilterBtn);
			
			if(headerIndex == -1)
			{
				if(_headers.length < 1)
					_headerLessBtns.push(newFilterBtn);
				else
					headerIndex = _headers.length - 1;
			}
					
			
			if(headerIndex != -1 && _headers.length > headerIndex)
			{
				_headers[headerIndex].addFilter(newFilterBtn);
				if(_headers[headerIndex].filterCount > 1)
				{
					_headers[headerIndex].sortFilters(orderItems);
				}
			}
				
			layout();
		}
		
		public function addFilterHeader( text:Label, bg:String, padding:Number = 0, headerPadding:Number = 0, index:int = -1 ):void
		{
			if(index == -1)
				index = _headers.length;
			
			var newFilterHeader:FilterHeader = new FilterHeader(text, bg, index, padding, headerPadding);
			addChild(newFilterHeader);
			_headers.push(newFilterHeader);
			
			_headers.sort(orderItems);
			
			layout();
		}
		
		private function orderItems( itemOne:*, itemTwo:* ):int
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
		
		private function layout():void
		{
			var len:uint;
			var filterBtnLen:uint;
			var currentFilterHeader:FilterHeader;
			var currentFilterBtn:FilterButton;
			var xPos:Number = 0;
			var yPos:Number = 0;
			var i:uint;
			
			len = _headerLessBtns.length;
			for (i = 0; i < len; ++i)
			{
				currentFilterBtn = _headerLessBtns[i];
				currentFilterBtn.x = xPos;
				currentFilterBtn.y = yPos;
				yPos += currentFilterBtn.height + currentFilterBtn.padding;
			}
			
			len = _headers.length;
			for(i = 0; i < len; ++i)
			{
				currentFilterHeader = _headers[i];
				currentFilterHeader.x = xPos;
				currentFilterHeader.y = yPos;
				filterBtnLen = currentFilterHeader.filterBtns.length;
				yPos += currentFilterHeader.height + currentFilterHeader.padding;
				for( var j:uint = 0; j < filterBtnLen; ++j)
				{
					currentFilterBtn = currentFilterHeader.filterBtns[j];
					currentFilterBtn.x = xPos;
					currentFilterBtn.y = yPos;
					yPos += currentFilterBtn.height + currentFilterBtn.padding;
				}
				
				yPos += currentFilterHeader.headerPadding;
			}
		}
		
		public function selectFilterByIndex( index:int ):void
		{
			if(index < _filterBtns.length)
			{
				selectFilterBtn(_filterBtns[index]);
				_filterBtns[index].selected = true;
			}
		}
		
		private function selectFilterBtn( filterBtn:FilterButton ):void
		{
			var index:int = _selectedFilterBtns.indexOf(filterBtn);
			
			if(_onlyOneFilterSelected && _selectedFilterBtns.length > 0)
			{
				if(index == -1 && _unselectOnReclick == false)
					clearSelections();
			}
			
			if(index == -1)
			{
				_selectedFilterBtns.push(filterBtn);
				_filter.push(filterBtn.filter);
			}
			else if(!_unselectOnReclick)
			{
				_selectedFilterBtns[index].selected = true;
			}
			else
			{
				_selectedFilterBtns.splice(index, 1);
				_filter.splice(index, 1);
			}
			
			if(index == -1 || _unselectOnReclick)
				onSelectionChanged.dispatch(_filter);
		}
		
		public function clearSelections():void
		{
			if(_selectedFilterBtns.length > 0)
			{
				_selectedFilterBtns[0].selected = false;
				_selectedFilterBtns.length = 0;
				_filter.length = 0;
			}
		}
		
		protected function onFilterClicked( e:MouseEvent ):void
		{
			var selected:FilterButton;
			if( e.target is FilterButton )
				selected = FilterButton(e.target);
			else
				selected = FilterButton(e.target.parent);
			
			selectFilterBtn(selected);
		}
		
		public function get enabled():Boolean { return enabled; }
		public function set enabled( value:Boolean ):void 
		{
			_enabled = value; 
			var len:uint = _filterBtns.length;
			for(var i:uint = 0; i < len; ++i)
			{
				_filterBtns[i].enabled = _enabled;
			}
		}
		
		public function destroy():void
		{
			_selectedFilterBtns.length = 0;
			_filter.length = 0;
			var len:uint = _filterBtns.length;
			for(var i:uint = 0; i < len; ++i)
			{
				_filterBtns[i].removeEventListener(MouseEvent.CLICK, onFilterClicked);
				_filterBtns[i].destroy();
				_filterBtns[i] = null;
			}
			_filterBtns.length = 0;
		}
		
	}
}