package com.ui.modal.information
{
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.adobe.utils.StringUtil;

	public class ResourceModalView extends View
	{
		private var _bg:Sprite;
		private var _actionBtn:BitmapButton;
		private var _cancelBtn:BitmapButton;
		private var _closeBtn:BitmapButton;

		private var _alloySymbol:Bitmap;
		private var _creditsSymbol:Bitmap;
		private var _energySymbol:Bitmap;
		private var _syntheticsSymbol:Bitmap;
		private var _premiumSymbol:Bitmap;

		private var _actionCostLbl:Label;
		private var _windowTitle:Label;
		private var _windowSubTitle:Label;
		private var _alloyLbl:Label;
		private var _creditsLbl:Label;
		private var _energyLbl:Label;
		private var _syntheticsLbl:Label;

		private var _actionBtnText:String;

		private var _actionCallback:Function;

		[PostConstruct]
		override public function init():void
		{
			super.init();
		}

		public function setUp( creditAmount:int, alloyAmount:int, energyAmount:int, syntheticAmount:int, windowTitle:String, windowSubtitle:String, isGainingResources:Boolean, actionCallback:Function,
							   actionCost:Number = 0, actionBtnTxt:String = 'CodeString.BuildRecycle.Title.Recycle' ):void
		{
			_actionCallback = actionCallback;
			_actionBtnText = actionBtnTxt;

			var mcBGClass:Class = Class(getDefinitionByName('ResourceModalWindowMC'));
			_bg = Sprite(new mcBGClass());
			addChild(_bg);

			_windowTitle = new Label(22, 0xFFFFFF, 383, 29, true);
			_windowTitle.x = 18;
			_windowTitle.y = 11.5;
			_windowTitle.constrictTextToSize = false;
			_windowTitle.align = TextFormatAlign.LEFT;
			_windowTitle.text = windowTitle;
			_windowTitle.letterSpacing = 1.5;
			addChild(_windowTitle);

			_windowSubTitle = new Label(22, 0xfbefaf, 360, 25, true);
			_windowSubTitle.x = 27;
			_windowSubTitle.y = 50;
			_windowSubTitle.constrictTextToSize = false;
			_windowSubTitle.align = TextFormatAlign.CENTER;
			_windowSubTitle.text = windowSubtitle;
			_windowSubTitle.letterSpacing = 1.5;
			addChild(_windowSubTitle);

			_creditsSymbol = PanelFactory.getPanel('LootedResourceCreditsBMD');
			_creditsSymbol.x = 33;
			_creditsSymbol.y = 87;
			addChild(_creditsSymbol);

			_alloySymbol = PanelFactory.getPanel('LootedResourceAlloyBMD');
			_alloySymbol.x = _creditsSymbol.x + 179;
			_alloySymbol.y = _creditsSymbol.y;
			addChild(_alloySymbol);

			_energySymbol = PanelFactory.getPanel('LootedResourceEnergyBMD');
			_energySymbol.x = _creditsSymbol.x;
			_energySymbol.y = _creditsSymbol.y + 50;
			addChild(_energySymbol);

			_syntheticsSymbol = PanelFactory.getPanel('LootedResourceSyntheticsBMD');
			_syntheticsSymbol.x = _alloySymbol.x;
			_syntheticsSymbol.y = _energySymbol.y;
			addChild(_syntheticsSymbol);

			var textColor:uint;
			var resourceLbl:String;
			if (!isGainingResources && creditAmount > 0)
			{
				textColor = 0xf04c4c;
				resourceLbl = '-' + StringUtil.commaFormatNumber(creditAmount);
			} else
			{
				textColor = 0x7afe60;
				resourceLbl = StringUtil.commaFormatNumber(creditAmount);
			}
			_creditsLbl = new Label(16, textColor, 100, 30, true, 1);
			_creditsLbl.x = _creditsSymbol.width * 0.5 + _creditsSymbol.x - 37;
			_creditsLbl.y = _creditsSymbol.height * 0.5 + _creditsSymbol.y - 6;
			_creditsLbl.constrictTextToSize = false;
			_creditsLbl.align = TextFormatAlign.LEFT;
			_creditsLbl.autoSize = TextFieldAutoSize.LEFT;
			_creditsLbl.text = resourceLbl;
			_creditsLbl.letterSpacing = 1.5;
			addChild(_creditsLbl);

			if (!isGainingResources && alloyAmount > 0)
			{
				textColor = 0xf04c4c;
				resourceLbl = '-' + StringUtil.commaFormatNumber(alloyAmount);
			} else
			{
				textColor = 0x7afe60;
				resourceLbl = StringUtil.commaFormatNumber(alloyAmount);
			}
			_alloyLbl = new Label(16, textColor, 100, 30, true, 1);
			_alloyLbl.x = _alloySymbol.width * 0.5 + _alloySymbol.x - 37;
			_alloyLbl.y = _alloySymbol.height * 0.5 + _alloySymbol.y - 6;
			_alloyLbl.constrictTextToSize = false;
			_alloyLbl.align = TextFormatAlign.LEFT;
			_alloyLbl.autoSize = TextFieldAutoSize.LEFT;
			_alloyLbl.text = resourceLbl;
			_alloyLbl.letterSpacing = 1.5;
			addChild(_alloyLbl);

			if (!isGainingResources && syntheticAmount > 0)
			{
				textColor = 0xf04c4c;
				resourceLbl = '-' + StringUtil.commaFormatNumber(syntheticAmount);
			} else
			{
				textColor = 0x7afe60;
				resourceLbl = StringUtil.commaFormatNumber(syntheticAmount);
			}
			_syntheticsLbl = new Label(16, textColor, 100, 30, true, 1);
			_syntheticsLbl.x = _syntheticsSymbol.width * 0.5 + _syntheticsSymbol.x - 37;
			_syntheticsLbl.y = _syntheticsSymbol.height * 0.5 + _syntheticsSymbol.y - 6;
			_syntheticsLbl.constrictTextToSize = false;
			_syntheticsLbl.align = TextFormatAlign.LEFT;
			_syntheticsLbl.autoSize = TextFieldAutoSize.LEFT;
			_syntheticsLbl.text = resourceLbl;
			_syntheticsLbl.letterSpacing = 1.5;
			addChild(_syntheticsLbl);

			if (!isGainingResources && energyAmount > 0)
			{
				textColor = 0xf04c4c;
				resourceLbl = '-' + StringUtil.commaFormatNumber(energyAmount);
			} else
			{
				textColor = 0x7afe60;
				resourceLbl = StringUtil.commaFormatNumber(energyAmount);
			}
			_energyLbl = new Label(16, textColor, 100, 30, true, 1);
			_energyLbl.x = _energySymbol.width * 0.5 + _energySymbol.x - 37;
			_energyLbl.y = _energySymbol.height * 0.5 + _energySymbol.y - 6;
			_energyLbl.constrictTextToSize = false;
			_energyLbl.align = TextFormatAlign.LEFT;
			_energyLbl.autoSize = TextFieldAutoSize.LEFT;
			_energyLbl.text = resourceLbl;
			_energyLbl.letterSpacing = 1.5;
			addChild(_energyLbl);

			_cancelBtn = ButtonFactory.getBitmapButton('RedBtnNeutralBMD', 61, 200, 'CodeString.Shared.CancelBtn', 0xF58993, 'RedBtnRolloverBMD', 'RedBtnSelectedBMD');
			_cancelBtn.fontSize = 26;
			_cancelBtn.label.y += 5;
			_cancelBtn.addEventListener(MouseEvent.CLICK, onCancelBtnClicked);
			addChild(_cancelBtn);

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 36, 11);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);
			addChild(_closeBtn);

			addActionButton(isGainingResources, actionCost);

			addEffects();
			effectsIN();
		}

		private function addActionButton( isGainingResources:Boolean, actionCost:Number = 0 ):void
		{
			if (isGainingResources)
			{
				_actionBtn = ButtonFactory.getBitmapButton('BlueBtnNeutralBMD', 206, 200, _actionBtnText, 0xc9e6f6, 'BlueBtnRolloverBMD', 'BlueBtnSelectedBMD');
				_actionBtn.fontSize = 26;
				_actionBtn.label.y += 5;
					//_actionBtn.label.constrictTextToSize = false;
			} else
			{
				var premiumSymbolClass:Class = Class(getDefinitionByName(('KalganSymbolBMD')));
				_premiumSymbol = new Bitmap(BitmapData(new premiumSymbolClass()));
				_premiumSymbol.x = 240;
				_premiumSymbol.y = 229;

				_actionCostLbl = new Label(18, 0xf0f0f0, 50, 25, false);
				_actionCostLbl.align = TextFormatAlign.LEFT;
				_actionCostLbl.autoSize = TextFieldAutoSize.LEFT;
				_actionCostLbl.constrictTextToSize = false;
				_actionCostLbl.x = 279;
				_actionCostLbl.y = 229;

				if (actionCost > 0)
				{
					_actionCostLbl.useLocalization = false;
					_actionCostLbl.text = String(actionCost);
				} else
				{
					_actionCostLbl.useLocalization = true;
					_actionCostLbl.text = 'CodeString.Shared.Free';
				}

				_actionBtn = ButtonFactory.getBitmapButton('btnBuyNeutralBMD', 206, 200, 'CodeString.Shared.GetResources', 0xf7c78b, 'btnBuyRolloverBMD', 'btnBuyNeutralBMD');
				_actionBtn.fontSize = 20;
				_actionBtn.label.constrictTextToSize = false;
				_actionBtn.label.x += 5;
				_actionBtn.label.y -= 4;
			}

			addListener(_actionBtn, MouseEvent.CLICK, onActionBtnClicked);
			addChild(_actionBtn);

			if (_actionCostLbl)
			{
				addChild(_actionCostLbl);
				addChild(_premiumSymbol);
			}
		}

		private function onActionBtnClicked( e:MouseEvent ):void
		{
			//Use the callback here so this window is destroyed properly
			if (_actionCallback != null)
				_actionCallback();

			destroy();
		}

		private function onCancelBtnClicked( e:MouseEvent ):void
		{
			destroy();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function destroy():void
		{
			super.destroy();
			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;

			_actionBtn.destroy();
			_actionBtn = null;
			_cancelBtn.destroy();
			_cancelBtn = null;

			_alloySymbol = null;
			_creditsSymbol = null;
			_energySymbol = null;
			_syntheticsSymbol = null;

			if (_actionCostLbl)
			{
				_actionCostLbl.destroy();
				_actionCostLbl = null;
			}

			_windowTitle.destroy();
			_windowTitle = null;

			_windowSubTitle.destroy();
			_windowSubTitle = null;

			_alloyLbl.destroy();
			_alloyLbl = null;

			_creditsLbl.destroy();
			_creditsLbl = null;

			_energyLbl.destroy();
			_energyLbl = null;

			_syntheticsLbl.destroy();
			_syntheticsLbl = null;
		}
	}
}
