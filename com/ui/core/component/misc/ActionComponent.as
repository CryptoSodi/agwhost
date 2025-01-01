package com.ui.core.component.misc
{
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.ui.ButtonEnum;
	import com.ui.UIFactory;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	public class ActionComponent extends Sprite implements IComponent
	{
		private var _actionBtn:BitmapButton;
		private var _instantActionBtn:BitmapButton;

		private var _cannotAffordActionBtn:BitmapButton;
		private var _cannotAffordInstantActionBtn:BitmapButton;

		private var _cannotAffordActionBtnProto:ButtonPrototype;
		private var _cannotAffordInstantActionBtnProto:ButtonPrototype;

		private var _actionBtnProto:ButtonPrototype;
		private var _instantActionBtnProto:ButtonPrototype;

		private var _actionTimeBox:Bitmap;
		private var _instantActionCostBox:Bitmap;
		private var _cannotAffordActionTimeBox:Bitmap;

		private var _instantCost:Label;
		private var _timeCost:Label;

		private var _premiumSymbol:Bitmap;

		private var _getMoreResourcesPremiumSymbol:Bitmap;

		private var _enabled:Boolean;

		private var _requirements:RequirementVO;

		private var _enabledFontSize:int;
		private var _disabledFontSize:int;
		private var _enabledLabelYPos:int;

		private var _freeText:String      = 'CodeString.Shared.Free'; //Free
		private var _offlineString:String = 'CodeString.Shipyard.BtnStatus.Offline'; //OFFLINE

		public function ActionComponent( actionButton:ButtonPrototype, instantActionButton:ButtonPrototype, cannotAffordActionBtnProto:ButtonPrototype, cannotAffordInstantActionButton:ButtonPrototype,
										 instantActionCost:int = 0, ActionTimeCost:int = 0 )
		{
			super();

			_enabledFontSize = 20;
			_disabledFontSize = 24;

			var premiumSymbolClass:Class = Class(getDefinitionByName(('KalganSymbolBMD')));

			_actionBtnProto = actionButton;
			_instantActionBtnProto = instantActionButton;

			_cannotAffordActionBtnProto = cannotAffordActionBtnProto;
			_cannotAffordInstantActionBtnProto = cannotAffordInstantActionButton;

			_instantActionBtn = UIFactory.getButton(ButtonEnum.GOLD_A, 126, 55, 134, 0, instantActionButton.text);
			_instantActionBtn.addEventListener(MouseEvent.CLICK, instantActionButton.callback, false, 0, true);
			_instantActionBtn.fontSize = _enabledFontSize;
			_instantActionBtn.label.y -= 4;

			_actionBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 126, 55, 0, 0, actionButton.text);
			_actionBtn.addEventListener(MouseEvent.CLICK, actionButton.callback, false, 0, true);
			_actionBtn.fontSize = _enabledFontSize;
			_actionBtn.label.y -= 4;

			_cannotAffordInstantActionBtn = UIFactory.getButton(ButtonEnum.GOLD_A, 126, 55, 134, 0, cannotAffordInstantActionButton.text);
			_cannotAffordInstantActionBtn.addEventListener(MouseEvent.CLICK, cannotAffordInstantActionButton.callback, false, 0, true);
			_cannotAffordInstantActionBtn.fontSize = _enabledFontSize;
			_cannotAffordInstantActionBtn.label.y -= 4;
			_cannotAffordInstantActionBtn.visible = false;

			_cannotAffordActionBtn = UIFactory.getButton(ButtonEnum.GOLD_A, 126, 55, 0, 0, cannotAffordActionBtnProto.text)
			_cannotAffordActionBtn.addEventListener(MouseEvent.CLICK, cannotAffordActionBtnProto.callback, false, 0, true);
			_cannotAffordActionBtn.fontSize = _enabledFontSize;
			_cannotAffordActionBtn.label.y -= 4;
			_cannotAffordActionBtn.visible = false;

			_enabledLabelYPos = _actionBtn.label.y;

			_premiumSymbol = new Bitmap(BitmapData(new premiumSymbolClass()));
			_premiumSymbol.x = 140;
			_premiumSymbol.y = 28;

			_timeCost = new Label(18, 0xf0f0f0, 119, 21, false);
			_timeCost.align = TextFormatAlign.CENTER;
			_timeCost.constrictTextToSize = false;
			_timeCost.x = 4;
			_timeCost.y = 28;
			_timeCost.text = String(instantActionCost);

			_instantCost = new Label(18, 0xf0f0f0, 119, 25, false);
			_instantCost.align = TextFormatAlign.CENTER;
			_instantCost.constrictTextToSize = false;
			_instantCost.x = 135;
			_instantCost.y = 28;
			_instantCost.setBuildTime(ActionTimeCost);

			_actionTimeBox = UIFactory.getScaleBitmap('InputBoxBMD');
			_actionTimeBox.width = 119;
			_actionTimeBox.height = 22;
			_actionTimeBox.x = 4;
			_actionTimeBox.y = 28;

			_instantActionCostBox = UIFactory.getScaleBitmap('InputBoxGoldBMD');
			_instantActionCostBox.width = 119;
			_instantActionCostBox.height = 22;
			_instantActionCostBox.x = 135;
			_instantActionCostBox.y = 28;

			_cannotAffordActionTimeBox = UIFactory.getScaleBitmap('InputBoxGoldBMD');
			_cannotAffordActionTimeBox.width = 119;
			_cannotAffordActionTimeBox.height = 22;
			_cannotAffordActionTimeBox.x = 4;
			_cannotAffordActionTimeBox.y = 28;
			_cannotAffordActionTimeBox.visible = false;

			addChild(_instantActionBtn);
			addChild(_actionBtn);

			addChild(_cannotAffordInstantActionBtn);
			addChild(_cannotAffordActionBtn);

			addChild(_actionTimeBox);
			addChild(_instantActionCostBox);
			addChild(_cannotAffordActionTimeBox);

			addChild(_timeCost);
			addChild(_instantCost);

			addChild(_premiumSymbol);

			_enabled = true;
		}

		public function set actionBtnText( text:String ):void
		{
			_actionBtn.text = text;

			if (!enabled)
				_actionBtn.label.y += 6;
		}

		public function set instantActionBtnText( text:String ):void
		{
			_instantActionBtn.text = text;

			if (!enabled)
				_instantActionBtn.label.y += 6;
		}

		public function set instantCost( instantActionCost:int ):void
		{
			if (instantActionCost > 0)
			{
				_instantCost.useLocalization = false;
				_instantCost.text = String(instantActionCost);
			} else
			{
				_instantCost.useLocalization = true;
				_instantCost.text = _freeText;
			}

		}

		public function set timeCost( actionTimeCost:int ):void
		{
			_timeCost.setBuildTime(actionTimeCost);
		}

		public function set requirements( reqs:RequirementVO ):void
		{
			_requirements = reqs;

			if (_enabled)
				updateBasedOnRequirements();
		}

		private function updateBasedOnRequirements():void
		{
			if (_requirements)
			{
				if (!_requirements.purchaseVO.costExceedsMaxResources)
				{
					_instantActionBtn.visible = _requirements.purchaseVO.canPurchaseWithPremium;
					_cannotAffordInstantActionBtn.visible = !_requirements.purchaseVO.canPurchaseWithPremium;

					_actionBtn.visible = _requirements.purchaseVO.canPurchase;
					_cannotAffordActionBtn.visible = !_requirements.purchaseVO.canPurchase;
					_cannotAffordActionTimeBox.visible = !_requirements.purchaseVO.canPurchase;
				}

			}
		}

		public function set enabled( value:Boolean ):void
		{
			_enabled = value;

			instantActionBtnEnabled = _enabled;
			actionBtnEnabled = _enabled;

			cannotAffordInstantActionBtnEnabled = _enabled;
			cannotAffordActionBtnEnabled = _enabled;

			if (_enabled)
				updateBasedOnRequirements();
		}

		public function get enabled():Boolean  { return _enabled; }

		public function set instantActionBtnEnabled( enabled:Boolean ):void
		{
			_instantActionBtn.enabled = enabled;
			_premiumSymbol.visible = enabled;
			_instantCost.visible = enabled;
			_instantActionCostBox.visible = enabled;
			if (!enabled)
			{
				_instantActionBtn.fontSize = _disabledFontSize;
				_instantActionBtn.text = _offlineString;
				_instantActionBtn.label.y += 6;
			} else
			{
				_instantActionBtn.fontSize = _enabledFontSize;
				_instantActionBtn.text = _instantActionBtnProto.text;
				_instantActionBtn.label.y = _enabledLabelYPos;
			}
		}

		public function set actionBtnEnabled( enabled:Boolean ):void
		{
			_actionBtn.enabled = enabled;
			_timeCost.visible = enabled;
			_actionTimeBox.visible = enabled;
			if (!enabled)
			{
				_actionBtn.fontSize = _disabledFontSize;
				_actionBtn.text = _offlineString;
				_actionBtn.label.y += 6;
			} else
			{
				_actionBtn.fontSize = _enabledFontSize;
				_actionBtn.text = _actionBtnProto.text;
				_actionBtn.label.y = _enabledLabelYPos;

			}
		}

		public function set cannotAffordInstantActionBtnEnabled( enabled:Boolean ):void
		{
			_cannotAffordInstantActionBtn.enabled = enabled;
			_cannotAffordActionTimeBox.visible = enabled;
			if (!enabled)
			{
				_cannotAffordInstantActionBtn.fontSize = _disabledFontSize;
				_cannotAffordInstantActionBtn.text = _offlineString;
				_cannotAffordInstantActionBtn.label.y += 6;
			} else
			{
				_cannotAffordInstantActionBtn.fontSize = _enabledFontSize;
				_cannotAffordInstantActionBtn.text = _cannotAffordInstantActionBtnProto.text;
				_cannotAffordInstantActionBtn.label.y = _enabledLabelYPos;
			}
		}

		public function set cannotAffordActionBtnEnabled( enabled:Boolean ):void
		{
			_cannotAffordActionBtn.enabled = enabled;
			_instantActionCostBox.visible = enabled;
			if (!enabled)
			{
				_cannotAffordActionBtn.fontSize = _disabledFontSize;
				_cannotAffordActionBtn.text = _offlineString;
				_cannotAffordActionBtn.label.y += 6;
			} else
			{
				_cannotAffordActionBtn.fontSize = _enabledFontSize;
				_cannotAffordActionBtn.text = _cannotAffordActionBtnProto.text;
				_cannotAffordActionBtn.label.y = _enabledLabelYPos;
			}
		}

		public function get actionBtn():BitmapButton  { return _actionBtn; }
		public function get instantActionBtn():BitmapButton  { return _instantActionBtn; }

		public function destroy():void
		{
			_instantActionBtn.removeEventListener(MouseEvent.CLICK, _instantActionBtnProto.callback);
			_instantActionBtn.destroy();
			_instantActionBtn = null;
			_instantActionBtnProto = null;

			_actionBtn.removeEventListener(MouseEvent.CLICK, _actionBtnProto.callback);
			_actionBtn.destroy();
			_actionBtn = null;
			_actionBtnProto = null;

			_timeCost.destroy();
			_timeCost = null;

			_instantCost.destroy();
			_instantCost = null;

			_premiumSymbol = null;
		}
	}
}
