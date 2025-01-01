package com.ui.core.component.misc
{
	import com.model.player.CurrentUser;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	public class BlueprintActionComponent extends Sprite implements IComponent
	{
		private var _partialPurchaseBtn:BitmapButton;
		private var _fullPurchaseBtn:BitmapButton;

		private var _cannotFullPurchaseBtn:BitmapButton;
		private var _cannotAffordPartialPurchaseBtn:BitmapButton;

		private var _cannotPartialCostBtnProto:ButtonPrototype;
		private var _cannotAffordFullCostBtnProto:ButtonPrototype;

		private var _partialPurchaseBtnProto:ButtonPrototype;
		private var _fullPurchaseBtnProto:ButtonPrototype;

		private var _fullCostText:Label;
		private var _partialCostText:Label;

		private var _leftPremiumSymbol:Bitmap;
		private var _rightPremiumSymbol:Bitmap;

		private var _enabled:Boolean;

		private var _fullCost:int;
		private var _partialCost:int;

		private var _enabledFontSize:int;
		private var _disabledFontSize:int;
		private var _enabledLabelYPos:int;

		private var _freeText:String    = 'CodeString.Shared.Free'; //Free
		private var _offlineText:String = 'OFFLINE';

		public function BlueprintActionComponent( fullPurchaseButton:ButtonPrototype, partialPurchaseButton:ButtonPrototype, cannotAffordPartialPurchaseBtnProto:ButtonPrototype, cannotAffordFullCostButton:ButtonPrototype,
												  partialCost:int = 0, fullCost:int = 0 )
		{
			super();

			_fullCost = fullCost;
			_partialCost = partialCost;

			_enabledFontSize = 20;
			_disabledFontSize = 24;

			_partialPurchaseBtnProto = partialPurchaseButton;
			_fullPurchaseBtnProto = fullPurchaseButton;

			_cannotPartialCostBtnProto = cannotAffordPartialPurchaseBtnProto;
			_cannotAffordFullCostBtnProto = cannotAffordFullCostButton;

			var premiumBitmapData:BitmapData = PanelFactory.getBitmapData('KalganSymbolBMD');

			_partialPurchaseBtn = ButtonFactory.getBitmapButton('InstantBtnNeutralBMD', 0, 0, partialPurchaseButton.text, 0xd9ab70, 'InstantBtnRollOverBMD', 'InstantBtnDownBMD', 'InactiveInstantBtn');
			_partialPurchaseBtn.addEventListener(MouseEvent.CLICK, partialPurchaseButton.callback, false, 0, true);
			_partialPurchaseBtn.fontSize = _enabledFontSize;
			_partialPurchaseBtn.label.y -= 3;

			_fullPurchaseBtn = ButtonFactory.getBitmapButton('ShortResourcesBtnNeutralBMD', 145, 0, fullPurchaseButton.text, 0xd9ab70, 'ShortResourcesBtnRolloverBMD', 'ShortResourcesBtnDownBMD', 'InactiveBuildBtn');
			_fullPurchaseBtn.addEventListener(MouseEvent.CLICK, fullPurchaseButton.callback, false, 0, true);
			_fullPurchaseBtn.fontSize = _enabledFontSize;
			_fullPurchaseBtn.label.y -= 3;

			_cannotAffordPartialPurchaseBtn = ButtonFactory.getBitmapButton('InstantBtnNeutralBMD', 0, 0, cannotAffordPartialPurchaseBtnProto.text, 0xd9ab70, 'InstantBtnRollOverBMD', 'InstantBtnDownBMD',
																			'InactiveInstantBtn');
			_cannotAffordPartialPurchaseBtn.addEventListener(MouseEvent.CLICK, cannotAffordPartialPurchaseBtnProto.callback, false, 0, true);
			_cannotAffordPartialPurchaseBtn.fontSize = _enabledFontSize;
			_cannotAffordPartialPurchaseBtn.label.y -= 3;
			_cannotAffordPartialPurchaseBtn.visible = false;

			_cannotFullPurchaseBtn = ButtonFactory.getBitmapButton('ShortResourcesBtnNeutralBMD', 145, 0, cannotAffordFullCostButton.text, 0xd9ab70, 'ShortResourcesBtnRolloverBMD', 'ShortResourcesBtnDownBMD',
																   'InactiveBuildBtn');
			_cannotFullPurchaseBtn.addEventListener(MouseEvent.CLICK, cannotAffordFullCostButton.callback, false, 0, true);
			_cannotFullPurchaseBtn.fontSize = _enabledFontSize;
			_cannotFullPurchaseBtn.label.y -= 3;
			_cannotFullPurchaseBtn.visible = false;

			_enabledLabelYPos = _fullPurchaseBtn.label.y;

			_leftPremiumSymbol = new Bitmap(premiumBitmapData);
			_leftPremiumSymbol.x = 33;
			_leftPremiumSymbol.y = 26;

			_rightPremiumSymbol = new Bitmap(premiumBitmapData);
			_rightPremiumSymbol.x = _fullPurchaseBtn.x + 36;
			_rightPremiumSymbol.y = 26;

			_partialCostText = new Label(18, 0xf0f0f0, 50, 25, false);
			_partialCostText.align = TextFormatAlign.RIGHT;
			_partialCostText.constrictTextToSize = false;
			_partialCostText.x = 38;
			_partialCostText.y = 30;

			_partialCostText.text = String(partialCost);

			_fullCostText = new Label(18, 0xf0f0f0, 50, 25, false);
			_fullCostText.align = TextFormatAlign.RIGHT;
			_fullCostText.constrictTextToSize = false;
			_fullCostText.x = _fullPurchaseBtn.x + 40;
			_fullCostText.y = 30;
			_fullCostText.text = String(fullCost);

			addChild(_partialPurchaseBtn);
			addChild(_fullPurchaseBtn);

			addChild(_cannotAffordPartialPurchaseBtn);
			addChild(_cannotFullPurchaseBtn);

			addChild(_partialCostText);
			addChild(_fullCostText);

			addChild(_leftPremiumSymbol);
			addChild(_rightPremiumSymbol);

			updateBasedOnHardCurrency();
		}

		public function set fullCost( fullCost:int ):void
		{
			_fullCost = fullCost;
			_fullCostText.text = String(fullCost);
			updateBasedOnHardCurrency();
		}

		public function set partialCost( partialCost:int ):void
		{
			_partialCost = partialCost;
			_partialCostText.text = String(partialCost);
			updateBasedOnHardCurrency();
		}

		private function updateBasedOnHardCurrency():void
		{
			var currentPremium:uint        = CurrentUser.wallet.premium;
			var canPurchasePartial:Boolean = (_partialCost <= currentPremium)
			var canPurchaseFull:Boolean    = (_fullCost <= currentPremium)
				
			if(CONFIG::IS_CRYPTO && _partialCost == 0 && _fullCost == 0)
			{
				_leftPremiumSymbol.visible = false;
				_partialCostText.visible = false;
				
				_partialPurchaseBtn.visible = false;
				_cannotAffordPartialPurchaseBtn.visible = false;
				
				_fullPurchaseBtn.visible = true;
				_cannotFullPurchaseBtn.visible = false;
			}
			else
			{
				_leftPremiumSymbol.visible = true;
				_partialCostText.visible = true;
				
				_partialPurchaseBtn.visible = canPurchasePartial;
				_cannotAffordPartialPurchaseBtn.visible = !canPurchasePartial;
	
				_fullPurchaseBtn.visible = canPurchaseFull;
				_cannotFullPurchaseBtn.visible = !canPurchaseFull;
			}
		}

		public function set enabled( value:Boolean ):void
		{
			_enabled = value;

			
			
			if(CONFIG::IS_CRYPTO && _partialCost == 0 && _fullCost == 0)
			{
				_leftPremiumSymbol.visible = false;
				_partialCostText.visible = false;
				
				partialPurchaseEnabled = false;
				fullPurchaseBtnEnabled = _enabled;
				
				cannotPartialPurchaseEnabled = false;
				cannotFullPurchaseBtnEnabled = false;
			}
			else
			{
				_leftPremiumSymbol.visible = true;
				_partialCostText.visible = true;
				
				partialPurchaseEnabled = _enabled;
				fullPurchaseBtnEnabled = _enabled;
	
				cannotPartialPurchaseEnabled = _enabled;
				cannotFullPurchaseBtnEnabled = _enabled;
			}
			if (_enabled)
				updateBasedOnHardCurrency();
		}

		public function get enabled():Boolean  { return _enabled; }

		public function set partialPurchaseEnabled( enabled:Boolean ):void
		{
			_partialPurchaseBtn.enabled = enabled;
			_leftPremiumSymbol.visible = enabled;
			_rightPremiumSymbol.visible = enabled;
			_fullCostText.visible = enabled;
			if (!enabled)
			{
				_partialPurchaseBtn.fontSize = _disabledFontSize;
				_partialPurchaseBtn.text = _offlineText;
				_partialPurchaseBtn.setMargin(20, 10);
				_partialPurchaseBtn.label.textColor = 0x929699;
			} else
			{
				_partialPurchaseBtn.fontSize = _enabledFontSize;
				_partialPurchaseBtn.text = _partialPurchaseBtnProto.text;
				_partialPurchaseBtn.label.y -= 3;
				_partialPurchaseBtn.label.textColor = 0xd9ab70;
			}
		}

		public function set fullPurchaseBtnEnabled( enabled:Boolean ):void
		{
			_fullPurchaseBtn.enabled = enabled;
			_partialCostText.visible = enabled;
			if (!enabled)
			{
				_fullPurchaseBtn.fontSize = _disabledFontSize;
				_fullPurchaseBtn.text = _offlineText;
				_fullPurchaseBtn.setMargin(15, 10);
				_fullPurchaseBtn.label.textColor = 0x929699;
			} else
			{
				_fullPurchaseBtn.fontSize = _enabledFontSize;
				_fullPurchaseBtn.text = _fullPurchaseBtnProto.text;
				_fullPurchaseBtn.label.y -= 3;
				_fullPurchaseBtn.label.textColor = 0xd9ab70;

			}
		}

		public function set cannotPartialPurchaseEnabled( enabled:Boolean ):void
		{
			_cannotAffordPartialPurchaseBtn.enabled = enabled;
			if (!enabled)
			{
				_cannotAffordPartialPurchaseBtn.fontSize = _disabledFontSize;
				_cannotAffordPartialPurchaseBtn.text = _offlineText;
				_cannotAffordPartialPurchaseBtn.setMargin(20, 10);
				_cannotAffordPartialPurchaseBtn.label.textColor = 0x929699;
			} else
			{
				_cannotAffordPartialPurchaseBtn.fontSize = _enabledFontSize;
				_cannotAffordPartialPurchaseBtn.text = _cannotPartialCostBtnProto.text;
				_cannotAffordPartialPurchaseBtn.label.y -= 3;
				_cannotAffordPartialPurchaseBtn.label.textColor = 0xd9ab70;
			}
		}

		public function set cannotFullPurchaseBtnEnabled( enabled:Boolean ):void
		{
			_cannotFullPurchaseBtn.enabled = enabled;
			if (!enabled)
			{
				_cannotFullPurchaseBtn.fontSize = _disabledFontSize;
				_cannotFullPurchaseBtn.text = _offlineText;
				_cannotFullPurchaseBtn.setMargin(20, 10);
				_cannotFullPurchaseBtn.label.textColor = 0x929699;
			} else
			{
				_cannotFullPurchaseBtn.fontSize = _enabledFontSize;
				_cannotFullPurchaseBtn.text = _cannotAffordFullCostBtnProto.text;
				_cannotFullPurchaseBtn.label.y -= 3;
				_cannotFullPurchaseBtn.label.textColor = 0xd9ab70;
			}
		}

		public function destroy():void
		{
			if (_partialPurchaseBtn)
			{
				_partialPurchaseBtn.removeEventListener(MouseEvent.CLICK, _partialPurchaseBtnProto.callback);
				_partialPurchaseBtn.destroy();
			}

			_partialPurchaseBtn = null;
			_partialPurchaseBtnProto = null;

			if (_fullPurchaseBtn)
			{
				_fullPurchaseBtn.removeEventListener(MouseEvent.CLICK, _fullPurchaseBtnProto.callback);
				_fullPurchaseBtn.destroy();
			}

			_fullPurchaseBtn = null;
			_fullPurchaseBtnProto = null;

			if (_partialCostText)
				_partialCostText.destroy();

			_partialCostText = null;

			if (_fullCostText)
				_fullCostText.destroy();

			_fullCostText = null;

			_leftPremiumSymbol = null;
			_rightPremiumSymbol = null;
		}
	}
}
