package com.ui.modal.dock
{
	import com.enum.FleetStateEnum;
	import com.enum.ui.ButtonEnum;
	import com.model.fleet.FleetVO;
	import com.ui.UIFactory;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.greensock.TweenLite;

	public class FleetButton extends Sprite
	{
		private var _fleet:FleetVO;

		private var _index:int;

		private var _bg:BitmapButton;

		private var _queueBtn:BitmapButton;

		private var _image:ImageComponent;

		private var _statusText:Label;

		private var _bgMask:Bitmap;

		private var _healthBar:ProgressBar;

		private var _battleSymbol:Bitmap;
		private var _repairingSymbol:Bitmap;
		private var _repairingSymbolBG:Bitmap;
		private var _lockedSymbol:Bitmap;

		private var _repairBGHolder:Sprite;

		private var _isQueued:Boolean;
		private var _isRepairing:Boolean;

		public var onSelectFleet:Function;
		public var onLoadShipImage:Function;

		private var _docking:String            = 'CodeString.Docks.FleetSelection.Docking'; //Docking
		private var _out:String                = 'CodeString.Docks.FleetSelection.Out'; //Out
		private var _recalled:String           = 'CodeString.Docks.FleetSelection.Recalled'; //Recalled
		private var _notUnlocked:String        = 'CodeString.Docks.FleetSelection.NotUnlocked'; //Not Yet Unlocked!
		private var _fleetLaunched:String      = 'CodeString.Docks.FleetSelection.FleetIsLaunched'; //Fleet Is Launched
		private var _fleetDefendingText:String = 'CodeString.Alert.Battle.DefendingStatus'; //Defending

		public function FleetButton()
		{
			super();

			_bg = UIFactory.getButton(ButtonEnum.FLEET);
			_bg.addEventListener(MouseEvent.CLICK, onMouse, false, 0, true);
			_bg.selectable = true;

			_image = new ImageComponent();
			_image.mouseEnabled = false;
			_image.init(_bg.width, _bg.height - 5);

			_bgMask = UIFactory.getBitmap('MaskBtnFleetBMD');
			_bgMask.x = _bg.x;
			_bgMask.y = _bg.y + 1;
			_bgMask.cacheAsBitmap = true;

			_healthBar = new ProgressBar();
			_healthBar.init(ProgressBar.VERTICAL, new Bitmap(new BitmapData(_bg.width, _bg.height, true, 0x8Cff0000)), null, 0.01);
			_healthBar.x = _bg.x;
			_healthBar.y = _bg.y;
			_healthBar.mask = _bgMask;
			_healthBar.cacheAsBitmap = true;
			_healthBar.setMinMax(0, 1);
			_healthBar.mouseChildren = false;
			_healthBar.mouseEnabled = false;

			_lockedSymbol = UIFactory.getBitmap('IconBlueLockedBMD');
			_lockedSymbol.x = _bg.x + (_bg.width - _lockedSymbol.width) * 0.5;
			_lockedSymbol.y = _bg.y + _bg.height - (_lockedSymbol.height + 5);
			_lockedSymbol.visible = false;

			_repairingSymbolBG = UIFactory.getBitmap('IconDockRepairCircleBMD');
			_repairingSymbolBG.x = -_repairingSymbolBG.width * 0.5;
			_repairingSymbolBG.y = -_repairingSymbolBG.height * 0.5;
			_repairingSymbolBG.smoothing = true;

			_repairBGHolder = new Sprite();
			_repairBGHolder.addChild(_repairingSymbolBG);
			_repairBGHolder.visible = false;
			_repairBGHolder.x = _bg.x + (_repairBGHolder.width * 0.25);
			_repairBGHolder.mouseChildren = false;
			_repairBGHolder.mouseEnabled = false;

			_repairingSymbol = UIFactory.getBitmap('IconDockRepairWrenchBMD');
			_repairingSymbol.visible = false;
			_repairingSymbol.x = _repairBGHolder.x - _repairingSymbol.width * 0.5;
			_repairingSymbol.y = _repairBGHolder.y - _repairingSymbol.height * 0.5;

			_queueBtn = UIFactory.getButton(ButtonEnum.QUEUE);
			_queueBtn.x = _bg.x + _bg.width - _queueBtn.width;
			_queueBtn.selectable = true;
			_queueBtn.addEventListener(MouseEvent.CLICK, onQueueBtnClicked, false, 0, true);

			_battleSymbol = UIFactory.getBitmap('CombatIconBMD');
			_battleSymbol.visible = false;
			_battleSymbol.x = _bg.x + (_bg.width - _battleSymbol.width) * 0.5;
			_battleSymbol.y = _bg.y + (_bg.height - _battleSymbol.height) * 0.5;

			_statusText = new Label(12, 0xffffff, 100, 20, true, 1);
			_statusText.x = _healthBar.x;
			_statusText.y = _healthBar.y;
			_statusText.width = _bg.width;
			_statusText.height = _bg.height;
			_statusText.multiline = true;
			_statusText.constrictTextToSize = false;
			_statusText.align = TextFormatAlign.CENTER;
			_statusText.mouseEnabled = false;

			addChild(_bg);
			addChild(_image);
			addChild(_healthBar);
			addChild(_bgMask);
			addChild(_battleSymbol);
			addChild(_lockedSymbol);
			addChild(_statusText);
			addChild(_repairBGHolder);
			addChild(_repairingSymbol);
			addChild(_queueBtn);
		}

		private function onQueueBtnClicked( e:MouseEvent ):void
		{
			e.stopImmediatePropagation();
			_isQueued = _queueBtn.selected;
		}

		public function showRepair( show:Boolean ):void
		{
			if (_bg.enabled)
			{
				_isRepairing = show;

				if (_fleet.sector == '' && _fleet.currentHealth > 0)
					_queueBtn.visible = !show;

				if (_fleet != null)
				{
					_repairingSymbol.visible = show;
					_repairBGHolder.visible = show;

					if (show)
						TweenLite.to(_repairBGHolder, 3000, {rotation:'540000', onUpdate:onRotate});
					else
						TweenLite.killTweensOf(_repairBGHolder);
				}
			}
		}

		private function onMouse( e:MouseEvent ):void
		{
			if (_fleet != null && e.target != _queueBtn)
				onSelectFleet(this);
		}

		override public function get height():Number
		{
			return _bg.height;
		}

		override public function get width():Number
		{
			return _bg.width;
		}

		public function get isQueued():Boolean
		{
			return _isQueued;
		}

		public function get fleet():FleetVO
		{
			return _fleet;
		}

		public function get id():String
		{
			return _fleet.id;
		}

		public function get index():int
		{
			return _index;
		}

		public function set selected( v:Boolean ):void
		{
			_bg.selected = v;
		}

		public function setFleet( fleet:FleetVO ):void
		{
			_fleet = fleet;
			TweenLite.killTweensOf(_repairBGHolder);
			if (_fleet == null || _fleet.numOfShips == 0)
			{
				if (_fleet == null)
				{
					_statusText.text = _notUnlocked;
					_lockedSymbol.visible = true;
					_bg.enabled = false;
				} else
					_bg.enabled = true;
				_image.clearBitmap();
				_healthBar.amount = 0;
				_queueBtn.visible = false;

			} else
			{
				_bg.enabled = true;
				_healthBar.amount = (1 - _fleet.currentHealth);
				var asset:String = _fleet.asset;
				if (asset != '')
					onLoadShipImage(asset, onImageLoaded);

				if (_isRepairing && _fleet.state != FleetStateEnum.REPAIRING)
					showRepair(false);

				if (_fleet.sector == '' && _fleet.currentHealth > 0 && !_isRepairing)
				{
					if (_fleet.state == FleetStateEnum.DEFENDING)
					{
						_statusText.text = _fleetDefendingText;
						_queueBtn.visible = false;
					} else
					{
						_statusText.text = '';
						_queueBtn.visible = true;
					}
				} else if (_fleet.sector != '')
				{
					_queueBtn.visible = false;
					if (_fleet.state != FleetStateEnum.DOCKING && _fleet.state != FleetStateEnum.FORCED_RECALLING)
						_statusText.text = (_fleet.defendTarget != "") ? _fleetDefendingText : _out;
					else
						_statusText.text = _recalled;
				} else
					_queueBtn.visible = false;

				if (_fleet.inBattle)
					_battleSymbol.visible = true;
				else
					_battleSymbol.visible = false;

				_lockedSymbol.visible = false;
			}
		}

		private function onImageLoaded( asset:BitmapData ):void
		{
			if (_image && _bg)
			{
				_image.onImageLoaded(asset);
				_image.x = _bg.x + (_bg.width - _image.width) * 0.5;
				_image.y = _bg.y + (_bg.height - _image.height) * 0.5;
			}
		}

		private function onRotate():void
		{
			_repairingSymbolBG.smoothing = true;
		}

		public function set index( index:int ):void
		{
			_index = index;
		}

		public function destroy():void
		{
			if (_bg)
			{
				_bg.removeEventListener(MouseEvent.CLICK, onMouse);
				_bg = UIFactory.destroyButton(_bg);
			}
		}
	}
}
