package com.ui.modal.dock
{
	import com.controller.transaction.requirements.PurchaseVO;
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.CurrencyEnum;
	import com.enum.FleetStateEnum;
	import com.enum.SlotComponentEnum;
	import com.enum.ToastEnum;
	import com.enum.server.PurchaseTypeEnum;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.transaction.TransactionVO;
	import com.presenter.starbase.IFleetPresenter;
	import com.ui.UIFactory;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ActionComponent;
	import com.ui.core.component.misc.ActionInProgressComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.hud.shared.command.ResourceComponent;
	import com.ui.modal.information.ResourceModalView;
	import com.ui.modal.shipyard.ShipyardView;
	import com.ui.modal.store.StoreView;
	import com.util.CommonFunctionUtil;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	import org.adobe.utils.StringUtil;
	import org.shared.ObjectPool;

	public class DockView extends View
	{
		private var DEFAULT_STATE:int                  = 0;
		private var REPAIR_STATE:int                   = 1;
		private var NEEDS_REPAIR_STATE:int             = 2;

		private var _bg:DefaultWindowBG;

		private var _fleetSelection:FleetSelection;

		private var _fleetInfoBG:Sprite;
		private var _fleetStatsBG:Sprite;

		private var _nameBG:ScaleBitmap;
		private var _ratingBG:ScaleBitmap;

		private var _powerSpent:ProgressBar;
		private var _fleetDpsBar:ProgressBar;
		private var _fleetHealthBar:ProgressBar;
		private var _fleetCargoBar:ProgressBar;
		private var _fleetMapSpeedBar:ProgressBar;

		private var _repairComponent:ActionComponent;
		private var _repairInProgressComponent:ActionInProgressComponent;
		private var _repairCostComponent:ResourceComponent;

		private var _changeFleetNameBtn:BitmapButton;
		private var _docksBtnTwo:BitmapButton;
		private var _docksBtnOne:BitmapButton;
		private var _shipActionBtn:BitmapButton;
		private var _shipRefitBtn:BitmapButton;

		private var _powerUsedText:Label;
		private var _fleetName:Label;
		private var _statusText:Label;
		private var _statusInfoText:Label;
		private var _subTitle:Label;
		private var _fleetNameLabel:Label;
		private var _fleetRatingLabel:Label;
		private var _fleetPowerLabel:Label;
		private var _fleetRatingText:Label;
		private var _fleetDpsLabel:Label;
		private var _fleetHealthLabel:Label;
		private var _fleetCargoLabel:Label;
		private var _fleetMapSpeedLabel:Label;
		private var _fleetDpsValue:Label;
		private var _fleetHealthValue:Label;
		private var _fleetCargoValue:Label;
		private var _fleetMapSpeedValue:Label;
		private var _fleetDamageTitle:Label;
		private var _fleetDamage:Label;

		private var _fleets:Vector.<FleetVO>;
		private var _shipButtons:Vector.<ShipButton>;

		private var _selectedShipButton:ShipButton;

		private var _redFilter:ColorMatrixFilter;
		private var _greenFilter:ColorMatrixFilter;
		private var _currentFilter:ColorMatrixFilter;

		private var _currentState:int;
		private var _currentRepairTime:int;

		private var _selectedFleet:FleetVO;

		private var _timer:Timer;
		private var _repairTransaction:TransactionVO;

		private var _currentRequirements:RequirementVO;

		protected var _speedUpBtnText:String           = 'CodeString.Shared.SpeedUp';
		protected var _cancelBtnText:String            = 'CodeString.Shared.CancelBtn';

		private var _titleText:String                  = 'CodeString.Docks.Title'; //DOCKS
		private var _level:String                      = 'CodeString.Shared.Level'; //Level [[Number.Level]]
		private var _mapSpeedText:String               = 'CodeString.Shared.MapSpeed'; // Map Speed [[Number.WorldMapSpeed]]
		private var _cargoText:String                  = 'CodeString.Shared.Cargo'; //Cargo [[Number.MaxCargoCount]]
		private var _cancelRepair:String               = 'CodeString.Shared.CancelBtn'; //Cancel
		private var _repair:String                     = 'CodeString.Docks.RepairBtn'; //Repair
		private var _repairNow:String                  = 'CodeString.Docks.RepairNowBtn'; //Repair Now
		private var _launch:String                     = 'CodeString.Docks.LaunchFleetBtn'; //Launch Fleet
		private var _defend:String                     = 'CodeString.Docks.DefendBaseBtn'; //Defend Base
		private var _offline:String                    = 'CodeString.Docks.OfflineBtn'; //Offline
		private var _noFlagship:String                 = 'CodeString.Docks.NoFlagShipBtn'; //No Flagship
		private var _needToRepair:String               = 'CodeString.Docks.NeedToRepairBtn'; //Need To Repair
		private var _recall:String                     = 'CodeString.Docks.RecallFleetBtn'; //Recall Fleet
		private var _gotoFleet:String                  = 'CodeString.Docks.GotoFleetBtn'; //Goto Fleet
		private var _outOfString:String                = 'CodeString.Shared.OutOf'; //[[Number.MinValue]]/[[Number.MaxValue]]
		private var _shipyardBusyAlertTitle:String     = 'CodeString.Alert.ShipyardBusy.Title'; //Shipyard Busy
		private var _shipyardBusyAlertBody:String      = 'CodeString.Alert.ShipyardBusy.Body'; //Your Shipyard is currently Busy. Would you like to speed up it's current transaction?
		private var _changeFleetNameAlertTitle:String  = 'CodeString.Alert.ChangeFleetName.Title'; //Change Fleet Name
		private var _changeFleetNameAlertBody:String   = 'CodeString.Alert.ChangeFleetName.Body'; //Please enter a name for your fleet
		private var _changeFleetNameAlertCancel:String = 'CodeString.Shared.CancelBtn'; //Cancel
		private var _changeFleetNameAlertAccept:String = 'CodeString.Shared.OkBtn'; //Ok
		private var _noFleetAlertTitle:String          = 'CodeString.Alert.NoShips.Title'; //No Unassigned Ships
		private var _noFleetAlertBody:String           = 'CodeString.Alert.NoShips.Body'; //Sorry but you have no unassigned ships to assign to fleets, but you can build more at your shipyard!
		private var _noFleetAlertClose:String          = 'CodeString.Shared.CloseBtn'; //Close
		private var _noFleetAlertOpenShipyard:String   = 'CodeString.Alert.NoShips.OpenShipyardBtn'; //Open Shipyard
		private var _speedUpText:String                = 'CodeString.Shared.SpeedUp'; //Speed Up
		private var _readyStatusText:String            = 'CodeString.Docks.Status.Ready'; //READY!
		private var _offlineStatusText:String          = 'CodeString.Docks.Status.Offline'; //OFFLINE!
		private var _BattleStatusText:String           = 'CodeString.Docks.Status.InCombat'; //IN COMBAT!
		private var _statusTitle:String                = 'CodeString.Docks.Status'; //STATUS
		private var _statusStandingBy:String           = 'CodeString.Docks.Status.StandingBy'; //STANDING BY!
		private var _damageTitleText:String            = 'CodeString.Shared.DamageTitle'; //Damage
		private var _healthTitleText:String            = 'CodeString.Shared.HealthTitle'; //Health
		private var _cargoTitleText:String             = 'CodeString.Shared.CargoTitle'; //Cargo
		private var _loadSpeedTitleText:String         = 'CodeString.Shared.LoadSpeedTitle'; //Load Speed
		private var _mapSpeedTitleText:String          = 'CodeString.Shared.MapSpeedTitle'; //Map Speed
		private var _percentText:String                = 'CodeString.Shared.Percent'; // [[Number.PercentValue]]%
		private var _auPerHr:String                    = 'CodeString.Shared.AuPerHr'; //[[Number.ValuePerHr]] au/h
		private var _perSecond:String                  = 'CodeString.Shared.PerSecond'; //[[Number.ValuePerSecond]]/s
		private var _alertBodyBuyResources:String      = 'CodeString.Alert.BuyResources.Body';
		private var _alertHeadingBuyResources:String   = 'CodeString.Alert.BuyResources.Title';

		private var _remove:String                     = 'CodeString.Docks.ShipSelection.Remove'; //Remove
		private var _add:String                        = 'CodeString.Docks.ShipSelection.Add'; //Select
		private var _refitShipBtnText:String           = 'CodeString.Shipyard.RefitShipBtn'; //REFIT

		private var _subtitleText:String               = 'CodeString.Dock.Subtitle'; //UPGRADE DOCK TO UNLOCK MORE FLEETS
		private var _fleetNameText:String              = 'CodeString.Dock.FleetName'; //FLEET NAME:
		private var _FleetRatingLabelText:String       = 'CodeString.Dock.FleetRating'; //FLEET RATING:
		private var _FleetPowerText:String             = 'CodeString.Dock.FleetPower'; //FLEET POWER:
		private var _fleetInfoText:String              = 'CodeString.Dock.FleetInfo'; //FLEET INFO
		private var _fleetStatsText:String             = 'CodeString.Dock.FleetStats'; //FLEET STATS
		private var _fleetHealthText:String            = 'CodeString.Dock.FleetHealth'; //FLEET HEALTH

		[Inject]
		public var tooltip:Tooltips;

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_greenFilter = CommonFunctionUtil.getColorMatrixFilter(0x48b53c);
			_redFilter = CommonFunctionUtil.getColorMatrixFilter(0xf81919);

			_timer = new Timer(1000)
			_timer.addEventListener(TimerEvent.TIMER, onRepairTick, false, 0, true);

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(959, 535);
			_bg.addTitle(_titleText, 470);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_subTitle = new Label(26, 0xffd785, 352, 45);
			_subTitle.align = TextFormatAlign.RIGHT;
			_subTitle.x = 140;
			_subTitle.y = 7;
			_subTitle.text = _subtitleText;
			_subTitle.visible = presenter.dockLevel < 10;

			_fleetSelection = new FleetSelection();
			_fleetSelection.x = 30;
			_fleetSelection.y = 53;
			_fleetSelection.loadShipImage = presenter.loadIconFromEntityData;
			_fleetSelection.onFleetSelected.add(onFleetSelected);

			_fleetInfoBG = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_INNER, PanelEnum.HEADER_NOTCHED, 563, 146, 32, 384, 133, _fleetInfoText, LabelEnum.H1);
			_fleetInfoBG.x = 398;
			_fleetInfoBG.y = 144;

			_fleetStatsBG = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED, PanelEnum.HEADER_NOTCHED, 563, 205, 32, 384, 319, _fleetStatsText, LabelEnum.H1);
			_fleetStatsBG.x = 398;
			_fleetStatsBG.y = 330;

			_docksBtnOne = UIFactory.getButton(ButtonEnum.BLUE_A, 239, 42, 478, 582, _defend, LabelEnum.H1);
			addListener(_docksBtnOne, MouseEvent.CLICK, onDockBtnOneClick);

			_docksBtnTwo = UIFactory.getButton(ButtonEnum.BLUE_A, 239, 42, 728, 582, _launch, LabelEnum.H1);
			addListener(_docksBtnTwo, MouseEvent.CLICK, onDockBtnTwoClick);

			_repairInProgressComponent = new ActionInProgressComponent(new ButtonPrototype(_cancelRepair, onCancelRepairClick), new ButtonPrototype(_speedUpText, onSpeedUpClick));
			_repairInProgressComponent.visible = false;
			_repairInProgressComponent.x = 681;
			_repairInProgressComponent.y = 257;

			_repairCostComponent = ObjectPool.get(ResourceComponent);
			_repairCostComponent.init(false, false, 35);
			_repairCostComponent.addMoreListener(onPurchaseMoreResources);
			_repairCostComponent.visible = false;
			_repairCostComponent.x = 405;
			_repairCostComponent.y = 251;

			_repairComponent = new ActionComponent(new ButtonPrototype(_repair, onRepairClick), new ButtonPrototype(_repairNow, onRepairNowClick), new ButtonPrototype(_alertHeadingBuyResources, onClickCannotAffordResourceDialog),
												   new ButtonPrototype(_repairNow, popPaywall));
			_repairComponent.visible = false;
			_repairComponent.x = 695;
			_repairComponent.y = 257;

			_nameBG = UIFactory.getScaleBitmap(PanelEnum.STATBAR_CONTAINER);
			_nameBG.width = 263;
			_nameBG.height = 31;
			_nameBG.x = 492;
			_nameBG.y = 185;

			_fleetName = new Label(20, 0xf0f0f0, 228, 30, false);
			_fleetName.align = TextFormatAlign.LEFT;
			_fleetName.x = _nameBG.x + 6;
			_fleetName.y = _nameBG.y + 4;

			_changeFleetNameBtn = UIFactory.getButton(ButtonEnum.EDIT);
			_changeFleetNameBtn.addEventListener(MouseEvent.CLICK, onChangeFleetName, false, 0, true);
			_changeFleetNameBtn.x = _nameBG.x + _nameBG.width - (_changeFleetNameBtn.width + 4);
			_changeFleetNameBtn.y = _nameBG.y + (_nameBG.height - _changeFleetNameBtn.height) * 0.5;

			_ratingBG = UIFactory.getScaleBitmap(PanelEnum.STATBAR_CONTAINER);
			_ratingBG.width = 54;
			_ratingBG.height = 31;
			_ratingBG.x = 895;
			_ratingBG.y = 185;

			_fleetRatingText = new Label(20, 0xf0f0f0, 54, 31, false);
			_fleetRatingText.align = TextFormatAlign.CENTER;
			_fleetRatingText.constrictTextToSize = false;
			_fleetRatingText.x = _ratingBG.x;
			_fleetRatingText.y = _ratingBG.y + 4;

			_powerSpent = UIFactory.getProgressBar(UIFactory.getPanel(PanelEnum.STATBAR_GREY, 448, 20), UIFactory.getPanel(PanelEnum.STATBAR_CONTAINER, 456, 26), 0, 1, 0, 492, 223);
			_powerSpent.overlay.y += 1;

			_powerUsedText = new Label(20, 0xf0f0f0, _powerSpent.width, _powerSpent.height);
			_powerUsedText.letterSpacing = 1.5;
			_powerUsedText.constrictTextToSize = false;
			_powerUsedText.align = TextFormatAlign.CENTER;
			_powerUsedText.x = _powerSpent.x;
			_powerUsedText.y = _powerSpent.y + 1;

			_fleetNameLabel = new Label(18, 0xf0f0f0, 93, 30);
			_fleetNameLabel.align = TextFormatAlign.CENTER;
			_fleetNameLabel.x = _fleetInfoBG.x + 1;
			_fleetNameLabel.y = _fleetInfoBG.y + 45;
			_fleetNameLabel.text = _fleetNameText;

			_fleetRatingLabel = new Label(18, 0xf0f0f0, 93, 30);
			_fleetRatingLabel.align = TextFormatAlign.CENTER;
			_fleetRatingLabel.x = _fleetInfoBG.x + 402;
			_fleetRatingLabel.y = _fleetInfoBG.y + 45;
			_fleetRatingLabel.text = _FleetRatingLabelText;

			_fleetPowerLabel = new Label(18, 0xf0f0f0, 93, 30);
			_fleetPowerLabel.align = TextFormatAlign.CENTER;
			_fleetPowerLabel.x = _fleetInfoBG.x + 1;
			_fleetPowerLabel.y = _fleetInfoBG.y + 80;
			_fleetPowerLabel.text = _FleetPowerText;

			_shipActionBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 170, 42, 35, 520, _add, LabelEnum.H1);
			addListener(_shipActionBtn, MouseEvent.CLICK, onActionBtnClicked);

			_shipRefitBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 170, 42, 218, 520, _refitShipBtnText, LabelEnum.H1);
			addListener(_shipRefitBtn, MouseEvent.CLICK, onRefitShip);

			_statusText = new Label(16, 0xFFFFFF, 140, 20, true, 1);
			_statusText.constrictTextToSize = false;
			_statusText.autoSize = TextFieldAutoSize.CENTER;
			_statusText.x = 99;
			_statusText.y = 144;
			_statusText.text = _statusTitle;

			_statusInfoText = new Label(14, 0x95c5f4, 140, 20, true, 1);
			_statusInfoText.constrictTextToSize = false;
			_statusInfoText.autoSize = TextFieldAutoSize.CENTER;
			_statusInfoText.x = 99;
			_statusInfoText.y = 162;
			_statusInfoText.text = _readyStatusText;

			_fleetDamageTitle = new Label(16, 0xFFFFFF, 140, 20, true, 1);
			_fleetDamageTitle.constrictTextToSize = false;
			_fleetDamageTitle.autoSize = TextFieldAutoSize.CENTER;
			_fleetDamageTitle.x = 317;
			_fleetDamageTitle.y = 144;
			_fleetDamageTitle.text = _fleetHealthText;

			_fleetDamage = new Label(14, 0x95c5f4, 140, 20, true, 1);
			_fleetDamage.constrictTextToSize = false;
			_fleetDamage.autoSize = TextFieldAutoSize.CENTER;
			_fleetDamage.x = 317;
			_fleetDamage.y = 162;

			addChild(_bg);
			addChild(_subTitle);
			addChild(_fleetSelection);
			addChild(_fleetInfoBG);
			addChild(_fleetStatsBG);
			addChild(_nameBG);
			addChild(_changeFleetNameBtn);
			addChild(_fleetName);
			addChild(_ratingBG);
			addChild(_fleetRatingText);
			addChild(_powerSpent);
			addChild(_powerUsedText);
			addChild(_fleetNameLabel);
			addChild(_fleetRatingLabel);
			addChild(_fleetPowerLabel);
			addChild(_statusInfoText);
			addChild(_statusText);
			addChild(_fleetDamageTitle);
			addChild(_fleetDamage);
			addChild(_repairInProgressComponent);
			addChild(_repairCostComponent);
			addChild(_repairComponent);
			addChild(_docksBtnOne);
			addChild(_docksBtnTwo);
			addChild(_shipActionBtn);
			addChild(_shipRefitBtn);

			createStatBar("_fleetDpsBar", "_fleetDpsLabel", "_fleetDpsValue", 'shipDps', 409, 366);
			createStatBar("_fleetHealthBar", "_fleetHealthLabel", "_fleetHealthValue", 'health', 409, 414);
			createStatBar("_fleetCargoBar", "_fleetCargoLabel", "_fleetCargoValue", 'cargo', 409, 461);
			createStatBar("_fleetMapSpeedBar", "_fleetMapSpeedLabel", "_fleetMapSpeedValue", 'mapSpeed', 409, 508);

			_fleets = presenter.fleets;
			_fleetSelection.addFleets(_fleets);

			_shipButtons = new Vector.<ShipButton>;
			var currentShipButton:ShipButton;
			var xPos:Number;
			var yPos:Number;
			for (var i:uint = 0; i < 6; ++i)
			{
				currentShipButton = new ShipButton();
				currentShipButton.onLoadShipImage.add(presenter.loadIconFromEntityData);
				currentShipButton.index = i;
				currentShipButton.onSelectShip.add(onSelectShip);
				tooltip.addTooltip(currentShipButton, this, currentShipButton.getTooltip, '', 250, 180, 14);

				switch (i)
				{
					case 0:
						xPos = 146;
						yPos = 153;
						break;
					case 1:
						xPos = 37;
						yPos = 211;
						break;
					case 2:
						xPos = 254;
						yPos = 211;
						break;
					case 3:
						xPos = 37;
						yPos = 335;
						break;
					case 4:
						xPos = 254;
						yPos = 335;
						break;
					case 5:
						xPos = 146;
						yPos = 391;
						break;
				}

				currentShipButton.x = xPos;
				currentShipButton.y = yPos;

				addChild(currentShipButton);
				_shipButtons.push(currentShipButton);
			}

			_fleetSelection.setSelected(presenter.selectedFleetID);
			presenter.addTransactionListener(transactionUpdate);
			presenter.addListenerOnFleetUpdated(onFleetsUpdated);
			transactionUpdate();
			addEffects();
			effectsIN();
		}

		//============================================================================================================
		//************************************************************************************************************
		//												FLEET CONTROL
		//************************************************************************************************************
		//============================================================================================================

		private function gotoFleet():void
		{
			presenter.gotoFleet(_selectedFleet);
			destroy();
		}

		private function recallFleet():void
		{
			presenter.recallFleet(_selectedFleet.id);
			_selectedFleet.state = FleetStateEnum.DOCKING;
			update();
		}

		private function defendBase():void
		{
			_selectedFleet.state = FleetStateEnum.DEFENDING;
			update();
		}

		private function stopDependingBase():void
		{
			_selectedFleet.state = FleetStateEnum.DOCKED;
			update();
		}

		private function launchFleet():void
		{
			var fleetsToLaunch:Array = _fleetSelection.queuedFleets;

			var index:int            = fleetsToLaunch.indexOf(_selectedFleet.id);
			if (index == -1)
				fleetsToLaunch.unshift(_selectedFleet);

			if (fleetsToLaunch.length > 0)
			{
				presenter.launchFleet(fleetsToLaunch);
				destroy();
			}
		}

		private function onChangeFleetName( e:MouseEvent ):void
		{
			showInputAlert(_changeFleetNameAlertTitle, _changeFleetNameAlertBody, _changeFleetNameAlertCancel, null, null, _changeFleetNameAlertAccept, onChangedName, null, true, 20, _fleetName.text);
		}

		private function onChangedName( newName:String ):void
		{
			setFleetName(newName);
			if (presenter)
				presenter.changeFleetName(_selectedFleet, newName);
		}

		private function setFleetName( v:String ):void
		{
			if (_fleetName)
				_fleetName.text = v;
		}

		//============================================================================================================
		//************************************************************************************************************
		//												 REPAIRING
		//************************************************************************************************************
		//============================================================================================================

		private function updateNeedsRepairState( show:Boolean ):void
		{
			_repairComponent.visible = show;
			_repairCostComponent.visible = show;

			if (show)
			{
				_selectedFleet.updateFleetStats();
				_repairComponent.timeCost = _selectedFleet.repairTime;
			}

		}

		private function updateRepairState( show:Boolean ):void
		{
			if (show)
				onRepairTick(null);

			_repairInProgressComponent.visible = show;
		}

		private function onRepairTick( e:TimerEvent ):void
		{
			if (_repairTransaction)
			{
				_repairInProgressComponent.timeRemaining = _repairTransaction.timeRemainingMS;

				if (_repairTransaction.timeRemainingMS <= 0)
					_timer.reset();
				else
					presenter.updateRepair();

				if (_repairTransaction.id == _selectedFleet.id)
				{
					updateShips(_repairTransaction && _repairTransaction.id == _selectedFleet.id);
					_fleetDamage.text = Math.round(_selectedFleet.currentHealth * 100) + '%';
				}

				onFleetUpdated(presenter.getFleet(_repairTransaction.id));
			}
		}

		private function onRepairClick( e:MouseEvent ):void
		{
			presenter.repairFleet(_selectedFleet, PurchaseTypeEnum.NORMAL);
		}

		private function onRepairNowClick( e:MouseEvent ):void
		{
			presenter.repairFleet(_selectedFleet, PurchaseTypeEnum.INSTANT);
		}

		private function onRepairWithResourcePurchase( e:MouseEvent ):void
		{
			repairWithResourcePurchase();
		}

		private function repairWithResourcePurchase():void
		{
			presenter.repairFleet(_selectedFleet, PurchaseTypeEnum.GET_RESOURCES);
		}

		private function onCancelRepairClick( e:MouseEvent ):void
		{
			presenter.cancelTransaction(_repairTransaction);
		}

		//============================================================================================================
		//************************************************************************************************************
		//													STATE
		//************************************************************************************************************
		//============================================================================================================

		private function onFleetSelected( fleetBtn:FleetButton ):void
		{
			if (fleetBtn)
			{
				if (_selectedShipButton)
				{
					_selectedShipButton.selectable = true;
					_selectedShipButton.selected = false;
					_selectedShipButton = null;
				}

				presenter.selectedFleetID = fleetBtn.id;
				_selectedFleet = fleetBtn.fleet;
				setFleetName(_selectedFleet.name);
				updateState();
			}
		}

		private function updateState( state:int = 0 ):void
		{
			_repairTransaction = presenter.dockTransaction;
			if (_repairTransaction && (_repairTransaction.timeMS > 0 || _repairTransaction.state == StarbaseTransactionStateEnum.PENDING))
				state = REPAIR_STATE;
			else if (_selectedFleet.needsRepair && _selectedFleet.sector == '')
				state = NEEDS_REPAIR_STATE;
			else
				state = DEFAULT_STATE;

			if (state != _currentState)
				cleanUpPreviousState();
			_currentState = state;
			update();
			switch (state)
			{
				case NEEDS_REPAIR_STATE:
					updateNeedsRepairState(true);
					break;
				case REPAIR_STATE:
					updateRepairState(true);
					break;
			}
		}

		private function cleanUpPreviousState():void
		{
			switch (_currentState)
			{
				case NEEDS_REPAIR_STATE:
					updateNeedsRepairState(false);
					break;
				case REPAIR_STATE:
					updateRepairState(false);
					break;
			}
		}

		private function transactionUpdate( data:* = null ):void
		{
			var i:uint;
			var len:uint;
			updateState();
			if (_repairTransaction)
			{
				if (!_timer.running)
				{
					presenter.updateRepair();
					_fleets = presenter.fleets;
					len = _fleets.length;
					for (i = 0; i < len; ++i)
						onFleetUpdated(_fleets[i]);

					_timer.start();
				}
			} else if (_timer.running)
			{
				_timer.reset();
				presenter.updateRepair();
				_fleets = presenter.fleets;
				len = _fleets.length;
				for (i = 0; i < len; ++i)
					onFleetUpdated(_fleets[i]);
			}
		}

		private function update():void
		{
			_selectedFleet = presenter.getFleet(_selectedFleet.id);
			onFleetUpdated(_selectedFleet);
			_selectedFleet.updateFleetStats();

			var maxFleetPower:int  = presenter.maxFleetPower;
			_currentRequirements = presenter.canRepair(_selectedFleet);

			var premCost:int       = _currentRequirements.purchaseVO.premium;
			_repairComponent.instantCost = premCost;
			_repairComponent.requirements = _currentRequirements;

			_repairCostComponent.updateCost(_selectedFleet.alloyCost, (_currentRequirements.purchaseVO.alloyAmountShort == 0), CurrencyEnum.ALLOY);
			_repairCostComponent.updateCost(_selectedFleet.creditsCost, (_currentRequirements.purchaseVO.creditsAmountShort == 0), CurrencyEnum.CREDIT);
			_repairCostComponent.updateCost(_selectedFleet.energyCost, (_currentRequirements.purchaseVO.energyAmountShort == 0), CurrencyEnum.ENERGY);
			_repairCostComponent.updateCost(_selectedFleet.syntheticCost, (_currentRequirements.purchaseVO.syntheticAmountShort == 0), CurrencyEnum.SYNTHETIC);

			var isRepairing:Boolean;
			if (_repairTransaction && _repairTransaction.id == _selectedFleet.id)
				isRepairing = true;

			updateShips(isRepairing);

			if (_selectedFleet.numOfShips == 0)
				onSelectShip(_shipButtons[0]);

			_fleetRatingText.text = String(_selectedFleet.level);
			_fleetDpsBar.amount = _selectedFleet.damage;
			_fleetHealthBar.amount = _selectedFleet.healthAmount;
			_fleetCargoBar.amount = _selectedFleet.maxCargo;
			_fleetMapSpeedBar.amount = _selectedFleet.sectorSpeed;
			_fleetDamage.text = Math.round(_selectedFleet.currentHealth * 100) + '%';

			_fleetDpsValue.text = StringUtil.commaFormatNumber(_selectedFleet.damage);
			_fleetHealthValue.text = StringUtil.commaFormatNumber(Math.round(_selectedFleet.healthAmount));
			_fleetCargoValue.text = StringUtil.commaFormatNumber(_selectedFleet.maxCargo);
			_fleetMapSpeedValue.setTextWithTokens(_auPerHr, {'[[Number.ValuePerHr]]':_selectedFleet.sectorSpeed});

			var massPercent:Number = _selectedFleet.powerUsage / maxFleetPower;

			var dockBtnOneEnabled:Boolean;
			var dockBtnTwoEnabled:Boolean;
			if (_selectedFleet.sector != '' || _selectedFleet.state == FleetStateEnum.DEFENDING)
			{
				_docksBtnTwo.text = _recall;
				_docksBtnOne.text = _gotoFleet;
				if (!_selectedFleet.inBattle)
					_statusInfoText.text = _readyStatusText;
				else
					_statusInfoText.text = _BattleStatusText;

				if (_selectedFleet.state == FleetStateEnum.DEFENDING)
					dockBtnOneEnabled = false;
				else
					dockBtnOneEnabled = true;

				if (_selectedFleet.state != FleetStateEnum.DOCKING && _selectedFleet.state != FleetStateEnum.FORCED_RECALLING)
					dockBtnTwoEnabled = true;
			} else if (_selectedFleet.numOfShips > 0 && _selectedFleet.ships[0] == null)
			{
				_statusInfoText.text = _readyStatusText;
				_docksBtnTwo.text = _noFlagship;
				_docksBtnOne.text = _noFlagship;
			} else if (_selectedFleet.currentHealth == 0 && _selectedFleet.numOfShips > 0)
			{
				_statusInfoText.text = _readyStatusText;
				_docksBtnTwo.text = _needToRepair;
				_docksBtnOne.text = _needToRepair;
			} else if (_selectedFleet.numOfShips == 0)
			{
				_statusInfoText.text = _offlineStatusText;
				_docksBtnTwo.text = _offline;
				_docksBtnOne.text = _offline;
			} else
			{
				_statusInfoText.text = _readyStatusText;
				_docksBtnTwo.text = _launch;
				_docksBtnOne.text = _defend;
				dockBtnOneEnabled = isRepairing ? false : false;
				dockBtnTwoEnabled = isRepairing ? false : (massPercent <= 1);
			}

			_docksBtnOne.enabled = dockBtnOneEnabled;
			_docksBtnTwo.enabled = dockBtnTwoEnabled;

			_changeFleetNameBtn.visible = (_selectedFleet.sector == '');

			if (_powerSpent.amount != massPercent)
			{
				_powerSpent.amount = massPercent;
				var newFilter:ColorMatrixFilter = getPowerBarColor(massPercent);
				if (_currentFilter != newFilter)
				{
					_currentFilter = newFilter
					_powerSpent.overlay.filters = [_currentFilter];
				}

				_powerUsedText.setTextWithTokens(_outOfString, {'[[Number.MinValue]]':StringUtil.commaFormatNumber(_selectedFleet.powerUsage), '[[Number.MaxValue]]':StringUtil.commaFormatNumber(maxFleetPower)});
			}
		}

		private function updateShips( isRepairing:Boolean ):void
		{
			if (_selectedFleet)
			{
				var ships:Vector.<ShipVO>     = _selectedFleet.ships;
				var len:uint                  = ships.length;
				var selectable:Boolean        = (_selectedFleet.sector == '' && ((_repairTransaction && _repairTransaction.id != _selectedFleet.id) || (_repairTransaction == null)));

				if (!selectable && _selectedShipButton)
				{
					_selectedShipButton.selected = false;
					_selectedShipButton = null;
				}

				var enableShipButtons:Boolean = true;
				if (_selectedFleet.numOfShips < 1)
				{
					if (_selectedFleet.ships[0] == null)
						enableShipButtons = false;
				}

				var shipVO:ShipVO;
				var shipBtn:ShipButton;
				for (var i:uint = 0; i < len; ++i)
				{
					shipVO = ships[i];
					shipBtn = _shipButtons[i];

					shipBtn.setShip(shipVO, null, _selectedFleet);
					shipBtn.showRepair(isRepairing);

					shipBtn.selectable = selectable;

					if (i != 0)
						shipBtn.enabled = enableShipButtons;
					else
					{
						if (_selectedShipButton == null && selectable)
						{
							shipBtn.selected = true;
							onSelectShip(shipBtn);
						}
					}
				}

				updateShipActionBtns();
			}
		}

		private function updateShipActionBtns():void
		{
			var selectable:Boolean;

			//For repair time split testing
			if (PrototypeModel.instance.getConstantPrototypeValueByName("isNewRepairSystemActive"))
				selectable = (_selectedFleet.sector == '' && ((_repairTransaction && _repairTransaction.id != _selectedFleet.id) || (_repairTransaction == null)) && _selectedFleet.currentHealth >= 1);
			else
				selectable = (_selectedFleet.sector == '' && ((_repairTransaction && _repairTransaction.id != _selectedFleet.id) || (_repairTransaction == null)));
			_shipActionBtn.visible = selectable;
			_shipRefitBtn.visible = (selectable && _selectedShipButton && _selectedShipButton.ship && _selectedShipButton.ship.currentHealth == 1);
		}

		private function onFleetUpdated( fleet:FleetVO ):void
		{
			if (fleet)
				_fleetSelection.updateFleet(fleet, (_repairTransaction && _repairTransaction.id == fleet.id));
		}

		private function onFleetsUpdated( fleet:FleetVO ):void
		{
			if (fleet == null)
			{
				_fleets = presenter.fleets;
				var len:uint = _fleets.length;
				for (var i:uint = 0; i < len; ++i)
				{
					fleet = _fleets[i];
					if (_selectedFleet && fleet.id == _selectedFleet.id)
						update();
					else
						onFleetUpdated(fleet);
				}

			} else
				onFleetUpdated(fleet);

		}

		//============================================================================================================
		//************************************************************************************************************
		//													MISC
		//************************************************************************************************************
		//============================================================================================================

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

		private function onRefitShip( e:MouseEvent ):void
		{
			if (_selectedShipButton && _selectedShipButton.ship)
			{
				var shipyardTransaction:TransactionVO = presenter.shipyardTransaction;
				if (_selectedFleet.sector == '' && shipyardTransaction == null)
				{
					var nShipyardView:ShipyardView = ShipyardView(_viewFactory.createView(ShipyardView));
					nShipyardView.refitShip = _selectedShipButton.ship;
					_viewFactory.notify(nShipyardView);
				} else
				{
					var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
					buttons.push(new ButtonPrototype(_speedUpBtnText, speedUpShipyardTransaction, null, true, ButtonEnum.GREEN_A));
					buttons.push(new ButtonPrototype(_cancelBtnText));
					showConfirmation(_shipyardBusyAlertTitle, _shipyardBusyAlertBody, buttons);
				}
			}
		}

		private function onSpeedUpClick( e:MouseEvent ):void
		{
			if (_repairTransaction)
				openStoreToTransaction(_repairTransaction)
		}

		private function speedUpShipyardTransaction():void
		{
			var shipyardTransaction:TransactionVO = presenter.shipyardTransaction;
			if (shipyardTransaction)
				openStoreToTransaction(shipyardTransaction);
		}

		private function openStoreToTransaction( transaction:TransactionVO ):void
		{
			var nStoreView:StoreView = StoreView(_viewFactory.createView(StoreView));
			_viewFactory.notify(nStoreView);
			nStoreView.setSelectedTransaction(transaction);
			destroy();
		}

		private function onDockBtnOneClick( e:MouseEvent ):void
		{
			if (_selectedFleet.numOfShips > 0 && _selectedFleet.ships[0] != null && _selectedFleet.currentHealth != 0)
			{
				if (_selectedFleet.sector != '')
					gotoFleet();
				else if (_selectedFleet.state == FleetStateEnum.DEFENDING)
					stopDependingBase();
				else
					defendBase();
			}
		}

		private function onDockBtnTwoClick( e:MouseEvent ):void
		{
			if (_selectedFleet.numOfShips > 0 && _selectedFleet.ships[0] != null && _selectedFleet.currentHealth != 0)
			{
				var modules:Dictionary = new Dictionary();
				var slots:Array        = new Array();
				var slot:String;
				var shipCount:int      = 0;
				var hasWeaponCount:int = 0;

				if (_selectedFleet.sector != '')
					recallFleet();
				else if (_selectedFleet.state == FleetStateEnum.DEFENDING)
					stopDependingBase();
				else
				{
					for each (var ship:ShipVO in _selectedFleet.ships)
					{
						if (ship)
						{
							shipCount++;
							modules = ship.modules;
							slots = ship.slots;
							for (var i:int = 0; i < slots.length; i++)
							{
								slot = slots[i];

								if (slot.indexOf(SlotComponentEnum.SLOT_TYPE_WEAPON) != -1)
								{
									if (modules.hasOwnProperty(slot) && modules[slot] != null)
									{
										hasWeaponCount++;
										break;
									}
								}
							}
						}

					}

					if (hasWeaponCount == shipCount)
						launchFleet();
					else
						showToast(ToastEnum.WRONG, null, 'CodeString.DockView.NoWeaponError');
				}



			}
		}

		protected function onClickCannotAffordResourceDialog( e:MouseEvent ):void
		{
			if (_currentRequirements.purchaseVO.canPurchaseResourcesWithPremium)
			{
				var purchaseVO:PurchaseVO  = _currentRequirements.purchaseVO;
				var view:ResourceModalView = ResourceModalView(_viewFactory.createView(ResourceModalView));
				_viewFactory.notify(view);
				view.setUp(purchaseVO.creditsAmountShort, purchaseVO.alloyAmountShort, purchaseVO.energyAmountShort, purchaseVO.syntheticAmountShort, 'CodeString.Alert.BuyResources.Title', 'CodeString.Alert.BuyResources.Body',
						   false, repairWithResourcePurchase, purchaseVO.resourcePremiumCost);
			} else
				popPaywall();
		}

		private function getPowerBarColor( v:Number ):ColorMatrixFilter
		{
			if (v > 1.0)
				return _redFilter;
			else
				return _greenFilter;
		}

		private function createStatBar( barRef:String, labelRef:String, valueRef:String, protoName:String, x:int, y:int ):void
		{
			var statProto:IPrototype   = presenter.getStatPrototypeByName(protoName);
			var defaultMaxValue:Number = presenter.getConstantPrototypeValueByName("interfaceCalibrationDefaultStatValue");
			var maxValue:Number        = statProto.getUnsafeValue("stdMax");
			maxValue = (maxValue) ? maxValue : defaultMaxValue;

			if (protoName == 'shipDps' || protoName == 'health' || protoName == 'cargo')
				maxValue *= 6;

			this[labelRef] = new Label(14, 0xf0f0f0, 248, 25, true, 1);
			this[labelRef].align = TextFormatAlign.LEFT;
			this[labelRef].text = statProto.getValue("lableLocKey");
			this[labelRef].y = y;
			this[labelRef].x = x;
			this[labelRef].constrictTextToSize = false;
			addChild(this[labelRef]);

			this[barRef] = UIFactory.getProgressBar(UIFactory.getPanel(PanelEnum.STATBAR, 531, 16), UIFactory.getPanel(PanelEnum.STATBAR_CONTAINER, 539, 24), 0, maxValue, 0, x, this[labelRef].y + this[labelRef].
													textHeight + 4);
			this[barRef]
			addChild(this[barRef]);

			this[valueRef] = new Label(14, 0xf0f0f0, 539, 25, true, 1);
			this[valueRef].letterSpacing = 1.5;
			this[valueRef].align = TextFormatAlign.CENTER;
			this[valueRef].y = this[barRef].y;
			this[valueRef].x = this[barRef].x;
			this[valueRef].constrictTextToSize = false;
			addChild(this[valueRef]);
		}

		private function showShipyardView():void
		{
			destroy();
			showView(ShipyardView);
		}

		private function onRemovedShipFromFleet( ship:ShipVO ):void
		{
			presenter.removeShipFromFleet(_selectedFleet, ship.id);

			if (_selectedFleet.numOfShips == 0)
				onSelectShip(_shipButtons[0]);

			_shipActionBtn.text = _add;
		}

		private function onSelectShip( shipBtn:ShipButton, autoSelect:Boolean = false ):void
		{
			if (shipBtn)
			{
				if (_selectedShipButton)
				{
					_selectedShipButton.selectable = true;
					_selectedShipButton.selected = false;
				}

				_selectedShipButton = shipBtn;
				_selectedShipButton.selected = true;
				_selectedShipButton.selectable = false;

				if (_selectedShipButton.ship)
					_shipActionBtn.text = _remove;
				else
				{
					if (autoSelect)
						onActionBtnClicked();

					_shipActionBtn.text = _add;
				}

				updateShipActionBtns();
			}
		}

		private function onActionBtnClicked( e:MouseEvent = null ):void
		{
			if (_selectedShipButton)
			{
				if (_selectedShipButton.ship)
					onRemovedShipFromFleet(_selectedShipButton.ship)
				else
					openShipSelect();
			}
		}

		private function openShipSelect():void
		{
			var unassignedShips:Vector.<ShipVO> = presenter.unassignedShips;
			if (unassignedShips.length == 0 || (unassignedShips.length == 1 && !unassignedShips[0].built))
			{
				var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
				buttons.push(new ButtonPrototype(_noFleetAlertOpenShipyard, showShipyardView, null, true, ButtonEnum.GREEN_A));
				buttons.push(new ButtonPrototype(_noFleetAlertClose));
				showConfirmation(_noFleetAlertTitle, _noFleetAlertBody, buttons);
			} else
			{
				var nShipSelectionView:ShipSelectionView = ShipSelectionView(_viewFactory.createView(ShipSelectionView));
				_viewFactory.notify(nShipSelectionView);
				nShipSelectionView.setUp(onShipSelected);
			}
		}

		private function onShipSelected( ship:ShipVO ):void
		{
			if (_selectedShipButton)
			{
				presenter.assignShipToFleet(_selectedFleet, ship, _selectedShipButton.index);
				_shipActionBtn.text = _remove;
			}
		}

		private function popPaywall( e:MouseEvent = null ):void
		{
			CommonFunctionUtil.popPaywall();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function get typeUnique():Boolean  { return false; }

		[Inject]
		public function set presenter( value:IFleetPresenter ):void  { _presenter = value; }
		public function get presenter():IFleetPresenter  { return IFleetPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.removeTransactionListener(transactionUpdate);
			presenter.removeListenerOnFleetUpdated(onFleetsUpdated);

			if (_timer)
			{
				if (_timer.running)
					_timer.stop();

				_timer.removeEventListener(TimerEvent.TIMER, onRepairTick);
			}

			_timer = null;

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			if (_repairComponent)
				_repairComponent.destroy();

			_repairComponent = null;

			if (_repairInProgressComponent)
				_repairInProgressComponent.destroy();

			_repairInProgressComponent = null;

			if (_repairCostComponent)
				_repairCostComponent.destroy();

			_repairCostComponent = null;

			if (_changeFleetNameBtn)
				_changeFleetNameBtn.destroy();

			_changeFleetNameBtn = null;

			if (_docksBtnTwo)
				_docksBtnTwo.destroy();

			_docksBtnTwo = null;

			if (_docksBtnOne)
				_docksBtnOne.destroy();

			_docksBtnOne = null;

			if (_fleetSelection)
				_fleetSelection.destroy();

			_fleetSelection = null;

			var len:uint = _shipButtons.length;
			for (var i:uint = 0; i < len; ++i)
			{
				_shipButtons[i].destroy();
				_shipButtons[i] = null;
			}
			_shipButtons.length = 0;

			if (_subTitle)
				_subTitle.destroy();

			_subTitle = null;

			if (_fleetRatingText)
				_fleetRatingText.destroy();

			_fleetRatingText = null;

			if (_fleetName)
				_fleetName.destroy();

			_fleetName = null;

			if (_fleetDpsLabel)
				_fleetDpsLabel.destroy();

			_fleetDpsLabel = null;

			if (_fleetHealthLabel)
				_fleetHealthLabel.destroy();

			_fleetHealthLabel = null;

			if (_fleetCargoLabel)
				_fleetCargoLabel.destroy();

			_fleetCargoLabel = null;

			if (_fleetMapSpeedLabel)
				_fleetMapSpeedLabel.destroy();

			_fleetMapSpeedLabel = null;

			if (_fleetDpsValue)
				_fleetDpsValue.destroy();

			_fleetDpsValue = null;

			if (_fleetHealthValue)
				_fleetHealthValue.destroy();

			_fleetHealthValue = null;

			if (_fleetCargoValue)
				_fleetCargoValue.destroy();

			_fleetCargoValue = null;

			if (_fleetMapSpeedValue)
				_fleetMapSpeedValue.destroy();

			_fleetMapSpeedValue = null;

			if (_powerUsedText)
				_powerUsedText.destroy();

			_powerUsedText = null;

			if (_statusText)
				_statusText.destroy();

			_statusText = null;

			if (_statusInfoText)
				_statusInfoText.destroy();

			_statusInfoText = null;

			_repairTransaction = null;

			if (_fleetDpsBar)
				_fleetDpsBar.destroy();

			_fleetDpsBar = null;

			if (_fleetHealthBar)
				_fleetHealthBar.destroy();

			_fleetHealthBar = null;

			if (_fleetCargoBar)
				_fleetCargoBar.destroy();

			_fleetCargoBar = null;

			if (_fleetMapSpeedBar)
				_fleetMapSpeedBar.destroy();

			_fleetMapSpeedBar = null;

			if (_fleetNameLabel)
				_fleetNameLabel.destroy();

			_fleetNameLabel = null;

			if (_fleetRatingLabel)
				_fleetRatingLabel.destroy();

			_fleetRatingLabel = null;

			if (_fleetPowerLabel)
				_fleetPowerLabel.destroy();

			_fleetPowerLabel = null;

			super.destroy();

		}
	}
}


