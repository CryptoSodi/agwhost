package com.ui.modal.store
{
	import com.model.prototype.IPrototype;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class StoreItem extends BitmapButton
	{
		private var _itemIcon:ImageComponent;
		private var _premiumSymbol:Bitmap;
		private var _itemDetailSubtext:Label;
		private var _itemStatusText:Label;
		private var _costText:Label;
		private var _itemDetails:Label;
		private var _itemBonusDetails:Label;
		private var _item:IPrototype;
		private var _cost:int;
		private var _ableToAfford:Boolean;
		private var _subcategory:String;

		private var _buyText:String          = 'CodeString.Store.BuyBtn';
		private var _freeText:String         = 'CodeString.Shared.Free';
		private var _unavailableText:String  = 'CodeString.Store.UnavailableBtn';
		private var _cannotAffordText:String = 'CodeString.Store.CannotAffordBtn'

		private var _btnText:String;

		public var onClicked:Signal;

		public function StoreItem()
		{
			super();

			onClicked = new Signal(StoreItem);

			var buyUpClass:Class       = Class(getDefinitionByName('StoreItemBuyBGBMD'));
			var buyROClass:Class       = Class(getDefinitionByName('StoreItemBuyRollOverBGBMD'));
			var buySelectedClass:Class = Class(getDefinitionByName('StoreItemBuySelectedBGBMD'));
			var bmdDisabledClass:Class = Class(getDefinitionByName('StoreItemBuyDisabledBGBMD'));

			super.init(BitmapData(new buyUpClass()), BitmapData(new buyROClass()), BitmapData(new buySelectedClass()), BitmapData(new bmdDisabledClass()), BitmapData(new buySelectedClass()));

			_itemIcon = ObjectPool.get(ImageComponent);
			_itemIcon.init(2000, 2000);

			_btnText = _buyText;

			_costText = new Label(18, 0xfbefaf, 76, 19, false);
			_costText.align = TextFormatAlign.CENTER;
			_costText.constrictTextToSize = false;
			_costText.x = 317;
			_costText.y = 63;
			_costText.text = '999';

			var bmdClass:Class         = Class(getDefinitionByName('KalganSymbolBMD'));
			_premiumSymbol = new Bitmap(BitmapData(new bmdClass()));
			_premiumSymbol.x = 313;
			_premiumSymbol.y = 60;

			_itemDetails = new Label(18, 0xfecf93, _bitmap.width - 120);
			_itemDetails.allCaps = true;
			_itemDetails.multiline = true;
			_itemDetails.constrictTextToSize = false;
			_itemDetails.align = TextFormatAlign.LEFT;
			_itemDetails.x = 105;
			_itemDetails.y = 2;

			_itemDetailSubtext = new Label(12, 0xdddddd, _itemDetails.width, 80, true, 1);
			_itemDetailSubtext.multiline = true;
			_itemDetailSubtext.constrictTextToSize = false;
			_itemDetailSubtext.align = TextFieldAutoSize.LEFT;
			_itemDetailSubtext.x = 106;
			_itemDetailSubtext.y = 22;

			_itemBonusDetails = new Label(12, 0xdddddd, _itemDetails.width, 80, true, 1);
			_itemBonusDetails.multiline = true;
			_itemBonusDetails.constrictTextToSize = false;
			_itemBonusDetails.align = TextFieldAutoSize.LEFT;
			_itemBonusDetails.x = 106;

			_itemStatusText = new Label(20, 0xffffff, 205, 40);
			_itemStatusText.constrictTextToSize = false;
			_itemStatusText.align = TextFormatAlign.RIGHT;
			_itemStatusText.x = 290;
			_itemStatusText.y = 62;

			addChild(_itemIcon);
			addChild(_premiumSymbol);
			addChild(_costText);
			addChild(_itemDetails);
			addChild(_itemDetailSubtext);
			addChild(_itemBonusDetails);
			addChild(_itemStatusText);
		}

		override public function set enabled( enabled:Boolean ):void
		{
			super.enabled = enabled;
			updateText();
		}

		public function set canAfford( afford:Boolean ):void
		{
			_ableToAfford = afford;
			updateText();
		}

		public function get canAfford():Boolean
		{
			return _ableToAfford;
		}

		override protected function onMouse( e:MouseEvent ):void
		{
			super.onMouse(e);
			if (mouseEnabled)
			{
				switch (e.type)
				{
					case MouseEvent.CLICK:
						onClicked.dispatch(this);
						break;
				}

			}
		}

		public function setItemIcon( bmd:BitmapData ):void
		{
			if (_itemIcon && bmd)
			{
				_itemIcon.onImageLoaded(bmd);
				_itemIcon.x = 8 + (81 - _itemIcon.width) * 0.5;
				_itemIcon.y = 7 + (82 - _itemIcon.height) * 0.5;
			}
		}

		public function setItemDetail( itemDetail:String ):void
		{
			_itemDetails.text = itemDetail;
		}

		public function setItemDetailSubtext( itemDetailSubtext:String ):void
		{
			_itemDetailSubtext.text = itemDetailSubtext;
			_itemBonusDetails.y = _itemDetailSubtext.y + _itemDetailSubtext.textHeight + 2;
		}

		public function setItemBonusDetailSubtext( itemBonusDetailSubtext:String ):void
		{
			_itemBonusDetails.htmlText = itemBonusDetailSubtext;
		}

		public function setBuyBtnText( text:String ):void
		{
			_btnText = text;
			updateText();
		}

		private function updateText():void
		{
			if (_itemStatusText)
			{
				if (!enabled)
				{
					_itemStatusText.textColor = 0x929699;
					_costText.textColor = 0xfbefaf;
					_itemStatusText.text = _unavailableText;
				} else if (!_ableToAfford)
				{
					_itemStatusText.textColor = 0xf04c4c;
					_costText.textColor = 0xf04c4c;
					_itemStatusText.text = _cannotAffordText;
				} else
				{
					_itemStatusText.textColor = 0xd9ab70;
					_costText.textColor = 0xfbefaf;
					_itemStatusText.text = _btnText;
				}

				if (enabled)
					_itemStatusText.x = 100;
				else
					_itemStatusText.x = 190;
			}

			if (_premiumSymbol)
				_premiumSymbol.visible = enabled;

			if (_costText)
				_costText.visible = enabled;

		}

		public function setItemCost( cost:int ):void
		{
			_cost = cost;
			_costText.visible = enabled;

			if (_cost == 0)
			{
				if (enabled)
					_premiumSymbol.visible = false;

				_costText.useLocalization = true;
				_costText.text = _freeText;
			} else
			{
				if (enabled)
					_premiumSymbol.visible = true;

				_costText.useLocalization = false;
				_costText.text = String(_cost);
			}
		}

		public function set itemProto( storeItem:IPrototype ):void  { _item = storeItem; }
		public function get itemProto():IPrototype  { return _item }

		public function get cost():int  { return _cost; }

		public function get subcategory():String  { return _subcategory; }
		public function set subcategory( v:String ):void  { _subcategory = v; }

		override public function get width():Number
		{
			return _bitmap.width;
		}

		override public function get height():Number
		{
			return _bitmap.height;
		}

		public function get buyBtn():BitmapButton  { return this; }

		override public function destroy():void
		{
			ObjectPool.give(_itemIcon);

			_costText.destroy();
			_costText = null;

			_itemDetails.destroy();
			_itemDetails = null;

			_itemDetailSubtext.destroy();
			_itemDetailSubtext = null;

			_itemStatusText.destroy();
			_itemStatusText = null;

			_itemBonusDetails.destroy();
			_itemBonusDetails = null;

			_premiumSymbol = null;
		}
	}
}
