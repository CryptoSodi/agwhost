package com.model.fleet
{
	import com.enum.FleetStateEnum;
	import com.model.Model;
	import com.model.prototype.PrototypeModel;
	import com.model.transaction.TransactionVO;
	import com.service.server.incoming.data.FleetData;
	import com.service.server.incoming.data.ShipData;

	import flash.utils.Dictionary;

	import org.adobe.utils.DictionaryUtil;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class FleetModel extends Model
	{
		public var onUpdatedFleetsSignal:Signal;

		private var _dirty:Boolean; //set to true when we want to wipe and rebuild all data. should only be set in rare cases such as a server crash
		private var _maxAvailableShipSlots:int;
		private var _fleets:Vector.<FleetVO>;
		private var _lookup:Dictionary;
		private var _unassignedShips:Vector.<ShipVO>;
		private var _prototypeModel:PrototypeModel;

		[PostConstruct]
		public function init():void
		{
			_dirty = false;
			_fleets = new Vector.<FleetVO>();
			_lookup = new Dictionary();
			_unassignedShips = new Vector.<ShipVO>();
			onUpdatedFleetsSignal = new Signal(FleetVO);
		}

		//============================================================================================================
		//************************************************************************************************************
		//													FLEETS
		//************************************************************************************************************
		//============================================================================================================

		/**
		 * Take the latest fleet data received from the server and updates an existing fleet or creates a new one
		 * @param fleetData The data from the server
		 */
		public function importFleetData( fleetData:FleetData ):void
		{
			if (!_lookup[fleetData.id] || _dirty)
			{
				var fleetVO:FleetVO = ObjectPool.get(FleetVO);
				_fleets.push(fleetVO);
				_lookup[fleetData.id] = fleetVO;
			}

			_lookup[fleetData.id].importData(fleetData);
		}

		/**
		 * Assigns a ship to a fleet
		 * @param selectedFleet The target fleet
		 * @param selectedShip The ship to add
		 * @param index The index to store the ship at on the fleet
		 */
		public function assignShipToFleet( selectedFleet:FleetVO, selectedShip:ShipVO, index:int ):void
		{
			var wasAdded:Boolean = selectedFleet.addShip(selectedShip, index);

			if (wasAdded)
			{
				index = _unassignedShips.indexOf(selectedShip);

				if (index != -1)
					_unassignedShips.splice(index, 1);

				updateFleet(selectedFleet);
			}
		}

		public function removeShipFromFleet( id:String, addToUnassignedShips:Boolean = true ):void
		{
			var ship:ShipVO = _lookup[id];

			if (ship && ship.fleetOwner != '' && ship.fleetOwner != null)
			{
				var fleet:FleetVO      = _lookup[ship.fleetOwner];
				var wasRemoved:Boolean = fleet.removeShip(ship);

				if (wasRemoved)
				{
					if (addToUnassignedShips)
						_unassignedShips.push(ship);

					updateFleet(fleet);
				}
			}
		}

		public function repairFleet( fleetToRepair:FleetVO, instant:Boolean = false, transaction:TransactionVO = null ):void
		{
			if(fleetToRepair == null)
				return;
			
			var ship:ShipVO;

			if (instant)
			{
				var ships:Vector.<ShipVO> = fleetToRepair.ships;
				var len:uint              = ships.length;

				for (var i:uint = 0; i < len; ++i)
				{
					ship = ships[i];

					if (ship && ship.currentHealth != ship.maxHealth)
						ship.currentHealth = ship.maxHealth;
				}

				fleetToRepair.state = FleetStateEnum.DOCKED;
				fleetToRepair.updateFleetStats();
				fleetToRepair.currentHealth = 1;
				updateFleet(fleetToRepair);
			}

			else if (transaction && fleetToRepair && _prototypeModel)
			{
				fleetToRepair.updateFleetStats();
				var shipTimeDiff:Number;
				var diff:Number                     = fleetToRepair.repairTime - (transaction.timeRemainingMS) / 1000;
				var isNewRepairSystemActive:Boolean = _prototypeModel.getConstantPrototypeValueByName("isNewRepairSystemActive");

				//find a ship to repair
				for (i = 0; i < fleetToRepair.ships.length; ++i)
				{
					ship = fleetToRepair.ships[i];

					if (ship && ship.currentHealth != 1)
					{
						shipTimeDiff = (ship.currentRepairTime <= diff) ? ship.currentRepairTime : diff;
						ship.currentHealth += ship.healthGainedASecond * shipTimeDiff;
						if (!isNewRepairSystemActive)
						{
							diff -= shipTimeDiff;

							if (diff <= 0)
								break;
						}
					}
				}
			}
		}

		public function renameFleet( fleetToRename:FleetVO, newName:String ):void
		{
			fleetToRename.name = newName;
			updateFleet(fleetToRename);
		}

		public function updateShipFromRefit( id:String, built:Boolean, refiting:Boolean, refitSuccess:Boolean ):void
		{
			var currentShip:ShipVO;
			var len:uint = _unassignedShips.length;

			for (var i:int = 0; i < len; i++)
			{
				currentShip = _unassignedShips[i];

				if (currentShip.id == id)
				{
					currentShip.built = built;
					currentShip.refiting = refiting;

					if (refitSuccess)
					{
						var refitMods:Dictionary = currentShip.refitModules;

						for (var key:String in refitMods)
							currentShip.equipModule(refitMods[key], key);
					}
				}
			}

		}

		public function getFleetByBattleAddress( address:String ):FleetVO
		{
			for (var i:int = 0; i < _fleets.length; i++)
			{
				if (_fleets[i].battleServerAddress == address)
					return _fleets[i];
			}

			return null;
		}

		public function getFleet( id:String ):FleetVO  { return _lookup[id]; }
		public function updateFleet( selectedFleet:FleetVO ):void  { onUpdatedFleetsSignal.dispatch(selectedFleet); }

		//============================================================================================================
		//************************************************************************************************************
		//													SHIPS
		//************************************************************************************************************
		//============================================================================================================

		public function importShipData( shipData:ShipData ):void
		{
			if (!_lookup[shipData.id] || _dirty)
			{
				var shipVO:ShipVO   = ObjectPool.get(ShipVO);
				_lookup[shipData.id] = shipVO;
				_lookup[shipData.id].importData(shipData);
				//add the ships to the fleet. we only need to do this when the fleet is first created
				//subsequent addition or removal of fleets will be taken care of by transactions
				var fleetVO:FleetVO = getFleet(shipData.fleetOwner);
				if (fleetVO)
					assignShipToFleet(fleetVO, shipVO, shipData.positionIndex);
				else
					addShip(shipVO);
			}
			_lookup[shipData.id].importData(shipData);
		}

		public function addShip( ship:ShipVO ):void
		{
			_unassignedShips.push(ship);
			_lookup[ship.id] = ship;
		}

		public function removeShip( id:String ):void
		{
			var ship:ShipVO = _lookup[id];
			if (ship)
			{
				if (ship.fleetOwner != null && ship.fleetOwner != '')
				{
					removeShipFromFleet(id, false);

				} else
				{
					var index:int = _unassignedShips.indexOf(ship);
					if (index != -1)
						_unassignedShips.splice(index, 1);
				}
				ship.destroy();
				delete _lookup[id];
			}
		}

		public function updateShipID( oldID:String, newID:String ):void
		{
			//TODO fix - crashes sometimes
			//ensure that the server didn't beat us to it
			if (_lookup[newID] != null)
			{
				_lookup[oldID] = null;
				delete _lookup[oldID];
			} else 
			{
				var shipVO:ShipVO = _lookup[oldID];
				_lookup[oldID] = null;
				delete _lookup[oldID];
				if(shipVO != null)
					shipVO.id = newID;
				_lookup[newID] = shipVO;
			}
		}

		public function getShip( id:String ):ShipVO  { return _lookup[id]; }

		public function get builtShipCount():Number
		{
			var count:uint = 0;
			
			for each (var value:Object in _lookup)
			{
				if(value as ShipVO)
				{
					++count;
				}
			}
			
			return count;
		}
		
		public function get canBuildNewShips():Boolean
		{
			var count:uint = 0;
			
			for each (var value:Object in _lookup)
			{
				if(value as ShipVO)
				{
					++count;
				}
			}			
			
			if (count < _maxAvailableShipSlots)
				return true;

			return false;
		}

		//============================================================================================================
		//************************************************************************************************************
		//************************************************************************************************************
		//============================================================================================================

		public function set dirty( v:Boolean ):void  { _dirty = v; }
		public function set maxAvailableShipSlots( v:Number ):void  { _maxAvailableShipSlots = v; }
		public function get maxAvailableShipSlots():Number  { return _maxAvailableShipSlots; }
		public function get fleets():Vector.<FleetVO>  { return _fleets; }
		public function get ships():Vector.<ShipVO>  { return _unassignedShips; }

		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
	}
}

