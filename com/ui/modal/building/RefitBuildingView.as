package com.ui.modal.building
{
	import com.controller.transaction.requirements.PurchaseVO;
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.CurrencyEnum;
	import com.enum.SlotComponentEnum;
	import com.enum.TypeEnum;
	import com.enum.server.PurchaseTypeEnum;
	import com.enum.ui.ButtonEnum;
	import com.event.TransactionEvent;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BuildingVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.starbase.IStarbasePresenter;
	import com.service.language.Localization;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ActionComponent;
	import com.ui.core.component.misc.ActionInProgressComponent;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.misc.TooltipComponent;
	import com.ui.hud.shared.command.ResourceComponent;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.ui.modal.construction.ConstructionView;
	import com.ui.modal.information.ResourceModalView;
	import com.ui.modal.information.StatInformationView;
	import com.ui.modal.shipyard.ComponentSelection;
	import com.ui.modal.store.StoreView;
	import com.util.CommonFunctionUtil;
	import com.util.statcalc.StatCalcUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	import org.adobe.utils.StringUtil;
	import org.shared.ObjectPool;

	public class RefitBuildingView extends View
	{
		private var _bg:Bitmap;
		private var _closeBtn:BitmapButton;
		private var _moduleKey:Bitmap;
		private var _statBg:ScaleBitmap;
		private var _statHolder:Array;
		private var _refitEntityImage:ImageComponent;
		private var _entityComponents:Dictionary; // String (slot name), ComponentSelection
		private var _viewTitle:Label;
		private var _statsTitle:Label;
		private var _equippedTitle:Label;

		private var _buildingVO:BuildingVO;
		private var _modules:Dictionary;
		private var _newComponents:Boolean           = false;
		private var _isTurret:Boolean                = false;

		private var _transaction:TransactionVO;

		private var _buildComponent:ActionComponent;
		private var _buildCostComponent:ResourceComponent;
		private var _refitInProgressComponent:ActionInProgressComponent;
		private var _toolTipComponent:TooltipComponent;
		private var _currentRequirements:RequirementVO;

		private var _statWindowString:String;

		private var _infoBtn:BitmapButton;

		private var _armorBar:ProgressBar;
		private var _buildingDpsBar:ProgressBar;
		private var _forceShieldingBar:ProgressBar;
		private var _explosiveShieldingBar:ProgressBar;
		private var _energyShieldingBar:ProgressBar;
		private var _healthBar:ProgressBar;
		private var _maskingBar:ProgressBar;
		private var _profileBar:ProgressBar;

		private var _buildingDpsLabel:Label;
		private var _buildingDpsValue:Label;
		private var _forceShieldingLabel:Label;
		private var _forceShieldingValue:Label;
		private var _explosiveShieldingLabel:Label;
		private var _explosiveShieldingValue:Label;
		private var _energyShieldingLabel:Label;
		private var _energyShieldingValue:Label;
		private var _healthLabel:Label;
		private var _healthValue:Label;
		private var _profileLabel:Label;
		private var _profileValue:Label;
		private var _armorLabel:Label;
		private var _armorValue:Label;
		private var _maskingLabel:Label;
		private var _maskingValue:Label;

		private var _equippedMod:IPrototype;

		private var _refitTimer:Timer;

		private var _cost:String                     = 'CodeString.Shared.Cost' //Cost
		private var _buildNow:String                 = 'CodeString.Shared.BuildNowBtn'; // Build Now
		private var _build:String                    = 'CodeString.Shared.BuildBtn'; // Build
		private var _refitNow:String                 = 'CodeString.Shared.RefitNowBtn'; // Refit Now
		private var _refit:String                    = 'CodeString.Shared.RefitBtn'; // Refit
		private var _stats:String                    = 'CodeString.Shared.Stats'; // Stats
		private var _offline:String                  = 'CodeString.Docks.OfflineBtn'; // Offline
		private var _cancelText:String               = 'CodeString.Shared.CancelBtn'; //Cancel
		private var _speedUpText:String              = 'CodeString.ContextMenu.Starbase.SpeedUp'; //Speed Up

		private var _unequipBtn:String               = 'CodeString.BuildRefit.UnequipBtn' //Unequip
		private var _unequip:String                  = 'CodeString.BuildRefit.Unequip' //Click the unequip button below to remove the [[String.ModuleName]].
		private var _module:String                   = 'CodeString.BuildRefit.Module'; // Module
		private var _titleTurret:String              = 'CodeString.BuildRefit.Title.Turret' //TURRET
		private var _titleShield:String              = 'CodeString.BuildRefit.Title.Shield'; //SHIELD

		private var _getResourcesBtnText:String      = 'CodeString.Shared.GetResources'; //GET RESOURCES
		private var _alertBodyBuyResources:String    = 'CodeString.Alert.BuyResources.Body';
		private var _alertHeadingBuyResources:String = 'CodeString.Alert.BuyResources.Title';
		private var _emptySlot:String                = 'CodeString.Shipyard.EmptySlot'; //Empty

		private var _defenseProjectTitle:String      = 'CodeString.Alert.BuildRefit.Title'; //Defense Project In Progress
		private var _defenseProjectAlertBody:String  = 'CodeString.Alert.BuildRefit.Body'; //You have a defense project currently in progress. Would you like to speed it up?
		protected var _speedUpBtnText:String         = 'CodeString.Shared.SpeedUp';
		protected var _cancelBtnText:String          = 'CodeString.Shared.CancelBtn';

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_bg = PanelFactory.getPanel("RefitWindowBGBMD");
			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 40, 25);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			var scaleRect:Rectangle = new Rectangle(0, 5, 299, 16);
			_statBg = PanelFactory.getScaleBitmapPanel('RefitWindowStatsBGBMD', 299, 37, scaleRect);
			_statBg.x = 350;
			_statBg.y = 90;

			_statHolder = new Array;

			_refitEntityImage = new ImageComponent();
			_refitEntityImage.init(128, 128);

			_viewTitle = new Label(28, 0xffffff, 200, 30);
			_viewTitle.align = TextFormatAlign.LEFT;
			_viewTitle.x = 35;
			_viewTitle.y = 20;

			var keyClass:Class;
			switch (_buildingVO.asset)
			{
				case TypeEnum.SHIELD_GENERATOR:
					_viewTitle.text = _titleShield;
					_isTurret = false;
					keyClass = Class(getDefinitionByName('DefenseKeyBMD'));
					break;
				case TypeEnum.POINT_DEFENSE_PLATFORM:
					_viewTitle.text = _titleTurret;
					_isTurret = true;
					keyClass = Class(getDefinitionByName('WeaponKeyBMD'));
					break;
			}

			presenter.loadIcon(AssetModel.instance.getEntityData(_buildingVO.asset).iconImage, onImageLoaded);

			_moduleKey = new Bitmap(BitmapData(new keyClass));
			_moduleKey.x = 61;

			if (_isTurret)
				_moduleKey.y = 370;
			else
				_moduleKey.y = 375;


			_statsTitle = new Label(20, 0xf0f0f0, 200, 30);
			_statsTitle.align = TextFormatAlign.LEFT;
			_statsTitle.constrictTextToSize = false;
			_statsTitle.x = 350;
			_statsTitle.y = 66;
			_statsTitle.letterSpacing = 2;
			_statsTitle.text = _stats;

			var style:StyleSheet    = new StyleSheet();
			var hover:Object        = new Object();
			hover.color = "#b3ddf2";
			var link:Object         = new Object();
			link.color = "#e7e7e7";

			style.setStyle("a:link", link);
			style.setStyle("a:hover", hover);

			_equippedTitle = new Label(14, 0xe7e7e7, 240, 30);
			_equippedTitle.align = TextFormatAlign.LEFT;
			_equippedTitle.constrictTextToSize = false;
			_equippedTitle.x = 31;
			_equippedTitle.y = 386;
			_equippedTitle.letterSpacing = 1.5;
			_equippedTitle.htmlText = _emptySlot;
			addListener(_equippedTitle, TextEvent.LINK, linkEvent);
			addListener(_equippedTitle, MouseEvent.ROLL_OVER, onTextRollOver);
			addListener(_equippedTitle, MouseEvent.ROLL_OUT, onTextRollOut);
			_equippedTitle.mouseEnabled = true;
			_equippedTitle.styleSheet = style;

			_buildComponent = new ActionComponent(new ButtonPrototype(_refit, onBuildClick), new ButtonPrototype(_refitNow, onBuildNowClick), new ButtonPrototype(_getResourcesBtnText, onClickCannotAffordResourceDialog),
												  new ButtonPrototype(_buildNow, popPaywall));
			_buildComponent.x = 368;
			_buildComponent.y = 376;

			_buildCostComponent = ObjectPool.get(ResourceComponent);
			_buildCostComponent.init(true, false, 35);
			_buildCostComponent.x = 335;
			_buildCostComponent.y = 301;

			_refitInProgressComponent = new ActionInProgressComponent(new ButtonPrototype(_cancelText, onCancelClick), new ButtonPrototype(_speedUpText, openStoreToTransaction));
			_refitInProgressComponent.visible = false;
			_refitInProgressComponent.x = 349;
			_refitInProgressComponent.y = 366;

			_toolTipComponent = ObjectPool.get(TooltipComponent);
			_toolTipComponent.init(2, 332, 278);

			_infoBtn = ButtonFactory.getBitmapButton('TradeRouteInfoBtnNeutralBMD', 286, 69, '', 0xFFFFFF, 'TradeRouteInfoBtnRollOverBMD', 'TradeRouteInfoBtnDownBMD');
			_infoBtn.addEventListener(MouseEvent.CLICK, showFullTooltip);


			addChild(_bg);
			addChild(_statBg);
			addChild(_buildComponent);
			addChild(_buildCostComponent);
			addChild(_refitInProgressComponent);
			addChild(_closeBtn);
			addChild(_refitEntityImage);
			addChild(_viewTitle);
			addChild(_statsTitle);
			addChild(_equippedTitle);
			addChild(_infoBtn);
			addChild(_moduleKey);

			layoutComponentSelectors();

			if (_isTurret)
			{
				createProgressBar("_buildingDpsBar", "_buildingDpsLabel", "_buildingDpsValue", 'shipDps', 366, 102);
				createProgressBar("_healthBar", "_healthLabel", "_healthValue", 'health', 366, 129);
				createProgressBar("_profileBar", "_profileLabel", "_profileValue", 'profile', 366, 156);
				createProgressBar("_armorBar", "_armorLabel", "_armorValue", 'armor', 366, 183);
				createProgressBar("_maskingBar", "_maskingLabel", "_maskingValue", 'masking', 366, 210);
				_statBg.height += 110;
			} else
			{
				createProgressBar("_forceShieldingBar", "_forceShieldingLabel", "_forceShieldingValue", 'forceShielding', 366, 102);
				createProgressBar("_explosiveShieldingBar", "_explosiveShieldingLabel", "_explosiveShieldingValue", 'explosiveShielding', 366, 129);
				createProgressBar("_energyShieldingBar", "_energyShieldingLabel", "_energyShieldingValue", 'energyShielding', 366, 156);
				createProgressBar("_healthBar", "_healthLabel", "_healthValue", 'health', 366, 183);
				createProgressBar("_profileBar", "_profileLabel", "_profileValue", 'profile', 366, 210);
				createProgressBar("_armorBar", "_armorLabel", "_armorValue", 'armor', 366, 237);
				createProgressBar("_maskingBar", "_maskingLabel", "_maskingValue", 'masking', 366, 264);
				_statBg.height += 164;
			}


			_refitTimer = new Timer(1000);
			addListener(_refitTimer, TimerEvent.TIMER, updateTimer);

			_transaction = presenter.getStarbaseBuildingTransaction(null, _buildingVO.id);

			_modules = new Dictionary();
			var slots:Array         = _buildingVO.prototype.getValue('slots');
			var i:int               = 0;
			if (_transaction)
			{
				if (_transaction.type == TransactionEvent.STARBASE_REFIT_BUILDING)
				{
					for (i = 0; i < slots.length; i++)
					{
						if (_buildingVO.refitModules.hasOwnProperty(slots[i]))
							_modules[slots[i]] = _buildingVO.refitModules[slots[i]];

					}

					_refitInProgressComponent.visible = true;
					_buildComponent.visible = false;
					_buildCostComponent.visible = false;

					_refitTimer.start();
				}
			} else
			{
				//equip the current modules if any
				for (i = 0; i < slots.length; i++)
				{
					if (_buildingVO.modules.hasOwnProperty(slots[i]))
						_modules[slots[i]] = _buildingVO.modules[slots[i]];

				}
			}

			//start off with the currently equipped modules
			showEquipped();

			addEffects();
			effectsIN();
		}

		private function createProgressBar( barRef:String, labelRef:String, valueRef:String, protoName:String, x:int, y:int ):void
		{
			var statHolderClass:Class  = Class(getDefinitionByName('RefitWindowStatsBarBGBMD'));
			var statHolder:Bitmap      = new Bitmap(BitmapData(new statHolderClass));
			statHolder.x = x - 9;
			statHolder.y = y - 4;
			addChild(statHolder);
			_statHolder.push(statHolder);

			var statProto:IPrototype   = presenter.getStatPrototypeByName(protoName);
			var defaultMaxValue:Number = presenter.getConstantPrototypeValueByName("interfaceCalibrationDefaultStatValue");
			var maxValue:Number        = statProto.getUnsafeValue("stdMax");
			maxValue = (maxValue) ? maxValue : defaultMaxValue;
			this[barRef] = new ProgressBar();
			this[barRef].init(ProgressBar.HORIZONTAL, new Bitmap(new BitmapData(248, 15, true, 0x994f82b4)), null, 0.01);
			this[barRef].setMinMax(0, maxValue);
			this[barRef].x = x;
			this[barRef].y = y;
			addChild(this[barRef]);

			this[labelRef] = new Label(12, 0xFFFFFF, 248, 25, true, 1);
			this[labelRef].align = TextFormatAlign.LEFT;
			this[labelRef].text = statProto.getValue("lableLocKey");
			this[labelRef].y = this[barRef].y - 3;
			this[labelRef].x = this[barRef].x;
			this[labelRef].constrictTextToSize = false;
			addChild(this[labelRef]);

			this[valueRef] = new Label(12, 0xFFFFFF, 248, 25, true, 1);
			this[valueRef].align = TextFormatAlign.RIGHT;
			this[valueRef].y = this[barRef].y - 3;
			this[valueRef].x = this[barRef].x;
			this[valueRef].constrictTextToSize = false;
			addChild(this[valueRef]);
		}

		private function setBarValue( stat:String, useStatCalc:Boolean, rating:Boolean ):void
		{
			// Get the stat value by calc or directly as needed
			var statValue:Number;
			if (useStatCalc && _buildingVO)
				statValue = StatCalcUtil.entityStatCalc(_buildingVO, stat);
			else
				statValue = _buildingVO[stat];


			// Format the value and turn it into a string
			var statProto:IPrototype = presenter.getStatPrototypeByName(stat);
			var statString:String    = StringUtil.formatValue(String(statValue), statProto, "flat", "base");
			this["_" + stat + "Value"].setTextWithTokens(statProto.getValue("valueLocKey"), {'[[Value]]':statString});

			// Show modifier if this was a rating
			if (rating)
			{
				var loc:Localization = Localization.instance;
				var modProto:IPrototype = presenter.getStatPrototypeByName("genericPercent");
				var percentString:String = modProto.getValue("valueLocKey");
				var modValue:Number = CommonFunctionUtil.ratingToModifier(statValue);
				var modString:String = StringUtil.formatValue(String(modValue), modProto, "flat", "base");
				this["_" + stat + "Value"].text += loc.getStringWithTokens(percentString, {'[[Value]]':modString});
			}

			// Set the bar value
			this["_" + stat + "Bar"].amount = statValue;
		}

		private function onCancelClick( e:MouseEvent ):void
		{
			if (_transaction)
			{
				//cancel the refit
				presenter.cancelTransaction(_transaction);
				destroy();
			}
		}

		private function onBuildClick( e:MouseEvent ):void
		{
			//do refitting
			if (_newComponents)
			{
				var transaction:TransactionVO = presenter.getStarbaseBuildingTransaction('Defense');
				if (transaction)
				{
					popBusyDialog();
				} else
				{
					presenter.performTransaction(TransactionEvent.STARBASE_REFIT_BUILDING, _buildingVO, PurchaseTypeEnum.NORMAL, _modules);
					destroy();
				}
			}
		}

		private function onBuildNowClick( e:MouseEvent ):void
		{
			if (_newComponents)
			{
				var transaction:TransactionVO = presenter.getStarbaseBuildingTransaction('Defense');
				if (transaction)
				{
					popBusyDialog();
				} else
				{
					presenter.performTransaction(TransactionEvent.STARBASE_REFIT_BUILDING, _buildingVO, PurchaseTypeEnum.INSTANT, _modules);
					destroy();
				}
			}
		}

		private function onRefitWithResourcePurchase():void
		{
			if (_newComponents)
			{
				var transaction:TransactionVO = presenter.getStarbaseBuildingTransaction('Defense');
				if (transaction)
				{
					popBusyDialog();
				} else
				{
					presenter.performTransaction(TransactionEvent.STARBASE_REFIT_BUILDING, _buildingVO, PurchaseTypeEnum.GET_RESOURCES, _modules);
					destroy();
				}
			}
		}

		private function popBusyDialog():void
		{
			var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
			buttons.push(new ButtonPrototype(_speedUpBtnText, speedUpDefenseTransaction, null, true, ButtonEnum.GOLD_A));
			buttons.push(new ButtonPrototype(_cancelBtnText));
			showConfirmation(_speedUpBtnText, _defenseProjectAlertBody, buttons);
		}

		private function speedUpDefenseTransaction():void
		{
			var transaction:TransactionVO = presenter.getStarbaseBuildingTransaction('Defense');
			if (transaction)
			{
				var nStoreView:StoreView = StoreView(_viewFactory.createView(StoreView));
				_viewFactory.notify(nStoreView);
				nStoreView.setSelectedTransaction(transaction);
			}
		}

		private function updateTimer( e:TimerEvent ):void
		{
			if (_transaction)
			{
				var buildTime:int = _transaction.timeRemainingMS;
				_refitInProgressComponent.timeRemaining = buildTime;
				if (buildTime <= 0)
					clearTimer();
			} else
				clearTimer();

		}

		private function clearTimer():void
		{
			_refitTimer.stop();
		}

		private function openStoreToTransaction( e:MouseEvent ):void
		{
			if (_transaction)
			{
				var nStoreView:StoreView = StoreView(_viewFactory.createView(StoreView));
				_viewFactory.notify(nStoreView);
				nStoreView.setSelectedTransaction(_transaction);
				destroy();
			}
		}

		private function onPurchaseMoreResources( args:Array ):void
		{
			if (args && args.length > 0)
			{
				var nStoreView:StoreView = StoreView(_viewFactory.createView(StoreView));
				_viewFactory.notify(nStoreView);
				nStoreView.openToResourcesAndFilter(args[0]);
			}
		}

		private function onSelectComponent( slotId:String, index:uint, currentComponentSelection:ComponentSelection ):void
		{
			var basicSlotType:String              = presenter.getSlotType(currentComponentSelection.slotName);
			var constructionView:ConstructionView = ConstructionView(_viewFactory.createView(ConstructionView));
			constructionView.openOn(ConstructionView.COMPONENT, basicSlotType, null);
			_viewFactory.notify(constructionView);
		}

		protected function onClickCannotAffordResourceDialog( e:MouseEvent ):void
		{
			if (_currentRequirements.purchaseVO.canPurchaseResourcesWithPremium)
			{
				var purchaseVO:PurchaseVO  = _currentRequirements.purchaseVO;
				var view:ResourceModalView = ResourceModalView(_viewFactory.createView(ResourceModalView));
				_viewFactory.notify(view);
				view.setUp(purchaseVO.creditsAmountShort, purchaseVO.alloyAmountShort, purchaseVO.energyAmountShort, purchaseVO.syntheticAmountShort, 'CodeString.Alert.BuyResources.Title', 'CodeString.Alert.BuyResources.Body',
						   false, onRefitWithResourcePurchase, purchaseVO.resourcePremiumCost);
			} else
				popPaywall();
		}

		public function onModuleSelected( component:IPrototype ):void
		{
			var slot:String = _buildingVO.getValue("slots")[0];
			_buildingVO.equipRefitModule(component, slot);
			_modules[slot] = component;
			showEquipped();
		}

		private function showEquipped():void
		{
			var slots:Array        = _buildingVO.prototype.getValue('slots');
			var assetVO:AssetVO;
			var kalganCost:int     = 0;
			var title:String       = '';
			var description:String = '';
			var details:String     = '';
			var proto:IPrototype;
			_newComponents = false;

			_currentRequirements = null;
			//note the UI was only designed to work with 1 module
			for (var slot:String in _modules)
			{
				if (_modules.hasOwnProperty(slot))
				{
					proto = _modules[slot];
					if (proto)
					{
						if (!_buildingVO.modules.hasOwnProperty(slot) || proto != _buildingVO.modules[slot])
							_newComponents = true;

						assetVO = presenter.getAssetVO(proto);
						title = assetVO.visibleName;

							//						_description.text = assetVO.descriptionText;
					} else
					{
						// Player has cleared the slot. This only works because there is only one slot.
						//						_description.text = "";
						_buildCostComponent.visible = false;
						if (slot in _buildingVO.modules && proto != _buildingVO.modules[slot])
							_newComponents = true;
					}

					(_entityComponents[slot] as ComponentSelection).selectedComponent = proto;
				}
				_currentRequirements = presenter.getRequirements(TransactionEvent.STARBASE_REFIT_BUILDING, _buildingVO);
			}


			if (proto)
			{
				if (_newComponents)
				{
					_buildComponent.timeCost = (_buildingVO.buildTimeSeconds > 0) ? _buildingVO.buildTimeSeconds : 0;

					if (_currentRequirements)
					{
						_buildCostComponent.updateCost(_buildingVO.alloyCost, (_currentRequirements.purchaseVO.alloyAmountShort == 0), CurrencyEnum.ALLOY);
						_buildCostComponent.updateCost(_buildingVO.creditsCost, (_currentRequirements.purchaseVO.creditsAmountShort == 0), CurrencyEnum.CREDIT);
						_buildCostComponent.updateCost(_buildingVO.energyCost, (_currentRequirements.purchaseVO.energyAmountShort == 0), CurrencyEnum.ENERGY);
						_buildCostComponent.updateCost(_buildingVO.syntheticCost, (_currentRequirements.purchaseVO.syntheticAmountShort == 0), CurrencyEnum.SYNTHETIC);

						_buildComponent.requirements = _currentRequirements;
					}

					_buildComponent.instantCost = _currentRequirements.purchaseVO.premium;

					if (!_transaction)
						_buildCostComponent.visible = true;
					_buildComponent.actionBtnText = _build;
					_buildComponent.instantActionBtnText = _buildNow;

				} else
					_buildCostComponent.visible = false;

				_statWindowString = StringUtil.getTooltip(proto.getValue('type'), proto, false);

				_equippedMod = proto;

			} else
			{
				_buildComponent.timeCost = 0;
				_buildCostComponent.visible = false;
				_infoBtn.visible = false;
			}

			if (_isTurret)
				setBarValue("buildingDps", false, false);
			else
			{
				setBarValue("forceShielding", false, false);
				setBarValue("explosiveShielding", false, false);
				setBarValue("energyShielding", false, false);
			}
			setBarValue("health", true, false);
			setBarValue("profile", true, true);
			setBarValue("armor", true, true);
			setBarValue("masking", true, true);

			_buildComponent.enabled = _newComponents;

			title = Localization.instance.getString(title);
			if (title == '')
			{
				title = Localization.instance.getString(_emptySlot);
				_equippedTitle.htmlText = '<a href="event:' + title + '">' + title.toUpperCase() + '</a>';
			} else
			{
				_equippedTitle.htmlText = '<a href="event:' + title + '">' + title.toUpperCase() + '</a>';
				_equippedTitle.textColor = _entityComponents[slots[0]].rarityColor;
			}


		}

		private function linkEvent( event:TextEvent ):void
		{
			var slots:Array           = _buildingVO.prototype.getValue('slots');
			var cs:ComponentSelection = _entityComponents[slots[0]];

			onSelectComponent(cs.slotType, 0, cs);
		}

		private function layoutComponentSelectors():void
		{
			_entityComponents = new Dictionary;
			var slots:Array = _buildingVO.prototype.getValue('slots');
			var spaceX:int  = 50;
			var spaceY:int  = 50;

			var type:String;
			var cs:ComponentSelection;
			var xpos:Number = 109;
			var ypos:Number = 168;

			if (slots[0].indexOf(SlotComponentEnum.SLOT_TYPE_TECH) != -1)
				type = SlotComponentEnum.SLOT_TYPE_TECH;
			else if (slots[0].indexOf(SlotComponentEnum.SLOT_TYPE_DEFENSE) != -1)
				type = SlotComponentEnum.SLOT_TYPE_DEFENSE;
			else if (slots[0].indexOf(SlotComponentEnum.SLOT_TYPE_SPECIAL) != -1)
				type = SlotComponentEnum.SLOT_TYPE_SPECIAL;
			else if (slots[0].indexOf(SlotComponentEnum.SLOT_TYPE_WEAPON) != -1)
				type = SlotComponentEnum.SLOT_TYPE_WEAPON;
			else if (slots[0].indexOf(SlotComponentEnum.SLOT_TYPE_SHIELD) != -1)
				type = SlotComponentEnum.SLOT_TYPE_DEFENSE;
			cs = new ComponentSelection(type, slots[0], 0);
			cs.x = 171;
			cs.y = 230;
			xpos += cs.width;
			cs.onSelectComponent.add(onSelectComponent);
			cs.onHover.add(highlightPrototypeLabel);
			_entityComponents[slots[0]] = cs;
			addChild(cs);
		}

		private function onTextRollOver( e:MouseEvent ):void
		{
			if (_buildingVO)
			{
				var slots:Array = _buildingVO.prototype.getValue('slots');
				if (slots && slots.length > 0)
				{
					Label(e.target).textColor = 0xb3ddf2;
					_entityComponents[slots[0]].onOutsideRollOver();
				}
			}

		}

		private function onTextRollOut( e:MouseEvent ):void
		{
			if (_buildingVO)
			{
				var slots:Array = _buildingVO.prototype.getValue('slots');
				if (slots && slots.length > 0)
				{
					Label(e.target).textColor = _entityComponents[slots[0]].rarityColor;
					_entityComponents[slots[0]].onOutsideRollOut();
				}
			}
		}

		private function highlightPrototypeLabel( rollover:Boolean, index:uint ):void
		{
			var slots:Array = _buildingVO.prototype.getValue('slots');
			var color:uint;
			if (rollover)
				color = 0xb3ddf2;
			else
				color = _entityComponents[slots[0]].rarityColor;

			_equippedTitle.textColor = color;
		}

		private function showFullTooltip( e:MouseEvent ):void
		{
			_toolTipComponent.layoutTooltip(_statWindowString, 25, 68, 15, 6);

			var view:StatInformationView = StatInformationView(_viewFactory.createView(StatInformationView));
			view.SetUp(_toolTipComponent);
			_viewFactory.notify(view);
		}

		private function onImageLoaded( asset:BitmapData ):void
		{
			if (_refitEntityImage)
			{
				_refitEntityImage.onImageLoaded(asset);
				_refitEntityImage.x = 171 - (_refitEntityImage.width * 0.5);
				_refitEntityImage.y = 230 - (_refitEntityImage.height * 0.5);
			}
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		public function set buildingVO( vo:BuildingVO ):void
		{
			_buildingVO = vo;
			_buildingVO.calculateCosts();
		}

		private function popPaywall( e:MouseEvent = null ):void
		{
			CommonFunctionUtil.popPaywall();
		}

		[Inject]
		public function set presenter( value:IStarbasePresenter ):void  { _presenter = value; }
		public function get presenter():IStarbasePresenter  { return IStarbasePresenter(_presenter); }

		override public function get typeUnique():Boolean  { return false; }

		override public function destroy():void
		{
			super.destroy();

			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;
			_moduleKey = null;
			_statBg = null;

			_refitEntityImage.destroy();
			_refitEntityImage = null;

			for each (var cs:ComponentSelection in _entityComponents)
			{
				cs.onSelectComponent.remove(onSelectComponent);
				cs.destroy();
			}
			_entityComponents = null;

			_viewTitle.destroy();
			_viewTitle = null;

			_statsTitle.destroy();
			_statsTitle = null;

			_equippedTitle.destroy();
			_equippedTitle = null;

			_buildingVO = null;
			_modules = null;

			_buildComponent.destroy();
			_buildComponent = null;

			ObjectPool.give(_buildCostComponent);
			_buildCostComponent = null;

			_refitInProgressComponent.destroy();
			_refitInProgressComponent = null;

			ObjectPool.give(_toolTipComponent);
			_toolTipComponent = null;

			_currentRequirements = null;

			_statWindowString = null;

			_infoBtn.destroy();
			_infoBtn = null;

			_armorBar.destroy();
			_armorBar = null;

			if (_isTurret)
			{
				_buildingDpsBar.destroy();
				_buildingDpsBar = null;

				_buildingDpsLabel.destroy();
				_buildingDpsLabel = null;

				_buildingDpsValue.destroy();
				_buildingDpsValue = null;
			} else
			{
				_forceShieldingBar.destroy();
				_forceShieldingBar = null;

				_explosiveShieldingBar.destroy();
				_explosiveShieldingBar = null;

				_energyShieldingBar.destroy();
				_energyShieldingBar = null;

				_forceShieldingLabel.destroy();
				_forceShieldingLabel = null;

				_forceShieldingValue.destroy();
				_forceShieldingValue = null;

				_explosiveShieldingLabel.destroy();
				_explosiveShieldingLabel = null;

				_explosiveShieldingValue.destroy();
				_explosiveShieldingValue = null;

				_energyShieldingLabel.destroy();
				_energyShieldingLabel = null;

				_energyShieldingValue.destroy();
				_energyShieldingValue = null;
			}

			_healthBar.destroy();
			_healthBar = null;

			_maskingBar.destroy();
			_maskingBar = null;

			_profileBar.destroy();
			_profileBar = null;

			_healthLabel.destroy();
			_healthLabel = null;

			_healthValue.destroy();
			_healthValue = null;

			_profileLabel.destroy();
			_profileLabel = null;

			_profileValue.destroy();
			_profileValue = null;

			_armorLabel.destroy();
			_armorLabel = null;

			_armorValue.destroy();
			_armorValue = null;

			_maskingLabel.destroy();
			_maskingValue = null;

			_equippedMod = null;
		}
	}
}
