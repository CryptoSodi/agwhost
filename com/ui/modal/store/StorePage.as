package com.ui.modal.store
{
	import com.Application;
	import com.model.prototype.IPrototype;
	import com.presenter.starbase.IStorePresenter;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.filterlist.FilterListWithHeaders;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;

	public class StorePage extends Sprite
	{
		protected var _items:Vector.<IPrototype>;
		protected var _itemComponents:Vector.<StoreItem>;

		private var _mask:Rectangle;
		protected var _visibleItemsContainer:Sprite;
		protected var _init:Boolean;

		protected var _filterList:FilterListWithHeaders;
		protected var _filters:Array;

		protected var _itemsScrollbar:VScrollbar;
		protected var _maxHeight:Number;

		protected var _presenter:IStorePresenter;

		public var getHardCurrencyCost:Function;
		public var canAfford:Function;
		public var _openWindow:Function;

		public static var WINDOW_CANNOT_AFFORD:int            = 0;
		public static var WINDOW_BUILDING_VIEW:int            = 1;
		public static var WINDOW_DEFENSE_VIEW:int             = 2;
		public static var WINDOW_SHIPYARD_VIEW:int            = 3;
		public static var WINDOW_DEFENSE_RESEARCH_VIEW:int    = 4;
		public static var WINDOW_SHIP_RESEARCH_VIEW:int       = 5;
		public static var WINDOW_MODULES_RESEARCH_VIEW:int    = 6;
		public static var WINDOW_TECHNOLOGY_RESEARCH_VIEW:int = 7;
		public static var WINDOW_DOCK_VIEW:int                = 8;

		public function StorePage( items:Vector.<IPrototype> )
		{
			super();
			_itemComponents = new Vector.<StoreItem>;
			_items = items;

			_visibleItemsContainer = new Sprite();
			_visibleItemsContainer.name = "visibleItemsContainer";
			_visibleItemsContainer.x = 305;
			_visibleItemsContainer.y = 101;
			addChild(_visibleItemsContainer);

			_mask = new Rectangle(300, 105, 415, 440);
			_mask.x = 300;
			_mask.y = 0;

			_visibleItemsContainer.scrollRect = _mask;

			_itemsScrollbar = new VScrollbar();
			addChild(_itemsScrollbar);
			var scrollbarXPos:Number    = 719;
			var scrollbarYPos:Number    = 98;
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			_itemsScrollbar.init(7, 448, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this);
			_itemsScrollbar.onScrollSignal.add(onChangedScroll);
			_itemsScrollbar.updateScrollableHeight(_maxHeight);
			_itemsScrollbar.updateDisplayedHeight(_mask.height);
			_itemsScrollbar.maxScroll = 26.75;

			_filterList = new FilterListWithHeaders();
			_filterList.name = "filterList";
			_filterList.init('', true, false);
			_filterList.x = 28;
			_filterList.y = 108;
			_filterList.onSelectionChanged.add(filterItems);
			addChild(_filterList);

			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved, false, 0, true);
			addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
		}

		[PostConstruct]
		public function init():void
		{
			_presenter && _presenter.highfive();
		}

		protected function onRemoved( e:Event ):void
		{
			_itemsScrollbar.enabled = false;
			_filterList.enabled = false;
		}

		protected function onAdded( e:Event ):void
		{
			_itemsScrollbar.enabled = true;
			_filterList.enabled = true;
		}

		protected function addFilterBtn( filterName:String, btnName:String, btnPadding:Number, leftOffset:Boolean = true ):void
		{
			var btn:BitmapButton = ButtonFactory.getBitmapButton('StoreSingleListBtnUpBMD', 0, 0, btnName, 0xFFFFFF, 'StoreSingleListBtnRollOverBMD', null, null, 'StoreSingleListBtnSelectedBMD');
			if (leftOffset)
				btn.label.x -= (btn.label.width - btn.label.textWidth) * 0.5 - 6;
			_filterList.addFilterBtn(filterName, btn, btnPadding);
		}

		protected function addFilterHeader( headerName:String, padding:Number, headerPadding:Number ):void
		{
			var filterHeader:Label = new Label(18, 0xffffff, 225, 25);
			filterHeader.align = TextFormatAlign.LEFT;
			filterHeader.constrictTextToSize = false;
			filterHeader.text = headerName;
			_filterList.addFilterHeader(filterHeader, 'StoreHeaderBMD', padding, headerPadding);

		}

		protected function filterItems( filters:Array ):void
		{
			_filters = filters;
			if (_visibleItemsContainer.numChildren > 0)
				_visibleItemsContainer.removeChildren(0, (_visibleItemsContainer.numChildren - 1));

			var len:uint = _itemComponents.length;
			var currentStoreItem:StoreItem;
			for (var i:uint = 0; i < len; ++i)
			{
				currentStoreItem = _itemComponents[i];
				if (filters == null || filters.length == 0 || filters.indexOf(currentStoreItem.subcategory) != -1 || (filters.length != 0 && filters[0] == null))
				{
					_visibleItemsContainer.addChild(currentStoreItem);
				}
			}

			layout();
			_itemsScrollbar.resetScroll();
		}

		public function setUpStoreItems():void
		{
			if (_items)
			{
				_init = true;
				var len:uint = _items.length;
				var storeItem:StoreItem;
				var currentPrototype:IPrototype;
				for (var i:uint = 0; i < len; ++i)
				{
					currentPrototype = _items[i];
					storeItem = new StoreItem();
					storeItem.setItemDetail(_presenter.getPrototypeUIName(currentPrototype));
					storeItem.setItemDetailSubtext(_presenter.getProtoTypeUIDescriptionText(currentPrototype));
					if (currentPrototype.getValue('hardCurrencyCost') != -1)
					{
						var cost:int = getHardCurrencyCost(currentPrototype);
						storeItem.setItemCost(cost);
						storeItem.canAfford = canAfford(cost);
					}
					_presenter.loadIconFromPrototype(currentPrototype, storeItem.setItemIcon);
					storeItem.subcategory = currentPrototype.getValue('subcategory');
					storeItem.itemProto = currentPrototype;
					storeItem.onClicked.add(buy);

					_itemComponents.push(storeItem);
				}
				filterItems(_filters);
			}
		}

		public function setFilterTo( filterIndex:int ):void
		{
			_filterList.selectFilterByIndex(filterIndex);
		}

		protected function layout():void
		{
			var len:uint  = _visibleItemsContainer.numChildren;
			var xPos:uint = 300;
			var yPos:uint = 4;
			_maxHeight = 0;
			var storeItem:StoreItem;

			for (var i:uint = 0; i < len; ++i)
			{
				storeItem = StoreItem(_visibleItemsContainer.getChildAt(i));
				storeItem.x = xPos;
				storeItem.y = yPos;

				_maxHeight += storeItem.height + 15;
				yPos += storeItem.height + 15;
			}
			_maxHeight -= 8;
			_itemsScrollbar.updateScrollableHeight(_maxHeight);
		}

		public function updateStoreItems( added:Boolean = false ):void
		{
			if (!_init)
				setUpStoreItems();
		}

		private function onChangedScroll( percent:Number ):void
		{
			_mask.y = (_maxHeight - _mask.height) * percent;
			_visibleItemsContainer.scrollRect = _mask;
		}

		protected function buy( item:StoreItem ):void
		{
			if (item.canAfford)
				_presenter.buyItemTransaction(item.itemProto, false, item.cost);
			else
				_openWindow(WINDOW_CANNOT_AFFORD);
		}

		public function get itemsComponents():Vector.<StoreItem>  { return _itemComponents; }

		public function destroy():void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);

			_mask = null;
			_visibleItemsContainer = null;

			_itemsScrollbar.destroy();
			_itemsScrollbar = null;
		}

		public function set openWindow( v:Function ):void  { _openWindow = v; }

		override public function get height():Number  { return (parent != null) ? parent.height : height; }
		override public function get width():Number  { return (parent != null) ? parent.width : width; }

		public function get visibleItemsContainer():Sprite
		{
			return _visibleItemsContainer;
		}

		[Inject]
		public function set presenter( v:IStorePresenter ):void  { _presenter = v; }
		public function get presenter():IStorePresenter  { return IStorePresenter(_presenter); }

	}
}
