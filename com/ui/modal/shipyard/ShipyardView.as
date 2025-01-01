package com.ui.modal.shipyard
{
	import com.controller.transaction.requirements.PurchaseVO;
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.CurrencyEnum;
	import com.enum.SlotComponentEnum;
	import com.enum.server.PurchaseTypeEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.transaction.TransactionVO;
	import com.presenter.starbase.IShipyardPresenter;
	import com.service.ExternalInterfaceAPI;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ActionComponent;
	import com.ui.core.component.misc.ActionInProgressComponent;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.hud.shared.command.ResourceComponent;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.ui.modal.construction.ConstructionView;
	import com.ui.modal.information.ResourceModalView;
	import com.ui.modal.store.StoreView;
	import com.util.CommonFunctionUtil;
	import com.util.statcalc.StatCalcUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.adobe.utils.StringUtil;
	import org.shared.ObjectPool;

	public class ShipyardView extends View
	{
		private static const BUILD_STATE:int                = 1;
		private static const BUILDING_STATE:int             = 2;
		private static const REFIT_STATE:int                = 3;

		private static const GOOD_STATE:int                 = 1;
		private static const OVER_POWERED_STATE:int         = 2;
		private static const CANNOT_AFFORD_STATE:int        = 3;
		private static const NO_MODULES:int                 = 4;
		private static const NO_CHANGES:int                 = 5;
		private static const SHIPYARD_DAMAGED:int           = 6;

		private static const PADDING:int                    = 45;

		private var _buildBtn:BitmapButton;
		private var _buildComponent:ActionComponent;
		private var _buildCostComponent:ResourceComponent;
		private var _buildInProgressComponent:ActionInProgressComponent;
		private var _buildNowBtn:BitmapButton;
		private var _selectHullBtn:BitmapButton;
		private var _scrapShipBtn:BitmapButton;

		private var _bg:DefaultWindowBG;
		
		private var _changeShipNameBtn:BitmapButton;
		private var _bgFlair:Bitmap;
		private var _alloySymbol:Bitmap;
		private var _creditsSymbol:Bitmap;
		private var _energySymbol:Bitmap;
		private var _premiumSymbol:Bitmap;
		private var _resourcesBackingBottom:Bitmap;
		private var _resourcesBackingTop:Bitmap;
		private var _syntheticsSymbol:Bitmap;

		private var _buildShipTimer:Timer;
		private var _buildShipTransaction:TransactionVO;
		private var _components:Vector.<ComponentSelection>;
		private var _currentBuildableState:uint;
		private var _currentMassUsage:Number;
		private var _currentRequirements:RequirementVO;
		private var _currentWindowState:uint;
		private var _defaultHull:IPrototype;
		private var _deltas:Dictionary;
		private var _enableComponents:Boolean;
		private var _loadCallback:Function;
		private var _prototypeLabels:Array;
		private var _refitShip:ShipVO;
		private var _schematicImage:ImageComponent;
		private var _selectedIndex:int;
		private var _textHolder:Sprite;
		private var _tooltips:Tooltips;

		private var _alloyCost:Label;
		private var _armorLabel:Label;
		private var _armorValue:Label;
		private var _buildableStateText:Label;
		private var _cargoLabel:Label;
		private var _cargoValue:Label;
		private var _creditCost:Label;
		private var _shipDpsLabel:Label;
		private var _shipDpsValue:Label;
		private var _energyCost:Label;
		private var _evasionLabel:Label;
		private var _evasionValue:Label;
		private var _healthLabel:Label;
		private var _healthValue:Label;
		private var _rotationSpeedLabel:Label;
		private var _rotationSpeedValue:Label;
		private var _maskingLabel:Label;
		private var _maskingValue:Label;
		private var _powerUsage:Label;
		private var _powerUsageTitle:Label;
		private var _premiumCost:Label;
		private var _profileLabel:Label;
		private var _profileValue:Label;
		private var _shipPrototypeName:Label;
		private var _shipSchematicName:Label;
		private var _maxSpeedLabel:Label;
		private var _maxSpeedValue:Label;
		private var _syntheticCost:Label;
		private var _loadSpeedLabel:Label;
		private var _loadSpeedValue:Label;
		private var _mapSpeedLabel:Label;
		private var _mapSpeedValue:Label;
		private var _accelerationTimeLabel:Label;
		private var _accelerationTimeValue:Label;
		private var _availableShipSlotsTitle:Label;
		private var _availableShipSlots:Label;

		private var _armorBar:ProgressBar;
		private var _cargoBar:ProgressBar;
		private var _shipDpsBar:ProgressBar;
		private var _evasionBar:ProgressBar;
		private var _healthBar:ProgressBar;
		private var _rotationSpeedBar:ProgressBar;
		private var _maskingBar:ProgressBar;
		private var _profileBar:ProgressBar;
		private var _shipPowerUsage:ProgressBar;
		private var _maxSpeedBar:ProgressBar;
		private var _loadSpeedBar:ProgressBar;
		private var _mapSpeedBar:ProgressBar;
		private var _accelerationTimeBar:ProgressBar;

		private var _alertBodyBuyResources:String           = 'CodeString.Alert.BuyResources.Body';
		private var _alertHeadingBuyResources:String        = 'CodeString.Alert.BuyResources.Title';
		private var _buildNow:String                        = 'CodeString.Shared.BuildNowBtn'; // Build Now
		private var _build:String                           = 'CodeString.Shared.BuildBtn'; //Build
		private var _cancelShipBuildAlertBody:String        = 'CodeString.Alert.CancelShip.Body'; //Are you sure you wish to cancel this ship build in progress?
		private var _cancelShipBuildAlertCancelBuild:String = 'CodeString.Shared.YesBtn'; //Yes
		private var _cancelShipBuildAlertClose:String       = 'CodeString.Shared.NoBtn'; //No
		private var _cancelShipBuildAlertTitle:String       = 'CodeString.Alert.CancelShip.Title'; //Cancel Ship Build
		private var _cancelBuildBtnText:String              = 'CodeString.Shared.CancelBuild'; //Cancel Build
		private var _cancelText:String                      = 'CodeString.Shared.CancelBtn'; //Cancel
		private var _cost:String                            = 'CodeString.Shared.Cost' //Cost
		private var _emptySlot:String                       = 'CodeString.Shipyard.EmptySlot'; //Empty
		private var _freeText:String                        = 'CodeString.Shared.Free';
		private var _getResourcesBtnText:String             = 'CodeString.Shared.GetResources'; //GET RESOURCES
		private var _noChange:String                        = 'CodeString.Shipyard.NoChanges'; // STATE: NO CHANGES
		private var _damagedShipyard:String                 = 'CodeString.Shipyard.Damaged'; //STATE: DAMAGED SHIPYARD
		private var _offlineString:String                   = 'CodeString.Shipyard.BtnStatus.Offline'; //OFFLINE
		private var _outOf:String                           = 'CodeString.Shared.OutOf'; //[[Number.MinValue]]/[[Number.MaxValue]]
		private var _overPowered:String                     = 'CodeString.Shipyard.Overpowered'; //Overpowered
		private var _powerUseTitle:String                   = 'CodeString.Shipyard.PowerUseTitle'; //Power Usage
		private var _refitShipBtnText:String                = 'CodeString.Shipyard.RefitShipBtn'; //Refit Ship
		private var _refitShipNowBtnText:String             = 'CodeString.Shipyard.RefitShipNowBtn' //Refit Ship Now
		private var _scrapShipBtnText:String                = 'CodeString.Shipyard.ScrapShipBtn'; // Scrap Ship
		private var _scrapShipBody:String                   = 'CodeString.Shipyard.ScrapShipBody'; // Are you sure you wish to scrap this ship?
		private var _selectHullBtnText:String               = 'CodeString.Shipyard.SelectHullBtn'; //SELECT HULL
		private var _shipBuildInProgressAlertBody:String    = 'CodeString.Alert.ShipBuildInProgress.Body'; //Are you sure you wish to cancel this ship build in progress?
		private var _shipBuildInProgressAlertTitle:String   = 'CodeString.Alert.ShipBuildInProgress.Title'; //Ship Build Inprogress
		private var _speedUpText:String                     = 'CodeString.Shared.SpeedUp'; //maxSpeed Up
		private var _startRefitBtnText:String               = 'CodeString.Shipyard.StartRefitBtn'; // Start Refit
		private var _stateCannotAfford:String               = 'CodeString.Shipyard.CannotAfford'; //STATE: CANNOT AFFORD
		private var _stateOverpowered:String                = 'CodeString.Shipyard.Overpowered'; //STATE: OVERPOWERED SHIP
		private var _stateNoWeapons:String                  = 'CodeString.Shipyard.NoWeapons'; //STATE: NO WEAPONS
		private var _stateStandingBy:String                 = 'CodeString.Shipyard.StandingBy'; //STATE: STANDING BY
		private var _title:String                           = 'CodeString.Shipyard.Title'; //SHIPYARD
		private var _okBtn:String                           = 'CodeString.Shared.OkBtn'; //OK
		private var _shipyardFullAlertTitle:String          = 'CodeString.Alert.FullShipyard.Title'; //Shipyard Full
		private var _shipyardFullAlertBody:String           = 'CodeString.Alert.FullShipyard.Body'; //Your Shipyard is full, Commander. Scrap ships to make space.
		private var _availableShipSlotsText:String          = 'CodeString.Shipyard.AvailableShipSlotsText'; //Available Ship Slots
		private var _changeShipNameAlertTitle:String 		= 'CodeString.Alert.ChangeShipName.Title'; //Change Fleet Name
		private var _changeShipNameAlertBody:String   		= 'CodeString.Alert.ChangeShipName.Body'; //Please enter a name for your fleet
		private var _changeShipNameAlertCancel:String 		= 'CodeString.Shared.CancelBtn'; //Cancel
		private var _changeShipNameAlertAccept:String 		= 'CodeString.Shared.OkBtn'; //Ok

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(825, 598);
			_bg.addTitle(_title, 239);
			_bg.x = -5;
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);
			addChild(_bg);

			_bgFlair = UIFactory.getBitmap('ShipyardBGBMD');
			_bgFlair.x = 22;
			_bgFlair.y = 81;
			addChild(_bgFlair);

			_schematicImage = new ImageComponent()
			_schematicImage.init(1000, 1256);
			addChild(_schematicImage);

			_shipPowerUsage = new ProgressBar();
			_shipPowerUsage.init(ProgressBar.HORIZONTAL, new Bitmap(new BitmapData(166, 19, true, 0xa52ea34a)), null, 0.01);
			_shipPowerUsage.setMinMax(0, 1);
			_shipPowerUsage.x = 330;
			_shipPowerUsage.y = 422;
			addChild(_shipPowerUsage);

			_powerUsageTitle = new Label(16, 0xFFFFFF, 166, 22);
			_powerUsageTitle.align = TextFormatAlign.CENTER;
			_powerUsageTitle.y = _shipPowerUsage.y - (_powerUsageTitle.height + 2);
			_powerUsageTitle.x = _shipPowerUsage.x;
			_powerUsageTitle.constrictTextToSize = false;
			_powerUsageTitle.text = _powerUseTitle;
			addChild(_powerUsageTitle);

			_powerUsage = new Label(13, 0xFFFFFF, 166, 22);
			_powerUsage.align = TextFormatAlign.CENTER;
			_powerUsage.y = _shipPowerUsage.y;
			_powerUsage.x = _shipPowerUsage.x;
			_powerUsage.constrictTextToSize = false;
			addChild(_powerUsage);

			var buildText:String;
			var buildNowText:String;

			buildText = (_refitShip) ? _refitShipBtnText : _build;
			buildNowText = (_refitShip) ? _refitShipNowBtnText : _buildNow;

			_buildComponent = new ActionComponent(new ButtonPrototype(buildText, onBuild), new ButtonPrototype(buildNowText, onBuildNow), new ButtonPrototype(_getResourcesBtnText, onClickCannotAffordResourceDialog),
												  new ButtonPrototype(buildNowText, popPaywall));
			_buildComponent.visible = false;
			_buildComponent.x = 549;
			_buildComponent.y = 547;
			addChild(_buildComponent);

			_buildInProgressComponent = new ActionInProgressComponent(new ButtonPrototype(_cancelText, onCancelBuild), new ButtonPrototype(_speedUpText, onSpeedUp));
			_buildInProgressComponent.visible = false;
			_buildInProgressComponent.x = 518;
			_buildInProgressComponent.y = 547;
			addChild(_buildInProgressComponent);

			_buildCostComponent = ObjectPool.get(ResourceComponent);
			_buildCostComponent.init(false, false, 35);
			_buildCostComponent.addMoreListener(onPurchaseMoreResources);
			_buildCostComponent.visible = false;
			_buildCostComponent.x = 535;
			_buildCostComponent.y = 465;
			addChild(_buildCostComponent);

			_scrapShipBtn = ButtonFactory.getBitmapButton('CancelBtnNeutralBMD', 0, 27, _scrapShipBtnText, 0xF58993, 'CancelBtnRollOverBMD', 'CancelBtnDownBMD');
			_scrapShipBtn.x = _buildInProgressComponent.x - (_scrapShipBtn.width + 5);
			_scrapShipBtn.y = _buildInProgressComponent.y + _buildInProgressComponent.height - (_scrapShipBtn.height + 12);
			_scrapShipBtn.addEventListener(MouseEvent.CLICK, onScrapShip, false, 0, true);
			addChild(_scrapShipBtn);
			_scrapShipBtn.visible = false;

			_selectHullBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 240, 41, 38, 47, _selectHullBtnText, LabelEnum.H1);
			addListener(_selectHullBtn, MouseEvent.CLICK, showHullSelect);
			addChild(_selectHullBtn);

			createProgressBar("_shipDpsBar", "_shipDpsLabel", "_shipDpsValue", 'shipDps', 552, 99);
			createProgressBar("_healthBar", "_healthLabel", "_healthValue", 'health', 552, 126);
			createProgressBar("_maxSpeedBar", "_maxSpeedLabel", "_maxSpeedValue", 'maxSpeed', 552, 153);
			createProgressBar("_rotationSpeedBar", "_rotationSpeedLabel", "_rotationSpeedValue", 'rotationSpeed', 552, 180);

			createProgressBar("_accelerationTimeBar", "_accelerationTimeLabel", "_accelerationTimeValue", 'accelerationTime', 552, 223);
			createProgressBar("_profileBar", "_profileLabel", "_profileValue", 'profile', 552, 250);
			createProgressBar("_evasionBar", "_evasionLabel", "_evasionValue", 'evasion', 552, 277);
			createProgressBar("_armorBar", "_armorLabel", "_armorValue", 'armor', 552, 304);
			createProgressBar("_maskingBar", "_maskingLabel", "_maskingValue", 'masking', 552, 332);

			createProgressBar("_mapSpeedBar", "_mapSpeedLabel", "_mapSpeedValue", 'mapSpeed', 552, 376);
			createProgressBar("_loadSpeedBar", "_loadSpeedLabel", "_loadSpeedValue", 'loadSpeed', 552, 403);
			createProgressBar("_cargoBar", "_cargoLabel", "_cargoValue", 'cargo', 552, 430);

			_shipPrototypeName = new Label(20, 0xe7e7e7)
			_shipPrototypeName.autoSize = TextFieldAutoSize.RIGHT;
			_shipPrototypeName.y = 52;
			_shipPrototypeName.x = 492;
			_shipPrototypeName.constrictTextToSize = false;
			addChild(_shipPrototypeName);
			
			_shipSchematicName = new Label(24, 0xe7e7e7)
			_shipSchematicName.autoSize = TextFieldAutoSize.RIGHT;
			_shipSchematicName.y = 82;
			_shipSchematicName.x = 492;
			_shipSchematicName.constrictTextToSize = false;
			addChild(_shipSchematicName);
			
			_changeShipNameBtn = UIFactory.getButton(ButtonEnum.EDIT);
			_changeShipNameBtn.addEventListener(MouseEvent.CLICK, onChangeShipName, false, 0, true);
			_changeShipNameBtn.x = 280;
			_changeShipNameBtn.y = 82;
			addChild(_changeShipNameBtn);

			_buildableStateText = new Label(18, 0xe7e7e7, 240, 40);
			_buildableStateText.align = TextFormatAlign.CENTER;
			_buildableStateText.y = 425;
			_buildableStateText.x = 86;
			_buildableStateText.constrictTextToSize = false;
			addChild(_buildableStateText);

			_availableShipSlotsTitle = new Label(16, 0xFFFFFF, 90, 22);
			_availableShipSlotsTitle.align = TextFormatAlign.CENTER;
			_availableShipSlotsTitle.y = 50;
			_availableShipSlotsTitle.x = 650;
			_availableShipSlotsTitle.constrictTextToSize = false;
			_availableShipSlotsTitle.text = _availableShipSlotsText;
			addChild(_availableShipSlotsTitle);
			
			var shipSlotsUsageColor:uint = 0xFFFFFF;
			
			if (presenter.builtShipCount >= 0.8 * presenter.maxAvailableShipSlots)
			{
				shipSlotsUsageColor = 0xFFFF00;
			}
			else if (presenter.builtShipCount == presenter.maxAvailableShipSlots)
			{
				shipSlotsUsageColor = 0xFF0000;
			}
			
			_availableShipSlots = new Label(16, shipSlotsUsageColor, 80, 22);
			_availableShipSlots.align = TextFormatAlign.CENTER;
			_availableShipSlots.y = _availableShipSlotsTitle.y;
			_availableShipSlots.x = _availableShipSlotsTitle.x + _availableShipSlotsTitle.width;
			_availableShipSlots.constrictTextToSize = false;
			_availableShipSlots.text = presenter.builtShipCount.toString() + " / " + presenter.maxAvailableShipSlots.toString();
			addChild(_availableShipSlots);
			
			_components = new Vector.<ComponentSelection>();
			_selectedIndex = -1;

			_prototypeLabels = [];
			_currentMassUsage = 0;
			_buildShipTimer = new Timer(1000);
			addListener(_buildShipTimer, TimerEvent.TIMER, updateTimer);

			_buildShipTransaction = presenter.shipyardTransaction;
			_currentBuildableState = GOOD_STATE;
			var state:int                 = REFIT_STATE
			if (_refitShip == null)
			{
				if (_buildShipTransaction != null)
				{
					state = BUILDING_STATE;
					presenter.currentShip = presenter.getBuildingShip();
				} else
				{
					state = BUILD_STATE;
					if (presenter.savedShip.prototypeVO)
						presenter.currentShip = presenter.savedShip;
				}
			} else
			{
				presenter.currentShip = _refitShip.clone();
				presenter.currentShip.id = _refitShip.id;
			}

			var hulls:Vector.<IPrototype> = presenter.shipPrototypes;
			if (hulls.length)
			{
				hulls.sort(orderItems);
				if (presenter.currentShip.prototypeVO == null)
					_defaultHull = hulls[0];
				else
					_defaultHull = presenter.currentShip.prototypeVO;
				presenter.currentShip.prototypeVO = _defaultHull;
			}

			presenter.addTransactionListener(transactionUpdate);
			updateTimer(null);

			_textHolder = new Sprite();
			addChild(_textHolder);

			selectSchematic(_defaultHull);
			setWindowState(state);

			addEffects();
			effectsIN();
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

		private function transactionUpdate( data:* = null ):void
		{
			_buildShipTransaction = presenter.shipyardTransaction;

			if (_buildShipTransaction != null)
			{
				setWindowState(BUILDING_STATE)
				updateTimer(null);
				if (!_buildShipTimer.running)
					_buildShipTimer.start();
			} else
			{
				updateTimer(null);
				if (_buildShipTimer.running)
					clearTimer();
			}

		}
		private function onChangeShipName( e:MouseEvent ):void
		{
			showInputAlert(_changeShipNameAlertTitle, _changeShipNameAlertBody, _changeShipNameAlertCancel, null, null, _changeShipNameAlertAccept, onChangedName, null, true, 20, presenter.currentShip.refitShipName);
		}
		
		private function onChangedName( newName:String ):void
		{
			if(newName.length == 0)
				return;
			
			setShipName(newName);
			if (presenter)
			{
				presenter.currentShip.setNewShipName(newName);
				if(presenter.currentShip.shipName != presenter.currentShip.refitShipName)
					updateInfo();
			}
			
		}
		
		private function setShipName( v:String ):void
		{
			if (_shipSchematicName)
				_shipSchematicName.text = v;
		}

		private function setWindowState( state:int ):void
		{
			if (_currentWindowState != state)
			{
				switch (state)
				{
					case BUILD_STATE:
						if (presenter.savedShip.prototypeVO)
							presenter.currentShip = presenter.savedShip;
						if (_buildShipTimer.running)
							_buildShipTimer.stop();
						_buildComponent.visible = true;
						_buildCostComponent.visible = true;
						_scrapShipBtn.visible = _buildInProgressComponent.visible = false;
						_selectHullBtn.enabled = true;
						_enableComponents = true;
						_changeShipNameBtn.visible = true;
						break;
					case BUILDING_STATE:
						presenter.currentShip = presenter.getBuildingShip();
						_defaultHull = presenter.currentShip.prototypeVO;
						_buildComponent.visible = false;
						_scrapShipBtn.visible = _buildCostComponent.visible = false;
						_buildInProgressComponent.visible = true;
						_selectHullBtn.enabled = false;
						_buildShipTimer.start();
						_enableComponents = false;
						_changeShipNameBtn.visible = true;
						break;
					case REFIT_STATE:
						_selectHullBtn.enabled = false;
						var shipBuildInProgress:Boolean = (_buildShipTransaction != null)
						_buildComponent.visible = !shipBuildInProgress;
						_scrapShipBtn.visible = (_refitShip.currentHealth == 1);
						_buildInProgressComponent.visible = shipBuildInProgress;
						_buildCostComponent.visible = !shipBuildInProgress;
						_enableComponents = true;
						_changeShipNameBtn.visible = true;
						break;
				}

				_currentWindowState = state;

				var len:uint = _components.length;
				var i:uint;
				for (i = 0; i < len; i++)
				{
					_components[i].enabled = _enableComponents;
				}

				len = _prototypeLabels.length;
				for (i = 0; i < len; i++)
				{
					removeListener(_prototypeLabels[i], MouseEvent.CLICK, onTextClicked);
					if (_enableComponents)
						addListener(_prototypeLabels[i], MouseEvent.CLICK, onTextClicked);
				}

				updateInfo();
			}
		}

		private function setBuildableState( state:int ):void
		{
			if (_currentBuildableState != state)
			{
				switch (state)
				{
					case OVER_POWERED_STATE:
						_buildComponent.enabled = false;
						_buildComponent.actionBtnText = _buildComponent.instantActionBtnText = _offlineString;
						_buildableStateText.textColor = 0xf04c4c;
						_buildableStateText.text = _stateOverpowered;
						break;
					case CANNOT_AFFORD_STATE:
						_buildComponent.enabled = true;
						_buildableStateText.textColor = 0xf04c4c;
						_buildableStateText.text = _stateCannotAfford;
						break;
					case NO_MODULES:
						_buildComponent.enabled = false;
						_buildComponent.actionBtnText = _buildComponent.instantActionBtnText = _offlineString;
						_buildableStateText.textColor = 0xf04c4c;
						_buildableStateText.text = _stateNoWeapons;
						break;
					case GOOD_STATE:
						_buildComponent.enabled = true;
						_buildableStateText.textColor = 0x2ea34a;
						_buildableStateText.text = _stateStandingBy;
						break;
					case NO_CHANGES:
						_buildComponent.enabled = false;
						_buildComponent.actionBtnText = _buildComponent.instantActionBtnText = _offlineString;
						_buildableStateText.textColor = 0xf04c4c;
						_buildableStateText.text = _noChange;
						break;
					case SHIPYARD_DAMAGED:
						_buildComponent.enabled = false;
						_buildComponent.actionBtnText = _buildComponent.instantActionBtnText = _offlineString;
						_buildableStateText.textColor = 0xf04c4c;
						_buildableStateText.text = _noChange;
						_buildableStateText.text = _damagedShipyard
						break;
				}
				_currentBuildableState = state;
			}
		}

		private function selectSchematic( schematic:IPrototype ):void
		{
			presenter.currentShip.prototypeVO = schematic;
			var currentHullAssetVO:AssetVO = presenter.getAssetVO(schematic);
			
			_shipSchematicName.text = presenter.currentShip.shipName;
			setSchematicImage(currentHullAssetVO.largeImage);

			for (var i:uint = 0; i < _prototypeLabels.length; ++i)
			{
				removeListener(_prototypeLabels[i], MouseEvent.CLICK, onTextClicked);
				_prototypeLabels[i].destroy();
				_textHolder.removeChild(_prototypeLabels[i]);
				_prototypeLabels[i] = null;
			}
			_prototypeLabels.length = 0;
			if(_shipSchematicName.text.length == 0)
			{
				_shipSchematicName.text = currentHullAssetVO.visibleName;
				_shipSchematicName.textColor = CommonFunctionUtil.getRarityColor(schematic.getValue('rarity'));
				
				_shipPrototypeName.visible = false;
			}
			else
			{
				_shipSchematicName.textColor = 0xe7e7e7;
				
				_shipPrototypeName.visible = true;
				_shipPrototypeName.text = currentHullAssetVO.visibleName;
				_shipPrototypeName.textColor = CommonFunctionUtil.getRarityColor(schematic.getValue('rarity'));
			}
			layoutComponents();
			onComponentSelected(null);

		}

		private function onTextClicked( e:MouseEvent ):void
		{
			var index:int = _prototypeLabels.indexOf(e.target);
			if (index != -1)
			{
				onSelectComponent(_components[index].slotName, index, _components[index]);
			}
		}

		private function showHullSelect( e:MouseEvent ):void
		{
			var hulls:Vector.<IPrototype>                = presenter.shipPrototypes;
			var componentSelectionView:ShipSchematicView = ShipSchematicView(showView(ShipSchematicView));
			componentSelectionView.addShips(hulls, selectSchematic);
		}

		private function onBuild( e:MouseEvent ):void
		{
			if (presenter.currentShip.prototypeVO)
			{
				if (presenter.canBuildNewShips || _currentWindowState == REFIT_STATE)
				{
					if (_currentWindowState == REFIT_STATE)
					{
						presenter.refitShip(presenter.currentShip, PurchaseTypeEnum.NORMAL);
						presenter.currentShip.refiting = true;
					} else
					{
						var ship:ShipVO = presenter.currentShip.clone();
						presenter.savedShip = presenter.currentShip;
						presenter.buildShip(ship, PurchaseTypeEnum.NORMAL);
					}
				} else
				{
					popFullDocksMessage();
				}
			}
		}

		private function onBuildNow( e:MouseEvent ):void
		{
			if (presenter.currentShip.prototypeVO)
			{
				if (presenter.canBuildNewShips || _currentWindowState == REFIT_STATE)
				{
					if (_currentRequirements && _currentRequirements.purchaseVO.canPurchaseWithPremium)
					{
						if (_currentWindowState == REFIT_STATE)
						{
							presenter.refitShip(presenter.currentShip, PurchaseTypeEnum.INSTANT);
							presenter.currentShip.refiting = false;
						} else
						{
							var ship:ShipVO = presenter.currentShip.clone();
							presenter.savedShip = presenter.currentShip;
							presenter.buildShip(ship, PurchaseTypeEnum.INSTANT);
						}
					}
				} else
				{
					popFullDocksMessage();
				}
			}
		}

		private function onBuildWithResourcePurchase():void
		{
			if (_currentWindowState == REFIT_STATE)
			{
				presenter.refitShip(presenter.currentShip, PurchaseTypeEnum.GET_RESOURCES);
				presenter.currentShip.refiting = true;
			} else
			{
				var ship:ShipVO = presenter.currentShip.clone();
				presenter.savedShip = presenter.currentShip;
				presenter.buildShip(ship, PurchaseTypeEnum.GET_RESOURCES);
			}
		}

		protected function onClickCannotAffordResourceDialog( e:MouseEvent ):void
		{
			if (presenter.canBuildNewShips || _currentWindowState == REFIT_STATE)
			{
				if (_currentRequirements.purchaseVO.canPurchaseResourcesWithPremium)
				{
					var purchaseVO:PurchaseVO  = _currentRequirements.purchaseVO;
					var view:ResourceModalView = ResourceModalView(_viewFactory.createView(ResourceModalView));
					_viewFactory.notify(view);
					view.setUp(purchaseVO.creditsAmountShort, purchaseVO.alloyAmountShort, purchaseVO.energyAmountShort, purchaseVO.syntheticAmountShort, 'CodeString.Alert.BuyResources.Title', 'CodeString.Alert.BuyResources.Body',
							   false, onBuildWithResourcePurchase, purchaseVO.resourcePremiumCost);
				} else
					popPaywall();
			} else
			{
				popFullDocksMessage();
			}
		}

		private function onCancelBuild( e:MouseEvent ):void
		{
			var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
			buttons.push(new ButtonPrototype(_cancelShipBuildAlertCancelBuild, cancelBuildConfirmed, null, true, ButtonEnum.GREEN_A));
			buttons.push(new ButtonPrototype(_cancelShipBuildAlertClose));
			showConfirmation(_cancelShipBuildAlertTitle, _cancelShipBuildAlertBody, buttons);
		}

		private function cancelBuildConfirmed():void
		{
			var transaction:TransactionVO = presenter.shipyardTransaction;
			if (transaction)
			{
				presenter.cancelTransaction(transaction);
			}
		}

		private function popFullDocksMessage():void
		{
			var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
			buttons.push(new ButtonPrototype(_okBtn, null, null, true, ButtonEnum.GREEN_A));
			showConfirmation(_shipyardFullAlertTitle, _shipyardFullAlertBody, buttons);
		}

		private function openStoreToTransaction():void
		{
			var transaction:TransactionVO = presenter.shipyardTransaction;
			if (transaction)
			{
				var nStoreView:StoreView = StoreView(_viewFactory.createView(StoreView));
				_viewFactory.notify(nStoreView);
				nStoreView.setSelectedTransaction(transaction);
				destroy();
			}
		}

		private function onScrapShip( e:MouseEvent ):void
		{
			var selectedAsset:String   = _refitShip.asset;
			var selectedLevel:int      = _refitShip.getValue('level');
			var creditRefund:int       = _refitShip.scrapCreditsCost
			var alloyRefund:int        = _refitShip.scrapAlloyCost;
			var energyRefund:int       = _refitShip.scrapEnergyCost;
			var syntheticRefund:int    = _refitShip.scrapSyntheticCost;

			var view:ResourceModalView = ResourceModalView(_viewFactory.createView(ResourceModalView));
			_viewFactory.notify(view);
			view.setUp(Math.floor(creditRefund), Math.floor(alloyRefund),
					   Math.floor(energyRefund), Math.floor(syntheticRefund), _scrapShipBtnText, 'CodeString.BuildRecycle.Refund', true, scrapShipConfirmed, 0, _scrapShipBtnText);

			//showAlert(_scrapShipBtnText, _scrapShipBody, _cancelShipBuildAlertClose, null, null, _cancelShipBuildAlertCancelBuild, scrapShipConfirmed, null);
		}

		private function scrapShipConfirmed():void
		{
			presenter.recycleShip(_refitShip);
			destroy();
		}

		private function onSpeedUp( e:MouseEvent ):void
		{
			openStoreToTransaction();
		}

		private function onPurchaseMoreResources( type:String ):void
		{
			var nStoreView:StoreView = StoreView(_viewFactory.createView(StoreView));
			_viewFactory.notify(nStoreView);
			switch (type)
			{
				case CurrencyEnum.ALLOY:
					nStoreView.openToResourcesAndFilter(StoreView.FILTER_ALLOY);
					break;
				case CurrencyEnum.CREDIT:
					nStoreView.openToResourcesAndFilter(StoreView.FILTER_CREDITS);
					break;
				case CurrencyEnum.ENERGY:
					nStoreView.openToResourcesAndFilter(StoreView.FILTER_ENERGY);
					break;
				case CurrencyEnum.SYNTHETIC:
					nStoreView.openToResourcesAndFilter(StoreView.FILTER_SYNTHETIC);
					break;
			}
		}

		private function updateInfo():void
		{
			var previousMassUsage:Number = _currentMassUsage;

			var currentShip:ShipVO       = presenter.currentShip;

			var shipTotalPower:int       = currentShip.power;
			var creditCost:int           = currentShip.creditsCost;
			var alloyCost:int            = currentShip.alloyCost;
			var energyCost:int           = currentShip.energyCost;
			var syntheticCost:int        = currentShip.syntheticCost;
			var buildTime:int            = currentShip.buildTimeSeconds;
			var massUsage:Number         = currentShip.powerUsage;

			var isRefitChanged:Boolean   = false;
			if (_currentWindowState == REFIT_STATE)
			{
				var oldModules:Dictionary = presenter.currentShip.modules;
				var newModules:Dictionary = presenter.currentShip.refitModules;

				for (var slot:String in newModules)
				{
					var module:IPrototype    = newModules[slot];
					var oldModule:IPrototype = oldModules.hasOwnProperty(slot) ? oldModules[slot] : null;

					if (oldModule && oldModule.name == module.name || (oldModule == null && (module == null || module == ShipVO.EMPTY_SLOT)))
						continue;

					isRefitChanged = true;
				}
				if(presenter.currentShip.shipName != presenter.currentShip.refitShipName && presenter.currentShip.refitShipName.length>0)
				{
					isRefitChanged = true;
				}
			}

			setBarValue("shipDps", false, false);
			setBarValue("health", true, false);
			setBarValue("maxSpeed", true, false);
			setBarValue("rotationSpeed", true, false);
			setBarValue("accelerationTime", false, false);
			setBarValue("profile", true, true);
			setBarValue("evasion", true, true);
			setBarValue("armor", true, true);
			setBarValue("masking", true, true);
			setBarValue("mapSpeed", true, false);
			setBarValue("loadSpeed", true, false);
			setBarValue("cargo", true, false);

			_powerUsage.setTextWithTokens(_outOf, {'[[Number.MinValue]]':massUsage, '[[Number.MaxValue]]':shipTotalPower});
			_currentMassUsage = massUsage / shipTotalPower;
			_shipPowerUsage.amount = _currentMassUsage;
			if (previousMassUsage <= 1 && _currentMassUsage > 1)
				_shipPowerUsage.setOverlay(new Bitmap(new BitmapData(166, 19, true, 0x99ff0000)));
			else if (previousMassUsage > 1 && _currentMassUsage <= 1)
				_shipPowerUsage.setOverlay(new Bitmap(new BitmapData(166, 19, true, 0xa52ea34a)));

			_currentRequirements = presenter.canBuild(currentShip);

			_buildCostComponent.updateCost(alloyCost, (_currentRequirements.purchaseVO.alloyAmountShort == 0), CurrencyEnum.ALLOY);
			_buildCostComponent.updateCost(creditCost, (_currentRequirements.purchaseVO.creditsAmountShort == 0), CurrencyEnum.CREDIT);
			_buildCostComponent.updateCost(energyCost, (_currentRequirements.purchaseVO.energyAmountShort == 0), CurrencyEnum.ENERGY);
			_buildCostComponent.updateCost(syntheticCost, (_currentRequirements.purchaseVO.syntheticAmountShort == 0), CurrencyEnum.SYNTHETIC);

			var premiumCost:int          = _currentRequirements.purchaseVO.premium;
			_buildComponent.instantCost = premiumCost;

			var modules:Dictionary       = currentShip.modules;
			var numWeapons:int           = 0;
			var slots:Array              = currentShip.slots;

			for (var i:int = 0; i < slots.length; i++)
			{
				slot = slots[i];
				if ((modules.hasOwnProperty(slot) && modules[slot] != null && modules[slot] != ShipVO.EMPTY_SLOT &&
					(newModules == null || !newModules.hasOwnProperty(slot) || newModules[slot] != ShipVO.EMPTY_SLOT)) ||
					(newModules && newModules.hasOwnProperty(slot) && newModules[slot] != null && newModules[slot] != ShipVO.EMPTY_SLOT))
				{
					if (slot.indexOf(SlotComponentEnum.SLOT_TYPE_WEAPON) != -1)
					{
						numWeapons++;
					}
				}
			}

			if (presenter.isShipyardRepairing())
				setBuildableState(SHIPYARD_DAMAGED);
			else if (numWeapons == 0)
				setBuildableState(NO_MODULES);
			else if (_currentMassUsage > 1)
				setBuildableState(OVER_POWERED_STATE);
			else if (_currentMassUsage < 1 && _currentRequirements.purchaseVO.canPurchase != true)
				setBuildableState(CANNOT_AFFORD_STATE);
			else if (_currentWindowState == REFIT_STATE && !isRefitChanged)
				setBuildableState(NO_CHANGES);
			else if (_currentBuildableState != GOOD_STATE)
				setBuildableState(GOOD_STATE);

			_buildComponent.timeCost = buildTime;
			_buildComponent.requirements = _currentRequirements;
			
			_availableShipSlots.text = presenter.builtShipCount.toString() + " / " + presenter.maxAvailableShipSlots.toString();
		}

		private function setBarValue( stat:String, useStatCalc:Boolean, rating:Boolean ):void
		{
			// Get the stat value by calc or directly as needed
			var statValue:Number;
			if (useStatCalc)
				statValue = StatCalcUtil.entityStatCalc(presenter.currentShip, stat);
			else
				statValue = presenter.currentShip[stat];

			// Format the value and turn it into a string
			var statProto:IPrototype = presenter.getStatPrototypeByName(stat);
			var statString:String    = StringUtil.formatValue(String(statValue), statProto, "flat", "base");
			this["_" + stat + "Value"].setTextWithTokens(statProto.getValue("valueLocKey"), {'[[Value]]':statString});

			// Show modifier if this was a rating
			if (rating)
			{
				var loc:Localization     = Localization.instance;
				var modProto:IPrototype  = presenter.getStatPrototypeByName("genericPercent");
				var percentString:String = modProto.getValue("valueLocKey");
				var modValue:Number      = CommonFunctionUtil.ratingToModifier(statValue);
				var modString:String     = StringUtil.formatValue(String(modValue), modProto, "flat", "base");
				this["_" + stat + "Value"].text += loc.getStringWithTokens(percentString, {'[[Value]]':modString});
			}

			// Set the bar value
			this["_" + stat + "Bar"].amount = statValue;
		}

		private function updateTimer( e:TimerEvent ):void
		{
			if (presenter.shipyardTransaction)
			{
				var buildTime:int = presenter.shipyardTransaction.timeRemainingMS;
				_buildInProgressComponent.timeRemaining = buildTime;
				if (buildTime <= 0)
					_buildShipTimer.stop();
			} else
				clearTimer();
		}

		private function clearTimer():void
		{
			_buildShipTimer.stop();
			if (presenter.refittingShip)
			{
				//refit is done or the player cancelled it. allow refit to continue
				presenter.currentShip = presenter.refittingShip;
				_refitShip = presenter.currentShip;
				_refitShip.calculateCosts();
				setWindowState(REFIT_STATE);
			} else if (_refitShip)
				setWindowState(REFIT_STATE);
			else
				setWindowState(BUILD_STATE);
		}

		private function setSchematicImage( imgUrl:String ):void
		{
			presenter.loadIcon(imgUrl, loadedSchematicImage);
		}

		private function layoutComponents():void
		{
			for (var i:int = 0; i < _components.length; i++)
			{
				_components[i].destroy();
				_schematicImage.removeChild(_components[i]);
			}
			_components.length = 0;

			var prototypeVO:IPrototype      = presenter.currentShip.prototypeVO;
			var slots:Array                 = prototypeVO.getValue('slots');
			var slotPrototype:IPrototype;
			var shipModules:Dictionary      = presenter.currentShip.modules;
			var shipRefitModules:Dictionary = presenter.currentShip.refitModules;
			var type:String;
			var cs:ComponentSelection;
			for (i = 0; i < slots.length; i++)
			{
				if (slots[i].indexOf(SlotComponentEnum.SLOT_TYPE_TECH) != -1)
					type = SlotComponentEnum.SLOT_TYPE_TECH;
				else if (slots[i].indexOf(SlotComponentEnum.SLOT_TYPE_DEFENSE) != -1)
					type = SlotComponentEnum.SLOT_TYPE_DEFENSE;
				else if (slots[i].indexOf(SlotComponentEnum.SLOT_TYPE_SPECIAL) != -1)
					type = SlotComponentEnum.SLOT_TYPE_SPECIAL;
				else if (slots[i].indexOf(SlotComponentEnum.SLOT_TYPE_DRONE) != -1)
					type = SlotComponentEnum.SLOT_TYPE_SPECIAL;
				else if (slots[i].indexOf(SlotComponentEnum.SLOT_TYPE_ARC) != -1)
					type = SlotComponentEnum.SLOT_TYPE_SPECIAL;
				else if (slots[i].indexOf(SlotComponentEnum.SLOT_TYPE_WEAPON) != -1)
					type = SlotComponentEnum.SLOT_TYPE_WEAPON;
				else if (slots[i].indexOf(SlotComponentEnum.SLOT_TYPE_STRUCTURE) != -1)
					type = SlotComponentEnum.SLOT_TYPE_STRUCTURE;

				slotPrototype = presenter.getSlotPrototype(slots[i]);
				cs = new ComponentSelection(type, slots[i], i);
				cs.x = slotPrototype.getValue("slotX");
				cs.y = slotPrototype.getValue("slotY");
				cs.onSelectComponent.add(onSelectComponent);
				cs.onHover.add(highlightPrototypeLabel);
				cs.enabled = _enableComponents;
				if (presenter.currentShip)
				{
					if (shipRefitModules.hasOwnProperty(slots[i]))
					{
						if (shipRefitModules[slots[i]] != null)
							cs.selectedComponent = shipRefitModules[slots[i]];
					} else
						cs.selectedComponent = shipModules[slots[i]];
				}

				_tooltips.addTooltip(cs, this, cs.tooltip, '', 250, 180, 14);

				_components.push(cs);
				_schematicImage.addChild(cs);
			}
		}

		private function loadedSchematicImage( asset:BitmapData ):void
		{
			if (_schematicImage)
			{
				_schematicImage.clearBitmap();
				_schematicImage.onImageLoaded(asset);
				_schematicImage.x = 380 + (467 - _schematicImage.width) * 0.5;
				_schematicImage.y = 170 + (308 - _schematicImage.height) * 0.5;
				_schematicImage.rotation = 90;

				if (_loadCallback != null)
					_loadCallback();
			}
		}

		private function onSelectComponent( slotId:String, index:uint, currentComponentSelection:ComponentSelection ):void
		{
			var slotPrototype:IPrototype          = presenter.getSlotPrototype(slotId);
			var basicSlotType:String              = slotPrototype.getValue("slotType");
			var constructionView:ConstructionView = ConstructionView(_viewFactory.createView(ConstructionView));
			constructionView.openOn(ConstructionView.COMPONENT, basicSlotType, slotId);
			_viewFactory.notify(constructionView);
			_selectedIndex = index;
		}

		public function onNoSelection():void
		{
			_selectedIndex = -1;
		}

		public function onComponentSelected( component:IPrototype ):void
		{
			var shipPrototype:IPrototype    = presenter.currentShip.prototypeVO;
			var slots:Array                 = shipPrototype.getValue('slots');
			var defenseIndex:int            = 0;
			var specialIndex:int            = 0;
			var techIndex:int               = 0;
			var weaponIndex:int             = 0;
			var structureIndex:int          = 0;
			var x:int                       = 0;
			var y:int                       = 0;
			var slotName:String;
			var moduleName:String;

			if (_selectedIndex != -1)
			{
				slotName = slots[_selectedIndex];
				if (_currentWindowState == REFIT_STATE)
					presenter.currentShip.equipRefitModule(component, slotName);
				else
					presenter.currentShip.equipModule(component, slotName);

				_components[_selectedIndex].selectedComponent = component;
				_selectedIndex = -1;
			}

			var shipModules:Dictionary      = presenter.currentShip.modules;
			var shipRefitModules:Dictionary = presenter.currentShip.refitModules;

			for (var i:int = 0; i < slots.length; i++)
			{
				slotName = slots[i];

				if (_components[i].uiAsset != '')
				{
					moduleName = AssetModel.instance.getEntityData(_components[i].uiAsset).visibleName;
				} else
					moduleName = _components[i].uiAsset;

				if (moduleName == '')
					moduleName = _emptySlot;

				if (moduleName != null)
				{
					if (slotName.indexOf(SlotComponentEnum.SLOT_TYPE_WEAPON) != -1)
					{
						x = 59;
						y = 466 + (15 * weaponIndex);
						++weaponIndex;
					} else if (slotName.indexOf(SlotComponentEnum.SLOT_TYPE_DEFENSE) != -1)
					{
						x = 214;
						y = 466 + (15 * defenseIndex);
						++defenseIndex;
					} else if (slotName.indexOf(SlotComponentEnum.SLOT_TYPE_TECH) != -1)
					{
						x = 371;
						y = 466 + (15 * techIndex);
						++techIndex;
					} else if (slots[i].indexOf(SlotComponentEnum.SLOT_TYPE_STRUCTURE) != -1)
					{
						x = 214;
						y = 563 + (15 * structureIndex);
						++structureIndex;
					} else //if (slotName.indexOf(SlotComponentEnum.SLOT_TYPE_SPECIAL) != -1)
					{
						x = 59;
						y = 561 + (15 * specialIndex);
						++specialIndex;
					}

					if (_prototypeLabels[i] == null)
					{
						_prototypeLabels[i] = new Label(11, 0xe7e7e7, 135, 20, true, 1);
						_prototypeLabels[i].align = TextFormatAlign.LEFT;
						_prototypeLabels[i].mouseEnabled = true;

						if (_enableComponents)
							addListener(_prototypeLabels[i], MouseEvent.CLICK, onTextClicked);
						addListener(_prototypeLabels[i], MouseEvent.ROLL_OVER, onTextRollOver);
						addListener(_prototypeLabels[i], MouseEvent.ROLL_OUT, onTextRollOut);
						_textHolder.addChild(_prototypeLabels[i]);
					}
					_prototypeLabels[i].text = moduleName;
					_prototypeLabels[i].textColor = _components[i].rarityColor;
					_prototypeLabels[i].x = x;
					_prototypeLabels[i].y = y;

				} else if (_prototypeLabels[i] != null)
				{
					_prototypeLabels[i].destroy();
					_textHolder.removeChild(_prototypeLabels[i]);
					_prototypeLabels[i] = null;
				}
				moduleName = '';
			}
			updateInfo();
		}

		private function onTextRollOver( e:MouseEvent ):void
		{
			var index:int = _prototypeLabels.indexOf(e.target);
			if (index != -1)
			{
				Label(e.target).textColor = 0xb3ddf2;
				_components[index].onOutsideRollOver();
			}
		}

		private function onTextRollOut( e:MouseEvent ):void
		{
			var index:int = _prototypeLabels.indexOf(e.target);
			if (index != -1)
			{
				Label(e.target).textColor = _components[index].rarityColor;
				_components[index].onOutsideRollOut();
			}
		}

		private function highlightPrototypeLabel( rollover:Boolean, index:uint ):void
		{
			if (_prototypeLabels[index])
			{
				var color:uint;
				if (rollover)
					color = 0xb3ddf2;
				else
					color = _components[index].rarityColor;

				_prototypeLabels[index].textColor = color;
			}
		}

		private function createProgressBar( barRef:String, labelRef:String, valueRef:String, protoName:String, x:int, y:int ):void
		{
			var statProto:IPrototype   = presenter.getStatPrototypeByName(protoName);
			var defaultMaxValue:Number = presenter.getConstantPrototypeValueByName("interfaceCalibrationDefaultStatValue");
			var maxValue:Number        = statProto.getUnsafeValue("stdMax");
			maxValue = (maxValue) ? maxValue : defaultMaxValue;

			this[barRef] = UIFactory.getProgressBar(UIFactory.getPanel(PanelEnum.STATBAR, 248, 15), UIFactory.getPanel(PanelEnum.STATBAR_CONTAINER, 256, 23), 0, maxValue, 0, x, y);
			addChild(this[barRef]);

			this[labelRef] = new Label(12, 0xFFFFFF, 248, 25, true, 1);
			this[labelRef].align = TextFormatAlign.LEFT;
			this[labelRef].text = statProto.getValue("lableLocKey");
			this[labelRef].y = y + 1;
			this[labelRef].x = x + 3;
			this[labelRef].constrictTextToSize = false;
			addChild(this[labelRef]);

			this[valueRef] = new Label(12, 0xFFFFFF, 248, 25, true, 1);
			this[valueRef].align = TextFormatAlign.RIGHT;
			this[valueRef].y = y + 1;
			this[valueRef].x = x + 3;
			this[valueRef].constrictTextToSize = false;
			addChild(this[valueRef]);
		}

		private function popPaywall( e:MouseEvent = null ):void
		{
			CommonFunctionUtil.popPaywall();
		}

		public function addLoadCallback( callback:Function ):void  { _loadCallback = callback; }

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		public function get components():Vector.<ComponentSelection>  { return _components; }
		[Inject]
		public function set presenter( value:IShipyardPresenter ):void  { _presenter = value; }
		public function get presenter():IShipyardPresenter  { return IShipyardPresenter(_presenter); }
		public function set refitShip( ship:ShipVO ):void
		{
			_refitShip = ship;
			_refitShip.calculateCosts();
		}

		[Inject]
		public function set tooltips( value:Tooltips ):void  { _tooltips = value; }
		override public function get typeUnique():Boolean  { return false; }

		override public function destroy():void
		{
			presenter.removeTransactionListener(transactionUpdate);

			if (_buildShipTimer.running)
				_buildShipTimer.stop();

			_buildShipTimer = null;

			var i:uint;
			var len:uint = _prototypeLabels.length;
			for (i = 0; i < len; ++i)
			{
				removeListener(_prototypeLabels[i], MouseEvent.CLICK, onTextClicked);
				_prototypeLabels[i].destroy();
				_textHolder.removeChild(_prototypeLabels[i]);
				_prototypeLabels[i] = null;
			}
			_prototypeLabels.length = 0;

			len = _components.length;
			for (i = 0; i < len; ++i)
			{
				_components[i].destroy();
				_schematicImage.removeChild(_components[i]);
			}
			_components.length = 0;

			super.destroy();
			if (_refitShip)
			{
				_refitShip = null;
			}
			
			if (_changeShipNameBtn)
				_changeShipNameBtn.destroy();
			
			_changeShipNameBtn = null;

			_buildComponent.destroy();
			_buildComponent = null;

			_buildInProgressComponent.destroy();
			_buildInProgressComponent = null;

			_buildCostComponent.destroy();
			_buildCostComponent = null;

			_schematicImage.destroy();
			_schematicImage = null;

			_selectHullBtn.destroy();
			_selectHullBtn = null;

			_bg = null;

			_textHolder = null;

			_powerUsageTitle.destroy();
			_powerUsageTitle = null;

			_shipPowerUsage.destroy();
			_shipPowerUsage = null;

			_powerUsage.destroy();
			_powerUsage = null;

			_shipPrototypeName.destroy();
			_shipPrototypeName = null;
			
			_shipSchematicName.destroy();
			_shipSchematicName = null;

			_shipDpsLabel.destroy();
			_shipDpsLabel = null;

			_healthLabel.destroy();
			_healthLabel = null;

			_maxSpeedLabel.destroy();
			_maxSpeedLabel = null;

			_rotationSpeedLabel.destroy();
			_rotationSpeedLabel = null;

			_maskingLabel.destroy();
			_maskingLabel = null;

			_armorLabel.destroy();
			_armorLabel = null;

			_profileLabel.destroy();
			_profileLabel = null;

			_evasionLabel.destroy();
			_evasionLabel = null;

			_mapSpeedLabel.destroy();
			_mapSpeedLabel = null;

			_loadSpeedLabel.destroy();
			_loadSpeedLabel = null;

			_cargoLabel.destroy();
			_cargoLabel = null;

			_shipDpsValue.destroy();
			_shipDpsValue = null;

			_healthValue.destroy();
			_healthValue = null;

			_maxSpeedValue.destroy();
			_maxSpeedValue = null;

			_rotationSpeedValue.destroy();
			_rotationSpeedValue = null;

			_maskingValue.destroy();
			_maskingValue = null;

			_armorValue.destroy();
			_armorValue = null;

			_profileValue.destroy();
			_profileValue = null;

			_evasionValue.destroy();
			_evasionValue = null;

			_mapSpeedValue.destroy();
			_mapSpeedValue = null;

			_loadSpeedValue.destroy();
			_loadSpeedValue = null;

			_cargoValue.destroy();
			_cargoValue = null;

			_shipDpsBar.destroy();
			_shipDpsBar = null;

			_healthBar.destroy();
			_healthBar = null;

			_maxSpeedBar.destroy();
			_maxSpeedBar = null;

			_rotationSpeedBar.destroy();
			_rotationSpeedBar = null;

			_maskingBar.destroy();
			_maskingBar = null;

			_armorBar.destroy();
			_armorBar = null;

			_profileBar.destroy();
			_profileBar = null;

			_evasionBar.destroy();
			_evasionBar = null;

			_mapSpeedBar.destroy();
			_mapSpeedBar = null;

			_loadSpeedBar.destroy();
			_loadSpeedBar = null;

			_cargoBar.destroy();
			_cargoBar = null;

			_tooltips.removeTooltip(null, this);
			_tooltips = null;
			
			_availableShipSlotsTitle.destroy();
			_availableShipSlotsTitle = null;
			
			_availableShipSlots.destroy();
			_availableShipSlots = null;
		}
	}
}


