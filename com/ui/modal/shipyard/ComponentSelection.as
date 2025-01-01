package com.ui.modal.shipyard
{
	import com.enum.SlotComponentEnum;
	import com.enum.ui.ButtonEnum;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.misc.ImageComponent;
	import com.util.CommonFunctionUtil;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.utils.getDefinitionByName;

	import org.adobe.utils.StringUtil;
	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.osflash.signals.Signal;

	public class ComponentSelection extends BitmapButton
	{
		public var onSelectComponent:Signal;
		public var onHover:Signal;

		private var _bgUp:BitmapData;
		private var _bgOver:BitmapData;
		private var _bgSelected:BitmapData;
		private var _index:uint;
		private var _componentType:String;
		private var _selectedComponent:IPrototype;
		private var _image:ImageComponent;
		private var _slotType:String;

		public function ComponentSelection( componentType:String, slotType:String, index:uint )
		{
			super();

			_componentType = componentType;
			_slotType = slotType;
			_index = index;
			onHover = new Signal(Boolean, uint);
			onSelectComponent = new Signal(String, uint, Sprite);

			setUpComponent();
		}

		override public function set x( value:Number ):void
		{
			super.x = value - width * 0.5;
		}

		override public function set y( value:Number ):void
		{
			super.y = value - height * 0.5;
		}

		private function setUpComponent():void
		{
			var upBMD:String;
			var overBMD:String;
			var selectedBMD:String;

			switch (_componentType)
			{
				case SlotComponentEnum.SLOT_TYPE_WEAPON:
					upBMD = 'WeaponSlotUpBMD';
					overBMD = 'WeaponSlotRollOverBMD';
					selectedBMD = 'WeaponSlotSelectedBMD';
					break;
				case SlotComponentEnum.SLOT_TYPE_SPECIAL:
					upBMD = 'SpecialSlotUpBMD';
					overBMD = 'SpecialSlotRollOverBMD';
					selectedBMD = 'SpecialSlotSelectedBMD';
					break;
				case SlotComponentEnum.SLOT_TYPE_DEFENSE:
					upBMD = 'ShieldSlotUpBMD';
					overBMD = 'ShieldSlotRollOverBMD';
					selectedBMD = 'ShieldSlotSelectedBMD';
					break;
				case SlotComponentEnum.SLOT_TYPE_TECH:
					upBMD = 'TechSlotUpBMD';
					overBMD = 'TechSlotRollOverBMD';
					selectedBMD = 'TechSlotSelectedBMD';
					break;
				case SlotComponentEnum.SLOT_TYPE_TURRET:
					upBMD = 'WeaponSlotUpBMD';
					overBMD = 'WeaponSlotRollOverBMD';
					selectedBMD = 'WeaponSlotSelectedBMD';
					break;
				case SlotComponentEnum.SLOT_TYPE_STRUCTURE:
					upBMD = 'StructureSlotUpBMD';
					overBMD = 'StructureSlotRollOverBMD';
					selectedBMD = 'StructureSlotSelectedBMD';
					break;
			}

			_bgUp = UIFactory.getBitmapData(upBMD);
			_bgOver = UIFactory.getBitmapData(overBMD);
			_bgSelected = UIFactory.getBitmapData(selectedBMD);

			super.init(_bgUp, _bgOver, _bgSelected);
			_image = new ImageComponent();
			_image.init(60, 60);
			addChild(_image);
		}

		override protected function onMouse( e:MouseEvent ):void
		{
			super.onMouse(e);
			switch (e.type)
			{
				case MouseEvent.CLICK:
					if (mouseEnabled)
						onSelectComponent.dispatch(_slotType, _index, this);
					break;
				case MouseEvent.ROLL_OVER:
					onHover.dispatch(true, _index);
					break;
				case MouseEvent.ROLL_OUT:
					onHover.dispatch(false, _index);
					break;
			}
		}

		private function scaleOut():void
		{
			TweenLite.to(_image, .2, {scaleX:1.15, scaleY:1.15, ease:Quad.easeIn});
		}

		private function scaleIn():void
		{
			TweenLite.to(_image, .2, {scaleX:1.0, scaleY:1.0, ease:Quad.easeIn});
		}

		public function onOutsideRollOver():void
		{
			if (_bitmap.visible)
			{
				if (!_selected)
				{
					_state = ButtonEnum.STATE_OVER;
					showState();
				}
			} else
			{
				scaleOut();
			}
		}

		public function onOutsideRollOut():void
		{
			if (_bitmap.visible)
			{
				_state = (_selected) ? ButtonEnum.STATE_SELECTED : ButtonEnum.STATE_NORMAL;
				showState();
			} else
			{
				scaleIn();
			}
		}

		public function set selectedComponent( vo:IPrototype ):void
		{
			_selectedComponent = vo;
			_image.filters = [];
			if (vo)
			{
				_bitmap.visible = false;
				var assetModel:AssetModel  = AssetModel.instance;
				var currentAssetVO:AssetVO = assetModel.getEntityData(vo.uiAsset);
				if (currentAssetVO)
					assetModel.getFromCache("assets/" + currentAssetVO.iconImage, loadImage);
				else
				{
					if (_image)
						_image.clearBitmap();

					_bitmap.visible = true;
				}


			} else
			{
				if (_image)
					_image.clearBitmap();

				_bitmap.visible = true;
			}
		}

		public function get selectedComponent():IPrototype
		{
			return _selectedComponent;
		}

		private function loadImage( asset:BitmapData ):void
		{
			if (_image)
			{
				_image.onImageLoaded(asset);

				var angleInRadians:Number       = Math.PI * 2 * (-90 / 360);

				var bitmapRotationMatrix:Matrix = new Matrix();
				bitmapRotationMatrix.identity();

				bitmapRotationMatrix.translate(-(_image.width * 0.5), -(_image.height * 0.5));
				bitmapRotationMatrix.rotate(angleInRadians);
				bitmapRotationMatrix.translate(_bitmap.x + (_bitmap.width - _image.width) * 0.5 + (_image.width * 0.5), _bitmap.y + (_bitmap.height - _image.height) * 0.5 + (_image.height * 0.5));
				_image.transform.matrix = bitmapRotationMatrix;
				if (_selectedComponent != null)
					getGlow(_selectedComponent.getValue('rarity'));
			}
		}

		private function getGlow( rarity:String ):void
		{
			var glow:GlowFilter = GlowFilter(CommonFunctionUtil.getRarityGlow(rarity).clone());

			if (glow.color != 0)
			{
				glow.inner = false;
				glow.strength = 4;
				glow.quality = BitmapFilterQuality.HIGH;
				_image.filters = [glow];
			}
		}

		public function get rarityColor():uint
		{
			var color:uint;
			if (_selectedComponent)
				color = CommonFunctionUtil.getRarityColor(_selectedComponent.getValue('rarity'));
			else
				color = 0xf0f0f0;
			return color;
		}

		public function tooltip():String
		{
			var tooltip:String = '';
			if (_selectedComponent)
				tooltip = StringUtil.getTooltip(_selectedComponent.getValue('type'), _selectedComponent);

			return tooltip;
		}

		public function get uiAsset():String
		{
			if (_selectedComponent)
				return _selectedComponent.uiAsset;
			else
				return '';
		}

		public function get slotType():String
		{
			if (_slotType.indexOf(SlotComponentEnum.SLOT_TYPE_TECH) != -1)
				return SlotComponentEnum.SLOT_TYPE_TECH;
			else if (_slotType.indexOf(SlotComponentEnum.SLOT_TYPE_DEFENSE) != -1)
				return SlotComponentEnum.SLOT_TYPE_DEFENSE;
			else if (_slotType.indexOf(SlotComponentEnum.SLOT_TYPE_SPECIAL) != -1)
				return SlotComponentEnum.SLOT_TYPE_SPECIAL;
			else if (_slotType.indexOf(SlotComponentEnum.SLOT_TYPE_DRONE) != -1)
				return SlotComponentEnum.SLOT_TYPE_SPECIAL;
			else if (_slotType.indexOf(SlotComponentEnum.SLOT_TYPE_ARC) != -1)
				return SlotComponentEnum.SLOT_TYPE_SPECIAL;
			else if (_slotType.indexOf(SlotComponentEnum.SLOT_TYPE_WEAPON) != -1)
				return SlotComponentEnum.SLOT_TYPE_WEAPON;
			else if (_slotType.indexOf(SlotComponentEnum.SLOT_TYPE_STRUCTURE) != -1)
				return SlotComponentEnum.SLOT_TYPE_STRUCTURE;

			return 'Borked';
		}

		public function get slotName():String
		{
			return _slotType;
		}

		override public function destroy():void
		{
			onSelectComponent.removeAll();
			onHover.removeAll();
		}
	}
}
