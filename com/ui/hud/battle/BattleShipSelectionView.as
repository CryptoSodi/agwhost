package com.ui.hud.battle
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.PanelEnum;
	import com.game.entity.components.battle.Health;
	import com.game.entity.systems.interact.controls.ControlledEntity;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.player.CurrentUser;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.effects.EffectFactory;
	import com.ui.modal.dock.ShipIcon;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import org.ash.core.Entity;
	import org.greensock.TweenLite;
	import org.parade.util.DeviceMetrics;

	public class BattleShipSelectionView extends BattleBaseView
	{
		private var _bg:Sprite;
		private var _fleet:FleetVO;
		private var _fleetFrame:Bitmap;
		private var _fleetName:Label;
		private var _minimizeButton:BitmapButton;
		private var _maximizeButton:BitmapButton;
		private var _selectAllShipsButton:BitmapButton;
		private var _selectedFleetShips:Vector.<ShipIcon>;
		private var _ships:Dictionary;
		private var _windowState:int;

		private const MIN_X_POS:Number = 271;
		private const MIN_Y_POS:Number = 467;
		private const MAXIMIZED:Number = 1;
		private const MINIMIZED:Number = 0;

		[PostConstruct]
		override public function init():void
		{
			_windowState = MAXIMIZED;
			_fleet = presenter.getSelectedFleet();
			if (_fleet == null)
				return;

			_ships = new Dictionary();

			super.init();

			_selectedFleetShips = new Vector.<ShipIcon>;

			_bg = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_DOUBLE_NOTCHED_ARROWS, PanelEnum.HEADER_NOTCHED, 225, 156, 32, 0, 0, _fleet.name);
			_bg.mouseEnabled = false;

			_fleetFrame = UIFactory.getBitmap('SectorFleetSelectionBGBMD');
			_fleetFrame.x = _bg.x + (_bg.width - _fleetFrame.width) * 0.5;
			_fleetFrame.y = _bg.y + (_bg.height - _fleetFrame.height) * 0.5 + 15;

			_fleetName = new Label(22, 0xf0f0f0, 200, 30);
			_fleetName.allCaps = true;
			_fleetName.useLocalization = false;
			_fleetName.align = TextFormatAlign.LEFT;
			_fleetName.x = 3;
			_fleetName.y = 3;

			_minimizeButton = UIFactory.getButton(ButtonEnum.ICON_WINDOW_MIN, 0, 0, 205, 13);
			_maximizeButton = UIFactory.getButton(ButtonEnum.ICON_WINDOW_FULL, 0, 0, 205, 13);
			_maximizeButton.visible = false;

			_selectAllShipsButton = UIFactory.getButton(ButtonEnum.BLUE_A, 225, 46, 0, 0, "Select All");
			/*if(CONFIG::IS_MOBILE){
				_selectAllShipsButton.scaleX = _selectAllShipsButton.scaleY = 2;
			}*/
			_selectAllShipsButton.y = -(_selectAllShipsButton.height + 4);
			_selectAllShipsButton.x = _bg.x;
			_selectAllShipsButton.addEventListener(MouseEvent.CLICK, _onSelectAllShipsClicked);
			addListener(_minimizeButton, MouseEvent.CLICK, onMinimize);
			addListener(_maximizeButton, MouseEvent.CLICK, onMaximize);

			addChild(_bg);

			addChild(_minimizeButton);
			addChild(_maximizeButton);
			addChild(_fleetFrame);
			addChild(_fleetName);
			addChild(_selectAllShipsButton);

			presenter.addListenerVitalPercentUpdates(onHealthUpdated);
			presenter.addListenerBattleEntitiesControlledUpdated(BattleEntitiesControlledUpdated);

			onStageResize();
			setUpShips();

			addHitArea();
			addEffects();
			effectsIN();

			visible = !presenter.inFTE;
		}
		
		private function _onSelectAllShipsClicked(e:MouseEvent):void{
			stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, Keyboard.Q));
			stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.Q));

		}

		private function setUpShips():void
		{
			var image:ShipIcon;
			var xPos:Number;
			var yPos:Number;
			var currentShip:ShipVO;
			var currentEntity:Entity;
			//68.5
			//143
			for (var i:uint = 0; i < 6; ++i)
			{
				image = new ShipIcon();
				image.scale(0.37, 0.37);
				image.index = i;

				switch (i)
				{
					case 0:
						xPos = _fleetFrame.x + 47;
						yPos = _fleetFrame.y;
						break;
					case 1:
						xPos = _fleetFrame.x + 1;
						yPos = _fleetFrame.y + 26;
						break;
					case 2:
						xPos = _fleetFrame.x + 91;
						yPos = _fleetFrame.y + 26;
						break;
					case 3:
						xPos = _fleetFrame.x + 1;
						yPos = _fleetFrame.y + 77;
						break;
					case 4:
						xPos = _fleetFrame.x + 91;
						yPos = _fleetFrame.y + 77;
						break;
					case 5:
						xPos = _fleetFrame.x + 45;
						yPos = _fleetFrame.y + 105;
						break;
				}

				image.x = xPos;
				image.y = yPos;
				addChild(image);

				if (_fleet != null)
					currentShip = _fleet.ships[i];

				if (currentShip)
				{
					currentEntity = presenter.getEntity(currentShip.id);
					image.onLoadShipImage.add(presenter.loadMiniIconFromEntityData);
					image.setShip(currentShip, null, _fleet);
					if (currentEntity)
					{
						var health:Health = currentEntity.get(Health);
						image.setBarValue(1 - health.percent);
						image.selectable = true;
					} else
						image.setBarValue(1);

					addListener(image, MouseEvent.CLICK, onShipClicked);

					_ships[currentShip.id] = image;
				}
				_selectedFleetShips.push(image);
			}
		}

		private function onShipClicked( e:MouseEvent ):void
		{
			var icon:ShipIcon;
			if (e.target is ShipIcon)
				icon = ShipIcon(e.target);
			else if (e.target.parent is ShipIcon)
				icon = ShipIcon(e.target.parent);

			if (icon)
			{
				var ship:ShipVO = icon.ship;
				if (ship)
					presenter.selectOwnedShipById(ship.id)
			}
			e.stopPropagation();
		}

		private function onHealthUpdated( playerId:String, percent:Number ):void
		{
			if (playerId == CurrentUser.id)
			{
				var selectedShipIcon:ShipIcon;
				var selectedShip:ShipVO;
				for each (var ship:ShipIcon in _ships)
				{
					selectedShip = ship.ship;

					if (selectedShip)
					{
						var entity:Entity = presenter.getShip(selectedShip.id);
						if (entity)
						{
							var health:Health = entity.get(Health);
							if (health)
								ship.setBarValue(1 - health.percent);
						}
					}
				}
			}
		}

		private function onMinimize( e:MouseEvent ):void
		{
			_windowState = MINIMIZED;
			_minimizeButton.visible = false;
			_maximizeButton.visible = true;
			TweenLite.to(this, .2, {y:DeviceMetrics.HEIGHT_PIXELS - 32});
			e.stopPropagation();
		}

		private function onMaximize( e:MouseEvent ):void
		{
			_windowState = MAXIMIZED;
			_minimizeButton.visible = true;
			_maximizeButton.visible = false;
			TweenLite.to(this, .2, {y:DeviceMetrics.HEIGHT_PIXELS - (_bg.height * Application.SCALE)});
			e.stopPropagation();
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.RIGHT, PositionEnum.BOTTOM, onStageResize, x, y));
		}

		private function onStageResize():void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			TweenLite.killTweensOf(this);
			var yPos:Number;
			switch (_windowState)
			{
				case MAXIMIZED:
					yPos = DeviceMetrics.HEIGHT_PIXELS - height;
					break;
				case MINIMIZED:
					yPos = DeviceMetrics.HEIGHT_PIXELS - (32 * Application.SCALE);
					break;
			}
			y = (yPos < MIN_Y_POS) ? MIN_Y_POS : yPos;
			x = (DeviceMetrics.WIDTH_PIXELS - width < MIN_X_POS) ? MIN_X_POS : DeviceMetrics.WIDTH_PIXELS - width;
		}

		private function BattleEntitiesControlledUpdated( v:Vector.<ControlledEntity> ):void
		{
			var len:uint                  = v.length;
			var currentEntity:ControlledEntity;
			var controlledList:Dictionary = new Dictionary;
			for (var i:uint = 0; i < len; ++i)
				controlledList[v[i].entity.id] = "";

			for each (var ship:ShipIcon in _ships)
			{
				if (ship.id in controlledList)
				{
					ship.selectable = true;
					ship.selected = true;
					ship.selectable = false;
				} else
				{
					ship.selectable = true;
					ship.selected = false;
				}
			}
		}

		override public function get height():Number  { return _bg.height * Application.SCALE; }
		override public function get width():Number  { return _bg.width * Application.SCALE; }

		override public function destroy():void
		{
			_selectAllShipsButton.removeEventListener(MouseEvent.CLICK, _onSelectAllShipsClicked);
			presenter.removeListenerVitalPercentUpdates(onHealthUpdated);
			var len:uint = _selectedFleetShips.length;
			var selectedShipIcon:ShipIcon;
			for (var i:uint = 0; i < len; ++i)
			{
				selectedShipIcon = _selectedFleetShips[i];

				if (selectedShipIcon.ship)
					removeListener(selectedShipIcon, MouseEvent.CLICK, onShipClicked);

				selectedShipIcon.destroy();
				selectedShipIcon = null;
			}
			_selectedFleetShips.length = 0;

			_bg = null;
			_fleetFrame = null;

			if (_fleetName)
				_fleetName.destroy();

			_fleetName = null;

			super.destroy();
		}
	}
}
