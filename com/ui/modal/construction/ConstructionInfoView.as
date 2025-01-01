package com.ui.modal.construction
{
	import com.enum.AudioEnum;
	import com.controller.transaction.requirements.CategoryNotBuildingRequirement;
	import com.controller.transaction.requirements.IRequirement;
	import com.controller.transaction.requirements.PurchaseVO;
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.CurrencyEnum;
	import com.enum.StarbaseConstructionEnum;
	import com.enum.TypeEnum;
	import com.enum.server.PurchaseTypeEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.event.TransactionEvent;
	import com.model.asset.AssetVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BuildingVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.starbase.IConstructionPresenter;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;
	import com.ui.core.component.label.RequirementLabel;
	import com.ui.core.component.misc.ActionComponent;
	import com.ui.core.component.misc.BlueprintActionComponent;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.misc.TooltipComponent;
	import com.ui.hud.shared.command.ResourceComponent;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.information.ResourceModalView;
	import com.ui.modal.information.StatInformationView;
	import com.ui.modal.store.StoreView;
	import com.util.CommonFunctionUtil;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormatAlign;

	import org.adobe.utils.StringUtil;
	import org.shared.ObjectPool;

	public class ConstructionInfoView extends View
	{
		private var _actionComponent:ActionComponent;
		private var _bg:DefaultWindowBG;
		private var _blueprint:BlueprintVO;
		private var _blueprintActionComponent:BlueprintActionComponent;
		private var _blueprintActionComponent_complete:BlueprintActionComponent;
		private var _callback:Function;
		private var _closeButton:BitmapButton;
		private var _description:Label;
		private var _image:ImageComponent;
		private var _imageFrame:ScaleBitmap;
		private var _infoPanel:Sprite;
		private var _infoBtn:BitmapButton;
		private var _soundBtn:BitmapButton;
		private var _prototype:IPrototype;
		private var _requirements:RequirementVO;
		private var _requirementsBG:ScaleBitmap;
		private var _requirementLabels:Vector.<RequirementLabel>;
		private var _requirementsPanel:Sprite;
		private var _resourceComponent:ResourceComponent;
		private var _specialButton:BitmapButton;
		private var _state:int;
		private var _statsPanel:Sprite;
		private var _statWindowString:String;
		private var _title:Label;
		private var _tooltipComponent:TooltipComponent;
		private var _fullStatTooltipComponent:TooltipComponent;
		
		protected var _soundToPlay:String;

		//code strings for localization
		private var _buildNow:String              = 'CodeString.Shared.BuildNowBtn'; // Build Now
		private var _build:String                 = 'CodeString.Shared.BuildBtn'; //Build
		private var _getResources:String          = 'CodeString.Shared.GetResources'; //GET RESOURCES
		private var _research:String              = 'CodeString.Build.ResearchBtn';
		private var _researchNow:String           = 'CodeString.ResearchInformation.ResearchNowBtn'; //Research Now
		private var _upgrade:String               = 'CodeString.BuildUpgrade.UpgradeBtn'; // Upgrade
		private var _upgradeNow:String            = 'CodeString.BuildUpgrade.UpgradeNowBtn'; // Upgrade Now
		private var _buildProjectTitle:String     = 'CodeString.Alert.BuildInProgress.Title'; //Build Project In Progress
		private var _buildProjectAlertBody:String = 'CodeString.Alert.BuildInProgress.Body'; //You have a build project currently in progress. Would you like to speed it up?
		private var _speedUpBtnText:String        = 'CodeString.Shared.SpeedUp';
		private var _cancelBtnText:String         = 'CodeString.Shared.CancelBtn';
		private var _contructionViewClose:String  = 'CodeString.ConstructionView.Close'; //CLOSE
		private var _contructionViewInfo:String   = 'CodeString.ConstructionView.Info'; //INFO
		private var _upgradeTitle:String          = 'CodeString.BuildUpgrade.Title.Upgrade'; //UPGRADE
		private var _detailsTitle:String          = 'CodeString.ConstructionItem.Details'; //DETAILS
		private var _buildTitle:String            = 'CodeString.ConstructionItem.Build'; //BUILD
		private var _researchTitle:String         = 'CodeString.Research.Title'; //RESEARCH
		private var _salvageTitle:String          = 'CodeString.Shared.SalvageBtn'; //SALVAGE
		private var _statsHeading:String          = 'CodeString.Shipyard.StatsHeading'; //STATS
		private var _requirementsHeading:String   = 'CodeString.Shared.Requirements'; //REQUIREMENTS
		private var _completeBtnText:String       = 'CodeString.Shared.CompleteBtn'; //COMPLETE
		private var _purchaseOneText:String       = 'CodeString.Shared.PurchaseOneBtn'; //PURCHASE ONE
		private var _completeResearchBtnText:String       = 'CodeString.Shared.CompleteResearchBtn'; //COMPLETE RESEARCH

		[Inject]
		override public function init():void
		{
			super.init();
			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(688, 308);

			_closeButton = UIFactory.getButton(ButtonEnum.BLUE_A, 240, 40, _bg.width - 263, _bg.height + 9, _contructionViewClose);

			setupInfoPanel();
			if (setupStatsPanel())
				setupRequirementsPanel();

			_closeButton.y = _bg.height + 9;

			addChild(_bg);
			addChild(_closeButton);
			if (_specialButton)
			{
				_specialButton.y = _closeButton.y;
				addChild(_specialButton);
			}
			addChild(_infoPanel);
			addChild(_statsPanel);
			addChild(_description);
			addChild(_image);
			addChild(_imageFrame);
			addChild(_title);
			addChild(_tooltipComponent);

			if (_requirementsPanel)
			{
				addChild(_requirementsPanel);
				addChild(_requirementsBG);
				addChild(_resourceComponent);
				addChild(_actionComponent);
				if (_blueprintActionComponent)
					addChild(_blueprintActionComponent);
				
				if(_blueprintActionComponent_complete)
					addChild(_blueprintActionComponent_complete);
				
				for (var i:int = 0; i < _requirementLabels.length; i++)
				{
					if (_requirementLabels[i].lbl.htmlText != "")
					{
						if (_requirementLabels[i].showLink)
						{
							_requirementLabels[i].lbl.addEventListener(TextEvent.LINK, onClickLink);
							_requirementLabels[i].lbl.mouseEnabled = true;
							_requirementLabels[i].lbl.styleSheet = LabelFactory.linkStyleSheet;
						}
						addChild(_requirementLabels[i]);
					}
				}
			}

			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);
			addListener(_closeButton, MouseEvent.CLICK, onClose);
			if (_specialButton)
				addListener(_specialButton, MouseEvent.CLICK, onSpecialClicked);

			_infoBtn = ButtonFactory.getBitmapButton('TradeRouteInfoBtnNeutralBMD', 111, 88, '', 0xFFFFFF, 'TradeRouteInfoBtnRollOverBMD', 'TradeRouteInfoBtnDownBMD');
			_infoBtn.addEventListener(MouseEvent.CLICK, showFullTooltip);
			addChild(_infoBtn);
			
			if (_soundToPlay != null)
			{
				_soundBtn = ButtonFactory.getBitmapButton('TradeRouteInfoBtnNeutralBMD', 111, 166, '', 0xFFFFFF, 'TradeRouteInfoBtnRollOverBMD', 'TradeRouteInfoBtnDownBMD');
				_soundBtn.addEventListener(MouseEvent.CLICK, playVOSound);
				addChild(_soundBtn);
			}

			addEffects();
			effectsIN();
		}

		public function setup( state:int, prototype:IPrototype ):void
		{
			_prototype = prototype;
			_state = state;
		}

		private function setupInfoPanel():void
		{
			_infoPanel = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED, PanelEnum.HEADER_NOTCHED, 667, 118, 32, _bg.bg.x + 15, _bg.bg.y + 5, _contructionViewInfo);

			_image = ObjectPool.get(ImageComponent);
			_image.init(100, 100);
			_image.center = true;
			_image.x = _infoPanel.x + 9;
			_image.y = _infoPanel.y + 41;

			_imageFrame = UIFactory.getPanel(PanelEnum.CHARACTER_FRAME, 100, 100, _image.x, _image.y);

			var assetVO:AssetVO = presenter.getAssetVO(_prototype);
			
			if(false && assetVO.key != null && assetVO.key.length > 0)
				_soundToPlay = AudioEnum.VO_INFO_BASE_DIRECTORY + assetVO.key + AudioEnum.VO_INFO_BASE_FORMAT;
			
			presenter.loadImage(assetVO.mediumImage, _image.onImageLoaded);

			_title = UIFactory.getLabel(LabelEnum.TITLE, 300, 45, _image.x + 108, _image.y - 2);
			_title.align = TextFormatAlign.LEFT;
			_title.useLocalization = false;
			_title.bold = false;
			_title.constrictTextToSize = true;
			_title.text = Localization.instance.getString(assetVO.visibleName).toUpperCase();

			_description = UIFactory.getLabel(LabelEnum.DESCRIPTION, 525, 75, _title.x, _title.y + _title.height - 15);
			_description.fontSize = 14;
			_description.leading = -2;
			_description.text = assetVO.descriptionText;
		}

		private function setupStatsPanel():Boolean
		{
			var proto:IPrototype;
			var showRequirements:Boolean = true;
			_statsPanel = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED, PanelEnum.HEADER_NOTCHED, 667, 110, 32, _infoPanel.x, _infoPanel.y + _infoPanel.height + 4, _statsHeading);

			_tooltipComponent = ObjectPool.get(TooltipComponent);
			_tooltipComponent.init(3, _statsPanel.width - 8, 92);
			_tooltipComponent.x = _statsPanel.x + 4;
			_tooltipComponent.y = _statsPanel.y + 36;
			_tooltipComponent.mouseEnabled = _tooltipComponent.mouseChildren = false;

			_fullStatTooltipComponent = ObjectPool.get(TooltipComponent);
			_fullStatTooltipComponent.init(2, 332, 278);
			_fullStatTooltipComponent.mouseEnabled = _fullStatTooltipComponent.mouseChildren = false;

			switch (_state)
			{
				case ConstructionView.BUILD:
					var count:int              = presenter.getBuildingCount(_prototype.itemClass);
					var maxCount:int           = presenter.getBuildingMaxCount(_prototype.itemClass);
					var building:BuildingVO    = new BuildingVO();
					proto = _prototype;
					if (_prototype is BuildingVO)
					{
						if (presenter.getBuildingUpgrade(_prototype.getValue('upgrade')) != null)
						{
							_bg.addTitle(_upgradeTitle, 300);
							proto = presenter.getBuildingUpgrade(_prototype.getValue('upgrade'));
							building.prototype = proto;
							_requirements = presenter.getRequirements(TransactionEvent.STARBASE_BUILDING_UPGRADE, building);
						} else
						{
							_bg.addTitle(_detailsTitle, 300);
							showRequirements = false;
						}
					} else
					{
						if (count < maxCount)
						{
							_bg.addTitle(_buildTitle, 300);
							building.prototype = proto;
							_requirements = presenter.getRequirements(TransactionEvent.STARBASE_BUILDING_BUILD, building);
						} else if (_prototype.getValue('constructionCategory') != StarbaseConstructionEnum.PLATFORM &&
							presenter.getBuildingVOByClass(_prototype.itemClass, true) &&
							presenter.getBuildingVOByClass(_prototype.itemClass, true).level != 10)
						{
							_bg.addTitle(_upgradeTitle, 300);
							_prototype = presenter.getBuildingVOByClass(_prototype.itemClass, true);
							proto = presenter.getBuildingUpgrade(_prototype.getValue('upgrade'));
							building.prototype = proto;
							_requirements = presenter.getRequirements(TransactionEvent.STARBASE_BUILDING_UPGRADE, building);
						} else
						{
							_bg.addTitle(_detailsTitle, 300);
							showRequirements = false;
						}
					}

					_statWindowString = StringUtil.getTooltip(_prototype.getValue("type"), _prototype is BuildingVO ? BuildingVO(_prototype).prototype : _prototype, false);

					_title.text += " " + count + "/" + maxCount;
					_tooltipComponent.layoutTooltip(StringUtil.getTooltip(_prototype.getValue("type"), proto is BuildingVO ? BuildingVO(proto).prototype : proto, false, (proto == _prototype) ? null : _prototype));
					if (_prototype is BuildingVO && _prototype.getValue("canBeRecycled") == true)
						_specialButton = UIFactory.getButton(ButtonEnum.RED_A, 240, 40, _closeButton.x - 250, _closeButton.y, _salvageTitle);
					break;

				case ConstructionView.RESEARCH:
					var requirementMet:Boolean = presenter.requirementsMet(_prototype);
					var isResearched:Boolean   = presenter.isResearched(_prototype.name);
					if (isResearched || !requirementMet)
					{
						if (isResearched)
							showRequirements = false;
						_bg.addTitle(_detailsTitle, 300);
					} else if (requirementMet)
						_bg.addTitle(_researchTitle, 300);

					//see if this is a blueprint
					var blueprint:BlueprintVO  = presenter.getBlueprint(_prototype.name);
					if (blueprint && (CONFIG::IS_CRYPTO || blueprint.partsCollected < blueprint.totalParts))
						_title.text += " " + blueprint.partsCollected + "/" + blueprint.totalParts;
					if (blueprint)
						_requirements = presenter.getRequirements(TransactionEvent.STARBASE_BLUEPRINT_PURCHASE, _prototype);
					else
						_requirements = presenter.getRequirements(TransactionEvent.STARBASE_RESEARCH, _prototype);

					var rarity:String          = _prototype.getUnsafeValue('rarity');
					if (rarity != 'Common')
					{
						var glow:GlowFilter = CommonFunctionUtil.getRarityGlow(rarity);
						_title.textColor = glow.color;
						_imageFrame.filters = [glow];
					}

					proto = presenter.getResearchItemPrototypeByName(_prototype.getValue("referenceName"));
					_tooltipComponent.layoutTooltip(StringUtil.getTooltip(proto.getValue("type"), proto, false));
					_statWindowString = StringUtil.getTooltip(proto.getValue("type"), proto, false);
					break;
			}

			if (!showRequirements)
			{
				_statsPanel = UIFactory.destroyPanel(_statsPanel);
				_statsPanel = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_DOUBLE_NOTCHED, PanelEnum.HEADER_NOTCHED, 667, 110, 32, _infoPanel.x, _infoPanel.y + _infoPanel.height + 4, _statsHeading);
			}

			return showRequirements;
		}

		private function setupRequirementsPanel():void
		{
			_bg.setBGSize(688, 498);
			_requirementLabels = new Vector.<RequirementLabel>;
			_requirementsPanel = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_DOUBLE_NOTCHED, PanelEnum.HEADER_NOTCHED, 667, 155, 32, _infoPanel.x, _statsPanel.y + _statsPanel.height + 4, _requirementsHeading);

			_requirementsBG = UIFactory.getPanel(PanelEnum.CONTAINER_NOTCHED_RIGHT_SMALL, 646, 61, _requirementsPanel.x + 9, _requirementsPanel.y + 40);
			_resourceComponent = ObjectPool.get(ResourceComponent);
			_resourceComponent.init(true, false, 35);
			_resourceComponent.x = _requirementsBG.x;
			_resourceComponent.y = _requirementsBG.y + _requirementsBG.height + 9;

			_resourceComponent.updateCost(_requirements.purchaseVO.alloyCost, _requirements.purchaseVO.alloyAmountShort == 0, CurrencyEnum.ALLOY);
			_resourceComponent.updateCost(_requirements.purchaseVO.creditsCost, _requirements.purchaseVO.creditsAmountShort == 0, CurrencyEnum.CREDIT);
			_resourceComponent.updateCost(_requirements.purchaseVO.energyCost, _requirements.purchaseVO.energyAmountShort == 0, CurrencyEnum.ENERGY);
			_resourceComponent.updateCost(_requirements.purchaseVO.syntheticCost, _requirements.purchaseVO.syntheticAmountShort == 0, CurrencyEnum.SYNTHETIC);

			switch (_state)
			{
				case ConstructionView.BUILD:
					var building:BuildingVO = new BuildingVO();
					var action:String       = (_prototype is BuildingVO) ? _upgrade : _build;
					var instant:String      = (_prototype is BuildingVO) ? _upgradeNow : _buildNow;
					_actionComponent = new ActionComponent(new ButtonPrototype(action, onActionBtnClick), new ButtonPrototype(instant, onActionBtnClick), new ButtonPrototype(_getResources, onClickCannotAffordResourceDialog),
														   new ButtonPrototype(instant, onActionBtnClick));
					_actionComponent.instantCost = _requirements.purchaseVO.premium;

					if (_prototype is BuildingVO && _prototype.getValue("upgrade") != "")
						building.prototype = presenter.getBuildingUpgrade(_prototype.getValue('upgrade'));
					else
						building.prototype = _prototype;

					_actionComponent.timeCost = building.buildTimeSeconds;
					_actionComponent.requirements = _requirements;

					var requirement:IRequirement;
					for (var i:int = 0; i < _requirements.requirements.length; ++i)
					{
						requirement = _requirements.requirements[i];
						if (!(requirement is CategoryNotBuildingRequirement) && !requirement.isMet)
						{
							_actionComponent.enabled = false;
							break;
						}
					}
					break;

				case ConstructionView.RESEARCH:
					_actionComponent = new ActionComponent(new ButtonPrototype(_research, onActionBtnClick), new ButtonPrototype(_researchNow, onActionBtnClick), new ButtonPrototype(_getResources, onClickCannotAffordResourceDialog),
														   new ButtonPrototype(_researchNow, onActionBtnClick));
					_actionComponent.timeCost = _prototype.buildTimeSeconds;
					_actionComponent.enabled = _requirements.allMet;

					//see if this is a blueprint
					_blueprint = presenter.getBlueprint(_prototype.name);
					if (_blueprint)
					{
						_actionComponent.visible = false;
						_blueprintActionComponent = new BlueprintActionComponent(
							new ButtonPrototype(_completeBtnText, onBlueprintFullPurchase), new ButtonPrototype(_purchaseOneText, onBlueprintPartialPurchase),
							new ButtonPrototype(_purchaseOneText, popPaywall), new ButtonPrototype(_completeBtnText, popPaywall));
						_blueprintActionComponent.x = _resourceComponent.x + _resourceComponent.width + 25;
						_blueprintActionComponent.y = _resourceComponent.y + 3;
						_blueprintActionComponent.fullCost = presenter.getBlueprintHardCurrencyCost(_blueprint, _blueprint.partsRemaining);
						_blueprintActionComponent.partialCost = presenter.getBlueprintHardCurrencyCost(_blueprint, 1);
						if (_blueprint.partsCompleted == _blueprint.totalParts || _blueprint.partsCollected >= _blueprint.totalParts)
							_blueprintActionComponent.visible = false;
						_resourceComponent.visible = false;
					}
					
					if(CONFIG::IS_CRYPTO)
					{
						if (_blueprint)
						{
							_actionComponent.visible = false;
							_blueprintActionComponent_complete = new BlueprintActionComponent(
								new ButtonPrototype(_completeResearchBtnText, onBlueprintResearchComplete), new ButtonPrototype(_purchaseOneText, onBlueprintPartialPurchase),
								new ButtonPrototype(_purchaseOneText, popPaywall), new ButtonPrototype(_completeResearchBtnText, popPaywall));
							_blueprintActionComponent_complete.x = _resourceComponent.x + _resourceComponent.width + 25;
							_blueprintActionComponent_complete.y = _resourceComponent.y + 3;
							_blueprintActionComponent_complete.fullCost = 0;
							_blueprintActionComponent_complete.partialCost = 0;
							if (_blueprint.partsCompleted == 0 && _blueprint.partsCollected >= _blueprint.totalParts)
								_blueprintActionComponent_complete.visible = true;
							else
								_blueprintActionComponent_complete.visible = false;
							_resourceComponent.visible = false;
						}
					}

					break;
			}
			_actionComponent.instantCost = _requirements.purchaseVO.premium;
			_actionComponent.requirements = _requirements;
			_actionComponent.x = _resourceComponent.x + _resourceComponent.width + 50;
			_actionComponent.y = _resourceComponent.y + 3;

			//show the requirements
			var currentLabel:RequirementLabel;
			var yPos:int = 0;
			for (i = 0; i < _requirements.requirements.length; i++)
			{
				var hText:String = _requirements.requirementsToHtml(_requirements.requirements[i]);

				if (hText != "")
				{
					currentLabel = new RequirementLabel(0, 0, 12, 0xF0F0F0, 275, 30, true, 1);
					currentLabel.lbl.multiline = true;
					currentLabel.lbl.constrictTextToSize = false;
					currentLabel.lbl.align = TextFormatAlign.LEFT;
					currentLabel.lbl.htmlText = hText;
					currentLabel.x = _requirementsBG.x + 6 + (325 * Math.floor(_requirementLabels.length / 3));
					currentLabel.y = _requirementsBG.y + 2 + yPos;
					yPos += currentLabel.lbl.textHeight + 1;
					if (_requirementLabels.length == 2)
						yPos = 0;
					currentLabel.formatObject();

					if (!(_requirements.requirements[i].isMet))
					{
						currentLabel.checkMark.visible = false;
						currentLabel.showLink = true;
					} else
					{
						currentLabel.checkMark.visible = true;
						currentLabel.showLink = false;
					}
					_requirementLabels.push(currentLabel);
				}
			}
		}

		private function onClickLink( event:TextEvent ):void
		{
			var proto:IPrototype = presenter.getPrototypeByName(event.text);
			if (proto)
			{
				var key:uint                  = uint(proto.getValue('type'));
				var isBuilding:Boolean;
				switch (key)
				{
					case TypeEnum.BUILDING_TT:
					case TypeEnum.BASE_SHIELD_TT:
					case TypeEnum.BASE_TURRET_TT:
						isBuilding = true;
				}

				var view:ConstructionInfoView = ConstructionInfoView(_viewFactory.createView(ConstructionInfoView));
				if (isBuilding)
				{
					var building:BuildingVO = presenter.getBuildingVOByClass(proto.itemClass);
					view.setup(ConstructionView.BUILD, building ? building : proto);
				} else
					view.setup(ConstructionView.RESEARCH, proto);
				_viewFactory.notify(view);
			}
			destroy();
		}

		private function popBusyDialog():void
		{
			var title:String                     = _buildProjectTitle;
			var body:String                      = _buildProjectAlertBody;

			var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
			buttons.push(new ButtonPrototype(_speedUpBtnText, speedUpTransaction, [presenter.getStarbaseBuildingTransaction(_prototype.getValue("constructionCategory"))], true, ButtonEnum.GOLD_A));
			buttons.push(new ButtonPrototype(_cancelBtnText));
			showConfirmation(title, body, buttons);
		}

		private function onActionBtnClick( e:MouseEvent = null ):void
		{
			if(_actionComponent == null)
				return;
			
			if(_prototype == null)
				return;
			
			var purchaseType:int = (!e || e.currentTarget == _actionComponent.actionBtn) ? PurchaseTypeEnum.NORMAL : PurchaseTypeEnum.INSTANT;
			if (purchaseType == PurchaseTypeEnum.NORMAL && _requirements && _requirements.purchaseVO && !_requirements.purchaseVO.canPurchase)
				purchaseType = PurchaseTypeEnum.GET_RESOURCES;
			switch (_state)
			{
				case ConstructionView.BUILD:
					if (presenter.getStarbaseBuildingTransaction(_prototype.getValue("constructionCategory")) != null)
						popBusyDialog();
					else
					{
						if (purchaseType == PurchaseTypeEnum.INSTANT && _requirements && _requirements.purchaseVO && !_requirements.purchaseVO.canPurchaseWithPremium)
						{
							popPaywall(null);
							return;
						}
						if (_prototype is BuildingVO)
							presenter.performTransaction(TransactionEvent.STARBASE_BUILDING_UPGRADE, BuildingVO(_prototype), purchaseType);
						else
							presenter.performTransaction(TransactionEvent.STARBASE_BUILDING_BUILD, _prototype, purchaseType);
						if (_callback != null)
							_callback();
						destroy();
					}
					break;

				case ConstructionView.RESEARCH:
					if (presenter.getStarbaseResearchTransaction(_prototype.getValue("requiredBuildingClass")) != null)
						popBusyDialog();
					else
					{
						if (purchaseType == PurchaseTypeEnum.INSTANT && _requirements && _requirements.purchaseVO && !_requirements.purchaseVO.canPurchaseWithPremium)
						{
							popPaywall(null);
							return;
						}
						presenter.performTransaction(TransactionEvent.STARBASE_RESEARCH, _prototype, purchaseType);
						if (_callback != null)
							_callback();
						destroy();
					}
					break;
			}
		}

		private function onClickCannotAffordResourceDialog( e:MouseEvent ):void
		{
			switch (_state)
			{
				case ConstructionView.BUILD:
					if (presenter.getStarbaseBuildingTransaction(_prototype.getValue("constructionCategory")) != null)
					{
						popBusyDialog();
						return;
					}
					break;

				case ConstructionView.RESEARCH:
					if (presenter.getStarbaseResearchTransaction(_prototype.getValue("requiredBuildingClass")) != null)
					{
						popBusyDialog();
						return;
					}
					break;
			}

			if (_requirements.purchaseVO.canPurchaseResourcesWithPremium)
			{
				var purchaseVO:PurchaseVO  = _requirements.purchaseVO;
				var view:ResourceModalView = ResourceModalView(_viewFactory.createView(ResourceModalView));
				_viewFactory.notify(view);
				view.setUp(purchaseVO.creditsAmountShort, purchaseVO.alloyAmountShort, purchaseVO.energyAmountShort, purchaseVO.syntheticAmountShort, 'CodeString.Alert.BuyResources.Title', 'CodeString.Alert.BuyResources.Body',
						   false, onActionBtnClick, purchaseVO.resourcePremiumCost);
			} else
				popPaywall();
		}

		private function onSpecialClicked( e:MouseEvent ):void
		{
			var selectedAsset:String   = _prototype.asset;
			var selectedLevel:int      = _prototype.getValue('level');
			var creditRefund:int       = _prototype.creditsCost;
			var alloyRefund:int        = _prototype.alloyCost;
			var energyRefund:int       = _prototype.energyCost;
			var syntheticRefund:int    = _prototype.syntheticCost;

			/*var allBuildings:Vector.<IPrototype> = presenter.buildingPrototypes;
			   var len:uint                         = allBuildings.length;
			   var currentVO:IPrototype;
			   for (var i:uint = 0; i < len; ++i)
			   {
			   currentVO = allBuildings[i];
			   if (currentVO != null && selectedAsset == currentVO.asset && selectedLevel > currentVO.getValue('level'))
			   {
			   creditRefund = _buildingVO.creditsCost;
			   alloyRefund = _buildingVO.alloyCost;
			   energyRefund = _buildingVO.energyCost;
			   syntheticRefund = _buildingVO.syntheticCost;
			   }
			   }*/

			creditRefund = _prototype.creditsCost;
			alloyRefund = _prototype.alloyCost;
			energyRefund = _prototype.energyCost;
			syntheticRefund = _prototype.syntheticCost;

			var view:ResourceModalView = ResourceModalView(_viewFactory.createView(ResourceModalView));
			_viewFactory.notify(view);
			view.setUp(Math.floor(creditRefund * 0.20), Math.floor(alloyRefund * 0.20), Math.floor(syntheticRefund * 0.20), Math.floor(energyRefund * 0.20), 'CodeString.BuildRecycle.Title.Recycle', 'CodeString.BuildRecycle.Refund',
					   true, onRecycleClick);
		}

		private function onBlueprintFullPurchase( e:MouseEvent ):void
		{
			if (_blueprint && !_blueprint.complete)
			{
				presenter.purchaseBlueprint(_blueprint, _blueprint.partsRemaining);
				if (_callback != null)
					_callback();
				destroy();
			}
		}

		private function onBlueprintPartialPurchase( e:MouseEvent ):void
		{
			if (_blueprint && !_blueprint.complete)
			{
				presenter.purchaseBlueprint(_blueprint, 1);
				if (_callback != null)
					_callback();
				destroy();
			}
		}
		
		private function onBlueprintResearchComplete( e:MouseEvent ):void
		{
			if (_blueprint && !_blueprint.complete)
			{
				presenter.completeBlueprintResearch(_blueprint);
				if (_callback != null)
					_callback();
				destroy();
			}
		}

		private function popPaywall( e:MouseEvent = null ):void
		{
			CommonFunctionUtil.popPaywall();
		}

		private function onRecycleClick( e:MouseEvent = null ):void
		{
			presenter.performTransaction(TransactionEvent.STARBASE_BUILDING_RECYCLE, _prototype, PurchaseTypeEnum.INSTANT);
			if (_callback != null)
				_callback();
			destroy();
		}

		private function showFullTooltip( e:MouseEvent ):void
		{

			_fullStatTooltipComponent.layoutTooltip(_statWindowString, 25, 68, 10, 6);

			var view:StatInformationView = StatInformationView(_viewFactory.createView(StatInformationView));
			view.SetUp(_fullStatTooltipComponent);
			_viewFactory.notify(view);
		}
		private function playVOSound( e:MouseEvent ):void
		{
			if (_soundToPlay != null)
				presenter.playSound(_soundToPlay);
		}

		protected function speedUpTransaction( transaction:TransactionVO ):void
		{
			if (transaction)
			{
				var nStoreView:StoreView = StoreView(_viewFactory.createView(StoreView));
				_viewFactory.notify(nStoreView);
				nStoreView.setSelectedTransaction(transaction);
			}
		}

		public function set callback( v:Function ):void
		{
			_callback = v;
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( v:IConstructionPresenter ):void
		{
			_presenter = v;
		}

		public function get presenter():IConstructionPresenter
		{
			return IConstructionPresenter(_presenter);
		}

		override public function destroy():void
		{
			super.destroy();

			ObjectPool.give(_bg);
			_bg = null;
			_closeButton = UIFactory.destroyButton(_closeButton);
			_description = UIFactory.destroyLabel(_description);
			ObjectPool.give(_image);
			_image = null;
			_imageFrame = UIFactory.destroyPanel(_imageFrame);
			_infoPanel = UIFactory.destroyPanel(_infoPanel);
			_prototype = null;
			_requirements = null;
			_specialButton = UIFactory.destroyButton(_specialButton);
			_statsPanel = UIFactory.destroyPanel(_statsPanel);
			_title = UIFactory.destroyLabel(_title);
			ObjectPool.give(_tooltipComponent);
			_tooltipComponent = null;
			ObjectPool.give(_fullStatTooltipComponent);
			_fullStatTooltipComponent = null;

			if (_requirementsPanel)
			{
				_actionComponent = null;
				_blueprint = null;
				_blueprintActionComponent = null;
				_blueprintActionComponent_complete = null;
				_requirementsPanel = UIFactory.destroyPanel(_requirementsPanel);
				ObjectPool.give(_resourceComponent);
				_resourceComponent = null;
				_requirementsBG = UIFactory.destroyPanel(_requirementsBG);
				for (var i:int = 0; i < _requirementLabels.length; i++)
					_requirementLabels[i].lbl.removeEventListener(TextEvent.LINK, onClickLink);
				_requirementLabels.length = 0;
				_requirementLabels = null;
			}

			_infoBtn.destroy();
			_infoBtn = null;
			if(_soundBtn != null)
			{
				_soundBtn.destroy();
				_soundBtn = null;
			}
			_callback = null;
		}
	}
}
