package com.ui.modal.dock
{
	import com.model.fleet.FleetVO;

	import flash.display.Sprite;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	public class FleetSelection extends Sprite
	{
		private var _fleets:Dictionary;
		private var _selectedFleet:FleetButton;
		public var loadShipImage:Function;
		public var onFleetSelected:Signal;

		public function FleetSelection()
		{
			super();
			_fleets = new Dictionary();
			onFleetSelected = new Signal(FleetButton);
		}

		public function addFleets( fleets:Vector.<FleetVO> ):void
		{
			var i:uint;
			var len:uint = fleets.length;
			var fleetIcon:FleetButton;
			var currentFleetVO:FleetVO;
			for (i = 0; i < 10; ++i)
			{
				currentFleetVO = (i < fleets.length) ? fleets[i] : null;
				fleetIcon = new FleetButton();
				fleetIcon.index = i;
				fleetIcon.onSelectFleet = onSelected;
				fleetIcon.onLoadShipImage = loadShipImage;
				fleetIcon.setFleet(currentFleetVO);
				addChild(fleetIcon);

				if (currentFleetVO)
					_fleets[currentFleetVO.id] = fleetIcon;
			}

			layout();
		}

		public function updateFleet( fleet:FleetVO, isRepairing:Boolean ):void
		{
			var i:uint;
			var fleetBtn:FleetButton;

			if (fleet.id in _fleets)
			{
				fleetBtn = _fleets[fleet.id];
				fleetBtn.setFleet(fleet);
				fleetBtn.showRepair(isRepairing);
			}

			layout();
		}

		public function setSelected( ID:String ):void
		{
			if (ID in _fleets)
			{
				var fleetIcon:FleetButton = _fleets[ID];
				onSelected(fleetIcon);
			} else if (ID == null)
			{
				onSelected(FleetButton(getChildAt(0)));
			}
		}

		private function onSelected( selectedIcon:FleetButton ):void
		{
			if (_selectedFleet != null)
				_selectedFleet.selected = false;

			_selectedFleet = selectedIcon;

			_selectedFleet.selected = true;

			onFleetSelected.dispatch(selectedIcon);
		}

		private function onFleetClick( selectedFleet:FleetButton ):void
		{
			onSelected(selectedFleet);
		}

		public function layout():void
		{
			var fleetIcon:FleetButton;
			var xPos:int = 0;
			var yPos:int = 0;

			var len:uint = numChildren;
			for (var i:uint = 0; i < len; ++i)
			{
				fleetIcon = FleetButton(getChildAt(i));
				fleetIcon.x = xPos;
				fleetIcon.y = yPos;

				xPos += fleetIcon.width + 12;
			}
		}

		public function destroy():void
		{
			var len:uint = numChildren;
			var fleetIcon:FleetButton;
			for (var i:uint = 0; i < len; ++i)
			{
				fleetIcon = FleetButton(getChildAt(i));
				fleetIcon.destroy();
				fleetIcon = null;
			}

			_selectedFleet.destroy();
			_selectedFleet = null;

			onFleetSelected.removeAll();
		}

		public function get queuedFleets():Array
		{
			var queuedFleets:Array = new Array();
			var len:uint           = numChildren;
			var fleetBtn:FleetButton;
			for (var i:uint = 0; i < len; ++i)
			{
				fleetBtn = FleetButton(getChildAt(i));
				if (fleetBtn.isQueued)
					queuedFleets.push(fleetBtn.fleet);
			}
			return queuedFleets;
		}

		public function getFleetBtn( id:String ):FleetButton
		{
			if (id in _fleets)
			{
				var fleetBtn:FleetButton = _fleets[id];
				return fleetBtn;
			}

			return null;
		}
	}
}
