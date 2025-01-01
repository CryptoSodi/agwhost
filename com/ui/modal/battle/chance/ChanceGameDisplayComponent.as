package com.ui.modal.battle.chance
{
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleRerollVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	import org.adobe.utils.StringUtil;
	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class ChanceGameDisplayComponent extends Sprite implements IComponent
	{
		public var onPurchaseComplete:Signal;
		public var loadIconSignal:Signal;
		public var rerollClickSignal:Signal;
		public var scanClickSignal:Signal;
		public var denyClickSignal:Signal;

		public var getBlueprintPrototype:Function;
		public var getResearchPrototypeByName:Function;
		public var getSelectionInfo:Function;

		private var _componentHolder:Sprite;

		private var _cargoFull:Boolean;
		private var _blueprintFrame:Bitmap;
		private var _blueprintShipIcon:ImageComponent;

		private var _purchaseBlueprintBtn:BitmapButton;
		private var _rerollBtn:BitmapButton;
		private var _deepScanBtn:BitmapButton;
		private var _denyBtn:BitmapButton;

		private var _blueprintBG:Bitmap;
		private var _blueprintNameBG:Bitmap;
		private var _blueprintGlow:Bitmap;
		private var _blueprintPremiumSymbol:Bitmap;
		private var _scanRerollSymbol:Bitmap;

		private var _blueprintName:Label;
		private var _bpCollectedNumbers:Label;
		private var _blueprintCompleteCost:Label;
		private var _deepScanCost:Label;
		private var _rerollCost:Label;

		private var _blueprint:BlueprintVO;
		private var _blueprintCost:int;
		private var _blueprintProto:IPrototype;

		private var _battleRerollVO:BattleRerollVO;

		private var _scanCost:Number;
		private var _rollCost:Number;

		private var _resourceHolder:Sprite;
		private var _resAlloySymbol:Bitmap;
		private var _resCreditsSymbol:Bitmap;
		private var _resEnergySymbol:Bitmap;
		private var _resSyntheticsSymbol:Bitmap;
		private var _resourceBG:Bitmap;

		private var _resAlloyLbl:Label;
		private var _resCreditsLbl:Label;
		private var _resEnergyLbl:Label;
		private var _resSyntheticsLbl:Label;

		private var _timeRemainingTitleLbl:Label;
		private var _timeRemainingLbl:Label;
		private var _timeRemaining:Timer;
		private var _timeProgressBar:ProgressBar;

		private var _colorFilter:ColorMatrixFilter;

		private var _scanPrice:int;
		private var _rerollPrice:int;

		private var _blueprintsCollectedString:String = 'CodeString.Shared.OutOf'; //[[Number.MinValue]]/[[Number.MaxValue]]
		private var _timeRemainingText:String         = 'CodeString.BattleUserView.TimeRemaining'; //TIME REMAINING
		private var _rerollBtnText:String             = 'CodeString.GameOfChance.RerollBtn'; //Reroll
		private var _deepScanBtnText:String           = 'CodeString.GameOfChance.DeepScanBtn'; //Deep Scan
		private var _noBlueprint:String               = 'CodeString.GameOfChance.NoBlueprint'; //BLUEPRINT NOT FOUND


		public function ChanceGameDisplayComponent()
		{
			super();
			onPurchaseComplete = new Signal(String, String);
			loadIconSignal = new Signal(String, Function);
			rerollClickSignal = new Signal(String, String);
			scanClickSignal = new Signal(String);
			denyClickSignal = new Signal(String);

			_colorFilter = CommonFunctionUtil.getColorMatrixFilter(0x3cf219);

			_componentHolder = new Sprite();

			var bgRect:Rectangle            = new Rectangle(175, 0, 6, 116);
			_blueprintBG = UIFactory.getScaleBitmap('LootedBlueprintBMD');
			_blueprintBG.scale9Grid = bgRect;
			_blueprintBG.width += 100;
			_blueprintBG.x = 0; //376;
			_blueprintBG.y = 0; //324;

			var blueprintBgFrameClass:Class = Class(getDefinitionByName('SelectionFrameBMD'));
			_blueprintFrame = new Bitmap(BitmapData(new blueprintBgFrameClass()));
			_blueprintFrame.x = 11; //385;
			_blueprintFrame.y = 7; //331;

			_blueprintShipIcon = new ImageComponent()
			_blueprintShipIcon.init(100, 100);

			var blueprintNoBPClass:Class    = Class(getDefinitionByName('IconNoBlueprintsBMD'));
			onBlueprintIconLoaded(BitmapData(new blueprintNoBPClass()));


			_blueprintCompleteCost = new Label(18, 0xf0f0f0, 114, 25, false);

			_blueprintNameBG = PanelFactory.getPanel('BlueprintNameTagBMD');
			_blueprintNameBG.x = _blueprintFrame.x + _blueprintFrame.width + 13;
			_blueprintNameBG.y = _blueprintFrame.y + _blueprintFrame.height - _blueprintNameBG.height;

			_blueprintName = new Label(16, 0x213745, 216, 25);
			_blueprintName.x = _blueprintNameBG.x;
			_blueprintName.y = _blueprintNameBG.y + 2;
			_blueprintName.text = _noBlueprint;

			_bpCollectedNumbers = new Label(12, 0xF0F0F0, 10, 25, true, 1);

			_denyBtn = ButtonFactory.getCloseButton(437, 0);
			_denyBtn.addEventListener(MouseEvent.CLICK, onDenyClick);

			_timeRemainingTitleLbl = UIFactory.getLabel(LabelEnum.DEFAULT, 88, 30, _blueprintFrame.x + _blueprintFrame.width + 143, _blueprintFrame.y);
			_timeRemainingTitleLbl.text = _timeRemainingText;
			_timeRemainingLbl = UIFactory.getLabel(LabelEnum.SUBTITLE, 88, 30, _blueprintFrame.x + _blueprintFrame.width + 143, _timeRemainingTitleLbl.y + _timeRemainingTitleLbl.textHeight + 2);

			_timeRemaining = new Timer(1000);
			_timeRemaining.addEventListener(TimerEvent.TIMER, onTimeRemainingTimer);

			var time:Bitmap                 = UIFactory.getBitmap(PanelEnum.STATBAR_GREY);
			time.width = _timeRemainingTitleLbl.width - 10;
			time.height = 15;

			_timeProgressBar = new ProgressBar();
			_timeProgressBar.init(ProgressBar.HORIZONTAL, time, null, 0.15);
			_timeProgressBar.setMinMax(0, 300000);
			_timeProgressBar.filters = [_colorFilter];
			_timeProgressBar.scaleY = 1.4;
			_timeProgressBar.x = _timeRemainingLbl.x + 5;
			_timeProgressBar.y = _timeRemainingLbl.y + _timeRemainingLbl.textHeight + 2;

			_componentHolder.addChild(_blueprintBG);
			_componentHolder.addChild(_blueprintFrame);
			_componentHolder.addChild(_blueprintShipIcon);
			_componentHolder.addChild(_denyBtn);
			_componentHolder.addChild(_timeProgressBar);
			_componentHolder.addChild(_timeRemainingTitleLbl);
			_componentHolder.addChild(_timeRemainingLbl);
			_componentHolder.addChild(_blueprintNameBG);
			_componentHolder.addChild(_blueprintName);

			addChild(_componentHolder);
		}

		[PostConstruct]
		public function init( blueprintVO:BlueprintVO ):void
		{
			if (blueprintVO)
				_blueprint = blueprintVO;
		}

		public function showScanView():void
		{
			_deepScanBtn = ButtonFactory.getBitmapButton('SquareBuyBtnNeutralBMD', 157, 5, _deepScanBtnText, 0xf7c78b, 'SquareBuyBtnRollOverBMD', 'SquareBuyBtnSelectedBMD');
			_deepScanBtn.x = _blueprintFrame.x + _blueprintFrame.width + 13;
			_deepScanBtn.y = _blueprintFrame.y + 2
			_deepScanBtn.label.fontSize = 22;
			_deepScanBtn.addEventListener(MouseEvent.CLICK, onDeepScanClick);
			_componentHolder.addChild(_deepScanBtn);

			_deepScanCost = UIFactory.getLabel(LabelEnum.DEFAULT, 114, 25, _deepScanBtn.x + 4, _deepScanBtn.y + 26);
			_deepScanCost.fontSize = 18;
			_deepScanCost.text = String(_scanCost);
			_componentHolder.addChild(_deepScanCost);

			_scanRerollSymbol = UIFactory.getBitmap('KalganSymbolBMD');
			_scanRerollSymbol.x = _deepScanBtn.x + 7;
			_scanRerollSymbol.y = _deepScanBtn.y + 24;
			_componentHolder.addChild(_scanRerollSymbol);

			if (_battleRerollVO.timeRemaining > 0 && !_timeRemaining.running)
				_timeRemaining.start();

		}

		public function showGainedResourcesView( rerollVO:BattleRerollVO ):void
		{
			_blueprintBG.visible = false;
			_blueprintFrame.visible = false;
			_denyBtn.visible = false;
			_blueprintShipIcon.visible = false;

			if (_rerollBtn)
			{
				_rerollBtn.visible = false;
				_rerollCost.visible = false;
				_scanRerollSymbol.visible = false;
			}

			if (_deepScanBtn)
			{
				_deepScanBtn.visible = false;
				_deepScanCost.visible = false;
				_scanRerollSymbol.visible = false;
			}

			if (_timeRemainingLbl)
			{
				_timeRemainingLbl.visible = false;
				_timeRemainingTitleLbl.visible = false;
				_timeProgressBar.visible = false;
			}

			getResourceIcons(rerollVO.creditsReward, rerollVO.alloyReward, rerollVO.energyReward, rerollVO.syntheticReward);
		}

		private function getResourceIcons( credGained:int, alloyGained:int, energyGained:int, synthGained:int ):void
		{
			_resourceBG = UIFactory.getBitmap('LootedResourceContainerBMD');
			_resourceBG.x = 103;
			_resourceBG.y = 0;

			_resourceHolder = new Sprite();
			_resourceHolder.x = 109;
			_resourceHolder.y = 11;

			_resCreditsSymbol = PanelFactory.getPanel('LootedResourceCreditsBMD');

			_resEnergySymbol = PanelFactory.getPanel('LootedResourceEnergyBMD');
			_resEnergySymbol.x = _resCreditsSymbol.x + 179;
			_resEnergySymbol.y = _resCreditsSymbol.y;

			_resAlloySymbol = PanelFactory.getPanel('LootedResourceAlloyBMD');
			_resAlloySymbol.x = _resCreditsSymbol.x;
			_resAlloySymbol.y = _resCreditsSymbol.y + 50;

			_resSyntheticsSymbol = PanelFactory.getPanel('LootedResourceSyntheticsBMD');
			_resSyntheticsSymbol.x = _resEnergySymbol.x;
			_resSyntheticsSymbol.y = _resAlloySymbol.y;


			_resCreditsLbl = new Label(13, 0xffdd3d, 140, 30, true, 1);
			_resCreditsLbl.x = _resCreditsSymbol.width * 0.5 + _resCreditsSymbol.x - 35;
			_resCreditsLbl.y = _resCreditsSymbol.height * 0.5 + _resCreditsSymbol.y - 4;
			_resCreditsLbl.constrictTextToSize = false;
			_resCreditsLbl.align = TextFormatAlign.LEFT;
			_resCreditsLbl.text = StringUtil.commaFormatNumber(credGained);
			_resCreditsLbl.letterSpacing = 1.5;


			_resAlloyLbl = new Label(13, 0xffdd3d, 140, 30, true, 1);
			_resAlloyLbl.x = _resAlloySymbol.width * 0.5 + _resAlloySymbol.x - 35;
			_resAlloyLbl.y = _resAlloySymbol.height * 0.5 + _resAlloySymbol.y - 4;
			_resAlloyLbl.constrictTextToSize = false;
			_resAlloyLbl.align = TextFormatAlign.LEFT;
			_resAlloyLbl.text = StringUtil.commaFormatNumber(alloyGained);
			_resAlloyLbl.letterSpacing = 1.5;


			_resSyntheticsLbl = new Label(13, 0xffdd3d, 140, 30, true, 1);
			_resSyntheticsLbl.x = _resSyntheticsSymbol.width * 0.5 + _resSyntheticsSymbol.x - 35;
			_resSyntheticsLbl.y = _resSyntheticsSymbol.height * 0.5 + _resSyntheticsSymbol.y - 4;
			_resSyntheticsLbl.constrictTextToSize = false;
			_resSyntheticsLbl.align = TextFormatAlign.LEFT;
			_resSyntheticsLbl.text = StringUtil.commaFormatNumber(synthGained);
			_resSyntheticsLbl.letterSpacing = 1.5;


			_resEnergyLbl = new Label(13, 0xffdd3d, 140, 30, true, 1);
			_resEnergyLbl.x = _resEnergySymbol.width * 0.5 + _resEnergySymbol.x - 35;
			_resEnergyLbl.y = _resEnergySymbol.height * 0.5 + _resEnergySymbol.y - 4;
			_resEnergyLbl.constrictTextToSize = false;
			_resEnergyLbl.align = TextFormatAlign.LEFT;
			_resEnergyLbl.text = StringUtil.commaFormatNumber(energyGained);
			_resEnergyLbl.letterSpacing = 1.5;

			_resourceHolder.addChild(_resCreditsSymbol);
			_resourceHolder.addChild(_resAlloySymbol);
			_resourceHolder.addChild(_resSyntheticsSymbol);
			_resourceHolder.addChild(_resEnergySymbol);
			_resourceHolder.addChild(_resCreditsLbl);
			_resourceHolder.addChild(_resAlloyLbl);
			_resourceHolder.addChild(_resSyntheticsLbl);
			_resourceHolder.addChild(_resEnergyLbl);


			_componentHolder.addChild(_resourceBG);
			_componentHolder.addChild(_resourceHolder);
		}

		public function showBlueprint( blueprintProtoName:String, blueprintVO:BlueprintVO, bpAsset:AssetVO, hardCurrencyCost:int ):void
		{
			_blueprintGlow = PanelFactory.getPanel('BlueprintGlowBMD');
			_blueprintGlow.x = -7;
			_blueprintGlow.y = -10;
			_blueprintGlow.alpha = 0;

			_purchaseBlueprintBtn = ButtonFactory.getBitmapButton('SquareBuyBtnNeutralBMD', 166, 23, 'CodeString.Dialogue.Complete', 0xf7c78b, 'SquareBuyBtnRollOverBMD', 'SquareBuyBtnSelectedBMD');
			_purchaseBlueprintBtn.x = _blueprintFrame.x + _blueprintFrame.width + 2;
			_purchaseBlueprintBtn.y = _blueprintFrame.y + 12;
			_purchaseBlueprintBtn.label.fontSize = 22;
			_purchaseBlueprintBtn.addEventListener(MouseEvent.CLICK, onBlueprintPurchase, false, 0, true);

			if (_battleRerollVO && _battleRerollVO.isReroll && !_battleRerollVO.hasPaid)
			{
				_rerollBtn = ButtonFactory.getBitmapButton('SquareBuyBtnNeutralBMD', _purchaseBlueprintBtn.x + 130, _purchaseBlueprintBtn.y, _rerollBtnText, 0xf7c78b, 'SquareBuyBtnRollOverBMD', 'SquareBuyBtnSelectedBMD');
				_rerollBtn.label.fontSize = 22;
				_rerollBtn.addEventListener(MouseEvent.CLICK, onRerollClick, false, 0, true);

				_rerollCost = UIFactory.getLabel(LabelEnum.DEFAULT, 114, 25, _rerollBtn.x + 4, _rerollBtn.y + 26);
				_rerollCost.fontSize = 18;
				_rerollCost.text = String(_rollCost);

				_scanRerollSymbol = UIFactory.getBitmap('KalganSymbolBMD');
				_scanRerollSymbol.x = _rerollBtn.x + 7;
				_scanRerollSymbol.y = _rerollBtn.y + 24;

				_timeRemainingTitleLbl.x = _rerollBtn.x + _rerollBtn.width + 2;
				_timeRemainingTitleLbl.y = _rerollBtn.y - 1;

				_timeRemainingLbl.x = _timeRemainingTitleLbl.x;
				_timeRemainingLbl.y = _timeRemainingTitleLbl.y + _timeRemainingTitleLbl.textHeight + 2;

				_timeProgressBar.x = _timeRemainingLbl.x + 5;
				_timeProgressBar.y = _timeRemainingLbl.y + _timeRemainingLbl.textHeight + 2;

				if (_battleRerollVO.timeRemaining > 0 && !_timeRemaining.running)
					_timeRemaining.start();
			}

			_blueprintCompleteCost.align = TextFormatAlign.CENTER;
			_blueprintCompleteCost.constrictTextToSize = false;
			_blueprintCompleteCost.x = _purchaseBlueprintBtn.x + 4;
			_blueprintCompleteCost.y = _purchaseBlueprintBtn.y + 26;

			_blueprintPremiumSymbol = PanelFactory.getPanel('KalganSymbolBMD');
			_blueprintPremiumSymbol.x = _purchaseBlueprintBtn.x + 7;
			_blueprintPremiumSymbol.y = _purchaseBlueprintBtn.y + 24;

			_blueprintProto = getBlueprintPrototype(blueprintProtoName);
			if (!_blueprintProto)
				_blueprintProto = getBlueprintPrototype(blueprintVO.name);

			if (bpAsset.largeImage == '')
				loadIconSignal.dispatch(bpAsset.mediumImage, onBlueprintIconLoaded);
			else
				loadIconSignal.dispatch(bpAsset.largeImage, onBlueprintIconLoaded);

			var rarity:String;
			if (_blueprintProto)
				rarity = _blueprintProto.getValue('rarity');
			else if (blueprintVO)
				rarity = blueprintVO.prototype.getValue('rarity');

			var bpLabelColor:uint = CommonFunctionUtil.getRarityColor(rarity);
			_blueprintFrame.filters = [CommonFunctionUtil.getRarityGlow(rarity)];

			_blueprintName.textColor = bpLabelColor;
			_blueprintName.constrictTextToSize = false;
			_blueprintName.align = TextFormatAlign.CENTER;
			_blueprintName.text = bpAsset.visibleName;
			_blueprintName.letterSpacing = 1.5;

			var numCollected:int  = 0;
			if (_blueprint)
				numCollected = _blueprint.partsCollected;
			else
				++numCollected;

			_bpCollectedNumbers.constrictTextToSize = false;
			_bpCollectedNumbers.autoSize = TextFieldAutoSize.LEFT;
			if (_blueprintProto)
				_bpCollectedNumbers.setTextWithTokens(_blueprintsCollectedString, {'[[Number.MinValue]]':numCollected, '[[Number.MaxValue]]':_blueprintProto.getValue('parts')});
			else if (blueprintVO)
				_bpCollectedNumbers.setTextWithTokens(_blueprintsCollectedString, {'[[Number.MinValue]]':numCollected, '[[Number.MaxValue]]':blueprintVO.prototype.getValue('parts')});
			_bpCollectedNumbers.letterSpacing = 1;

			if (_blueprint)
			{
				if (_blueprint.complete)
				{
					_purchaseBlueprintBtn.visible = false;
					_blueprintCompleteCost.visible = false;
					_blueprintPremiumSymbol.visible = false;
					onDenyClick(null);
					_blueprintNameBG.x = 139;
					_blueprintNameBG.y = _blueprintBG.y + 43;

					_blueprintName.x = _blueprintNameBG.x + 4;
					_blueprintName.y = _blueprintNameBG.y + 3;

					_bpCollectedNumbers.x = _blueprintNameBG.x + _blueprintNameBG.width + 1;
					_bpCollectedNumbers.y = _blueprintNameBG.y + 3;

					onBlueprintGlowFadeOut();
				} else
				{
					_purchaseBlueprintBtn.visible = true;
					_blueprintCompleteCost.visible = true;
					_blueprintPremiumSymbol.visible = true;
					_blueprintCost = hardCurrencyCost;
					_blueprintCompleteCost.text = String(_blueprintCost);

					_blueprintNameBG.x = 139;
					_blueprintNameBG.y = 79;

					_blueprintName.x = _blueprintNameBG.x + 4;
					_blueprintName.y = _blueprintNameBG.y + 3;

					_bpCollectedNumbers.x = _blueprintNameBG.x + _blueprintNameBG.width + 1;
					_bpCollectedNumbers.y = _blueprintNameBG.y + 3;
					onBlueprintGlowFadeOut();
				}
			} else
			{
				_blueprintNameBG.x = 139;
				_blueprintNameBG.y = 79;

				_blueprintName.x = _blueprintNameBG.x + 4;
				_blueprintName.y = _blueprintNameBG.y + 3;

				_bpCollectedNumbers.x = _blueprintNameBG.x + _blueprintNameBG.width + 1;
				_bpCollectedNumbers.y = _blueprintNameBG.y + 3;
			}

			if (_battleRerollVO)
			{
				_componentHolder.addChild(_blueprintGlow);
				_componentHolder.addChild(_bpCollectedNumbers);

				_componentHolder.addChild(_purchaseBlueprintBtn);
				if (_rerollBtn)
					_componentHolder.addChild(_rerollBtn);
				if (_rerollCost)
					_componentHolder.addChild(_rerollCost);
				if (_scanRerollSymbol)
					_componentHolder.addChild(_scanRerollSymbol);
				_componentHolder.addChild(_blueprintCompleteCost);
				_componentHolder.addChild(_blueprintPremiumSymbol);
			}

			if (_blueprint)
			{
				if (_blueprint.complete && _componentHolder.contains(_purchaseBlueprintBtn))
					_componentHolder.removeChild(_purchaseBlueprintBtn);
			}
		}

		private function onBlueprintIconLoaded( asset:BitmapData ):void
		{
			if (asset && _blueprintShipIcon)
			{
				_blueprintShipIcon.clearBitmap();
				_blueprintShipIcon.onImageLoaded(asset);
				_blueprintShipIcon.x = (_blueprintFrame.x + _blueprintFrame.width * 0.5) - (_blueprintShipIcon.width * 0.5);
				_blueprintShipIcon.y = (_blueprintFrame.y + _blueprintFrame.height * 0.5) - (_blueprintShipIcon.height * 0.5);
			}
		}

		private function onBlueprintGlowFadeOut():void
		{
			TweenLite.to(_blueprintGlow, 1.0, {alpha:1.0, ease:Quad.easeOut, onComplete:onBlueprintGlowFadeIn, overwrite:0});
		}

		private function onBlueprintGlowFadeIn():void
		{
			TweenLite.to(_blueprintGlow, 1.0, {alpha:0.0, ease:Quad.easeIn, onComplete:onBlueprintGlowFadeOut, overwrite:0});
		}

		private function onBlueprintPurchase( e:MouseEvent ):void
		{
			if (_blueprint && !_blueprint.complete)
			{
				if (CurrentUser.wallet.premium >= _blueprintCost)
				{
					onPurchaseComplete.dispatch(_blueprint.id, _battleRerollVO.battleKey);
					if (_rerollBtn)
						_scanRerollSymbol.visible = _rerollCost.visible = _rerollBtn.visible = false;
					_timeProgressBar.visible = _timeRemainingLbl.visible = false;
					_denyBtn.visible = false;
					_componentHolder.visible = false;
					_purchaseBlueprintBtn.visible = false;
					_blueprintCompleteCost.visible = false;
					_blueprintPremiumSymbol.visible = false;
					if (_bpCollectedNumbers)
						_bpCollectedNumbers.setTextWithTokens(_blueprintsCollectedString, {'[[Number.MinValue]]':_blueprint.totalParts, '[[Number.MaxValue]]':_blueprint.totalParts});
					onBlueprintGlowFadeOut();

				} else
					CommonFunctionUtil.popPaywall();
			}
		}

		public function tooltip( prototype:IPrototype ):String
		{
			return getSelectionInfo(prototype, StringUtil.getTooltip);
		}

		public function getTooltip():String
		{
			var proto:IPrototype = getResearchPrototypeByName(_blueprintProto.getValue('key'));
			return String(getSelectionInfo(proto, StringUtil.getTooltip));
		}

		public function hideBlueprint():void
		{
			if (_blueprintShipIcon)
				_blueprintShipIcon.clearBitmap();

			if (_blueprintName)
				_blueprintName.text = '';

			if (_purchaseBlueprintBtn)
			{
				_purchaseBlueprintBtn.visible = false;
				_blueprintPremiumSymbol.visible = false;
			}
		}

		public function updateBlueprint( blueprintProtoName:String, blueprintVO:BlueprintVO, bpAsset:AssetVO, hardCurrencyCost:int ):void
		{
			_denyBtn.visible = false;

			if (_rerollBtn)
			{
				_rerollBtn.visible = false;
				_rerollCost.visible = false;
				_scanRerollSymbol.visible = false;
			}

			if (_deepScanBtn)
			{
				_deepScanBtn.visible = false;
				_deepScanCost.visible = false;
				_scanRerollSymbol.visible = false;
			}

			if (_timeRemainingLbl)
			{
				_timeRemainingLbl.visible = false;
				_timeProgressBar.visible = false;
			}

			hideBlueprint();

			if (!_battleRerollVO.isReroll)
				showBlueprint(blueprintProtoName, blueprintVO, bpAsset, hardCurrencyCost);


			_blueprintProto = getBlueprintPrototype(blueprintProtoName);
			if (!_blueprintProto)
				_blueprintProto = getBlueprintPrototype(blueprintVO.name);

			if (bpAsset.largeImage == '')
				loadIconSignal.dispatch(bpAsset.mediumImage, onBlueprintIconLoaded);
			else
				loadIconSignal.dispatch(bpAsset.largeImage, onBlueprintIconLoaded);

			var rarity:String;
			if (_blueprintProto)
				rarity = _blueprintProto.getValue('rarity');
			else if (blueprintVO)
				rarity = blueprintVO.prototype.getValue('rarity');

			var bpLabelColor:uint = CommonFunctionUtil.getRarityColor(rarity);
			_blueprintFrame.filters = [CommonFunctionUtil.getRarityGlow(rarity)];

			_blueprintName.text = bpAsset.visibleName;

			var numCollected:int  = 0;
			if (_blueprint)
				numCollected = _blueprint.partsCollected;
			else
				++numCollected;

			if (_blueprintProto)
				_bpCollectedNumbers.setTextWithTokens(_blueprintsCollectedString, {'[[Number.MinValue]]':numCollected, '[[Number.MaxValue]]':_blueprintProto.getValue('parts')});
			else if (blueprintVO)
				_bpCollectedNumbers.setTextWithTokens(_blueprintsCollectedString, {'[[Number.MinValue]]':numCollected, '[[Number.MaxValue]]':blueprintVO.prototype.getValue('parts')});

			if (_blueprint)
			{
				if (_blueprint.complete)
				{
					_purchaseBlueprintBtn.visible = false;
					_blueprintCompleteCost.visible = false;
					_blueprintPremiumSymbol.visible = false;
					_blueprintNameBG.x = 139;
					_blueprintNameBG.y = _blueprintBG.y + 43;

					_blueprintName.x = _blueprintNameBG.x + 4;
					_blueprintName.y = _blueprintNameBG.y + 3;

					_bpCollectedNumbers.x = _blueprintNameBG.x + _blueprintNameBG.width + 1;
					_bpCollectedNumbers.y = _blueprintNameBG.y + 3;

					onBlueprintGlowFadeOut();
				} else
				{
					_purchaseBlueprintBtn.visible = true;
					_blueprintCompleteCost.visible = true;
					_blueprintPremiumSymbol.visible = true;
					_blueprintCost = hardCurrencyCost;
					_blueprintCompleteCost.text = String(_blueprintCost);

					_blueprintNameBG.x = 139;
					_blueprintNameBG.y = 79;

					_blueprintName.x = _blueprintNameBG.x + 4;
					_blueprintName.y = _blueprintNameBG.y + 3;

					_bpCollectedNumbers.x = _blueprintNameBG.x + _blueprintNameBG.width + 1;
					_bpCollectedNumbers.y = _blueprintNameBG.y + 3;
					onBlueprintGlowFadeOut();
				}
			} else
			{
				_blueprintNameBG.x = 139;
				_blueprintNameBG.y = 79;

				_blueprintName.x = _blueprintNameBG.x + 4;
				_blueprintName.y = _blueprintNameBG.y + 3;

				_bpCollectedNumbers.x = _blueprintNameBG.x + _blueprintNameBG.width + 1;
				_bpCollectedNumbers.y = _blueprintNameBG.y + 3;
			}


		}

		private function onDenyClick( e:MouseEvent ):void
		{
			_denyBtn.visible = false;

			if (_rerollBtn)
			{
				_rerollBtn.visible = false;
				_rerollCost.visible = false;
				_scanRerollSymbol.visible = false;
			}

			if (_deepScanBtn)
			{
				_deepScanBtn.visible = false;
				_deepScanCost.visible = false;
				_scanRerollSymbol.visible = false;
			}

			if (_timeProgressBar)
			{
				_timeRemainingTitleLbl.visible = _timeRemainingLbl.visible = _timeProgressBar.visible = false;
			}

			if (e)
			{
				_componentHolder.visible = false;
				if(_battleRerollVO != null)
					denyClickSignal.dispatch(_battleRerollVO.battleKey);
			}
		}

		private function onTimeRemainingTimer( e:TimerEvent ):void
		{
			if (_battleRerollVO.timeRemaining <= 0)
			{
				_timeRemainingLbl.visible = false;
				_timeRemaining.stop();
				onDenyClick(null);
			} else
			{
				_timeRemainingLbl.text = StringUtil.getBuildTime(_battleRerollVO.timeRemaining / 1000);
				if (_timeProgressBar)
					_timeProgressBar.amount = (_battleRerollVO.timeRemaining);
			}
		}

		private function onRerollClick( e:MouseEvent ):void
		{
			if (CurrentUser.wallet.premium >= _rollCost)
			{
				_timeRemaining.stop();
				onDenyClick(null);
				rerollClickSignal.dispatch(_battleRerollVO.battleKey, _blueprint.prototype.name);

			} else
				CommonFunctionUtil.popPaywall();

		}

		private function onDeepScanClick( e:MouseEvent ):void
		{
			if (CurrentUser.wallet.premium >= _scanCost)
			{
				_timeRemaining.stop();
				onDenyClick(null);
				scanClickSignal.dispatch(_battleRerollVO.battleKey);
			} else
				CommonFunctionUtil.popPaywall();
		}

		override public function get width():Number  { return _componentHolder.width; }
		override public function get height():Number  { return _componentHolder.height; }

		public function setTimeRemaining( time:Number ):void  { _timeRemainingLbl.text = String(time); }
		public function getTimeRemainingText():Number  { return Number(_timeRemainingLbl.text); }

		public function get enabled():Boolean  { return false; }
		public function set enabled( value:Boolean ):void  {}

		public function get blueprintShipIcon():ImageComponent  { return _blueprintShipIcon; }
		public function set blueprintShipIcon( value:ImageComponent ):void  { _blueprintShipIcon = value; }

		public function get battleRerollVO():BattleRerollVO  { return _battleRerollVO; }
		public function set battleRerollVO( value:BattleRerollVO ):void  { _battleRerollVO = value; }

		public function get timeRemainingLbl():Label  { return _timeRemainingLbl; }
		public function set timeRemainingLbl( value:Label ):void  { _timeRemainingLbl = value; }

		public function get cargoFull():Boolean  { return _cargoFull; }
		public function set cargoFull( value:Boolean ):void  { _cargoFull = value; }

		public function get componentHolder():Sprite  { return _componentHolder; }
		public function set componentHolder( value:Sprite ):void  { _componentHolder = value; }

		public function get percent():Number  { return _timeProgressBar.amount; }
		public function set percent( v:Number ):void  { _timeProgressBar.amount = v; }

		public function set scanCost( value:Number ):void  { _scanCost = value; }
		public function set rollCost( value:Number ):void  { _rollCost = value; }

		public function destroy():void
		{
			_blueprintFrame = null;
			_blueprintBG = null;
			_blueprintPremiumSymbol = null;
			_blueprintNameBG = null;
			_scanRerollSymbol = null;
			_resAlloySymbol = null;
			_resCreditsSymbol = null;
			_resEnergySymbol = null;
			_resSyntheticsSymbol = null;
			_resourceBG = null;
			_blueprint = null;

			_blueprintProto = null;
			_battleRerollVO = null;
			_resourceHolder = null;
			_componentHolder = null;

			onPurchaseComplete.removeAll();
			loadIconSignal.removeAll();
			rerollClickSignal.removeAll();
			scanClickSignal.removeAll();
			denyClickSignal.removeAll();

			onPurchaseComplete = null;
			loadIconSignal = null;
			rerollClickSignal = null;
			scanClickSignal = null;
			denyClickSignal = null;

			if (_blueprintGlow)
				TweenLite.killTweensOf(_blueprintGlow);

			_blueprintGlow = null;

			if (_blueprintShipIcon)
				ObjectPool.give(_blueprintShipIcon);

			_blueprintShipIcon = null;

			if (_purchaseBlueprintBtn)
				_purchaseBlueprintBtn.destroy();

			_purchaseBlueprintBtn = null;

			if (_blueprintName)
				_blueprintName.destroy();

			_blueprintName = null;

			if (_bpCollectedNumbers)
				_bpCollectedNumbers.destroy();

			_bpCollectedNumbers = null;

			if (_blueprintCompleteCost)
				_blueprintCompleteCost.destroy();

			_blueprintCompleteCost = null;

			if (_purchaseBlueprintBtn)
			{
				_purchaseBlueprintBtn.destroy();
				_purchaseBlueprintBtn = null;
			}

			if (_rerollBtn)
			{
				_rerollBtn.destroy();
				_rerollBtn = null;
			}

			if (_rerollCost)
			{
				_rerollCost.destroy();
				_rerollCost = null;
			}

			if (_deepScanBtn)
			{
				_deepScanBtn.destroy();
				_deepScanBtn = null;
			}

			if (_deepScanCost)
			{
				_deepScanCost.destroy();
				_deepScanCost = null;
			}

			if (_denyBtn)
			{
				_denyBtn.destroy();
				_denyBtn = null;
			}


			if (_resAlloyLbl)
			{
				_resAlloyLbl.destroy();
				_resAlloyLbl = null;
			}

			if (_resCreditsLbl)
			{
				_resCreditsLbl.destroy();
				_resCreditsLbl = null;
			}

			if (_resEnergyLbl)
			{
				_resEnergyLbl.destroy();
				_resEnergyLbl = null;
			}

			if (_resSyntheticsLbl)
			{
				_resSyntheticsLbl.destroy();
				_resSyntheticsLbl = null;
			}

			if (_timeRemainingLbl)
			{
				_timeRemainingLbl.destroy();
				_timeRemainingLbl = null;
			}

			_timeRemaining.stop();

			if (_timeProgressBar)
				_timeProgressBar.destroy();

			_timeProgressBar = null;
		}

	}
}
