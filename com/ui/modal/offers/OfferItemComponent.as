package com.ui.modal.offers
{
	import com.model.asset.AssetModel;
	import com.ui.UIFactory;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;

	import org.shared.ObjectPool;
	import com.ui.core.component.misc.ImageComponent;

	public class OfferItemComponent extends Sprite
	{
		private var _itemBacking:Bitmap;
		private var _itemImage:ImageComponent;

		private var _itemName:Label;
		private var _itemDescription:Label;

		public function OfferItemComponent()
		{
			super();

			_itemBacking = UIFactory.getBitmap('ItemBGBMD');

			_itemImage = ObjectPool.get(ImageComponent);
			_itemImage.init(3000, 3000);

			_itemName = new Label(18, 0xfecf93, 245);
			_itemName.allCaps = true;
			_itemName.multiline = true;
			_itemName.constrictTextToSize = false;
			_itemName.align = TextFormatAlign.LEFT;
			_itemName.x = 80; //120;
			_itemName.y = 0;

			_itemDescription = new Label(12, 0xdddddd, 275, 80, true, 1);
			_itemDescription.align = TextFormatAlign.LEFT;
			_itemDescription.constrictTextToSize = true;
			_itemDescription.multiline = true;
			_itemDescription.x = 80; //120;
			_itemDescription.y = 20;

			addChild(_itemBacking);
			addChild(_itemImage);
			addChild(_itemName);
			addChild(_itemDescription);
		}

		public function onImageLoaded( asset:BitmapData ):void
		{
			if (_itemImage)
			{
				_itemImage.onImageLoaded(asset);
				_itemImage.x = 10 // 5 + (102 - _itemImage.width) * 0.5;
				_itemImage.y = 11 + (52 - _itemImage.height) * 0.5;

			}
		}

		public function setItemName( v:String ):void
		{
			_itemName.text = v;
		}

		public function setItemNameWithTokens( v:String, tokens:Object ):void
		{
			_itemName.setTextWithTokens(v, tokens);
		}

		public function setItemDescription( v:String ):void
		{
			_itemDescription.text = v;
		}

		public function setItemDescriptionWithTokens( v:String, tokens:Object ):void
		{
			_itemDescription.setTextWithTokens(v, tokens);
		}

		public function destroy():void
		{
			_itemBacking = null;

			ObjectPool.give(_itemImage);
			_itemImage = null;

			_itemName.destroy();
			_itemName = null;

			_itemDescription.destroy();
			_itemDescription = null;
		}
	}
}
