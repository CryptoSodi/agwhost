package com.ui.modal.offers
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.player.OfferVO;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.IUIPresenter;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	import org.shared.ObjectPool;

	public class OfferView extends View
	{
		private var _actionBtn:BitmapButton;
		private var _closeBtn:BitmapButton;

		private var _bg:DefaultWindowBG;

		private var _timeRemainingBG:Bitmap;
		private var _goldPlate:Bitmap;
		private var _eightsImage:Bitmap;

		private var _offerItemHolder:Sprite;

		private var _offer:OfferVO;
		private var _palladium:Number;
		private var _bonusPalladiumPercent:Number;

		private var _timeRemaining:Label;
		private var _headerSubtitle:Label;
		private var _headerLbl:Label
		private var _timeText:Label;

		private var _timeRemainingTimer:Timer;

		private var palladiumImage:String           = 'Palladium_50x50.png';

		private var _titleText:String               = 'CodeString.OfferWindow.Offer'; // OFFER
		private var _bonusText:String               = 'CodeString.OfferWindow.Bonus'; //BONUS!
		private var _buyBtnText:String              = 'CodeString.OfferWindow.BuyNow'; //Buy Now
		private var _timeRemainingText:String       = 'CodeString.OfferWindow.TimeText'; //This one-time offer ends in:
		private var _palladiumTitle:String          = 'CodeString.OfferWindow.BonusPalladiumTitle'; //[[Number.BonusPalladium]] FREE Palladium!
		private var _palladiumDetails:String        = 'CodeString.OfferWindow.BonusPalladiumBody'; //Bend the laws of time and space with up to [[Number.BonusPercent]]% bonus Palladium!

		private var _palladiumPercentTitle:String   = 'CodeString.OfferWindow.PercentBonusPalladiumTitle'; //[[Number.BonusPercent]]% BONUS Palladium!
		private var _palladiumPercentDetails:String = 'CodeString.OfferWindow.PercentBonusPalladiumBody'; //Bend the laws of time and space with up to [[Number.BonusPercent]]% bonus Palladium!

		[PostConstruct]
		override public function init():void
		{
			super.init();


			if (!_offer)
				return;

			var offerVO:IPrototype                   = presenter.getOfferPrototypeByName(_offer.offerPrototype);

			if (!offerVO)
				return;

			var offerItems:Vector.<IPrototype>       = presenter.getOfferItemsByItemGroup(offerVO.getValue('itemGroup'));
			var assetVO:AssetVO                      = presenter.getAssetVOFromIPrototype(offerVO);

			var minPalladiumPurchasedRequired:Number = offerVO.getValue('minPalladiumPurchasedReq');

			_palladium = offerVO.getValue('palladium');
			_bonusPalladiumPercent = offerVO.getValue('bonusPalladiumPct');


			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(418, 300);
			_bg.addTitle(assetVO.visibleName, 150);
			_bg.x = 264;
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_goldPlate = UIFactory.getBitmap('GoldPlateBMD');
			_goldPlate.x = _bg.x - 13;
			_goldPlate.y = -130;

			_eightsImage = UIFactory.getBitmap('EightsBMD');
			_eightsImage.y = -32;

			_offerItemHolder = new Sprite();
			_offerItemHolder.x = _bg.x + 40;
			_offerItemHolder.y = 130;

			_timeRemainingBG = UIFactory.getPanel(PanelEnum.CONTAINER_DOUBLE_NOTCHED_ARROWS, 373, 61, _bg.x + 39, 371);

			_timeText = new Label(18, 0xecffff, 373, 25);
			_timeText.constrictTextToSize = false;
			_timeText.align = TextFormatAlign.CENTER;
			_timeText.textColor = 0xecffff;
			_timeText.text = _timeRemainingText;
			_timeText.x = _timeRemainingBG.x;
			_timeText.y = _timeRemainingBG.y;

			_timeRemaining = new Label(30, 0xd40c12, 373, 50, false);
			_timeRemaining.constrictTextToSize = false;
			_timeRemaining.align = TextFormatAlign.CENTER;
			_timeRemaining.bold = true;
			_timeRemaining.x = _timeRemainingBG.x;
			_timeRemaining.y = _timeText.y + _timeText.textHeight;

			_headerLbl = new Label(60, 0x14202e, 373, 60);
			_headerLbl.align = TextFormatAlign.CENTER;
			_headerLbl.constrictTextToSize = false;
			_headerLbl.textColor = 0x14202e;
			_headerLbl.bold = true;
			_headerLbl.text = _bonusText;
			_headerLbl.x = _bg.x + 36;
			_headerLbl.y = 35;

			_headerSubtitle = new Label(16, 0x14202e, 375);
			_headerSubtitle.autoSize = TextFieldAutoSize.CENTER;
			_headerSubtitle.align = TextFormatAlign.CENTER;
			_headerSubtitle.constrictTextToSize = false;
			_headerSubtitle.multiline = true;
			_headerSubtitle.textColor = 0x14202e;
			_headerSubtitle.bold = true;
			if (minPalladiumPurchasedRequired > 0)
				_headerSubtitle.setTextWithTokens(assetVO.descriptionText, {'[[Number.MinPurchase]]':(minPalladiumPurchasedRequired)});
			else
				_headerSubtitle.text = assetVO.descriptionText;
			_headerSubtitle.x = _bg.x + 36;
			_headerSubtitle.y = 95;

			_actionBtn = UIFactory.getButton(ButtonEnum.GOLD_A, 240, 40, _timeRemainingBG.x + _timeRemainingBG.width * 0.5 - 120, _timeRemainingBG.y + _timeRemainingBG.height + 12, _buyBtnText);
			addListener(_actionBtn, MouseEvent.CLICK, onActionBtnClick);

			//Time remaining
			_timeRemainingTimer = new Timer(1000);
			addListener(_timeRemainingTimer, TimerEvent.TIMER, updateTimer);
			_timeRemainingTimer.start();

			addChild(_bg);
			addChild(_goldPlate);
			addChild(_eightsImage);
			addChild(_offerItemHolder);
			addChild(_timeRemainingBG);
			addChild(_timeText);
			addChild(_timeRemaining);
			addChild(_headerLbl);
			addChild(_headerSubtitle);
			addChild(_actionBtn);

			addEffects();
			effectsIN();
			layoutItems(offerItems);
		}

		private function onActionBtnClick( e:MouseEvent ):void
		{
			CommonFunctionUtil.popPaywall();
			destroy();
		}

		private function addPalladiumItem():void
		{
			var itemComponent:OfferItemComponent = new OfferItemComponent();
			itemComponent.setItemNameWithTokens(_palladiumTitle, {'[[Number.BonusPalladium]]':_palladium});
			itemComponent.setItemDescriptionWithTokens(_palladiumDetails, {'[[Number.BonusPercent]]':(_palladium * 10)});
			presenter.loadIcon(palladiumImage, itemComponent.onImageLoaded);
			_offerItemHolder.addChild(itemComponent);
		}

		private function addPalladiumBonus( isPalladiumAdded:Boolean ):void
		{
			var itemComponent:OfferItemComponent = new OfferItemComponent();
			itemComponent.setItemNameWithTokens(_palladiumPercentTitle, {'[[Number.BonusPercent]]':_bonusPalladiumPercent});
			itemComponent.setItemDescriptionWithTokens(_palladiumPercentDetails, {'[[Number.BonusPercent]]':(_bonusPalladiumPercent)});
			presenter.loadIcon(palladiumImage, itemComponent.onImageLoaded);
			itemComponent.y = 80;
			_offerItemHolder.addChild(itemComponent);
		}

		public function layoutItems( itemGroup:Vector.<IPrototype> ):void
		{
			var count:int      = 0;

			if (_palladium > 0)
			{
				addPalladiumItem();
				++count;
			}

			if (_bonusPalladiumPercent > 0)
			{
				if (_palladium > 0)
				{
					addPalladiumBonus(true);
				}
				else
				{
					addPalladiumBonus(false);
				}
				++count;
			}

			var uiAsset:String = '';
			var offset:Number;
			for each (var item:IPrototype in itemGroup)
			{
				var itemProto:IPrototype;
				switch (item.getValue('itemType'))
				{
					case 'Buff':
						uiAsset = item.getValue('itemName');
						break;
					case 'Blueprint':
						itemProto = presenter.getBlueprintPrototypeByName(item.getValue('itemName'));
						break;
					case 'Ship':
						itemProto = presenter.getPrototypeByName(item.getValue('itemName'));
						break;
					default:
						uiAsset = item.getValue('itemName');
						break;
				}

				if (uiAsset != '' && itemProto)
					uiAsset = item.uiAsset;

				if (uiAsset != '')
				{
					if (count == 1)
						offset = 0;
					else
						offset = 0;

					var itemAsset:AssetVO                = presenter.getAssetVO(uiAsset);
					var image:String;
					if (itemAsset.mediumImage == '')
						image = itemAsset.smallImage;
					else
						image = itemAsset.mediumImage;

					var itemComponent:OfferItemComponent = new OfferItemComponent();
					itemComponent.setItemName(itemAsset.visibleName);
					itemComponent.setItemDescription(itemAsset.descriptionText);
					presenter.loadIcon(image, itemComponent.onImageLoaded);
					itemComponent.y = (80 + offset) * count;
					_offerItemHolder.addChild(itemComponent);
					++count;
				}
			}
		}

		private function updateTimer( e:TimerEvent ):void
		{
			if (_offer == null)
			{
				if (_timeRemainingTimer)
					_timeRemainingTimer.stop();

				return;
			}
			var timeRemaining:Number = _offer.timeRemainingMS;

			if (timeRemaining <= 0)
			{
				_timeRemainingTimer.stop();
				destroy();
			} else
			{
				if (_timeRemaining)
					_timeRemaining.setBuildTime(timeRemaining / 1000);
			}
		}

		public function set offerProtoName( v:OfferVO ):void  { _offer = v; }

		override public function get height():Number  { return 695; }
		override public function get width():Number  { return _bg.x + _bg.width; }

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			_eightsImage = null;
			_goldPlate = null;

			_offerItemHolder = null;

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			if (_timeRemainingTimer)
			{
				removeListener(_timeRemainingTimer, TimerEvent.TIMER, updateTimer);
				if (_timeRemainingTimer.running)
					_timeRemainingTimer.stop();
			}

			_timeRemainingTimer = null;

			if (_timeRemaining)
				_timeRemaining.destroy();

			_timeRemaining = null;

			if (_headerLbl)
				_headerLbl.destroy();

			_headerLbl = null;

			if (_headerSubtitle)
				_headerSubtitle.destroy();

			_headerSubtitle = null;

			if (_timeText)
				_timeText.destroy();

			_timeText = null;

			super.destroy();
		}
	}
}
