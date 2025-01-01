package com.ui.modal.dock
{
	import com.model.fleet.ShipVO;
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
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class ShipPanelSelection extends Sprite
	{
		public var onClicked:Signal;

		private var _ship:ShipVO;
		private var _shipBG:Bitmap;
		private var _shipName:Label;
		private var _shipCustomName:Label;

		private var _dpsBG:Bitmap;
		private var _armorBG:Bitmap;
		private var _rangeBG:Bitmap;
		private var _evasionBG:Bitmap;
		private var _maskingBG:Bitmap;
		private var _cargoBG:Bitmap;

		private var _health:Label;
		private var _healthTitle:Label;
		private var _dps:Label;
		private var _armor:Label;
		private var _range:Label;
		private var _evasion:Label;
		private var _masking:Label;
		private var _cargo:Label;

		private var _healthBar:ProgressBar;

		private var _shipBtn:BitmapButton;

		private var _image:ImageComponent;

		public function ShipPanelSelection()
		{
			addEventListener(MouseEvent.CLICK, onMouse, false, 5, true);

			var statsBGBitmapData:BitmapData = new BitmapData(153, 18, false, 0x437b89);

			_shipBtn = new BitmapButton();
			_shipBtn.init(UIFactory.getBitmapData('SelectFrameBMD'), UIFactory.getBitmapData('SelectFrameRollOverBMD'), UIFactory.getBitmapData('SelectFrameDownBMD'));
			_shipBtn.scale9Grid = new Rectangle(10, 10, 10, 10);
			_shipBtn.setSize(600, 113);

			onClicked = new Signal(ShipVO);

			_shipBG = UIFactory.getBitmap('SelectionFrameBMD');
			_shipBG.x = 3;
			_shipBG.y = 7;

			_image = new ImageComponent();
			_image.init(_shipBG.width, _shipBG.height);
			
			_shipCustomName = new Label(18, 0xfffffff, 90, 20, true);
			_shipCustomName.autoSize = TextFieldAutoSize.LEFT;
			_shipCustomName.allCaps = true;
			_shipCustomName.x = 115;
			_shipCustomName.y = 20;
			_shipCustomName.constrictTextToSize = false;

			_shipName = new Label(12, 0xfffffff, 90, 20, true);
			_shipName.autoSize = TextFieldAutoSize.LEFT;
			_shipName.allCaps = true;
			_shipName.x = 115;
			_shipName.y = 5;
			_shipName.constrictTextToSize = false;
			
			_dpsBG = new Bitmap(statsBGBitmapData);
			_dpsBG.alpha = .5;
			_dpsBG.x = 117;
			_dpsBG.y = 45;

			_armorBG = new Bitmap(statsBGBitmapData);
			_armorBG.alpha = .5;
			_armorBG.x = 117;
			_armorBG.y = 70;

			_rangeBG = new Bitmap(statsBGBitmapData);
			_rangeBG.alpha = .5;
			_rangeBG.x = 438;
			_rangeBG.y = 45;

			_evasionBG = new Bitmap(statsBGBitmapData);
			_evasionBG.alpha = .5;
			_evasionBG.x = 277;
			_evasionBG.y = 45;

			_maskingBG = new Bitmap(statsBGBitmapData);
			_maskingBG.alpha = .5;
			_maskingBG.x = 277;
			_maskingBG.y = 70;

			_cargoBG = new Bitmap(statsBGBitmapData);
			_cargoBG.alpha = .5;
			_cargoBG.x = 438;
			_cargoBG.y = 70;

			_dps = new Label(12, 0xfffffff, _dpsBG.width, _dpsBG.height, true, 1);
			_dps.align = TextFormatAlign.LEFT;
			_dps.x = _dpsBG.x;
			_dps.y = _dpsBG.y;
			_dps.constrictTextToSize = false;

			_armor = new Label(12, 0xfffffff, _armorBG.width, _armorBG.height, true, 1);
			_armor.align = TextFormatAlign.LEFT;
			_armor.x = _armorBG.x;
			_armor.y = _armorBG.y;
			_armor.constrictTextToSize = false;

			_range = new Label(12, 0xfffffff, _rangeBG.width, _rangeBG.height, true, 1);
			_range.align = TextFormatAlign.LEFT;
			_range.x = _rangeBG.x;
			_range.y = _rangeBG.y;
			_range.constrictTextToSize = false;

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

			var healthy:ScaleBitmap          = PanelFactory.getScaleBitmapPanel('FleetHealthBarGoodBMD', 140, 21, new Rectangle(2, 10, 1, 1));
			var damaged:ScaleBitmap          = PanelFactory.getScaleBitmapPanel('FleetHealthBarHurtBMD', 140, 20, new Rectangle(2, 10, 1, 1));
			_healthBar = new ProgressBar()
			_healthBar.init(ProgressBar.HORIZONTAL, healthy, damaged, 0.01);
			_healthBar.x = 451;
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
			addChild(_shipCustomName);
			addChild(_shipBG);
			addChild(_dpsBG);
			addChild(_armorBG);
			addChild(_rangeBG);
			addChild(_evasionBG);
			addChild(_maskingBG);
			addChild(_cargoBG);
			addChild(_dps);
			addChild(_armor);
			addChild(_range);
			addChild(_evasion);
			addChild(_masking);
			addChild(_cargo);
			addChild(_healthBar);
			addChild(_healthTitle);
			addChild(_health);
			addChild(_image);
		}

		public function onLoadImage( asset:BitmapData ):void
		{
			if (_image)
			{
				_image.onImageLoaded(asset);
				_image.x = _shipBG.x + (_shipBG.width - _image.width) * 0.5
				_image.y = _shipBG.y + (_shipBG.height - _image.height) * 0.5
			}
		}

		public function setName( name:String ):void
		{
			_shipName.text = name;
		}
		public function setCustomName( name:String ):void
		{
			if(name.length>0)
				_shipCustomName.text = name;
			else
			{
				_shipCustomName.text = _shipName.text;
				_shipName.text = "";
			}
				
		}

		public function set ship( ship:ShipVO ):void
		{
			_ship = ship;

			_dps.setTextWithTokens('CodeString.Shared.Damage', {'[[Number.Damage]]':_ship.shipDps});

			_armor.setTextWithTokens('CodeString.Shared.Armor', {'[[Number.Armor]]':_ship.armor});


			_range.setTextWithTokens('CodeString.Shared.Range', {'[[Number.Range]]':_ship.maxRange});

			_evasion.setTextWithTokens('CodeString.Shared.Evasion', {'[[Number.Evasion]]':_ship.evasion});

			_masking.setTextWithTokens('CodeString.Shared.Masking', {'[[Number.Masking]]':_ship.masking});

			_cargo.setTextWithTokens('CodeString.Shared.Cargo', {'[[Number.Cargo]]':_ship.cargo});

			_healthBar.amount = _ship.currentHealth;

			var totalHealth:int = _ship.healthAmount;

			_health.text = Math.round(_ship.currentHealth * totalHealth) + ' / ' + totalHealth;


			var rarity:String   = _ship.getValue('rarity');
			_shipName.textColor = CommonFunctionUtil.getRarityColor(rarity);
			_shipCustomName.textColor = _shipName.textColor;
			if (rarity != 'Common')
				_shipBG.filters = [CommonFunctionUtil.getRarityGlow(rarity)];
		}

		private function createGlow( rgb:uint ):GlowFilter
		{
			var glow:GlowFilter = new GlowFilter()
			glow.inner = true;
			glow.color = rgb;
			glow.blurX = 5;
			glow.blurY = 5;

			return glow;
		}

		public function get itemClass():String
		{
			return _ship.getValue('itemClass');
		}

		public function getTooltip():String
		{
			var tooltip:String = '';
			if (_ship)
				tooltip = _ship.tooltip;

			return tooltip;
		}

		private function onMouse( e:MouseEvent ):void
		{
			onClicked.dispatch(_ship);
		}

		public function destroy():void
		{
			removeEventListener(MouseEvent.CLICK, onMouse);

			if (onClicked)
				onClicked.removeAll();

			onClicked = null;

			_shipBG = null;
			_dpsBG = null;
			_armorBG = null;
			_rangeBG = null;
			_evasionBG = null;
			_maskingBG = null;
			_cargoBG = null;

			if (_shipName)
				_shipName.destroy();

			_shipName = null;
			
			if (_shipCustomName)
				_shipCustomName.destroy();
			
			_shipCustomName = null;

			if (_health)
				_health.destroy();

			_health = null;

			if (_healthTitle)
				_healthTitle.destroy();

			_healthTitle = null;

			if (_dps)
				_dps.destroy();

			_dps = null;

			if (_armor)
				_armor.destroy();

			_armor = null;

			if (_range)
				_range.destroy();

			_range = null;

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
