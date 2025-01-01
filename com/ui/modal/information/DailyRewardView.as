package com.ui.modal.information
{
	import com.Application;
	import com.enum.ui.PanelEnum;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.model.asset.AssetVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.presenter.shared.IUIPresenter;
	import com.service.language.Localization;
	import com.service.server.incoming.starbase.StarbaseDailyRewardResponse;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.adobe.utils.StringUtil;
	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.shared.ObjectPool;

	public class DailyRewardView extends View
	{
		private var _bg:Sprite;
		private var _closeBtn:BitmapButton;
		private var _windowTitle:Label;
		private var _header:Label;
		private var _subheader:Label;
		private var _iconFrames:Vector.<Bitmap>;
		private var _resourceLbls:Vector.<Label>;
		private var _rewards:StarbaseDailyRewardResponse;
		private var _numRewardIcons:int;
		private var _collectRewardBtn:BitmapButton;

		private var _blueprintProtoName:String;
		private var _blueprintHolder:Sprite;
		private var _blueprintFrame:Bitmap;
		private var _blueprintShipIcon:ImageComponent;
		private var _buffIcon:ImageComponent;
		private var _purchaseBlueprintBtn:BitmapButton;
		private var _blueprintBG:Bitmap;
		private var _blueprintNameBG:Bitmap;
		private var _blueprintGlow:Bitmap;
		private var _blueprintPremiumSymbol:Bitmap;
		private var _blueprintName:Label;
		private var _bpCollectedNumbers:Label;
		private var _blueprintCompleteCost:Label;
		private var _blueprint:BlueprintVO;
		private var _blueprintCost:int;
		private var _buff:IPrototype;
		private var _blueprintsCollectedString:String = 'CodeString.Shared.OutOf'; //[[Number.MinValue]]/[[Number.MaxValue]]

		private var _uiPresenter:IUIPresenter;

		private var _windowTitleString:String         = 'CodeString.RewardView.Title';
		private var _gratsBroString:String            = 'CodeString.RewardView.GratsBro';
		private var _subtitleString:String            = 'CodeString.RewardView.Subtitle';

		private var _tooltips:Tooltips;

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_closeBtn = ButtonFactory.getCloseButton(490, 19);
			addListener(_closeBtn, MouseEvent.CLICK, onCollectReward);

			_resourceLbls = new Vector.<Label>;
			_iconFrames = new Vector.<Bitmap>;
			_numRewardIcons = 0;

			var mcBGClass:Class = Class(getDefinitionByName('DailyRewardMC'));
			_bg = Sprite(new mcBGClass());
			addChild(_bg);


			_collectRewardBtn = ButtonFactory.getBitmapButton('BtnRewardUpBMD', _bg.x + _bg.width - 250, _bg.y + _bg.height + 2, 'COLLECT REWARDS', 0xacd1ff, 'BtnRewardROBMD', 'BtnRewardDownBMD');
			_collectRewardBtn.fontSize = 28;
			_collectRewardBtn.addEventListener(MouseEvent.CLICK, onCollectReward);
			addChild(_collectRewardBtn);


			_windowTitle = new Label(30, 0xd1e5f7, 383, 5, true);
			_windowTitle.x = 30;
			_windowTitle.y = 5;
			_windowTitle.constrictTextToSize = false;
			_windowTitle.align = TextFormatAlign.LEFT;
			_windowTitle.autoSize = TextFieldAutoSize.LEFT;
			_windowTitle.text = _windowTitleString;
			addChild(_windowTitle);

			_header = new Label(44, 0xd1e5f7, 518, 5, true);
			addChild(_header);

			_subheader = new Label(20, 0xffd785, 518, 5, true);
			addChild(_subheader);

			if (_rewards.creditsReward > 0)
				_numRewardIcons++;

			if (_rewards.alloyReward > 0)
				_numRewardIcons++;

			if (_rewards.energyReward > 0)
				_numRewardIcons++;

			if (_rewards.syntheticReward > 0)
				_numRewardIcons++;

			if (_rewards.buffPrototype != '')
				_numRewardIcons++;

			_buff = _uiPresenter.getBuffPrototypeByName(_rewards.buffPrototype);

			_buffIcon = ObjectPool.get(ImageComponent);
			_buffIcon.init(50, 50);


			_blueprintProtoName = _rewards.blueprintPrototype; // = 'Fighter_IGA_Legendary';
			if (_blueprintProtoName)
				showBlueprint();

			layout();

			addEffects();
			effectsIN();
		}

		private function layout():void
		{

			_header.x = 21;
			_header.constrictTextToSize = false;
			_header.align = TextFormatAlign.CENTER;
			_header.autoSize = TextFieldAutoSize.CENTER;
			_header.text = _gratsBroString;

			//determine x, y pos based on number of rewards and blueprints gained
			var xPos:int         = 0;
			var yPos:int         = 0;
			if (_numRewardIcons == 4)
				xPos = 137;
			else
				xPos = 99;

			if (_blueprintProtoName)
			{
				_header.y = 42;
				yPos = 233;
			} else
			{
				_header.y = 100;
				yPos = 187;
			}

			_subheader.x = 21;
			_subheader.y = _header.y + _header.textHeight + 2;
			_subheader.constrictTextToSize = false;
			_subheader.align = TextFormatAlign.CENTER;
			_subheader.autoSize = TextFieldAutoSize.CENTER;
			_subheader.text = _subtitleString;

			var tooltip:String;
			var loc:Localization = Localization.instance;
			for (var i:int = 0; i < _numRewardIcons; i++)
			{
				_iconFrames[i] = addScaleBitmap(PanelEnum.BLUE_FRAME, xPos + (i * 76), yPos);

				_resourceLbls[i] = new Label(18, 0xd1e5f7, 39, 17, false);
				_resourceLbls[i].constrictTextToSize = false;

				switch (i)
				{
					case 0:
						addBitmap('DailyCreditsIconBMD', _iconFrames[i].x + 5, _iconFrames[i].y + 5);
						_resourceLbls[i].text = StringUtil.abbreviateNumber(_rewards.creditsReward);
						break;
					case 1:
						addBitmap('DailyAlloyIconBMD', _iconFrames[i].x + 5, _iconFrames[i].y + 5);
						_resourceLbls[i].text = StringUtil.abbreviateNumber(_rewards.alloyReward);
						break;
					case 2:
						addBitmap('DailyEnergyIconBMD', _iconFrames[i].x + 5, _iconFrames[i].y + 5);
						_resourceLbls[i].text = StringUtil.abbreviateNumber(_rewards.energyReward);
						break;
					case 3:
						addBitmap('DailySynthIconBMD', _iconFrames[i].x + 5, _iconFrames[i].y + 5);
						_resourceLbls[i].text = StringUtil.abbreviateNumber(_rewards.syntheticReward);
						break;
					case 4:
						if (_buff)
						{
							var assetVO:AssetVO = _uiPresenter.getAssetVOFromIPrototype(_buff);
							_uiPresenter.loadIcon(assetVO.smallImage, _buffIcon.onImageLoaded);
							_buffIcon.x = _iconFrames[i].x + 5;
							_buffIcon.y = _iconFrames[i].y + 5;
							addChild(_buffIcon);
							tooltip = 'Buff\n' + loc.getString(assetVO.visibleName) + '\n' + loc.getString(assetVO.descriptionText);
							_tooltips.addTooltip(_buffIcon, this, null, tooltip);
						} else
							addBitmap('DailyBuffShieldIconBMD', _iconFrames[i].x + 5, _iconFrames[i].y + 5);
						break;
				}

				if (i != 4)
					addBitmap('TextBackingBMD', _iconFrames[i].x + 17, _iconFrames[i].y + 39);

				_resourceLbls[i].x = _iconFrames[i].x + 18;
				_resourceLbls[i].y = _iconFrames[i].y + 37;

				addChild(_resourceLbls[i]);
			}

		}

		private function addBitmap( className:String, dx:Number, dy:Number ):Bitmap
		{
			var bmpClass:Class = Class(getDefinitionByName((className)));
			var newBmp:Bitmap;
			newBmp = new Bitmap(BitmapData(new bmpClass));
			newBmp.x = dx;
			newBmp.y = dy;

			addChild(newBmp);

			return newBmp;
		}

		private function addScaleBitmap( className:String, dx:Number, dy:Number ):Bitmap
		{
			var newBmp:ScaleBitmap = UIFactory.getScaleBitmap(className);
			newBmp.width = 60;
			newBmp.height = 60;
			newBmp.x = dx;
			newBmp.y = dy;

			addChild(newBmp);

			return newBmp;
		}

		private function showBlueprint():void
		{
			var blueprintBgClass:Class      = Class(getDefinitionByName(('LootedBlueprintBMD')));
			_blueprintBG = new Bitmap(BitmapData(new blueprintBgClass()));
			_blueprintBG.x = 476;
			_blueprintBG.y = 342;

			var blueprintBgFrameClass:Class = Class(getDefinitionByName('SelectionFrameBMD'));
			_blueprintFrame = new Bitmap(BitmapData(new blueprintBgFrameClass()));
			_blueprintFrame.x = 136; //485;
			_blueprintFrame.y = 121; //331;

			_blueprintShipIcon = new ImageComponent()
			_blueprintShipIcon.init(100, 100);

			_blueprintGlow = PanelFactory.getPanel('BlueprintGlowBMD');
			_blueprintGlow.x = 120; //469;
			_blueprintGlow.y = 104; //314;
			_blueprintGlow.alpha = 0;

			_blueprintNameBG = PanelFactory.getPanel('BlueprintPlacardBMD');

			_purchaseBlueprintBtn = ButtonFactory.getBitmapButton('SquareBuyBtnNeutralBMD', 293, 127, 'COMPLETE', 0xf7c78b, 'SquareBuyBtnRollOverBMD', 'SquareBuyBtnSelectedBMD');
			_purchaseBlueprintBtn.label.fontSize = 22;
			_purchaseBlueprintBtn.addEventListener(MouseEvent.CLICK, onBlueprintPurchase, false, 0, true);

			_blueprintCompleteCost = new Label(18, 0xf0f0f0, 114, 25, false);
			_blueprintCompleteCost.align = TextFormatAlign.CENTER;
			_blueprintCompleteCost.constrictTextToSize = false;
			_blueprintCompleteCost.x = _purchaseBlueprintBtn.x + 4;
			_blueprintCompleteCost.y = _purchaseBlueprintBtn.y + 26;

			_blueprintPremiumSymbol = PanelFactory.getPanel('KalganSymbolBMD');
			_blueprintPremiumSymbol.x = _purchaseBlueprintBtn.x + 7;
			_blueprintPremiumSymbol.y = _purchaseBlueprintBtn.y + 24;

			var blueprintVO:IPrototype      = PrototypeModel.instance.getBlueprintPrototype(_blueprintProtoName);
			var bpAsset:AssetVO             = _uiPresenter.getAssetVOFromIPrototype(blueprintVO);
			//Only ships have schematic images
			if (bpAsset.largeImage == '')
				_uiPresenter.loadIcon(bpAsset.mediumImage, onBlueprintIconLoaded);
			else
				_uiPresenter.loadIcon(bpAsset.largeImage, onBlueprintIconLoaded);

			var rarity:String               = blueprintVO.getValue('rarity');
			var bpLabelColor:uint           = CommonFunctionUtil.getRarityColor(rarity);
			_blueprintFrame.filters = [CommonFunctionUtil.getRarityGlow(rarity)];


			// Blueprint Name
			_blueprintName = new Label(16, bpLabelColor, 176, 26);
			_blueprintName.constrictTextToSize = false;
			_blueprintName.align = TextFormatAlign.CENTER;
			_blueprintName.text = bpAsset.visibleName;
			_blueprintName.letterSpacing = 1.5;

			var numCollected:int            = 0;
			_blueprint = _uiPresenter.getBlueprintByName(_blueprintProtoName);
			if (_blueprint)
				numCollected = _blueprint.partsCollected;
			else
				++numCollected;

			// Blueprints Collected
			_bpCollectedNumbers = new Label(12, 0xF0F0F0, 10, 25, true, 1);
			_bpCollectedNumbers.constrictTextToSize = false;
			_bpCollectedNumbers.autoSize = TextFieldAutoSize.LEFT;
			_bpCollectedNumbers.setTextWithTokens(_blueprintsCollectedString, {'[[Number.MinValue]]':numCollected, '[[Number.MaxValue]]':blueprintVO.getValue('parts')});
			_bpCollectedNumbers.letterSpacing = 1;

			if (_blueprint)
			{
				if (_blueprint.complete)
				{
					_purchaseBlueprintBtn.visible = false;
					_blueprintCompleteCost.visible = false;
					_blueprintPremiumSymbol.visible = false;
					_blueprintNameBG.x = 265;
					_blueprintNameBG.y = _blueprintFrame.y + 33;

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
					_blueprintCost = _uiPresenter.getBlueprintHardCurrencyCost(_blueprint, _blueprint.partsRemaining);
					_blueprintCompleteCost.text = String(_blueprintCost);

					_blueprintNameBG.x = 265;
					_blueprintNameBG.y = 194;

					_blueprintName.x = _blueprintNameBG.x + 4;
					_blueprintName.y = _blueprintNameBG.y + 3;

					_bpCollectedNumbers.x = _blueprintNameBG.x + _blueprintNameBG.width + 1;
					_bpCollectedNumbers.y = _blueprintNameBG.y + 3;
				}
			} else
			{
				_blueprintNameBG.x = 265;
				_blueprintNameBG.y = 194;

				_blueprintName.x = _blueprintNameBG.x + 4;
				_blueprintName.y = _blueprintNameBG.y + 3;

				_bpCollectedNumbers.x = _blueprintNameBG.x + _blueprintNameBG.width + 1;
				_bpCollectedNumbers.y = _blueprintNameBG.y + 3;
			}

			addChild(_blueprintFrame);
			addChild(_blueprintShipIcon);
			addChild(_blueprintNameBG);
			addChild(_blueprintGlow);
			addChild(_blueprintName);
			addChild(_bpCollectedNumbers);
			addChild(_purchaseBlueprintBtn);
			addChild(_blueprintCompleteCost);
			addChild(_blueprintPremiumSymbol);
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
					_uiPresenter.purchaseBlueprint(_blueprint, _blueprint.partsRemaining);
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

		private function onCollectReward( e:MouseEvent ):void
		{
			destroy();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		public function get rewards():StarbaseDailyRewardResponse  { return _rewards; }
		public function set rewards( value:StarbaseDailyRewardResponse ):void  { _rewards = value; }

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _uiPresenter = value; }

		[Inject]
		public function set tooltips( value:Tooltips ):void  { _tooltips = value; }

		override public function destroy():void
		{
			if (Application.STATE == StateEvent.GAME_STARBASE)
				_uiPresenter.dispatch(new StarbaseEvent(StarbaseEvent.WELCOME_BACK));

			super.destroy();
			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;

			_windowTitle.destroy();
			_windowTitle = null;

			_header.destroy();
			_header = null;

			_subheader.destroy();
			_subheader = null;

			_iconFrames = null;
			_resourceLbls = null;

			_rewards.destroy();
			_rewards = null;

			_collectRewardBtn.destroy();
			_collectRewardBtn = null;

			if (_buffIcon)
				ObjectPool.give(_buffIcon);

			_buffIcon = null;

			_blueprintFrame = null;
			_blueprintBG = null;
			_blueprintPremiumSymbol = null;

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

			if (_tooltips)
				_tooltips.removeTooltip(null, this);

			_tooltips = null;

		}
	}
}
