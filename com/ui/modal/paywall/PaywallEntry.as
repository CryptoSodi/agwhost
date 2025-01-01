package com.ui.modal.paywall
{
	import com.enum.ui.ButtonEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.service.ExternalInterfaceAPI;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;

	public class PaywallEntry extends Sprite
	{
		public var onClicked:Signal;

		private var _bg:BitmapButton;
		private var _checkbox:BitmapButton;

		private var _palladiumSymbol:Bitmap;

		private var _ingameCurrencyGranted:Label;

		private var _costLbl:Label;
		private var _descriptionInfoLbl:Label;
		private var _bonusLbl:Label;

		private var _id:String;
		private var _payoutID:String;

		private var _cost:int;
		private var _quantity:int;

		private var _kredsText:String = 'CodeString.PaywallView.Kreds'; //BUY NOW

		public function PaywallEntry( entry:Object )
		{
			onClicked = new Signal(PaywallEntry);

			super();
			var bonus:String       = '';
			var description:String = '';
			if ('description' in entry)
			{
				var stuff:Array = entry.description.split('\r\n');
				if (stuff.length >= 2)
					description = stuff[1];

				if (stuff.length >= 3)
					bonus = stuff[2];
			}

			_bg = UIFactory.getButton(ButtonEnum.FRAME_BLUE, 692, 43);
			_bg.addEventListener(MouseEvent.CLICK, onEntryClicked, false, 0, true);

			_checkbox = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 16, 12);
			_checkbox.enabled = _checkbox.selectable = false;

			_palladiumSymbol = UIFactory.getBitmap('KalganSymbolBMD');
			_palladiumSymbol.x = 48;
			_palladiumSymbol.y = _bg.y + (_bg.height - _palladiumSymbol.height) * 0.5;

			_ingameCurrencyGranted = new Label(20, 0xe4b170, 150, 25);
			_ingameCurrencyGranted.constrictTextToSize = false;
			_ingameCurrencyGranted.align = TextFormatAlign.LEFT;
			_ingameCurrencyGranted.x = 85;
			_ingameCurrencyGranted.y = 9;

			if ('name' in entry)
				_ingameCurrencyGranted.text = entry.name;

			_costLbl = new Label(20, 0xf0f0f0);
			_costLbl.constrictTextToSize = false;
			_costLbl.align = TextFormatAlign.LEFT;
			_costLbl.x = 272;
			_costLbl.y = 11;

			if ('price' in entry)
			{
				_costLbl.setTextWithTokens(_kredsText, {'[[Number.KredAmount]]':entry.price});
				_cost = entry.price;
			}

			_descriptionInfoLbl = new Label(20, 0xd3000d);
			_descriptionInfoLbl.constrictTextToSize = false;
			_descriptionInfoLbl.align = TextFormatAlign.LEFT;
			_descriptionInfoLbl.x = _costLbl.x + _costLbl.textWidth + 20;
			_descriptionInfoLbl.y = 11;

			if (description != '')
				_descriptionInfoLbl.text = description;


			_bonusLbl = new Label(20, 0xffdc41, 150, 25);
			_bonusLbl.constrictTextToSize = false;
			_bonusLbl.align = TextFormatAlign.LEFT;
			_bonusLbl.x = 475;
			_bonusLbl.y = 9;

			if (bonus != '')
				_bonusLbl.text = bonus;

			if ('identifier' in entry)
				_id = entry.identifier;

			addChild(_bg);
			addChild(_checkbox);
			addChild(_palladiumSymbol);
			addChild(_ingameCurrencyGranted);
			addChild(_costLbl);
			addChild(_descriptionInfoLbl);
			addChild(_bonusLbl);
			
			if ('quantity' in entry)
				_quantity = entry.quantity;
		}

		public function set selected( v:Boolean ):void
		{
			_bg.selectable = true;
			_bg.selected = v;
			_bg.selectable = false;

			_checkbox.enabled = _checkbox.selectable = true;
			_checkbox.selected = v;
			_checkbox.enabled = _checkbox.selectable = false;
		}

		private function onEntryClicked( e:MouseEvent ):void
		{
			onClicked.dispatch(this);
		}

		public function get id():String  { return _id; }
		public function get payoutID():String  { return _payoutID; }
		public function get cost():int  { return _cost; }
		public function get quantity():int  { return _quantity; }

		override public function get width():Number  { return _bg.width; }
		override public function get height():Number  { return _bg.height; }

		public function destroy():void
		{
			if (onClicked)
				onClicked.removeAll();

			onClicked = null;

			_palladiumSymbol = null;

			if (_bg)
			{
				_bg.removeEventListener(MouseEvent.CLICK, onEntryClicked);
				_bg.destroy();
			}
			_bg = null;

			if (_ingameCurrencyGranted)
				_ingameCurrencyGranted.destroy();

			_ingameCurrencyGranted = null;

			if (_costLbl)
				_costLbl.destroy();

			_costLbl = null;

			if (_descriptionInfoLbl)
				_descriptionInfoLbl.destroy();

			_descriptionInfoLbl = null;

			if (_bonusLbl)
				_bonusLbl.destroy();

			_bonusLbl = null;
		}
	}
}
