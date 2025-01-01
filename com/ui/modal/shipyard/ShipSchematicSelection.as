package com.ui.modal.shipyard
{
	import com.model.prototype.IPrototype;
	import com.ui.UIFactory;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;
	import com.ui.core.ScaleBitmap;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class ShipSchematicSelection extends Sprite
	{
		private var _shipSchematic:IPrototype;
		private var _shipBG:Bitmap;
		private var _shipName:Label;
		private var _lock:Bitmap;

		private var _powerBG:Bitmap;
		private var _armorBG:Bitmap;
		private var _loadTimeBG:Bitmap;
		private var _evasionBG:Bitmap;
		private var _maskingBG:Bitmap;
		private var _cargoBG:Bitmap;

		private var _health:Label;
		private var _healthTitle:Label;
		private var _power:Label;
		private var _armor:Label;
		private var _loadTime:Label;
		private var _evasion:Label;
		private var _masking:Label;
		private var _cargo:Label;

		private var _shipBtn:BitmapButton;

		private var _healthBar:ProgressBar;

		public var onClicked:Signal;

		private var _image:ImageComponent;

		public function ShipSchematicSelection()
		{
			addEventListener(MouseEvent.CLICK, onMouse, false, 0, true);

			var shipSelectBGClass:Class      = Class(getDefinitionByName('SelectionFrameBMD'));

			var statsBGBitmapData:BitmapData = new BitmapData(153, 18, false, 0x437b89);

			_shipBtn = new BitmapButton();
			_shipBtn.init(UIFactory.getBitmapData('SelectFrameBMD'), UIFactory.getBitmapData('SelectFrameRollOverBMD'), UIFactory.getBitmapData('SelectFrameDownBMD'));
			_shipBtn.scale9Grid = new Rectangle(10, 10, 10, 10);
			_shipBtn.setSize(700, 113);

			onClicked = new Signal(IPrototype);

			_shipBG = new Bitmap(BitmapData(new shipSelectBGClass()));
			_shipBG.x = 3;
			_shipBG.y = 7;

			_lock = UIFactory.getBitmap('IconBlueLockedBMD');

			_image = new ImageComponent();
			_image.init(_shipBG.width, _shipBG.height);

			_shipName = new Label(20, 0xfffffff, 90, 20, true);
			_shipName.autoSize = TextFieldAutoSize.LEFT;
			_shipName.allCaps = true;
			_shipName.x = 115;
			_shipName.y = 10;
			_shipName.constrictTextToSize = false;

			_powerBG = new Bitmap(statsBGBitmapData);
			_powerBG.alpha = .5;
			_powerBG.x = 117;
			_powerBG.y = 45;

			_armorBG = new Bitmap(statsBGBitmapData);
			_armorBG.alpha = .5;
			_armorBG.x = 117;
			_armorBG.y = 70;

			_loadTimeBG = new Bitmap(statsBGBitmapData);
			_loadTimeBG.alpha = .5;
			_loadTimeBG.x = 478;
			_loadTimeBG.y = 45;

			_evasionBG = new Bitmap(statsBGBitmapData);
			_evasionBG.alpha = .5;
			_evasionBG.x = 297;
			_evasionBG.y = 45;

			_maskingBG = new Bitmap(statsBGBitmapData);
			_maskingBG.alpha = .5;
			_maskingBG.x = 297;
			_maskingBG.y = 70;

			_cargoBG = new Bitmap(statsBGBitmapData);
			_cargoBG.alpha = .5;
			_cargoBG.x = 478;
			_cargoBG.y = 70;

			_power = new Label(12, 0xfffffff, _powerBG.width, _powerBG.height, true, 1);
			_power.align = TextFormatAlign.LEFT;
			_power.x = _powerBG.x;
			_power.y = _powerBG.y;
			_power.constrictTextToSize = false;

			_armor = new Label(12, 0xfffffff, _armorBG.width, _armorBG.height, true, 1);
			_armor.align = TextFormatAlign.LEFT;
			_armor.x = _armorBG.x;
			_armor.y = _armorBG.y;
			_armor.constrictTextToSize = false;

			_loadTime = new Label(12, 0xfffffff, _loadTimeBG.width, _loadTimeBG.height, true, 1);
			_loadTime.align = TextFormatAlign.LEFT;
			_loadTime.x = _loadTimeBG.x;
			_loadTime.y = _loadTimeBG.y;
			_loadTime.constrictTextToSize = false;

			_evasion = new Label(12, 0xfffffff, _evasionBG.width, _evasionBG.height, true, 1);
			_evasion.align = TextFormatAlign.LEFT;
			_evasion.x = _evasionBG.x;
			_evasion.y = _evasionBG.y;
			_evasion.constrictTextToSize = false;

			_masking = new Label(12, 0xfffffff, _maskingBG.width, _maskingBG.height, true, 1);
			_masking.align = TextFormatAlign.LEFT;
			_masking.x = _maskingBG.x;
			_masking.y = _maskingBG.y;
			_masking.constrictTextToSize = false;

			_cargo = new Label(12, 0xfffffff, _cargoBG.width, _cargoBG.height, true, 1);
			_cargo.align = TextFormatAlign.LEFT;
			_cargo.x = _cargoBG.x;
			_cargo.y = _cargoBG.y;
			_cargo.constrictTextToSize = false;

			var healthy:ScaleBitmap          = PanelFactory.getScaleBitmapPanel('FleetHealthBarGoodBMD', 140, 20, new Rectangle(2, 10, 1, 1));
			var damaged:ScaleBitmap          = PanelFactory.getScaleBitmapPanel('FleetHealthBarHurtBMD', 140, 20, new Rectangle(2, 10, 1, 1));
			_healthBar = new ProgressBar()
			_healthBar.init(ProgressBar.HORIZONTAL, healthy, damaged, 0.01);
			_healthBar.x = 491;
			_healthBar.y = 10;
			_healthBar.setMinMax(0, 1);

			_health = new Label(12, 0xfffffff, _healthBar.width, 25, true, 1);
			_health.align = TextFormatAlign.CENTER;
			_health.height -= 10;
			_health.x = _healthBar.x;
			_health.y = _healthBar.y;
			_health.constrictTextToSize = false;

			_healthTitle = new Label(16, 0xfffffff, 120, 25, true, 1);
			_healthTitle.align = TextFormatAlign.LEFT;
			_healthTitle.constrictTextToSize = false;
			_healthTitle.text = 'CodeString.Shared.HealthTitle';
			_healthTitle.x = _healthBar.x - _healthTitle.textWidth - 5;
			_healthTitle.y = _healthBar.y - 3;


			addChild(_shipBtn);
			addChild(_shipName);
			addChild(_shipBG);
			addChild(_powerBG);
			addChild(_armorBG);
			addChild(_loadTimeBG);
			addChild(_evasionBG);
			addChild(_maskingBG);
			addChild(_cargoBG);
			addChild(_power);
			addChild(_armor);
			addChild(_loadTime);
			addChild(_evasion);
			addChild(_masking);
			addChild(_cargo);
			addChild(_healthBar);
			addChild(_healthTitle);
			addChild(_health);
			addChild(_image);
			addChild(_lock);
		}

		public function onLoadImage( asset:BitmapData ):void
		{
			if (_image)
			{
				_image.onImageLoaded(asset);
				_image.x = _shipBG.x + (_shipBG.width - _image.width) * 0.5
				_image.y = _shipBG.y + (_shipBG.height - _image.height) * 0.5
				_lock.x = _image.x + (_image.width - _lock.width) * 0.5
				_lock.y = _image.y + (_image.height - _lock.height) * 0.5
			}
		}

		public function set locked( value:Boolean ):void
		{
			if (_lock)
				_lock.visible = value;
		}

		public function setName( name:String ):void
		{
			_shipName.text = name;
		}

		public function set ship( shipSchematic:IPrototype ):void
		{
			_shipSchematic = shipSchematic;

			_power.setTextWithTokens('CodeString.Shared.Power', {'[[Number.Power]]':_shipSchematic.getValue('power')});

			_armor.setTextWithTokens('CodeString.Shared.Armor', {'[[Number.Armor]]':_shipSchematic.getValue('armor')});


			_loadTime.setTextWithTokens('CodeString.Shared.LoadSpeed', {'[[Number.LoadSpeed]]':Math.round(_shipSchematic.getValue('loadSpeed'))});

			_evasion.setTextWithTokens('CodeString.Shared.Evasion', {'[[Number.Evasion]]':_shipSchematic.getValue('evasion')});

			_masking.setTextWithTokens('CodeString.Shared.Masking', {'[[Number.Masking]]':_shipSchematic.getValue('masking')});

			_cargo.setTextWithTokens('CodeString.Shared.Cargo', {'[[Number.Cargo]]':_shipSchematic.getValue('cargo')});

			_healthBar.amount = 1;

			var totalHealth:int = _shipSchematic.getValue('health');

			_health.text = String(totalHealth);

			var rarity:String   = _shipSchematic.getValue('rarity');

			_shipName.textColor = CommonFunctionUtil.getRarityColor(rarity);
			if (rarity != 'Common')
				_shipBG.filters = [CommonFunctionUtil.getRarityGlow(rarity)];

		}

		public function get itemClass():String
		{
			return _shipSchematic.getValue('itemClass');
		}

		public function get schematic():IPrototype
		{
			return _shipSchematic;
		}

		protected function onMouse( e:MouseEvent ):void
		{
			if (!_lock.visible)
			{
				onClicked.dispatch(_shipSchematic);
			}
		}

		public function destroy():void
		{
			removeEventListener(MouseEvent.CLICK, onMouse);

			if (onClicked)
				onClicked.removeAll();

			onClicked = null;

			_lock = null;
			_shipBG = null;
			_powerBG = null;
			_armorBG = null;
			_loadTimeBG = null;
			_evasionBG = null;
			_maskingBG = null;
			_cargoBG = null;

			if (_shipName)
				_shipName.destroy();

			_shipName = null;

			if (_health)
				_health.destroy();

			_health = null;

			if (_healthTitle)
				_healthTitle.destroy();

			_healthTitle = null;

			if (_power)
				_power.destroy();

			_power = null;

			if (_armor)
				_armor.destroy();

			_armor = null;

			if (_loadTime)
				_loadTime.destroy();

			_loadTime = null;

			if (_evasion)
				_evasion.destroy();

			_evasion = null;

			if (_masking)
				_masking.destroy();

			_masking = null;

			if (_cargo)
				_cargo.destroy();

			_cargo = null;


			if (_healthBar)
				ObjectPool.give(_healthBar);

			_healthBar = null;

			if (_shipBtn)
				ObjectPool.give(_shipBtn);

			_shipBtn = null;

			if (_image)
				ObjectPool.give(_image);

			_image = null;
		}

	}
}
