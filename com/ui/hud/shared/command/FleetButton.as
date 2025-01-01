package com.ui.hud.shared.command
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.fleet.FleetVO;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class FleetButton extends Sprite
	{
		private static const NORMAL:int       = 0;
		private static const OTHER_SECTOR:int = 1;
		private static const BATTLE:int       = 2;

		public var onLoadSmallImage:Signal;

		private var _name:Label;
		private var _cargo:Label;
		private var _healthBar:ProgressBar;
		private var _fleetID:String;
		private var _transgateIcon:Bitmap;
		private var _cargoImage:Bitmap;
		private var _shipFrame:ScaleBitmap;
		private var _btn:BitmapButton;
		private var _image:ImageComponent;
		private var _fleetVO:FleetVO;
		private var _currentSector:String;
		private var _btnSkins:Array;
		private var _state:int;

		public function FleetButton( skins:Array ):void
		{
			onLoadSmallImage = new Signal(String, Function);

			_btnSkins = skins;

			_btn = UIFactory.getButton(ButtonEnum.FRAME_BLUE, 186, 60);
			_btn.selectable = true;

			_image = ObjectPool.get(ImageComponent);
			_image.init(48, 47);

			_name = UIFactory.getLabel(LabelEnum.DEFAULT, 125, 40, 6, 6);
			_name.fontSize = 18;
			_name.constrictTextToSize = true;
			_name.align = TextFormatAlign.LEFT;
			addChild(_name);

			_cargo = new Label(14, 0xf0f0f0, 50, 20, false);
			_cargo.align = TextFormatAlign.LEFT;
			_cargo.x = 99;
			_cargo.y = 36;
			addChild(_cargo);

			_shipFrame = UIFactory.getScaleBitmap(PanelEnum.CHARACTER_FRAME);
			_shipFrame.width = 48;
			_shipFrame.height = 47;
			_shipFrame.x = 132;
			_shipFrame.y = 7;

			_cargoImage = UIFactory.getBitmap('CargoIconBMD');
			_cargoImage.x = 72;
			_cargoImage.y = 34;

			_healthBar = new ProgressBar();
			_healthBar.init(ProgressBar.VERTICAL, new Bitmap(new BitmapData(42, 37, true, 0x8Cff0000)), null, 0.01);
			_healthBar.x = _shipFrame.x + 3;
			_healthBar.y = _shipFrame.y + 6;
			_healthBar.setMinMax(0, 1);

			_state = 0;

			addChild(_btn);
			addChild(_image);
			addChild(_healthBar);
			addChild(_shipFrame);
			addChild(_cargoImage);
			addChild(_cargo);
			addChild(_name);
		}

		public function setFleetData( fleetVO:FleetVO, currentSector:String ):void
		{
			if (fleetVO)
			{
				_currentSector = currentSector;
				_fleetVO = fleetVO;
				_fleetID = _fleetVO.id;

				_healthBar.amount = 1 - fleetVO.currentHealth;
				_cargo.text = _fleetVO.cargoPercent + '%';
				_name.text = _fleetVO.name;

				onLoadSmallImage.dispatch(fleetVO.asset, onImageLoaded);

				if (_fleetVO.inBattle)
				{
					if (_state != BATTLE)
						_btn.updateBackgrounds(_btnSkins[8], _btnSkins[9], _btnSkins[10], null, _btnSkins[11]);
					_state = BATTLE;
				} else
				{
					if (_currentSector == _fleetVO.sector)
					{
						if (_state != NORMAL)
							_btn.updateBackgrounds(_btnSkins[0], _btnSkins[1], _btnSkins[2], null, _btnSkins[3]);
						_state = NORMAL;
					} else
					{
						if (_state != OTHER_SECTOR)
							_btn.updateBackgrounds(_btnSkins[4], _btnSkins[5], _btnSkins[6], null, _btnSkins[7]);
						_state = OTHER_SECTOR
					}
				}
			} else
				_image.clearBitmap();

		}

		private function onImageLoaded( asset:BitmapData ):void
		{
			if (_image && _shipFrame)
			{
				_image.onImageLoaded(asset);
				_image.x = _shipFrame.x + (_shipFrame.width - _image.width) * 0.5;
				_image.y = _shipFrame.y + (_shipFrame.height - _image.height) * 0.5;
			}
		}

		public function get fleetName():String  { return _fleetVO.name; }

		public function set selected( v:Boolean ):void  { _btn.selected = v; }
		public function get selected():Boolean  { return _btn.selected; }

		public function get fleet():FleetVO  { return _fleetVO; }
		public function get fleetID():String  { return _fleetID; }

		public function get inBattle():Boolean  { return _fleetVO.inBattle }

		public function get inSector():Boolean  { return (_currentSector == _fleetVO.sector); }

		public function destroy():void
		{
			if (onLoadSmallImage)
				onLoadSmallImage.removeAll();

			onLoadSmallImage = null;

			if (_name)
				_name.destroy();

			_name = null;

			if (_cargo)
				_cargo.destroy();

			_cargo = null;


			if (_healthBar)
				_healthBar.destroy();

			if (_btn)
				_btn.destroy();

			if (_image)
				ObjectPool.give(_image);

			_btnSkins.length = 0;

			_image = null;

			_healthBar = null;

			_transgateIcon = null;
			_cargoImage = null;
			_shipFrame = null;
			_state = 3;
		}

	}
}
