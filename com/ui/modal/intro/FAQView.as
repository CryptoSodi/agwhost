package com.ui.modal.intro
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.IUIPresenter;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.accordian.AccordianComponent;
	import com.ui.core.component.accordian.AccordianGroup;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.filterlist.FilterList;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	import org.shared.ObjectPool;

	public class FAQView extends View
	{
		private var _bg:DefaultWindowBG;

		private var _accordian:AccordianComponent;

		private var _groupID:String;
		private var _maxHeight:int;

		protected var _scrollRect:Rectangle;

		private var _container:Sprite;
		private var _selectionHolder:Sprite;

		private var _eightsImage:Bitmap;

		private var _scrollbar:VScrollbar;

		private var _componentPanelSelections:Dictionary;
		private var _visibleComponentPanelSelections:Vector.<FAQSelectionComponent>;

		private var _selectedComponent:FAQSelectionComponent;

		private var _titleText:String = 'CodeString.FAQView.Title'; //ASK EIGHTS

		[PostConstruct]
		override public function init():void
		{

			super.init();

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(736, 486);
			_bg.addTitle(_titleText, 240);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_eightsImage = UIFactory.getBitmap("AskEightsBMD");
			_eightsImage.x = 28;
			_eightsImage.y = 8;

			_accordian = ObjectPool.get(AccordianComponent);
			_accordian.init(151, 30);
			_accordian.x = _eightsImage.x;
			_accordian.y = _eightsImage.y + _eightsImage.height;
			_accordian.addListener(onAccordianSelected);

			_container = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED, PanelEnum.HEADER_NOTCHED_RIGHT, 551, 439, 30, _eightsImage.x + _eightsImage.width, 50, "MEH", LabelEnum.
												  H3);

			_componentPanelSelections = new Dictionary;
			_visibleComponentPanelSelections = new Vector.<FAQSelectionComponent>;

			_selectionHolder = new Sprite();
			_selectionHolder.x = _eightsImage.x + _eightsImage.width + 6;
			_selectionHolder.y = _bg.y + 85;
			_maxHeight = 0;

			_scrollRect = new Rectangle(0, _bg.y + 23, _bg.width - 20, 428);
			_scrollRect.y = 0;
			_selectionHolder.scrollRect = _scrollRect

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle        = new Rectangle(0, 5, 5, 2);
			_scrollbar.init(7, _scrollRect.height - 8, _container.x + _container.width - 31, _container.y + 34, dragBarBGRect, '', 'ScrollBarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 10.75;

			addChild(_bg);
			addChild(_accordian);
			addChild(_container);
			addChild(_selectionHolder);
			addChild(_scrollbar);
			addChild(_eightsImage);

			var options:Vector.<IPrototype>    = new Vector.<IPrototype>;
			var prototypes:Vector.<IPrototype> = presenter.getFAQPrototypes();
			for (var i:int = 0; i < prototypes.length; i++)
				options.push(prototypes[i]);

			addSelections(options);

			addEffects();
			effectsIN();
		}

		private function onAccordianSelected( groupID:String, subItemID:String, data:* ):void
		{
			_groupID = groupID;

			var group:AccordianGroup = _accordian.getGroup(groupID);
			setContainerTitle(group.text);

			if (_selectedComponent)
			{
				_selectedComponent.extended = !_selectedComponent.extended;
				_selectedComponent = null;
			}

			if (_selectionHolder.numChildren > 0)
				_selectionHolder.removeChildren(0, (_selectionHolder.numChildren - 1));

			_visibleComponentPanelSelections.length = 0;
			for each (var value:FAQSelectionComponent in _componentPanelSelections)
			{
				if (value.filter == _groupID)
				{
					_selectionHolder.addChild(value);
					_visibleComponentPanelSelections.push(value);
				}
			}

			_visibleComponentPanelSelections.sort(orderItems);

			layout();
			_scrollbar.resetScroll();
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_selectionHolder.scrollRect = _scrollRect;
		}

		private function orderFilters( filterOne:AssetVO, filterTwo:AssetVO ):Number
		{
			if (!filterOne)
				return -1;
			if (!filterTwo)
				return 1;

			if (filterOne.sort < filterTwo.sort)
				return -1;
			else
				return 1;
		}

		private function orderItems( itemOne:FAQSelectionComponent, itemTwo:FAQSelectionComponent ):Number
		{
			if (!itemOne)
				return -1;
			if (!itemTwo)
				return 1;

			var sortOne:Number     = itemOne.sort;
			var sortTwo:Number     = itemTwo.sort;

			var itemOneName:String = itemOne.selectionName.toLowerCase();
			var itemTwoName:String = itemTwo.selectionName.toLowerCase();

			if (sortOne < sortTwo)
				return -1;
			else if (sortOne > sortTwo)
				return 1;

			if (itemOneName > itemTwoName)
				return 1;
			else if (itemOneName < itemTwoName)
				return -1;

			return 0;
		}

		private function addSelections( components:Vector.<IPrototype> ):void
		{
			var currentSelectionComponent:FAQSelectionComponent;
			var assetVO:AssetVO;
			var filterAssetVO:AssetVO;
			var type:String;
			var i:uint;
			var filters:Array = new Array();
			var len:uint      = components.length;
			var proto:IPrototype;
			var image:String;
			for (i = 0; i < len; ++i)
			{
				proto = components[i];
				assetVO = presenter.getAssetVOFromIPrototype(proto);
				filterAssetVO = presenter.getFilterAssetVO(proto);

				if (components[i].name in _componentPanelSelections)
					currentSelectionComponent = _componentPanelSelections[components[i].name];
				else
					currentSelectionComponent = new FAQSelectionComponent();

				currentSelectionComponent.setInfoText(assetVO.descriptionText, 0xf0f0f0);
				currentSelectionComponent.selection = components[i];
				currentSelectionComponent.frameName = assetVO.visibleName;
				currentSelectionComponent.filter = filterAssetVO.type;
				currentSelectionComponent.sort = components[i].getUnsafeValue('sort');
				currentSelectionComponent.onClicked.add(onSelectedComponent);
				currentSelectionComponent.onSizeUpdated.add(layout);
				currentSelectionComponent.onResizeFinish.add(resizedFinished);
				_componentPanelSelections[components[i].name] = currentSelectionComponent;
				if (filters.indexOf(filterAssetVO) == -1)
					filters.push(filterAssetVO);
			}

			filters.sort(orderFilters);
			len = filters.length;
			var currentAssetVO:AssetVO;
			for (i = 0; i < len; ++i)
			{
				currentAssetVO = filters[i];
				_accordian.addGroup(currentAssetVO.type, currentAssetVO.visibleName);
				if (_groupID == null || _groupID == '')
					onAccordianSelected(currentAssetVO.type, null, null);
			}
		}

		private function onSelectedComponent( selectionBtn:FAQSelectionComponent ):void
		{
			var oldComponent:FAQSelectionComponent = _selectedComponent;
			_selectedComponent = selectionBtn;
			_selectionHolder.setChildIndex(selectionBtn, _selectionHolder.numChildren - 1);

			if (oldComponent)
				oldComponent.extended = !oldComponent.extended;
			else
				_selectedComponent.extended = !_selectedComponent.extended;
		}

		private function layout():void
		{
			var len:uint = _visibleComponentPanelSelections.length;
			var selection:FAQSelectionComponent;
			var yPos:int = 1;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _visibleComponentPanelSelections[i];
				selection.y = yPos;
				_maxHeight += selection.height + 5;
				yPos += selection.height + 5;
			}
			_maxHeight -= 4;
			_scrollbar.updateScrollableHeight(_maxHeight);
		}

		private function resizedFinished( selectionBtn:FAQSelectionComponent ):void
		{
			if (!selectionBtn.extended)
			{
				if (_selectedComponent != null)
				{
					if (selectionBtn != _selectedComponent)
						_selectedComponent.extended = !_selectedComponent.extended;
					else
						_selectedComponent = null;

					layout();
				}
			} else
			{
				layout();

				if (selectionBtn.y + selectionBtn.height > _scrollRect.height)
					_scrollbar.updateScrollY(selectionBtn.y + selectionBtn.height - _scrollRect.height + 3);
			}

			if (_maxHeight <= _scrollRect.height)
				_scrollbar.resetScroll();
		}

		private function cleanUpSelections():void
		{
			for (var key:Object in _componentPanelSelections)
			{
				_componentPanelSelections[key].destroy();
				delete _componentPanelSelections[key];
			}
			_visibleComponentPanelSelections.length = 0;
		}

		private function setContainerTitle( v:String ):void  { Label(_container.getChildAt(2)).text = v; }

		[Inject]
		public function set presenter( v:IUIPresenter ):void  { _presenter = v; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function get width():Number  { return _bg.width; }
		override public function get height():Number  { return _bg.height; }

		override public function destroy():void
		{
			super.destroy();

			cleanUpSelections();

			_selectedComponent = null;
			_scrollRect = null;
			_container = null;
			_selectionHolder = null;
			_eightsImage = null;
			_componentPanelSelections = null;
			_visibleComponentPanelSelections = null;

			_selectedComponent = null;

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			if (_accordian)
				ObjectPool.give(_accordian);

			_accordian = null;

			if (_scrollbar)
				_scrollbar.destroy();

			_scrollbar = null;
		}
	}
}

