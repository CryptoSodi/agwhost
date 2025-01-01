package com.ui.modal.dock
{
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.ui.UIFactory;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.misc.ImageComponent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	
	import org.osflash.signals.Signal;

	public class ShipIcon extends BitmapButton
	{
		protected var _index:int;
		protected var _fleet:FleetVO;
		protected var _ship:ShipVO;

		private var _image:ImageComponent;
		private var _bgMask:Bitmap;

		private var _healthBar:ProgressBar;
		private var _isSelected:Boolean;

		public var onLoadShipImage:Signal;

		public function ShipIcon()
		{
			super.init(UIFactory.getBitmapData('BtnShipUpBMD'), UIFactory.getBitmapData('BtnShipROBMD'), UIFactory.getBitmapData('BtnShipDownBMD'), UIFactory.getBitmapData('BtnShipDisabledBMD'), UIFactory.
					   getBitmapData('BtnShipSelectedBMD'));

			_image = new ImageComponent();
			_image.init(_bitmap.width, _bitmap.height);

			_bgMask = UIFactory.getBitmap('IconShipDamagedBMD');
			_bgMask.x = _bitmap.x + 3;
			_bgMask.y = _bitmap.y + 3;
			_bgMask.cacheAsBitmap = true;

			_healthBar = new ProgressBar();
			_healthBar.init(ProgressBar.VERTICAL, new Bitmap(new BitmapData(_bitmap.width, _bitmap.height, true, 0x8Cff0000)), null, 0.01);
			_healthBar.x = _bitmap.x;
			_healthBar.y = _bitmap.y;
			_healthBar.mask = _bgMask;
			_healthBar.cacheAsBitmap = true;
			_healthBar.setMinMax(0, 1);

			addChild(_image);
			addChild(_healthBar);
			addChild(_bgMask);

			onLoadShipImage = new Signal(String, Function);

			mouseChildren = false;
		}

		public function setBarValue( value:Number ):void
		{
			_healthBar.amount = value;
			_healthBar.visible = _healthBar.amount != 0;
		}

		public function setShip( ship:ShipVO, prototype:IPrototype = null, fleet:FleetVO = null ):void
		{
			if (ship)
				_setShip(ship, fleet);
			else if (prototype)
			{
				var vo:ShipVO = new ShipVO();
				vo.prototypeVO = prototype;
				_setShip(vo, fleet);
			} else
				_setShip(ship, fleet);
		}

		protected function _setShip( ship:ShipVO, fleet:FleetVO ):void
		{
			_fleet = fleet;
			_ship = ship;
			if (!_ship)
			{
				_image.clearBitmap();
				_healthBar.amount = 0;
				_healthBar.visible = false;
			} else
			{
				onLoadShipImage.dispatch(_ship.prototypeVO.asset, onImageLoaded);
				var isNewRepairSystemActive:Boolean = PrototypeModel.instance.getConstantPrototypeValueByName("isNewRepairSystemActive");
				if (isNewRepairSystemActive)
				{
					if(fleet)
					{
						var newHealthPct:Number = fleet.GetFleetHealthFromRepairTimeRemaining();
						var pctDamageRemaining:Number;
						if(fleet.currentHealth != 1)
							pctDamageRemaining = (1 - newHealthPct) / (1 - fleet.currentHealth);
						else
							pctDamageRemaining = 0;
						
						_healthBar.amount = ( ( 1- _ship.currentHealth) * pctDamageRemaining );
					}
				}
				else
					_healthBar.amount = (1 - _ship.currentHealth);
				
				_healthBar.visible = _healthBar.amount != 0;
			}
		}

		public function onImageLoaded( asset:BitmapData ):void
		{
			if (_image)
			{
				_image.onImageLoaded(asset);
				_image.smoothing = true;
				_image.x = _bitmap.x + (_bitmap.width - _image.width) * 0.5;
				_image.y = _bitmap.y + (_bitmap.height - _image.height) * 0.5;
			}
		}

		public function clearImageBitmap():void
		{
			_image.clearBitmap();
		}

		public function set index( index:int ):void
		{
			_index = index;
		}

		public function get index():int
		{
			return _index;
		}

		public function get ship():ShipVO
		{
			return _ship;
		}

		public function get id():String
		{
			return _ship.id;
		}

		override public function set scaleX( value:Number ):void
		{
			_bitmap.scaleX = value;
			_bgMask.scaleX = value;
			_healthBar.scaleX = value;
			_bgMask.cacheAsBitmap = true;
			_healthBar.mask = _bgMask;
			_healthBar.cacheAsBitmap = true;
		}

		override public function get scaleX():Number
		{
			return _bitmap.scaleX;
		}

		override public function set scaleY( value:Number ):void
		{
			_bitmap.scaleY = value;
			_bgMask.scaleY = value;
			_healthBar.scaleY = value;

			_bgMask.cacheAsBitmap = true;
			_healthBar.mask = _bgMask;
			_healthBar.cacheAsBitmap = true;

		}

		public function scale( x:Number, y:Number ):void
		{
			_bitmap.scaleX = x;
			_bitmap.scaleY = y;

			_bgMask.scaleX = y;
			_bgMask.scaleY = x;

			_healthBar.scaleX = x;
			_healthBar.scaleY = y;

			_healthBar.x = _bitmap.x;
			_healthBar.y = _bitmap.y;
			_bgMask.x = _bitmap.x + 1;
			_bgMask.y = _bitmap.y + 1;

			_bgMask.cacheAsBitmap = true;
			_healthBar.mask = _bgMask;
			_healthBar.cacheAsBitmap = true;
		}

		override public function get scaleY():Number
		{
			return _bitmap.scaleY;
		}

		override public function destroy():void
		{
			super.destroy();

			if (_healthBar)
			{
				_healthBar.destroy();
				_healthBar = null;
			}
		}
	}
}
