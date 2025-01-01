package com.ui.modal.dock
{
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;

	import org.greensock.TweenLite;
	import org.osflash.signals.Signal;

	public class ShipButton extends ShipIcon
	{
		private var _isRepairing:Boolean;

		private var _flagshipSymbol:Bitmap;
		private var _repairingSymbol:Bitmap;
		private var _repairingSymbolBG:Bitmap;

		private var _repairBGHolder:Sprite;

		public var onSelectShip:Signal;

		private var TOP_LEFT_X_OFFSET:int = 32;

		public function ShipButton()
		{
			super();
			onSelectShip = new Signal(ShipButton, Boolean);

			_repairingSymbolBG = UIFactory.getBitmap('IconDockRepairCircleBMD');
			_repairingSymbolBG.x = -_repairingSymbolBG.width * 0.5;
			_repairingSymbolBG.y = -_repairingSymbolBG.height * 0.5;
			_repairingSymbolBG.smoothing = true;

			_repairBGHolder = new Sprite();
			_repairBGHolder.addChild(_repairingSymbolBG);
			_repairBGHolder.visible = false;
			_repairBGHolder.x = _bitmap.x + TOP_LEFT_X_OFFSET + (_repairBGHolder.width * 0.25)

			_repairingSymbol = UIFactory.getBitmap('IconDockRepairWrenchBMD');
			_repairingSymbol.visible = false;
			_repairingSymbol.x = _repairBGHolder.x - _repairingSymbol.width * 0.5;
			_repairingSymbol.y = _repairBGHolder.y - _repairingSymbol.height * 0.5;

			_flagshipSymbol = UIFactory.getBitmap('DockShipBtnFlagshipBMD');
			_flagshipSymbol.visible = false;
			_flagshipSymbol.x = _bitmap.x + _bitmap.width * 0.75 - (TOP_LEFT_X_OFFSET + 22);
			_flagshipSymbol.y = _bitmap.y - 13;

			addChild(_flagshipSymbol);
			addChild(_repairBGHolder);
			addChild(_repairingSymbol);
		}

		override protected function onMouse( e:MouseEvent ):void
		{
			super.onMouse(e);
			if (mouseEnabled)
			{
				switch (e.type)
				{
					case MouseEvent.CLICK:
						if (!_fleet || _fleet.sector != '' || _isRepairing)
							return;

						onSelectShip.dispatch(this, true);
						break;
				}

			}
		}

		public function getTooltip():String
		{
			var tooltip:String = '';
			if (_ship)
				tooltip = _ship.tooltip;

			return tooltip;
		}

		override protected function _setShip( ship:ShipVO, fleet:FleetVO ):void
		{
			super._setShip(ship, fleet);
			_repairingSymbol.visible = _repairBGHolder.visible = _isRepairing = false;
			TweenLite.killTweensOf(_repairBGHolder);
		}

		public function showRepair( show:Boolean ):void
		{

			_isRepairing = show;

			if (enabled)
			{
				if (_ship != null && _ship.currentHealth != 1)
				{
					_repairingSymbol.visible = _isRepairing;
					_repairBGHolder.visible = _isRepairing;

					if (show)
						TweenLite.to(_repairBGHolder, 3000, {rotation:'540000', onUpdate:onRotate});
					else
						TweenLite.killTweensOf(_repairBGHolder);
				}
			}
		}

		private function onRotate():void
		{
			_repairingSymbolBG.smoothing = true;
		}

		override public function set index( index:int ):void
		{
			super.index = index;
			if (_index == 0)
				_flagshipSymbol.visible = true;
		}

		override public function destroy():void
		{
			TweenLite.killTweensOf(_repairBGHolder);

			onSelectShip.removeAll();
			onSelectShip = null;

			_flagshipSymbol = null;
			super.destroy();
		}

	}
}

