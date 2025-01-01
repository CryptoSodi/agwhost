package com.ui.modal.dock
{
	import com.enum.FactionEnum;
	import com.model.fleet.ShipVO;
	import com.model.player.CurrentUser;
	import com.presenter.starbase.IFleetPresenter;
	import com.ui.core.component.label.Label;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.filterlist.FilterList;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	public class ShipSelectionView extends View
	{
		private var _bg:ScaleBitmap;
		private var _closeBtn:BitmapButton;
		private var _topBG:Bitmap;
		private var _shipPanelSelections:Vector.<ShipPanelSelection>;
		private var _visiblePanelSelections:Vector.<ShipPanelSelection>;
		private var _onShipSelected:Function;
		
		private var _title:Label;
		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _holder:Sprite;
		private var _hitBlocker:Sprite;

		private var _filterList:FilterList;

		private var PADDING:int = 45;
		
		private var _titleText:String             = 'CodeString.Shipyard.SelectionTitle';

		[Inject]
		public var tooltip:Tooltips;

		public function ShipSelectionView()
		{
			super();
		}

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_topBG = UIFactory.getBitmap('ShipSelectHeaderBMD');

			var bgRect:Rectangle        = new Rectangle(0, 40, 637, 40);
			_bg = UIFactory.getScaleBitmap('ShipSelectFrameBMD');
			_bg.scale9Grid = bgRect;
			_bg.y = _topBG.height + 3;
			_bg.width = 640;
			_bg.height = 515;

			_shipPanelSelections = new Vector.<ShipPanelSelection>;
			_visiblePanelSelections = new Vector.<ShipPanelSelection>;

			_holder = new Sprite();
			_holder.x = _bg.x + 8;
			_holder.y = _bg.y + 8;
			_maxHeight = 0;

			_scrollRect = new Rectangle(_bg.x, _bg.y, _bg.width - 10, _bg.height - 30);
			_scrollRect.y = 0;
			_holder.scrollRect = _scrollRect

			_hitBlocker = new Sprite();
			_hitBlocker.graphics.clear();
			_hitBlocker.graphics.lineStyle(2, 0xffffff, 0);
			_hitBlocker.graphics.beginFill(0xffffff, 0);
			_hitBlocker.graphics.moveTo(0, 0);
			_hitBlocker.graphics.lineTo(_bg.width, 0);
			_hitBlocker.graphics.lineTo(_bg.width, _bg.y + _bg.height);
			_hitBlocker.graphics.lineTo(0, _bg.y + _bg.height);
			_hitBlocker.graphics.lineTo(0, 0);
			_hitBlocker.graphics.endFill();
			
			
			_title = new Label(15, 0xfffffff, 90, 20, true);
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.allCaps = true;
			_title.x = 12;
			_title.y = 6;
			_title.constrictTextToSize = false;
			_title.text = _titleText;

			var faction:String;
			switch (CurrentUser.faction)
			{
				case FactionEnum.IGA:
					faction = 'IGA';
					break;
				case FactionEnum.SOVEREIGNTY:
					faction = 'SOV';
					break;
				case FactionEnum.TYRANNAR:
					faction = 'TY';
					break;
			}

			_filterList = new FilterList();
			_filterList.init('', false, true, true);
			_filterList.x = 37;
			_filterList.y = 39;
			_filterList.onSelectionChanged.add(filterShips);

			var fighterBtn:BitmapButton;
			var heavyFighterBtn:BitmapButton;
			var corvetteBtn:BitmapButton;
			var destroyerBtn:BitmapButton;
			var battleshipBtn:BitmapButton;
			var dreadnoughtBtn:BitmapButton;
			var transportBtn:BitmapButton;

			fighterBtn = ButtonFactory.getBitmapButton(faction + 'LFBMD', 0, 0, '', 0xFFFFFF, faction + 'LFRollOverBMD', null, null, faction + 'LFRollOverBMD');
			_filterList.addFilterBtn('Fighter', fighterBtn, 45);

			heavyFighterBtn = ButtonFactory.getBitmapButton(faction + 'HFBMD', 0, 0, '', 0xFFFFFF, faction + 'HFRollOverBMD', null, null, faction + 'HFRollOverBMD');
			_filterList.addFilterBtn('Heavy Fighter', heavyFighterBtn, 45);

			corvetteBtn = ButtonFactory.getBitmapButton(faction + 'CVBMD', 0, 0, '', 0xFFFFFF, faction + 'CVRollOverBMD', null, null, faction + 'CVRollOverBMD');
			_filterList.addFilterBtn('Corvette', corvetteBtn, 45);

			destroyerBtn = ButtonFactory.getBitmapButton(faction + 'DDBMD', 0, 0, '', 0xFFFFFF, faction + 'DDRollOverBMD', null, null, faction + 'DDRollOverBMD');
			_filterList.addFilterBtn('Destroyer', destroyerBtn, 45);

			battleshipBtn = ButtonFactory.getBitmapButton(faction + 'BSBMD', 0, 0, '', 0xFFFFFF, faction + 'BSRollOverBMD', null, null, faction + 'BSRollOverBMD');
			_filterList.addFilterBtn('Battleship', battleshipBtn, 45);

			dreadnoughtBtn = ButtonFactory.getBitmapButton(faction + 'DNBMD', 0, 0, '', 0xFFFFFF, faction + 'DNRollOverBMD', null, null, faction + 'DNRollOverBMD');
			_filterList.addFilterBtn('Dreadnought', dreadnoughtBtn, 45);

			transportBtn = ButtonFactory.getBitmapButton(faction + 'TSBMD', 0, 0, '', 0xFFFFFF, faction + 'TSRollOverBMD', null, null, faction + 'TSRollOverBMD');
			_filterList.addFilterBtn('Transport', transportBtn, 45);

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 35, 35);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = _bg.x + _bg.width - 19;
			var scrollbarYPos:Number    = _bg.y + 15;
			_scrollbar.init(7, _scrollRect.height - 15, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 30;

			addChild(_hitBlocker);
			addChild(_topBG)
			addChild(_bg);
			addChild(_closeBtn);
			addChild(_filterList);
			addChild(_holder);
			addChild(_scrollbar);
			addChild(_title);

			addEffects();
			effectsIN();
		}

		override public function get height():Number
		{
			return _hitBlocker.height;
		}

		override public function get width():Number
		{
			return _hitBlocker.width;
		}

		private function filterShips( filters:Array ):void
		{
			if (_holder.numChildren > 0)
				_holder.removeChildren(0, (_holder.numChildren - 1));

			_visiblePanelSelections.length = 0;
			presenter.shipSelectionFilter = filters;
			var len:uint = _shipPanelSelections.length;
			var currentShipPanelSelection:ShipPanelSelection;
			for (var i:uint = 0; i < len; ++i)
			{
				currentShipPanelSelection = _shipPanelSelections[i];
				if (filters == null || filters.length == 0 || filters.indexOf(currentShipPanelSelection.itemClass) != -1)
				{
					_holder.addChild(currentShipPanelSelection);
					_visiblePanelSelections.push(currentShipPanelSelection);
				}
			}

			layout();
			_scrollbar.resetScroll();
		}

		override public function set visible( value:Boolean ):void
		{
			super.visible = value;
			_scrollbar.resetScroll();
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		public function addShips( ships:Vector.<ShipVO> ):void
		{

			var selectionsLen:uint    = _shipPanelSelections.length;
			var len:uint              = ships.length;
			var currentShipVO:ShipVO;
			var currentShipPanelSelection:ShipPanelSelection;
			var i:uint                = 0
			var currentShipCount:uint = 0;
			for (; i < len; ++i)
			{
				currentShipVO = ships[i];

				if (currentShipVO.built != true)
					continue;

				if (currentShipCount < selectionsLen)
				{
					currentShipPanelSelection = _shipPanelSelections[currentShipCount];
					++currentShipCount;
				} else
				{
					currentShipPanelSelection = new ShipPanelSelection();
					currentShipPanelSelection.onClicked.add(onShipClick);
					_shipPanelSelections.push(currentShipPanelSelection);
				}

				currentShipPanelSelection.ship = currentShipVO;
				tooltip.addTooltip(currentShipPanelSelection, this, currentShipPanelSelection.getTooltip, '', 250, 180, 14);

				if (currentShipVO.prototypeVO != null)
				{
					presenter.loadIconFromEntityData(currentShipVO.prototypeVO.asset, currentShipPanelSelection.onLoadImage);
					presenter.getProtoTypeUIName(currentShipVO.prototypeVO, currentShipPanelSelection.setName);
				}
				currentShipPanelSelection.setCustomName(currentShipVO.shipName);

			}

			if (i < selectionsLen)
			{
				var startValue:uint = i;
				for (; i < selectionsLen; ++i)
				{
					currentShipPanelSelection = _shipPanelSelections[i];
					currentShipPanelSelection.destroy();
					currentShipPanelSelection = null;
				}
				_shipPanelSelections.splice(startValue, selectionsLen - startValue);
			}

			if (presenter.shipSelectionFilter != null && presenter.shipSelectionFilter.length > 0)
				_filterList.selectFilterByFilter(presenter.shipSelectionFilter);
			else
				filterShips(null);
		}

		private function onShipClick( ship:ShipVO ):void
		{
			if (ship)
			{
				_onShipSelected(ship);
				destroy();
			}
		}

		public function setUp( onShipSelected:Function ):void
		{
			_onShipSelected = onShipSelected
			addShips(presenter.unassignedShips);
		}

		private function layout():void
		{
			var len:uint = _visiblePanelSelections.length;
			var shipSelection:ShipPanelSelection;
			var yPos:int = 15;
			_maxHeight = 0;
			var shipCount:int;
			for (var i:uint = 0; i < len; ++i)
			{
				shipSelection = _visiblePanelSelections[i];
				shipSelection.x = 10;
				shipSelection.y = yPos;
				_maxHeight += shipSelection.height + 5;
				yPos += shipSelection.height + 5;
				++shipCount;
			}
			_maxHeight += 10;

			_scrollbar.updateScrollableHeight(_maxHeight);
		}

		override public function get typeUnique():Boolean  { return false; }

		[Inject]
		public function set presenter( value:IFleetPresenter ):void  { _presenter = value; }
		public function get presenter():IFleetPresenter  { return IFleetPresenter(_presenter); }

		override public function destroy():void
		{
			super.destroy();

			if (_holder.numChildren > 0)
				_holder.removeChildren(0, (_holder.numChildren - 1));

			_visiblePanelSelections.length = 0;

			var len:uint = _shipPanelSelections.length;
			var currentShipPanel:ShipPanelSelection;
			for (var i:uint = 0; i < len; ++i)
			{
				currentShipPanel = _shipPanelSelections[i];
				currentShipPanel.destroy();
				currentShipPanel = null;
			}
			_shipPanelSelections.length = 0;
			_closeBtn.destroy();
			_closeBtn = null;
			
			if (_title)
				_title.destroy();
			
			_title = null;
		}
	}

}

