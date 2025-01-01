package com.ui.core.component.misc
{
	import com.game.entity.components.battle.Ship;
	import com.model.battle.BattleEntityVO;
	import com.ui.core.component.IComponent;
	import com.ui.modal.PanelFactory;
	import com.ui.modal.dock.ShipIcon;

	import flash.display.Sprite;

	public class FleetIconLayoutComponent extends Sprite implements IComponent
	{
		private var _selectedFleetShips:Vector.<ShipIcon>;
		private var _enabled:Boolean;

		public function FleetIconLayoutComponent()
		{
			super();

			//Init Ship Icons
			_selectedFleetShips = new Vector.<ShipIcon>();
			var image:ShipIcon;
			var xPos:uint;
			var yPos:uint;
			for (var i:uint = 0; i < 6; ++i)
			{
				image = new ShipIcon();
				image.scale(0.39, 0.39);
				//image.setShowBar(true);

				switch (i)
				{
					case 0:
						xPos = 45; //94;
						yPos = 0; //20;
						break;
					case 1:
						xPos = 0; //49;
						yPos = 23; //44;
						break;
					case 2:
						xPos = 90; //139;
						yPos = 23; //44;
						break;
					case 3:
						xPos = 0; //49;
						yPos = 75; //96;
						break;
					case 4:
						xPos = 90; //139;
						yPos = 75; //96;
						break;
					case 5:
						xPos = 45; //94;
						yPos = 102; //123;
						break;
				}

				image.x = xPos;
				image.y = yPos;
				addChild(image);
				_selectedFleetShips.push(image);
			}
			_enabled = true;
		}

		public function setUpEnemyFleetIcon( ships:Vector.<BattleEntityVO>, callback:Function ):void
		{
			var currentImage:ShipIcon;
			var i:uint;
			var len:uint = ships.length;
			for (; i < len; ++i)
			{
				currentImage = _selectedFleetShips[i];
				currentImage.clearImageBitmap();
				currentImage.mouseEnabled = false;

				currentImage.onLoadShipImage.add(callback);
				currentImage.setShip(null, ships[i].prototype);
				currentImage.setBarValue(1 - ships[i].healthPercent);
			}

			len = _selectedFleetShips.length;
			for (i = 0; i < len; ++i)
				_selectedFleetShips[i].mouseEnabled = false;
		}

		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled( value:Boolean ):void
		{
			_enabled = value;
			var len:uint = _selectedFleetShips.length;
			var currentIcon:ShipIcon;
			for (var i:uint = 0; i < len; ++i)
			{
				currentIcon = _selectedFleetShips[i];
				currentIcon.enabled = _enabled;
			}
		}

		public function destroy():void
		{
			var len:uint = _selectedFleetShips.length;
			var currentIcon:ShipIcon;
			for (var i:uint = 0; i < len; ++i)
			{
				currentIcon = _selectedFleetShips[i];
				currentIcon.destroy();
				currentIcon = null;
			}
			_selectedFleetShips.length = 0;
		}
	}
}
