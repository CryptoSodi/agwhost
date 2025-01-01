package com.ui.modal.store
{
	import com.enum.StarbaseCategoryEnum;
	import com.enum.TypeEnum;
	import com.enum.ui.ButtonEnum;
	import com.event.StateEvent;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.transaction.TransactionVO;
	import com.presenter.starbase.IStorePresenter;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.construction.ConstructionView;
	import com.ui.modal.dock.DockView;
	import com.ui.modal.shipyard.ShipyardView;
	import com.util.CommonFunctionUtil;
	import com.util.statcalc.StatCalcUtil;

	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	public class StoreView extends View
	{
		private var _bg:ScaleBitmap;
		private var _closeBtn:BitmapButton;
		private var _viewName:Label;
		private var _currentState:uint;

		private var _resourcesBtn:BitmapButton;
		private var _speedUpsBtn:BitmapButton;
		private var _protectionBtn:BitmapButton;
		private var _buffsBtn:BitmapButton;
		private var _developerBtn:BitmapButton;
		private var _otherBtn:BitmapButton;

		private var _selectedBtn:BitmapButton;
		private var _activePage:StorePage;
		private var _storeItems:Dictionary;

		private var _resourcePage:StoreResourcePage;
		private var _transactionPage:StoreTransactionPage;
		private var _buffsPage:StoreBuffPage;
		private var _protectionPage:StoreProtectionPage;
		private var _developerPage:StorePage;
		private var _otherPage:StoreOtherPage;

		private var _totalBtnWidth:Number;

		private var _title:String                      = 'CodeString.Store.Title';
		private var _resources:String                  = 'CodeString.Store.ResourcesBtn';
		private var _speedUps:String                   = 'CodeString.Store.SpeedUpBtn';
		private var _buffs:String                      = 'CodeString.Store.BuffsBtn';
		private var _protection:String                 = 'CodeString.Store.ProtectionBtn';
		private var _tradeRoutes:String                = 'CodeString.Store.TradeRouteBtn';
		private var _developer:String                  = 'CodeString.Store.DeveloperBtn';
		private var _other:String					   = 'CodeString.Store.OtherBtn';


		private static var STATE_SPEED:uint            = 0;
		private static var STATE_RESOURCES:uint        = 1;
		private static var STATE_BUFFS:uint            = 3;
		private static var STATE_DEVELOPER:uint        = 4;
		private static var STATE_PROTECTION:uint       = 5;
		private static var STATE_OTHER:uint       	   = 6;


		//universal
		public static var FILTER_ALL:uint              = 0;

		//buff page
		public static var FILTER_INCOME_FULL:uint      = 1;
		public static var FILTER_INCOME_HALF:uint      = 2;
		public static var FILTER_CREDITS_FULL:uint     = 3;
		public static var FILTER_CREDITS_HALF:uint     = 4;
		public static var FILTER_ALLOY_FULL:uint       = 5;
		public static var FILTER_ALLOY_HALF:uint       = 6;
		public static var FILTER_ENERGY_FULL:uint      = 7;
		public static var FILTER_ENERGY_HALF:uint      = 8;
		public static var FILTER_SYNTH_FULL:uint       = 9;
		public static var FILTER_SYNTH_HALF:uint       = 10;
		public static var FILTER_BUILD_SPEED_FULL:uint = 11;
		public static var FILTER_BUILD_SPEED_HALF:uint = 12;
		public static var FILTER_BUILD_TIME:uint       = 13;
		public static var FILTER_FLEET_SPEED:uint      = 14;
		public static var FILTER_CARGO_CAPACITY:uint   = 15;

		//protection page
		public static var FILTER_BASE_PROTECTION:uint  = 1;

		//resource page
		public static var FILTER_CREDITS:uint          = 1;
		public static var FILTER_ALLOY:uint            = 2;
		public static var FILTER_ENERGY:uint           = 3;
		public static var FILTER_SYNTHETIC:uint        = 4;

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_storeItems = new Dictionary();
			var allStoreItems:Vector.<IPrototype>  = presenter.getStoreItemPrototypes();
			var len:uint                           = allStoreItems.length;
			var currentItem:IPrototype;
			var currentCategory:String;
			for (var i:uint = 0; i < len; ++i)
			{
				currentItem = allStoreItems[i];
				currentCategory = currentItem.getValue('category');
				//if (currentCategory != "Developer" || CONFIG::DEBUG == true)
				{
					if (_storeItems[currentCategory] == null)
						_storeItems[currentCategory] = new Vector.<IPrototype>;

					_storeItems[currentCategory].push(currentItem);
				}
			}

			for each (var category:Vector.<IPrototype> in _storeItems)
			{
				category.sort(orderItems);
			}

			var windowBG:Class                     = Class(getDefinitionByName(('StoreBGBMD')));
			var bgRect:Rectangle                   = new Rectangle(9, 137, 709, 140);
			_bg = new ScaleBitmap(BitmapData(new windowBG()));
			_bg.scale9Grid = bgRect;
			addChild(_bg);

			_viewName = new Label(24, 0xffffff, _bg.width - 60, 30);
			_viewName.align = TextFormatAlign.LEFT;
			_viewName.text = _title;
			_viewName.x = 35;
			_viewName.y = 13;
			addChild(_viewName);

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 43, 16);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);
			addChild(_closeBtn);

			_totalBtnWidth = 0;

			var hasBuffs:Boolean                   = _storeItems.hasOwnProperty('Buffs');
			var hasDevBuffs:Boolean                = _storeItems.hasOwnProperty("Developer");
			_speedUpsBtn = setUpCategoryBtn(_speedUps, onSpeedClick);
			_speedUpsBtn.enabled = (_storeItems.hasOwnProperty("Speedups") && _storeItems['Speedups'].length > 0)

			_resourcesBtn = setUpCategoryBtn(_resources, onResourceClick);
			_resourcesBtn.enabled = (_storeItems.hasOwnProperty("Resources") && _storeItems['Resources'].length > 0);

			if (hasBuffs)
				_protectionBtn = setUpCategoryBtn(_protection, onProtectionClick);
			else
				_protectionBtn = setUpCategoryBtn(_protection, onProtectionClick);
			_protectionBtn.enabled = (_storeItems.hasOwnProperty("Protection") && _storeItems['Protection'].length > 0);

			if (hasBuffs)
			{
				if (hasDevBuffs)
					_buffsBtn = setUpCategoryBtn(_buffs, onBuffsClick);
				else
					_buffsBtn = setUpCategoryBtn(_buffs, onBuffsClick);

				_buffsBtn.enabled = (_storeItems.hasOwnProperty("Buffs") && _storeItems['Buffs'].length > 0);
			}

			if (hasDevBuffs && CONFIG::DEBUG == true)
				_developerBtn = setUpCategoryBtn(_developer, onDeveloperClick);

			_otherBtn = setUpCategoryBtn(_other, onOtherClick);
			_otherBtn.enabled = (_storeItems.hasOwnProperty("Other") && _storeItems['Other'].length > 0);
			
			layoutBtns();

			var getPrototypeUIName:Function        = presenter.getPrototypeUIName;
			var loadIconFromPrototype:Function     = presenter.loadIconFromPrototype;
			var getPrototypeUIDescription:Function = presenter.getProtoTypeUIDescriptionText;
			var getCostResource:Function           = presenter.getHardCurrencyCostFromResource;
			var getCostTime:Function               = presenter.getHardCurrencyCostFromSeconds;
			var buyBuff:Function                   = presenter.buyItemTransaction;

			_resourcePage = new StoreResourcePage(_storeItems['Resources']);
			presenter.injectObject(_resourcePage);
			_resourcePage.getHardCurrencyCost = getCostResource;
			_resourcePage.canAfford = canAfford;
			_resourcePage.openWindow = openWindow;

			var enableTransactionLinking:Boolean   = (presenter.getCurrentState() == StateEvent.GAME_STARBASE);
			_transactionPage = new StoreTransactionPage(_storeItems['Speedups']);
			presenter.injectObject(_transactionPage);
			_transactionPage.getHardCurrencyCost = getCostTime;
			_transactionPage.canAfford = canAfford;
			_transactionPage.openWindow = openWindow;
			_transactionPage.addTransactions(presenter.getTransactions());
			_transactionPage.enableTransactionLinking = enableTransactionLinking;
			presenter.addOnTransactionUpdatedListener(_transactionPage.onTransactionUpdated);
			presenter.addOnTransactionRemovedListener(_transactionPage.onTransactionRemoved);

			_protectionPage = new StoreProtectionPage(_storeItems['Protection']);
			presenter.injectObject(_protectionPage);
			_protectionPage.getHardCurrencyCost = getStoreItemCost;
			_protectionPage.canAfford = canAfford;
			_protectionPage.openWindow = openWindow;

			_buffsPage = new StoreBuffPage(_storeItems['Buffs']);
			presenter.injectObject(_buffsPage);
			_buffsPage.getHardCurrencyCost = getStoreItemCost;
			_buffsPage.canAfford = canAfford;
			_buffsPage.openWindow = openWindow;

			_developerPage = new StorePage(_storeItems['Developer']);
			presenter.injectObject(_developerPage);
			_developerPage.canAfford = canAfford;
			_developerPage.getHardCurrencyCost = getStoreItemCost;
			_developerPage.openWindow = openWindow;
			
			_otherPage = new StoreOtherPage(_storeItems['Other']);
			presenter.injectObject(_otherPage);
			_otherPage.canAfford = canAfford;
			_otherPage.getHardCurrencyCost = getStoreItemCost;
			_otherPage.openWindow = openWindow;

			setState(_currentState);

			presenter.addOnTransactionRemovedListener(updateActivePage);

			addEffects();
			effectsIN();
		}

		private function updateActivePage( data:* = null ):void
		{
			if (_activePage)
				_activePage.updateStoreItems();
		}

		private function getStoreItemCost( purchaseable:IPrototype ):int
		{
			return StatCalcUtil.baseStatCalc("hardCurrencyCost", purchaseable.getValue('hardCurrencyCost'));
		}

		private function canAfford( cost:uint ):Boolean
		{
			var premium:uint = CurrentUser.wallet.premium;
			return cost <= premium ? true : false;
		}

		private function orderItems( itemOne:IPrototype, itemTwo:IPrototype ):int
		{
			var sortOrderOne:Number = itemOne.getValue('sort');
			var sortOrderTwo:Number = itemTwo.getValue('sort');

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

		private function layoutBtns():void
		{
			var xPos:Number = (_bg.width - _totalBtnWidth) * 0.5;
			var yPos:Number = 50;
			_speedUpsBtn.x = xPos;
			_speedUpsBtn.y = yPos;
			_resourcesBtn.x = _speedUpsBtn.x + _speedUpsBtn.width + 10;
			_resourcesBtn.y = yPos;

			_protectionBtn.x = _resourcesBtn.x + _resourcesBtn.width + 10;
			_protectionBtn.y = yPos;

			if (_storeItems.hasOwnProperty("Buffs") && _buffsBtn)
			{
				_buffsBtn.x = _protectionBtn.x + _protectionBtn.width + 10;
				_buffsBtn.y = yPos;
			}

			if (_storeItems.hasOwnProperty("Other") && _otherBtn != null)
			{
				_otherBtn.x = (_buffsBtn) ? _buffsBtn.x + _buffsBtn.width + 10 : _protectionBtn.x + _protectionBtn.width + 10;
				_otherBtn.y = yPos;
			}
			
			if (_storeItems.hasOwnProperty("Developer") && CONFIG::DEBUG == true && _developerBtn != null)
			{
				_developerBtn.x = (_otherBtn) ? _otherBtn.x + _otherBtn.width + 10 : _protectionBtn.x + _protectionBtn.width + 10;
				_developerBtn.y = yPos;
			}	
		}

		private function setUpCategoryBtn( btnName:String, onClick:Function ):BitmapButton
		{
			var btn:BitmapButton = UIFactory.getButton(ButtonEnum.BLUE_A, 125, 35, 0, 0, btnName);
			btn.selectable = true;
			addListener(btn, MouseEvent.CLICK, onClick);
			addChild(btn);

			_totalBtnWidth += btn.width + 10;
			return btn;
		}

		private function setState( state:uint ):void
		{
			if (_selectedBtn)
				_selectedBtn.selected = false;

			if (_activePage)
			{
				removeChild(_activePage);
				CurrentUser.wallet.onPremiumChange.remove(_activePage.updateStoreItems);
			}

			_currentState = state

			switch (_currentState)
			{
				case STATE_RESOURCES:
					_selectedBtn = _resourcesBtn;
					_activePage = _resourcePage;
					break;
				case STATE_SPEED:
					_selectedBtn = _speedUpsBtn;
					_activePage = _transactionPage;
					break;
				case STATE_BUFFS:
					_selectedBtn = _buffsBtn;
					_activePage = _buffsPage;
					break;
				case STATE_DEVELOPER:
					_selectedBtn = _developerBtn;
					_activePage = _developerPage;
					break;
				case STATE_PROTECTION:
					_selectedBtn = _protectionBtn;
					_activePage = _protectionPage;
					break;
				case STATE_OTHER:
					_selectedBtn = _otherBtn;
					_activePage = _otherPage;
					break;
			}

			if (_activePage)
			{
				addChild(_activePage);
				_activePage.updateStoreItems();
				CurrentUser.wallet.onPremiumChange.add(_activePage.updateStoreItems);
				_selectedBtn.selected = true;
			}
		}

		public function setSelectedTransaction( transaction:TransactionVO ):void
		{
			_transactionPage.setSelectedTransactionId(transaction);
			setState(STATE_SPEED);
		}

		public function openToResourcesAndFilter( filterIndex:uint ):void
		{
			_resourcePage.setFilterTo(filterIndex);
			setState(STATE_RESOURCES);
		}

		public function openToProtectionAndFilter( filterIndex:uint ):void
		{
			_protectionPage.setFilterTo(filterIndex);
			setState(STATE_PROTECTION);
		}

		public function openToBuffsAndFilter( filterIndex:uint ):void
		{
			_buffsPage.setFilterTo(filterIndex);
			setState(STATE_BUFFS);
		}

		private function onResourceClick( e:MouseEvent ):void
		{
			setState(STATE_RESOURCES);
		}

		private function onSpeedClick( e:MouseEvent ):void
		{
			setState(STATE_SPEED);
		}

		private function onBuffsClick( e:MouseEvent ):void
		{
			setState(STATE_BUFFS);
		}

		private function onProtectionClick( e:MouseEvent ):void
		{
			setState(STATE_PROTECTION);
		}

		private function onDeveloperClick( e:MouseEvent ):void
		{
			setState(STATE_DEVELOPER);
		}
		
		private function onOtherClick( e:MouseEvent ):void
		{
			setState(STATE_OTHER);
		}

		private function openWindow( id:int ):void
		{
			switch (id)
			{
				case StorePage.WINDOW_CANNOT_AFFORD:
					CommonFunctionUtil.popPaywall();
					break;
				case StorePage.WINDOW_BUILDING_VIEW:
					openBuildView();
					break;
				case StorePage.WINDOW_DEFENSE_VIEW:
					openBuildViewToDefensiveTab();
					break;
				case StorePage.WINDOW_SHIPYARD_VIEW:
					openShipyardView();
					break;
				case StorePage.WINDOW_DEFENSE_RESEARCH_VIEW:
					openDefenseResearchView();
					break;
				case StorePage.WINDOW_SHIP_RESEARCH_VIEW:
					openShipResearchView();
					break;
				case StorePage.WINDOW_MODULES_RESEARCH_VIEW:
					openModulesResearchView();
					break;
				case StorePage.WINDOW_TECHNOLOGY_RESEARCH_VIEW:
					openTechResearchView();
					break;
				case StorePage.WINDOW_DOCK_VIEW:
					openDocksView();
					break;
			}
		}

		private function openShipResearchView():void
		{
			destroy();
			var view:ConstructionView = ConstructionView(_viewFactory.createView(ConstructionView));
			view.openOn(ConstructionView.RESEARCH, TypeEnum.SHIPYARD, null);
			_viewFactory.notify(view);
		}

		private function openModulesResearchView():void
		{
			destroy();
			var view:ConstructionView = ConstructionView(_viewFactory.createView(ConstructionView));
			view.openOn(ConstructionView.RESEARCH, TypeEnum.WEAPONS_FACILITY, null);
			_viewFactory.notify(view);
		}

		private function openTechResearchView():void
		{
			destroy();
			var view:ConstructionView = ConstructionView(_viewFactory.createView(ConstructionView));
			view.openOn(ConstructionView.RESEARCH, TypeEnum.ADVANCED_TECH, null);
			_viewFactory.notify(view);
		}

		private function openDefenseResearchView():void
		{
			destroy();
			var view:ConstructionView = ConstructionView(_viewFactory.createView(ConstructionView));
			view.openOn(ConstructionView.RESEARCH, TypeEnum.DEFENSE_DESIGN, null);
			_viewFactory.notify(view);
		}

		private function openBuildView():void
		{
			destroy();
			var view:ConstructionView = ConstructionView(_viewFactory.createView(ConstructionView));
			view.openOn(ConstructionView.BUILD, null, null);
			_viewFactory.notify(view);
		}

		private function openBuildViewToDefensiveTab():void
		{
			destroy();
			var view:ConstructionView = ConstructionView(_viewFactory.createView(ConstructionView));
			view.openOn(ConstructionView.BUILD, StarbaseCategoryEnum.DEFENSE, null);
			_viewFactory.notify(view);
		}

		private function openShipyardView():void
		{
			destroy();
			showView(ShipyardView);
		}

		private function openDocksView():void
		{
			destroy();
			showView(DockView);
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IStorePresenter ):void  { _presenter = value; }
		public function get presenter():IStorePresenter  { return IStorePresenter(_presenter); }

		override public function destroy():void
		{
			presenter.removeOnTransactionRemovedListener(updateActivePage);
			presenter.removeOnTransactionUpdatedListener(_transactionPage.onTransactionUpdated);
			presenter.removeOnTransactionRemovedListener(_transactionPage.onTransactionRemoved);

			_resourcePage.destroy();
			_resourcePage = null;

			_transactionPage.destroy();
			_transactionPage = null;

			_protectionPage.destroy();
			_protectionPage = null;

			_buffsPage.destroy();
			_buffsPage = null;

			_developerPage.destroy();
			_developerPage = null;
			
			_otherPage.destroy();
			_otherPage = null;

			super.destroy();

			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;

			_viewName.destroy();
			_viewName = null;

			_resourcesBtn.destroy();
			_resourcesBtn = null;

			_speedUpsBtn.destroy();
			_speedUpsBtn = null;

			_protectionBtn.destroy();
			_protectionBtn = null;

			if (_storeItems.hasOwnProperty("Buffs") && _buffsBtn)
			{
				_buffsBtn.destroy();
				_buffsBtn = null;
			}

			if (_storeItems.hasOwnProperty("Developer") && CONFIG::DEBUG == true && _developerBtn != null)
			{
				_developerBtn.destroy();
				_developerBtn = null;
			}
			
			if (_storeItems.hasOwnProperty("Other") && _otherBtn)
			{
				_otherBtn.destroy();
				_otherBtn = null;
			}
		}
	}
}
