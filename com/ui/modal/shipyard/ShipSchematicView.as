package com.ui.modal.shipyard
{
	import com.enum.FactionEnum;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.presenter.starbase.IShipyardPresenter;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.filterlist.FilterList;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;

	import org.adobe.utils.StringUtil;
	import org.parade.enum.ViewEnum;

	public class ShipSchematicView extends View
	{
		private var _topBG:Bitmap;
		private var _bg:ScaleBitmap;
		private var _closeBtn:BitmapButton;
		private var _shipPanelSelections:Vector.<ShipSchematicSelection>;
		private var _visiblePanelSelections:Vector.<ShipSchematicSelection>;
		private var _onSelectSchematic:Function;

		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _holder:Sprite;
		private var _hitBlocker:Sprite;

		private var _savedFilters:Array;

		private var _filterList:FilterList;

		private var _tooltips:Tooltips;

		private var fighterText:String      = 'CodeString.Ship.Fighter'; //Fighter
		private var heavyFighterText:String = 'CodeString.Ship.HeavyFighter'; //Heavy Fighter
		private var corvetteText:String     = 'CodeString.Ship.Corvette'; //Corvette
		private var destroyerText:String    = 'CodeString.Ship.Destroyer'; //Destroyer
		private var battleshipText:String   = 'CodeString.Ship.Battleship'; //Battleship
		private var dreadnoughtText:String  = 'CodeString.Ship.Dreadnought'; //Dreadnought
		private var transportText:String    = 'CodeString.Ship.Transport'; //Transport

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_topBG = UIFactory.getBitmap('ShipyardSchematicSelectTopBMD');
			_topBG.width = 782;

			var bgRect:Rectangle        = new Rectangle(0, 40, 637, 40);
			_bg = UIFactory.getScaleBitmap('ShipSelectFrameBMD');
			_bg.scale9Grid = bgRect;
			_bg.y = _topBG.height + 3;
			_bg.width = _topBG.width;
			_bg.height = 515;

			_shipPanelSelections = new Vector.<ShipSchematicSelection>;
			_visiblePanelSelections = new Vector.<ShipSchematicSelection>;

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

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 35, 10);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

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
			_filterList.init('', true, false, true);
			_filterList.x = 35;
			_filterList.y = 7;
			_filterList.onSelectionChanged.add(filterShips);

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = _bg.x + _bg.width - 33;
			var scrollbarYPos:Number    = _bg.y + 21;
			_scrollbar.init(7, _scrollRect.height - 15, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 29.5;

			var fighterBtn:ShipSchematicButton;
			var heavyFighterBtn:ShipSchematicButton;
			var corvetteBtn:ShipSchematicButton;
			var destroyerBtn:ShipSchematicButton;
			var battleshipBtn:ShipSchematicButton;
			var dreadnoughtBtn:ShipSchematicButton;
			var transportBtn:ShipSchematicButton;

			fighterBtn = setUpShipSchematicBtn(faction + 'LFBMD', fighterText, 0xFFFFFF, faction + 'LFRollOverBMD', faction + 'LFRollOverBMD');
			_filterList.addFilterBtn('Fighter', fighterBtn, 68);

			heavyFighterBtn = setUpShipSchematicBtn(faction + 'HFBMD', heavyFighterText, 0xFFFFFF, faction + 'HFRollOverBMD', faction + 'HFRollOverBMD');
			_filterList.addFilterBtn('Heavy Fighter', heavyFighterBtn, 68);

			corvetteBtn = setUpShipSchematicBtn(faction + 'CVBMD', corvetteText, 0xFFFFFF, faction + 'CVRollOverBMD', faction + 'CVRollOverBMD');
			_filterList.addFilterBtn('Corvette', corvetteBtn, 68);

			destroyerBtn = setUpShipSchematicBtn(faction + 'DDBMD', destroyerText, 0xFFFFFF, faction + 'DDRollOverBMD', faction + 'DDRollOverBMD');
			_filterList.addFilterBtn('Destroyer', destroyerBtn, 68);

			battleshipBtn = setUpShipSchematicBtn(faction + 'BSBMD', battleshipText, 0xFFFFFF, faction + 'BSRollOverBMD', faction + 'BSRollOverBMD');
			_filterList.addFilterBtn('Battleship', battleshipBtn, 68);

			dreadnoughtBtn = setUpShipSchematicBtn(faction + 'DNBMD', dreadnoughtText, 0xFFFFFF, faction + 'DNRollOverBMD', faction + 'DNRollOverBMD');
			_filterList.addFilterBtn('Dreadnought', dreadnoughtBtn, 68);

			transportBtn = setUpShipSchematicBtn(faction + 'TSBMD', transportText, 0xFFFFFF, faction + 'TSRollOverBMD', faction + 'TSRollOverBMD');
			_filterList.addFilterBtn('Transport', transportBtn, 68);
			_filterList.selectFilterByIndex(0);

			addChild(_hitBlocker);
			addChild(_topBG)
			addChild(_bg);
			addChild(_closeBtn);
			addChild(_filterList);
			addChild(_holder);
			addChild(_scrollbar);

			addEffects();
			effectsIN();
		}

		private function setUpShipSchematicBtn( upName:String, text:String = '', textColor:uint = 0xffffff, overName:String = null, downName:String = null ):ShipSchematicButton
		{
			var btn:ShipSchematicButton = new ShipSchematicButton();
			var up:BitmapData           = ButtonFactory.getBMD(upName);
			var ro:BitmapData           = ButtonFactory.getBMD(overName);
			var down:BitmapData         = ButtonFactory.getBMD(downName);
			btn.init(up, ro, down, null, down);
			btn.text = text;
			return btn;
		}

		public function filterShips( filters:Array ):void
		{
			if (_holder.numChildren > 0)
				_holder.removeChildren(0, (_holder.numChildren - 1));

			_visiblePanelSelections.length = 0;

			var len:uint = _shipPanelSelections.length;
			if (len)
			{
				if (_savedFilters != null)
					_savedFilters = null;

				var currentShipPanelSelection:ShipSchematicSelection;
				for (var i:uint = 0; i < len; ++i)
				{
					currentShipPanelSelection = _shipPanelSelections[i];
					if (filters != null && filters.indexOf(currentShipPanelSelection.itemClass) != -1)
					{
						_holder.addChild(currentShipPanelSelection);
						_visiblePanelSelections.push(currentShipPanelSelection)
					}
				}
				_visiblePanelSelections.sort(orderItems);
				layout();
				_scrollbar.resetScroll();
			} else
			{
				_savedFilters = filters
			}
		}

		private function orderItems( itemOne:ShipSchematicSelection, itemTwo:ShipSchematicSelection ):int
		{
			var sortOrderOne:Number = itemOne.schematic.getValue('sort');
			var sortOrderTwo:Number = itemTwo.schematic.getValue('sort');

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

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		public function addShips( ships:Vector.<IPrototype>, onSelectSchematic:Function ):void
		{
			_onSelectSchematic = onSelectSchematic;

			var selectionsLen:uint    = _shipPanelSelections.length;
			var len:uint              = ships.length;
			var isResearched:Boolean;
			var currentHullProto:IPrototype;
			var currentShipPanelSelection:ShipSchematicSelection;
			var i:uint                = 0
			var currentShipCount:uint = 0;
			for (; i < len; ++i)
			{
				currentHullProto = ships[i];
				isResearched = presenter.isResearched(currentHullProto.getValue('requiredResearch'));

				if (currentHullProto.getValue('hideWhileLocked') && !isResearched)
					continue;

				if (currentShipCount < selectionsLen)
				{
					currentShipPanelSelection = _shipPanelSelections[currentShipCount];
					++currentShipCount;
				} else
				{
					currentShipPanelSelection = new ShipSchematicSelection();
					currentShipPanelSelection.onClicked.add(onShipClick);
					_shipPanelSelections.push(currentShipPanelSelection);
				}
				currentShipPanelSelection.ship = currentHullProto;

				currentShipPanelSelection.setName(presenter.getAssetVO(currentHullProto).visibleName);
				presenter.loadIconFromEntityData(currentHullProto.uiAsset, currentShipPanelSelection.onLoadImage);
				_tooltips.addTooltip(currentShipPanelSelection, this, null, tooltip(currentHullProto));
				if (!isResearched)
					currentShipPanelSelection.locked = true;
				else
					currentShipPanelSelection.locked = false;
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

			if (_savedFilters != null)
				filterShips(_savedFilters);
		}

		private function onShipClick( ship:IPrototype ):void
		{
			if (ship != null && _onSelectSchematic != null)
			{
				_onSelectSchematic(ship);
				destroy();
			}
		}

		private function layout():void
		{
			var len:uint = _visiblePanelSelections.length;
			var shipSelection:ShipSchematicSelection;
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

		public function tooltip( prototype:IPrototype ):String
		{
			return getSelectionInfo(prototype, StringUtil.getTooltip);
		}

		private function getSelectionInfo( prototype:IPrototype, info:Function ):*
		{
			var selectionInfo:*;
			if (prototype)
			{
				var reqBuildClass:String = prototype.getUnsafeValue('requiredBuildingClass');
				if (reqBuildClass)
				{
					var proto:IPrototype;
					if (reqBuildClass == 'ShipDesignFacility')
					{
						proto = presenter.getPrototypeByName(prototype.getValue('referenceName'));
						if (proto)
						{
							selectionInfo = info(proto.getValue('type'), proto);
						} else
						{
							proto = presenter.getPrototypeByName(prototype.getValue('referenceName'));
							if (proto)
								selectionInfo = info(proto.getValue('type'), proto);
						}

					} else if (reqBuildClass == 'CommandCenter' || reqBuildClass == '')
					{
						selectionInfo = info(prototype.getValue('type'), prototype);
					} else
					{
						proto = presenter.getPrototypeByName(prototype.getValue('referenceName'));
						selectionInfo = info(proto.getValue('type'), proto);
					}
				} else
					selectionInfo = info(prototype.getValue('type'), prototype);
			}

			return selectionInfo;
		}

		[Inject]
		public function set presenter( value:IShipyardPresenter ):void  { _presenter = value; }
		public function get presenter():IShipyardPresenter  { return IShipyardPresenter(_presenter); }

		[Inject]
		public function set tooltips( value:Tooltips ):void  { _tooltips = value; }

		override public function get height():Number  { return _hitBlocker.height; }
		override public function get width():Number  { return _hitBlocker.width; }

		override public function set visible( value:Boolean ):void
		{
			_scrollbar.resetScroll();
			onChangedScroll(0);
			super.visible = value;
		}

		override public function get typeUnique():Boolean  { return false; }

		override public function destroy():void
		{
			super.destroy();

			if (_holder.numChildren > 0)
				_holder.removeChildren(0, (_holder.numChildren - 1));

			_visiblePanelSelections.length = 0;
			_closeBtn.destroy();
			_closeBtn = null;

			if (_shipPanelSelections)
			{
				var len:uint = _shipPanelSelections.length;
				var currentShipIcon:ShipSchematicSelection;
				for (var i:uint = 0; i < len; ++i)
				{
					currentShipIcon = _shipPanelSelections[i];
					currentShipIcon.destroy();
					currentShipIcon = null;
				}
				_shipPanelSelections.length = 0;
			}

			if (_tooltips)
				_tooltips.removeTooltip(null, this);

			_tooltips = null;
		}
	}
}


