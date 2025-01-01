package com.ui.hud.shared.command
{
	import com.enum.CurrencyEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.adobe.utils.StringUtil;
	import org.osflash.signals.Signal;

	public class ResourceComponent extends Sprite implements IComponent
	{
		private var _enabled:Boolean = false;
		private var _moreSignal:Signal;

		private var _alloyCheck:Bitmap;
		private var _creditsCheck:Bitmap;
		private var _energyCheck:Bitmap;
		private var _syntheticsCheck:Bitmap;

		private var _alloyIcon:Bitmap;
		private var _creditsIcon:Bitmap;
		private var _energyIcon:Bitmap;
		private var _syntheticsIcon:Bitmap;

		private var _alloyHolder:Sprite;
		private var _creditsHolder:Sprite;
		private var _energyHolder:Sprite;
		private var _syntheticsHolder:Sprite;

		private var _alloyBar:ProgressBar;
		private var _creditsBar:ProgressBar;
		private var _energyBar:ProgressBar;
		private var _syntheticsBar:ProgressBar;

		private var _alloyLabel:Label;
		private var _creditsLabel:Label;
		private var _energyLabel:Label;
		private var _syntheticsLabel:Label;

		private var _alloyMore:BitmapButton;
		private var _creditsMore:BitmapButton;
		private var _energyMore:BitmapButton;
		private var _syntheticsMore:BitmapButton;

		public function init( showPluses:Boolean, showInnerBar:Boolean, verticalSpacing:int = 48 ):void
		{
			_moreSignal = new Signal(String);

			_alloyHolder = new Sprite();
			_alloyHolder.y = verticalSpacing;
			_creditsHolder = new Sprite();
			_creditsHolder.x = 5;
			_energyHolder = new Sprite();
			_energyHolder.x = 162;
			_syntheticsHolder = new Sprite();
			_syntheticsHolder.x = 158;
			_syntheticsHolder.y = verticalSpacing;

			_alloyIcon = UIFactory.getPanel("IconAlloyBMD", 0, 0);
			_alloyIcon.smoothing = true;
			_creditsIcon = UIFactory.getPanel("IconCreditBMD", 0, 0);
			_creditsIcon.smoothing = true;
			_energyIcon = UIFactory.getPanel("IconEnergyBMD", 0, 0);
			_energyIcon.smoothing = true;
			_syntheticsIcon = UIFactory.getPanel("IconSynthBMD", 0, 0);
			_syntheticsIcon.smoothing = true;

			_alloyBar = UIFactory.getProgressBar(showInnerBar ? UIFactory.getPanel(PanelEnum.STATBAR, 94, 18) : null, UIFactory.getBitmap("ResourceBoxBMD"), 0, 1, 1,
												 _alloyIcon.x + _alloyIcon.width + 2, _alloyIcon.y + 3);
			_creditsBar = UIFactory.getProgressBar(showInnerBar ? UIFactory.getPanel(PanelEnum.STATBAR, 94, 18) : null, UIFactory.getBitmap("ResourceBoxBMD"), 0, 1, 1,
												   _creditsIcon.x + _creditsIcon.width + 2, _creditsIcon.y + 3);
			_energyBar = UIFactory.getProgressBar(showInnerBar ? UIFactory.getPanel(PanelEnum.STATBAR, 94, 18) : null, UIFactory.getBitmap("ResourceBoxBMD"), 0, 1, 1,
												  _energyIcon.x + _energyIcon.width + 2, _energyIcon.y + 3);
			_syntheticsBar = UIFactory.getProgressBar(showInnerBar ? UIFactory.getPanel(PanelEnum.STATBAR, 94, 18) : null, UIFactory.getBitmap("ResourceBoxBMD"), 0, 1, 1,
													  _syntheticsIcon.x + _syntheticsIcon.width + 2, _syntheticsIcon.y + 3);

			_alloyLabel = UIFactory.getLabel(LabelEnum.DEFAULT_OPEN_SANS, 101, 24, _alloyBar.x, _alloyBar.y);
			_creditsLabel = UIFactory.getLabel(LabelEnum.DEFAULT_OPEN_SANS, 101, 24, _creditsBar.x, _creditsBar.y);
			_energyLabel = UIFactory.getLabel(LabelEnum.DEFAULT_OPEN_SANS, 101, 24, _energyBar.x, _energyBar.y);
			_syntheticsLabel = UIFactory.getLabel(LabelEnum.DEFAULT_OPEN_SANS, 101, 24, _syntheticsBar.x, _syntheticsBar.y);

			_alloyHolder.addChild(_alloyIcon);
			_creditsHolder.addChild(_creditsIcon);
			_energyHolder.addChild(_energyIcon);
			_syntheticsHolder.addChild(_syntheticsIcon);

			_alloyHolder.addChild(_alloyBar);
			_creditsHolder.addChild(_creditsBar);
			_energyHolder.addChild(_energyBar);
			_syntheticsHolder.addChild(_syntheticsBar);

			_alloyHolder.addChild(_alloyLabel);
			_creditsHolder.addChild(_creditsLabel);
			_energyHolder.addChild(_energyLabel);
			_syntheticsHolder.addChild(_syntheticsLabel);

			if (showPluses)
			{
				_alloyMore = UIFactory.getButton(ButtonEnum.PLUS, 0, 0, _alloyBar.x + _alloyBar.width + 4, _alloyBar.y + 2);
				_creditsMore = UIFactory.getButton(ButtonEnum.PLUS, 0, 0, _creditsBar.x + _creditsBar.width + 4, _creditsBar.y + 2);
				_energyMore = UIFactory.getButton(ButtonEnum.PLUS, 0, 0, _energyBar.x + _energyBar.width + 4, _energyBar.y + 2);
				_syntheticsMore = UIFactory.getButton(ButtonEnum.PLUS, 0, 0, _syntheticsBar.x + _syntheticsBar.width + 4, _syntheticsBar.y + 2);

				_alloyMore.addEventListener(MouseEvent.CLICK, onMoreClick, false, 0, true);
				_creditsMore.addEventListener(MouseEvent.CLICK, onMoreClick, false, 0, true);
				_energyMore.addEventListener(MouseEvent.CLICK, onMoreClick, false, 0, true);
				_syntheticsMore.addEventListener(MouseEvent.CLICK, onMoreClick, false, 0, true);

				_alloyHolder.addChild(_alloyMore);
				_creditsHolder.addChild(_creditsMore);
				_energyHolder.addChild(_energyMore);
				_syntheticsHolder.addChild(_syntheticsMore);

				_alloyMore.hitArea = _alloyHolder;
				_creditsMore.hitArea = _creditsHolder;
				_energyMore.hitArea = _energyHolder;
				_syntheticsMore.hitArea = _syntheticsHolder;

				_alloyCheck = UIFactory.getPanel('CheckMarkBMD', 0, 0, _alloyMore.x - 3, _alloyMore.height - 12);
				_alloyCheck.visible = false;
				_creditsCheck = UIFactory.getPanel('CheckMarkBMD', 0, 0, _creditsMore.x - 3, _creditsMore.height - 12);
				_creditsCheck.visible = false;
				_energyCheck = UIFactory.getPanel('CheckMarkBMD', 0, 0, _energyMore.x - 3, _energyMore.height - 12);
				_energyCheck.visible = false;
				_syntheticsCheck = UIFactory.getPanel('CheckMarkBMD', 0, 0, _syntheticsMore.x - 3, _syntheticsMore.height - 12);
				_syntheticsCheck.visible = false;

				_alloyHolder.addChild(_alloyCheck);
				_creditsHolder.addChild(_creditsCheck);
				_energyHolder.addChild(_energyCheck);
				_syntheticsHolder.addChild(_syntheticsCheck);
			} else
			{
				_energyHolder.x -= 15;
				_syntheticsHolder.x -= 15;
			}

			addChild(_alloyHolder);
			addChild(_creditsHolder);
			addChild(_energyHolder);
			addChild(_syntheticsHolder);
		}

		public function updateResource( amount:int, max:int, type:String ):void
		{
			switch (type)
			{
				case CurrencyEnum.ALLOY:
					_alloyLabel.text = StringUtil.commaFormatNumber(amount);
					_alloyBar.amount = amount / max;
					break;
				case CurrencyEnum.CREDIT:
					_creditsLabel.text = StringUtil.commaFormatNumber(amount);
					_creditsBar.amount = amount / max;
					break;
				case CurrencyEnum.ENERGY:
					_energyLabel.text = StringUtil.commaFormatNumber(amount);
					_energyBar.amount = amount / max;
					break;
				case CurrencyEnum.SYNTHETIC:
					_syntheticsLabel.text = StringUtil.commaFormatNumber(amount);
					_syntheticsBar.amount = amount / max;
					break;
			}
		}

		public function updateCost( amount:int, canAfford:Boolean, type:String ):void
		{
			switch (type)
			{
				case CurrencyEnum.ALLOY:
					_alloyLabel.text = StringUtil.commaFormatNumber(amount);
					_alloyLabel.textColor = (canAfford) ? 0x48b53c : 0xea1118;
					if (_alloyMore)
					{
						_alloyCheck.visible = (canAfford) ? true : false;
						_alloyMore.visible = (canAfford) ? false : true;
					}
					break;
				case CurrencyEnum.CREDIT:
					_creditsLabel.text = StringUtil.commaFormatNumber(amount);
					_creditsLabel.textColor = (canAfford) ? 0x48b53c : 0xea1118;
					if (_creditsMore)
					{
						_creditsCheck.visible = (canAfford) ? true : false;
						_creditsMore.visible = (canAfford) ? false : true;
					}
					break;
				case CurrencyEnum.ENERGY:
					_energyLabel.text = StringUtil.commaFormatNumber(amount);
					_energyLabel.textColor = (canAfford) ? 0x48b53c : 0xea1118;
					if (_energyMore)
					{
						_energyCheck.visible = (canAfford) ? true : false;
						_energyMore.visible = (canAfford) ? false : true;
					}
					break;
				case CurrencyEnum.SYNTHETIC:
					_syntheticsLabel.text = StringUtil.commaFormatNumber(amount);
					_syntheticsLabel.textColor = (canAfford) ? 0x48b53c : 0xea1118;
					if (_syntheticsMore)
					{
						_syntheticsCheck.visible = (canAfford) ? true : false;
						_syntheticsMore.visible = (canAfford) ? false : true;
					}
					break;
			}
		}

		public function addMoreListener( listener:Function ):void  { _moreSignal.add(listener); }
		public function removeMoreListener( listener:Function ):void  { _moreSignal.remove(listener); }

		private function onMoreClick( e:MouseEvent ):void
		{
			if (!BitmapButton(e.currentTarget).visible)
				return;
			switch (e.currentTarget)
			{
				case _alloyMore:
					_moreSignal.dispatch(CurrencyEnum.ALLOY);
					break;
				case _creditsMore:
					_moreSignal.dispatch(CurrencyEnum.CREDIT);
					break;
				case _energyMore:
					_moreSignal.dispatch(CurrencyEnum.ENERGY);
					break;
				case _syntheticsMore:
					_moreSignal.dispatch(CurrencyEnum.SYNTHETIC);
					break;
			}
		}

		public function get alloyHolder():Sprite  { return _alloyHolder; }
		public function get creditsHolder():Sprite  { return _creditsHolder; }
		public function get energyHolder():Sprite  { return _energyHolder; }
		public function get syntheticHolder():Sprite  { return _syntheticsHolder; }

		public function get enabled():Boolean  { return false; }
		public function set enabled( value:Boolean ):void  { _enabled = value; }

		public function set hideBars( v:Boolean ):void
		{
			_alloyBar.visible = v;
			_creditsBar.visible = v;
			_energyBar.visible = v;
			_syntheticsBar.visible = v;
		}

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);
			while (_alloyHolder.numChildren > 0)
				_alloyHolder.removeChildAt(0);
			_alloyHolder = null;
			while (_creditsHolder.numChildren > 0)
				_creditsHolder.removeChildAt(0);
			_creditsHolder = null;
			while (_energyHolder.numChildren > 0)
				_energyHolder.removeChildAt(0);
			_energyHolder = null;
			while (_syntheticsHolder.numChildren > 0)
				_syntheticsHolder.removeChildAt(0);
			_syntheticsHolder = null;

			_moreSignal.removeAll();
			_moreSignal = null;

			_alloyIcon = UIFactory.destroyPanel(_alloyIcon);
			_creditsIcon = UIFactory.destroyPanel(_creditsIcon);
			_energyIcon = UIFactory.destroyPanel(_energyIcon);
			_syntheticsIcon = UIFactory.destroyPanel(_syntheticsIcon);

			_alloyBar = UIFactory.destroyProgressBar(_alloyBar);
			_creditsBar = UIFactory.destroyProgressBar(_creditsBar);
			_energyBar = UIFactory.destroyProgressBar(_energyBar);
			_syntheticsBar = UIFactory.destroyProgressBar(_syntheticsBar);

			_alloyLabel = UIFactory.destroyLabel(_alloyLabel);
			_creditsLabel = UIFactory.destroyLabel(_creditsLabel);
			_energyLabel = UIFactory.destroyLabel(_energyLabel);
			_syntheticsLabel = UIFactory.destroyLabel(_syntheticsLabel);

			if (_alloyMore)
			{
				_alloyMore.removeEventListener(MouseEvent.CLICK, onMoreClick);
				_alloyMore = UIFactory.destroyButton(_alloyMore);
				_creditsMore.removeEventListener(MouseEvent.CLICK, onMoreClick);
				_creditsMore = UIFactory.destroyButton(_creditsMore);
				_energyMore.removeEventListener(MouseEvent.CLICK, onMoreClick);
				_energyMore = UIFactory.destroyButton(_energyMore);
				_syntheticsMore.removeEventListener(MouseEvent.CLICK, onMoreClick);
				_syntheticsMore = UIFactory.destroyButton(_syntheticsMore);
			}

			_alloyCheck = UIFactory.destroyPanel(_alloyCheck);
			_creditsCheck = UIFactory.destroyPanel(_creditsCheck);
			_energyCheck = UIFactory.destroyPanel(_energyCheck);
			_syntheticsCheck = UIFactory.destroyPanel(_syntheticsCheck);

			visible = true;
		}
	}
}
