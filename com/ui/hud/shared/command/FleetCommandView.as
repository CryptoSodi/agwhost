package com.ui.hud.shared.command
{
	import com.Application;
	import com.enum.ui.PanelEnum;
	import com.event.StateEvent;
	import com.game.entity.components.shared.Cargo;
	import com.game.entity.components.shared.Move;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.presenter.shared.CommandPresenter;
	import com.presenter.shared.ICommandPresenter;
	import com.ui.UIFactory;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;
	import com.ui.modal.dock.ShipIcon;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	import org.adobe.utils.StringUtil;
	import org.ash.core.Entity;


	public class FleetCommandView extends Sprite
	{
		private var _fleetFrame:Bitmap;
		private var _fleetInfoFrame:Bitmap;

		private var _fleetBtnStates:Array;

		private var _selectedFleet:FleetButton;
		private var _activeFleets:Vector.<FleetButton>;
		private var _lookup:Dictionary;

		private var _selectedFleetShips:Vector.<ShipIcon>;

		private var _fleetName:Label;

		private var _cargoCountTitle:Label;
		private var _targetTitle:Label;
		private var _statusTitle:Label;

		private var _cargoCount:Label;
		private var _target:Label;
		private var _status:Label;
		private var _travelTime:Label;

		private var _currentState:String;
		private var _travelTimeRemaining:int;
		private var _travelTimer:Timer;

		private var _presenter:ICommandPresenter;

		private const STATUS_TEXT:String         = 'CodeString.FleetSelection.State'; //Status
		private const TARGET_TEXT:String         = 'CodeString.FleetSelection.Target'; //Target
		private const CARGO_TEXT:String          = 'CodeString.FleetSelection.Cargo'; //Cargo
		private const FLEET_STATUS_MOVING:String = 'CodeString.Fleet.Status.Moving'; //Moving
		private const FLEET_STATUS_IDLE:String   = 'CodeString.Fleet.Status.Idle'; //Idle
		private const FLEET_STATUS_BATTLE:String = 'CodeString.Fleet.Status.Battle'; //In Battle
		private const SECTOR_RAW_COORDS:String   = 'CodeString.Sector.RawCoords'; //[[Number.CoordinateX]] , [[Number.CoordinateY]]
		private const CARGO_CAPACITY:String      = 'CodeString.Sector.CargoCapacity'; //[[Number.CurrentCargoCount]] / [[Number.MaxCargoCount]] ([[Number.CargoPercent]]%)
		private const SHARED_NONE:String         = 'CodeString.Shared.None'; //None
		private const _fleetDefendingText:String = 'CodeString.Alert.Battle.DefendingStatus'; //Defending

		public function FleetCommandView():void
		{
			_activeFleets = new Vector.<FleetButton>();
			_lookup = new Dictionary();
			_selectedFleetShips = new Vector.<ShipIcon>();

			_fleetBtnStates = new Array();
			_fleetBtnStates.push(UIFactory.getBitmapData('BtnEmptyUpBMD'))
			_fleetBtnStates.push(UIFactory.getBitmapData('BtnEmptyROBMD'))
			_fleetBtnStates.push(UIFactory.getBitmapData('BtnEmptyDownBMD'))
			_fleetBtnStates.push(UIFactory.getBitmapData('BtnEmptySelectedBMD'))

			_fleetBtnStates.push(UIFactory.getBitmapData('BtnGoldUpBMD'))
			_fleetBtnStates.push(UIFactory.getBitmapData('BtnGoldROBMD'))
			_fleetBtnStates.push(UIFactory.getBitmapData('BtnGoldDownBMD'))
			_fleetBtnStates.push(UIFactory.getBitmapData('BtnGoldSelectedBMD'))

			_fleetBtnStates.push(UIFactory.getBitmapData('BtnRepairUpBMD'))
			_fleetBtnStates.push(UIFactory.getBitmapData('BtnRepairROBMD'))
			_fleetBtnStates.push(UIFactory.getBitmapData('BtnRepairDownBMD'))
			_fleetBtnStates.push(UIFactory.getBitmapData('BtnRepairSelectedBMD'))

			_fleetFrame = UIFactory.getBitmap('SectorFleetSelectionBGBMD');

			_fleetInfoFrame = UIFactory.getPanel(PanelEnum.CONTAINER_NOTCHED_RIGHT_SMALL, 191, 163);

			_fleetName = new Label(16, 0xb4e0ff, 250, 30);
			_fleetName.useLocalization = false;
			_fleetName.textColor = 0xb4e0ff;
			_fleetName.align = TextFormatAlign.LEFT;

			_statusTitle = new Label(16, 0xb4e0ff, 111);
			_statusTitle.constrictTextToSize = false;
			_statusTitle.align = TextFormatAlign.LEFT;
			_statusTitle.text = STATUS_TEXT;

			_status = new Label(16, 0xf0f0f0);
			_status.bold = true;
			_status.constrictTextToSize = false;
			_status.align = TextFormatAlign.LEFT;

			_targetTitle = new Label(16, 0xb4e0ff, 111);
			_targetTitle.constrictTextToSize = false;
			_targetTitle.align = TextFormatAlign.LEFT;
			_targetTitle.text = TARGET_TEXT;

			_target = new Label(16, 0xf0f0f0);
			_target.bold = true;
			_target.constrictTextToSize = false;
			_target.align = TextFormatAlign.LEFT;

			_cargoCountTitle = new Label(16, 0xb4e0ff, 111);
			_cargoCountTitle.constrictTextToSize = false;
			_cargoCountTitle.align = TextFormatAlign.LEFT;
			_cargoCountTitle.text = CARGO_TEXT;

			_cargoCount = new Label(16, 0xf0f0f0, 220);
			_cargoCount.bold = true;
			_cargoCount.constrictTextToSize = false;
			_cargoCount.align = TextFormatAlign.LEFT;
			_cargoCount.useLocalization = false;

			_travelTime = new Label(16, LabelFactory.DYNAMIC_TEXT_COLOR, 60, 20, false);
			_travelTime.constrictTextToSize = false;
			_travelTime.align = TextFormatAlign.CENTER;
			_travelTime.useLocalization = false;

			addChild(_fleetFrame);
			addChild(_fleetInfoFrame);
			addChild(_fleetName);
			addChild(_statusTitle);
			addChild(_status);
			addChild(_targetTitle);
			addChild(_target);
			addChild(_cargoCountTitle);
			addChild(_cargoCount);
			addChild(_travelTime);

			var currentShip:ShipIcon;
			var xPos:Number;
			var yPos:Number;
			for (var i:uint = 0; i < 6; ++i)
			{
				currentShip = new ShipIcon();
				currentShip.scale(0.37, 0.37);
				currentShip.mouseEnabled = false;
				addChild(currentShip);
				_selectedFleetShips.push(currentShip);
			}

			_travelTimer = new Timer(1000);
			_travelTimer.addEventListener(TimerEvent.TIMER, onTravelTimerTick, false, 0, true);
		}

		[PostConstruct]
		public function init():void
		{
			_presenter && _presenter.highfive();
			presenter.addListenerForFleetUpdate(showFleets);
			presenter.addStateListener(onStateChange);

			if (Application.STATE == StateEvent.GAME_SECTOR)
				presenter.addSelectionChangeListener(onSelectionChange);

			showFleets();
			layout();
		}

		public function layout():void
		{
			_fleetInfoFrame.x = 155;
			_fleetInfoFrame.y = 39;

			_fleetFrame.x = 10;
			_fleetFrame.y = 31;

			_fleetName.x = 150;
			_fleetName.y = 12;

			_statusTitle.x = 159;
			_statusTitle.y = 44;

			_status.x = 159;
			_status.y = 65;

			_targetTitle.x = 159;
			_targetTitle.y = 96;

			_target.x = 159;
			_target.y = 121;

			_cargoCountTitle.x = 159;
			_cargoCountTitle.y = 149;

			_cargoCount.x = 159;
			_cargoCount.y = 171;

			_travelTime.x = 50;
			_travelTime.y = 93;

			var len:uint = _selectedFleetShips.length;
			var currentShipIcon:ShipIcon;
			var xPos:Number;
			var yPos:Number;
			for (var i:uint = 0; i < len; ++i)
			{
				currentShipIcon = _selectedFleetShips[i];
				switch (i)
				{
					case 0:
						xPos = 56;
						yPos = 31;
						break;
					case 1:
						xPos = 10;
						yPos = 56;
						break;
					case 2:
						xPos = 100;
						yPos = 56;
						break;
					case 3:
						xPos = 10;
						yPos = 108;
						break;
					case 4:
						xPos = 100;
						yPos = 108;
						break;
					case 5:
						xPos = 55;
						yPos = 135;
						break;
				}
				currentShipIcon.x = xPos;
				currentShipIcon.y = yPos;
			}
		}

		public function showFleets( vo:FleetVO = null ):void
		{
			var fleets:Vector.<FleetVO> = presenter.fleets;
			var focusFleetID:String     = presenter.focusFleetID;
			var button:FleetButton;
			var currentFleet:FleetVO;
			var sector:String           = presenter.sectorID;
			for (var i:int = 0; i < fleets.length; i++)
			{
				button = null;
				if (!(fleets[i].id in _lookup) && fleets[i].sector != '')
					button = createFleetButton(fleets[i]);
				else if (_lookup[fleets[i].id] && fleets[i].sector == '')
					removeFleetButton(fleets[i]);
				else
					button = _lookup[fleets[i].id];

				if (button)
				{
					currentFleet = fleets[i];
					button.setFleetData(currentFleet, sector);
					if (!(fleets[i].id in _lookup))
						_lookup[button.fleetID] = button;
				}

				if (_selectedFleet == null && (focusFleetID == null || fleets[i].id == focusFleetID) && fleets[i].sector == presenter.sectorID)
					onClick(button, (!_selectedFleet && fleets[i].id == focusFleetID), false);
			}

			if (vo != null && _selectedFleet && vo.id == _selectedFleet.fleetID)
			{
				if (_travelTimer.running)
					_travelTimer.stop();
			}

			updateSelectedFleetStats();
			layoutFleets();
		}

		private function createFleetButton( fleetVO:FleetVO ):FleetButton
		{
			//add a new fleet button
			var button:FleetButton = new FleetButton(_fleetBtnStates);
			button.addEventListener(MouseEvent.CLICK, onFleetClicked, false, 0, true);
			button.onLoadSmallImage.add(presenter.loadSmallImageFromEntityData);
			addChild(button);
			_activeFleets.push(button);

			return button;
		}

		private function removeFleetButton( fleetVO:FleetVO ):void
		{
			//remove a fleet button
			for (var j:int = 0; j < _activeFleets.length; j++)
			{
				if (_activeFleets[j].fleetID == fleetVO.id)
				{
					_activeFleets[j].removeEventListener(MouseEvent.CLICK, onFleetClicked);
					removeChild(_activeFleets[j]);
					_activeFleets.splice(j, 1);
					_lookup[fleetVO.id] = null;
					delete _lookup[fleetVO.id];
					if (_selectedFleet && _selectedFleet.fleetID == fleetVO.id)
					{
						if (_activeFleets.length == 0)
							_selectedFleet = null;
						else
							_selectedFleet = _activeFleets[0];
					}
					break;
				}
			}
		}

		private function updateSelectedFleetStats():void
		{
			var len:uint;
			var currentImage:ShipIcon;
			var i:uint

			if (_selectedFleet)
			{
				var fleetVO:FleetVO       = presenter.getFleetVO(_selectedFleet.fleetID);
				var ships:Vector.<ShipVO> = fleetVO.ships;
				len = ships.length;
				var currentShip:ShipVO;
				for (i = 0; i < len; ++i)
				{
					currentShip = ships[i];
					currentImage = _selectedFleetShips[i];
					currentImage.clearImageBitmap();
					if (currentShip)
					{
						currentImage.onLoadShipImage.add(presenter.loadIconImageFromEntityData);
						currentImage.setShip(currentShip, null, fleetVO);
					} else
						currentImage.setShip(null);
				}
				_fleetName.text = _selectedFleet.fleetName;
				_selectedFleet.setFleetData(fleetVO, presenter.sectorID);
				var entity:Entity         = presenter.getEntity(_selectedFleet.fleetID);
				var move:Move             = entity ? entity.get(Move) : null;
				var cargo:Cargo           = entity ? entity.get(Cargo) : null;
				var currentCargo:int      = cargo ? cargo.cargo : fleetVO.currentCargo;
				var cargoPercent:Number   = currentCargo > 0 ? int(currentCargo / fleetVO.maxCargo * 100) : 0;

				_cargoCount.setTextWithTokens(CARGO_CAPACITY,
											  {'[[Number.CurrentCargoCount]]':StringUtil.commaFormatNumber(currentCargo), '[[Number.MaxCargoCount]]':StringUtil.commaFormatNumber(fleetVO.maxCargo),
												  '[[Number.CargoPercent]]':cargoPercent});

				var rawCoordsDict:Dictionary;
				_travelTime.visible = false;
				if (fleetVO.inBattle)
				{
					_status.text = FLEET_STATUS_BATTLE;
					_target.setTextWithTokens(SECTOR_RAW_COORDS,
											  {'[[Number.CoordinateX]]':int(fleetVO.sectorLocationX * 0.01), '[[Number.CoordinateY]]':int(fleetVO.sectorLocationY * 0.01)});
				} else if (move && move.moving)
				{
					_status.text = FLEET_STATUS_MOVING;
					_target.setTextWithTokens(SECTOR_RAW_COORDS,
											  {'[[Number.CoordinateX]]':int(move.destination.x * 0.01), '[[Number.CoordinateY]]':int(move.destination.y * 0.01)});

					_travelTimeRemaining = move.totalTime - move.time;
					_travelTime.setBuildTime(_travelTimeRemaining, 2);
					_travelTime.visible = true;
					_travelTimer.start();


				} else
				{
					_status.text = fleetVO.defendTarget != "" ? _fleetDefendingText : FLEET_STATUS_IDLE;
					_target.text = fleetVO.defendTarget != "" ? "Starbase" : SHARED_NONE; //change this later to the type of object we're defending when we can defend more than a starbase
				}

			} else
			{
				_fleetName.text = '';
				_cargoCount.text = '';
				_status.text = '';
				_target.text = '';
				len = _selectedFleetShips.length;
				for (i = 0; i < len; ++i)
				{
					currentImage = _selectedFleetShips[i];
					currentImage.setShip(null);
				}
			}
		}

		private function onTravelTimerTick( e:TimerEvent ):void
		{
			_travelTimeRemaining -= 1;
			if (_travelTimeRemaining > 0)
				_travelTime.setBuildTime(_travelTimeRemaining, 2);
			else
				_travelTimer.stop();
		}

		private function onFleetClicked( e:MouseEvent ):void
		{
			if (e)
			{
				e.stopImmediatePropagation();
				onClick(FleetButton(e.currentTarget));
			}
		}

		private function onClick( clickedFleet:FleetButton, gotoLocation:Boolean = true, canEnterBattle:Boolean = true, informPresenter:Boolean = true ):void
		{
			if (!presenter.hudEnabled)
				return;
			if (clickedFleet != null)
			{
				if (_selectedFleet != null)
					_selectedFleet.selected = false;

				gotoLocation = ((_selectedFleet != null && (_selectedFleet.fleetID == clickedFleet.fleetID || !clickedFleet.inSector) && gotoLocation)) ? gotoLocation : false;

				canEnterBattle = ((_selectedFleet != null && _selectedFleet.fleetID == clickedFleet.fleetID && canEnterBattle)) ? canEnterBattle : false;

				_selectedFleet = clickedFleet;
				_selectedFleet.selected = true;

				updateSelectedFleetStats();
				if (informPresenter)
					presenter.selectFleet(_selectedFleet.fleetID, gotoLocation, canEnterBattle);
			}
		}

		private function onSelectionChange( entity:Entity ):void
		{
			if (entity)
			{
				for (var i:int = 0; i < _activeFleets.length; i++)
				{
					if (_activeFleets[i].fleetID == entity.id)
						onClick(_activeFleets[i], false, false, false);
				}
			}
		}

		protected function onStateChange( v:String ):void
		{
			_currentState = v;

			switch (_currentState)
			{
				case StateEvent.GAME_SECTOR:
					presenter.addSelectionChangeListener(onSelectionChange);
					if (presenter.focusFleetID == null && _selectedFleet != null && _selectedFleet.inSector)
						presenter.selectFleet(_selectedFleet.fleetID, false, false);
					else if (_selectedFleet != null && _selectedFleet.fleetID != presenter.focusFleetID && presenter.focusFleetID in _lookup)
						onClick(_lookup[presenter.focusFleetID], false, false, true);
					break;
				case StateEvent.GAME_SECTOR_CLEANUP:
					presenter.removeSelectionChangeListener(onSelectionChange);
					break;
				case StateEvent.GAME_STARBASE:
					showFleets();
					if (presenter.focusFleetID == null && _selectedFleet != null)
						presenter.selectFleet(_selectedFleet.fleetID, false, false);
					break;
			}
		}

		public function layoutFleets():void
		{
			var yPos:Number = -33;
			var xPos:Number = 160;
			var secondColumn:Boolean;
			var len:uint    = _activeFleets.length;
			var currentFleet:FleetButton;

			for (var i:uint = 0; i < len; ++i)
			{
				currentFleet = _activeFleets[i];
				var vo:FleetVO = currentFleet.fleet;

				if (i != 0 && i % 4 == 0)
				{
					yPos = -97;
					xPos -= 193;
				} else
				{
					yPos -= (currentFleet.height + 3);
				}

				currentFleet.x = xPos;
				currentFleet.y = yPos;
			}
			mouseEnabled = (len > 0) ? true : false;
		}

		[Inject]
		public function set presenter( value:ICommandPresenter ):void  { _presenter = value; }
		public function get presenter():ICommandPresenter  { return CommandPresenter(_presenter); }

		public function destroy():void
		{
			presenter.removeListenerForFleetUpdate(showFleets);
			presenter.removeStateListener(onStateChange);
			presenter.removeSelectionChangeListener(onSelectionChange);
			_presenter && _presenter.shun();

			if (_travelTimer)
			{
				if (_travelTimer.running)
					_travelTimer.stop();

				_travelTimer.removeEventListener(TimerEvent.TIMER, onTravelTimerTick);
			}
			_travelTimer = null;

			_fleetFrame = null;
			_fleetInfoFrame = null;

			_fleetBtnStates.length = 0;

			var len:uint = _activeFleets.length;
			var i:uint   = 0;
			var currentFleet:FleetButton;
			for (i; i < len; ++i)
			{
				currentFleet = _activeFleets[i];
				currentFleet.removeEventListener(MouseEvent.CLICK, onFleetClicked);
				currentFleet.destroy();
				currentFleet = null;
			}
			_activeFleets.length = 0;

			_lookup = null;

			len = _selectedFleetShips.length;
			i = 0;
			var currentShip:ShipIcon;
			for (i; i < len; ++i)
			{
				currentShip = _selectedFleetShips[i];
				currentShip.destroy();
				currentShip = null;
			}
			_selectedFleetShips.length = 0;

			if (_fleetName)
				_fleetName.destroy();

			_fleetName = null;

			if (_cargoCountTitle)
				_cargoCountTitle.destroy();

			_cargoCountTitle = null;

			if (_targetTitle)
				_targetTitle.destroy();

			_targetTitle = null;

			if (_statusTitle)
				_statusTitle.destroy();

			_statusTitle = null;

			if (_cargoCount)
				_cargoCount.destroy();

			_cargoCount = null;

			if (_target)
				_target.destroy();

			_target = null;

			if (_status)
				_status.destroy();

			_status = null;

			if (_travelTime)
				_travelTime.destroy();

			_travelTime = null;
		}
	}
}
