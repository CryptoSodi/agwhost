package com.model.fleet
{
	import com.enum.FleetStateEnum;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.incoming.data.FleetData;
	import com.util.statcalc.StatCalcUtil;

	public class FleetVO implements IPrototype
	{
		public var battleServerAddress:String;
		public var inBattle:Boolean                      = false;
		public var level:int;
		public var ownerID:String;
		public var sectorLocationX:int;
		public var sectorLocationY:int;
		public var currentCargo:int;

		private var _repairCreditCost:int                = 0;
		private var _repairAlloyCost:int                 = 0;
		private var _repairEnergyCost:int                = 0;
		private var _repairSyntheticCost:int             = 0;
		private var _repairTime:int                      = 0;

		private var _id:String;
		private var _currentHealth:Number;
		private var _healthAmount:Number;
		private var _powerUsage:Number;
		private var _damage:int;
		private var _defendTarget:String;
		private var _fleetGroupData:Object               = {};
		private var _groupData:String;
		private var _loadSpeed:Number;
		private var _maxCargo:int                        = 0;
		private var _maxHealth:int;
		private var _name:String;
		private var _numOfShips:int;
		private var _ships:Vector.<ShipVO>;
		private var _starbaseID:String;
		private var _state:int;
		private var _sector:String;
		private var _sectorSpeed:Number                  = 0;

		//For new repair system
		private var _repairTimeRatingExponent:Number     = 0;
		private var _repairTimeRatingScale:Number        = 0;
		private var _repairTimeDamageExponent:Number     = 0;
		private var _repairResourceRatingExponent:Number = 0;
		private var _repairResourceRatingScale:Number    = 0;
		private var _repairResourceDamageExponent:Number = 0;
		private var _repairCreditsRatingExponent:Number  = 0;
		private var _repairCreditsRatingScale:Number     = 0;
		private var _repairCreditsDamageExponent:Number  = 0;
		
		// For new new repair system
		private var _repairTimeDamageAmountShift:Number		= 0;
		private var _repairTimeDamageScale:Number			= 0;
		private var _repairTimeDamageFactorShift:Number		= 0;
		private var _repairResourceDamageAmountShift:Number	= 0;
		private var _repairResourceDamageScale:Number		= 0;
		private var _repairResourceDamageFactorShift:Number	= 0;
		private var _repairCreditsDamageAmountShift:Number	= 0;
		private var _repairCreditsDamageScale:Number		= 0;
		private var _repairCreditsDamageFactorShift:Number	= 0;
		
		public function FleetVO()
		{
			_ships = new Vector.<ShipVO>(6, true);

			if (PrototypeModel.instance.getConstantPrototypeValueByName("isNewRepairSystemActive"))
			{
				_repairTimeRatingExponent = PrototypeModel.instance.getConstantPrototypeValueByName("RepairTimeRatingExponent");
				_repairTimeRatingScale = PrototypeModel.instance.getConstantPrototypeValueByName("RepairTimeRatingScale");
				_repairTimeDamageExponent = PrototypeModel.instance.getConstantPrototypeValueByName("RepairTimeDamageExponent");
				_repairResourceRatingExponent = PrototypeModel.instance.getConstantPrototypeValueByName("RepairResourceRatingExponent");
				_repairResourceRatingScale = PrototypeModel.instance.getConstantPrototypeValueByName("RepairResourceRatingScale");
				_repairResourceDamageExponent = PrototypeModel.instance.getConstantPrototypeValueByName("RepairResourceDamageExponent");
				_repairCreditsRatingExponent = PrototypeModel.instance.getConstantPrototypeValueByName("RepairCreditsRatingExponent");
				_repairCreditsRatingScale = PrototypeModel.instance.getConstantPrototypeValueByName("RepairCreditsRatingScale");
				_repairCreditsDamageExponent = PrototypeModel.instance.getConstantPrototypeValueByName("RepairCreditsDamageExponent");
			
			
				if (PrototypeModel.instance.getConstantPrototypeValueByName("useLogarithmicDamageScale"))
				{
					_repairTimeDamageAmountShift = PrototypeModel.instance.getConstantPrototypeValueByName("RepairTimeDamageAmountShift");
					_repairTimeDamageScale = PrototypeModel.instance.getConstantPrototypeValueByName("RepairTimeDamageScale");
					_repairTimeDamageFactorShift = PrototypeModel.instance.getConstantPrototypeValueByName("RepairTimeDamageFactorShift");
					_repairResourceDamageAmountShift = PrototypeModel.instance.getConstantPrototypeValueByName("RepairResourceDamageAmountShift");
					_repairResourceDamageScale = PrototypeModel.instance.getConstantPrototypeValueByName("RepairResourceDamageScale");
					_repairResourceDamageFactorShift = PrototypeModel.instance.getConstantPrototypeValueByName("RepairResourceDamageFactorShift");
					_repairCreditsDamageAmountShift = PrototypeModel.instance.getConstantPrototypeValueByName("RepairCreditsDamageAmountShift");
					_repairCreditsDamageScale = PrototypeModel.instance.getConstantPrototypeValueByName("RepairCreditsDamageScale");
					_repairCreditsDamageFactorShift = PrototypeModel.instance.getConstantPrototypeValueByName("RepairCreditsDamageFactorShift");
				}
			}
		}

		public function importData( fleetData:FleetData ):void
		{
			currentCargo = fleetData.currentCargo;
			_defendTarget = fleetData.defendTarget;
			_maxCargo = fleetData.cargoCapacity;
			_loadSpeed = fleetData.loadSpeed;
			currentHealth = fleetData.currentHealth;
			_id = fleetData.id;
			level = fleetData.level;
			_name = fleetData.name;
			ownerID = fleetData.ownerID;
			sector = fleetData.sector;
			sectorLocationX = fleetData.sectorLocationX;
			sectorLocationY = fleetData.sectorLocationY;
			_starbaseID = fleetData.starbaseID;
		}

		public function addShip( ship:ShipVO, index:uint ):Boolean
		{
			if (_ships[index] != ship)
			{
				_ships[index] = ship;
				ship.fleetOwner = id;
				updateFleetStats();
				return true;
			}
			return false;
		}

		public function removeShip( ship:ShipVO ):Boolean
		{
			for (var i:int = 0; i < _ships.length; i++)
			{
				if (_ships[i] == ship)
				{
					ship.fleetOwner = '';
					_ships[i] = null;
					updateFleetStats();
					return true
				}
			}
			return false;
		}

		public function updateFleetStats():void
		{
			_sectorSpeed = 0;
			_maxHealth = 1;
			_numOfShips = 0;
			_currentHealth = 0;
			_repairTime = 0;
			_damage = 0;
			_repairCreditCost = 0;
			_repairAlloyCost = 0;
			_repairEnergyCost = 0;
			_repairSyntheticCost = 0;
			_healthAmount = 0;
			_maxCargo = 0;
			_powerUsage = 0;
			var totalWeightedLoadSpeed:Number = 0.0;

			var len:uint                      = _ships.length;
			var currentShip:ShipVO;
			for (var i:uint = 0; i < len; ++i)
			{
				currentShip = _ships[i];
				if (currentShip)
				{
					if ((_sectorSpeed > currentShip.mapSpeed || _sectorSpeed == 0) && !isNaN(currentShip.mapSpeed))
						_sectorSpeed = currentShip.mapSpeed;

					_currentHealth += currentShip.currentHealth;
					//For New Repair System false
					if (!PrototypeModel.instance.getConstantPrototypeValueByName("isNewRepairSystemActive"))
					{
						_repairCreditCost += currentShip.repairCreditsCost;
						_repairAlloyCost += currentShip.repairAlloyCost;
						_repairEnergyCost += currentShip.repairEnergyCost;
						_repairSyntheticCost += currentShip.repairSyntheticCost;
						_repairTime += currentShip.currentRepairTime;
					}
					_damage += currentShip.shipDps;
					_healthAmount += currentShip.healthAmount;
					_powerUsage += currentShip.powerUsage;
					_maxCargo += currentShip.cargo;
					totalWeightedLoadSpeed += currentShip.loadSpeed * currentShip.cargo;

					++_numOfShips;
				}
			}

			if (_numOfShips > 0)
				_currentHealth /= _numOfShips;
			else
				_currentHealth = 1;

			//For New Repair System true
			// Total = RatingScale * ( e ^ ( Rating * RatingExponent ) )  * ( e ^ ( DamagePercent * DamageExponent ) )
			if (PrototypeModel.instance.getConstantPrototypeValueByName("isNewRepairSystemActive"))
			{	
				//For New New Repair System
				//Quantity = ( ( Ln( Damage + DamageAmountShift ) * DamageScale )  +  DamageFactorShift ) * ( TechScale * Exp( Rating * TechExponent ) )
				if (PrototypeModel.instance.getConstantPrototypeValueByName("useLogarithmicDamageScale")) 
				{	
					_repairCreditCost = ( ( Math.log((_maxHealth - _currentHealth) + _repairCreditsDamageAmountShift)
						* _repairCreditsDamageScale) + _repairCreditsDamageFactorShift) * (_repairCreditsRatingScale * Math.exp(this.level * _repairCreditsRatingExponent));
	
					if(_repairCreditCost < 0)
						_repairCreditCost = 0;
					
					_repairAlloyCost = ( ( Math.log((_maxHealth - _currentHealth) + _repairResourceDamageAmountShift)
						* _repairResourceDamageScale) + _repairResourceDamageFactorShift) * (_repairResourceRatingScale * Math.exp(this.level * _repairResourceRatingExponent));
					
					if(_repairAlloyCost < 0)
						_repairAlloyCost = 0;
					
					_repairEnergyCost = ( ( Math.log((_maxHealth - _currentHealth) + _repairResourceDamageAmountShift)
						* _repairResourceDamageScale) + _repairResourceDamageFactorShift) * (_repairResourceRatingScale * Math.exp(this.level * _repairResourceRatingExponent));
					
					if(_repairEnergyCost < 0)
						_repairEnergyCost = 0;
					
					_repairSyntheticCost = ( ( Math.log((_maxHealth - _currentHealth) + _repairResourceDamageAmountShift)
						* _repairResourceDamageScale) + _repairResourceDamageFactorShift) * (_repairResourceRatingScale * Math.exp(this.level * _repairResourceRatingExponent));
					
					if(_repairSyntheticCost < 0)
						_repairSyntheticCost = 0;
					
					_repairTime = ( ( Math.log((_maxHealth - _currentHealth) + _repairTimeDamageAmountShift)
						* _repairTimeDamageScale) + _repairTimeDamageFactorShift) * (_repairTimeRatingScale * Math.exp(this.level * _repairTimeRatingExponent));
					
					if(_repairTime < 0)
						_repairTime = 0;
				}
				else
				{
					_repairCreditCost = _repairCreditsRatingScale * (Math.exp(this.level * _repairCreditsRatingExponent)) * (Math.exp((_maxHealth - _currentHealth) * _repairCreditsDamageExponent));
					_repairAlloyCost = _repairResourceRatingScale * (Math.exp(this.level * _repairResourceRatingExponent)) * (Math.exp((_maxHealth - _currentHealth) * _repairResourceDamageExponent));
					_repairEnergyCost = _repairResourceRatingScale * (Math.exp(this.level * _repairResourceRatingExponent)) * (Math.exp((_maxHealth - _currentHealth) * _repairResourceDamageExponent));
					_repairSyntheticCost = _repairResourceRatingScale * (Math.exp(this.level * _repairResourceRatingExponent)) * (Math.exp((_maxHealth - _currentHealth) * _repairResourceDamageExponent));
					_repairTime = _repairTimeRatingScale * (Math.exp(this.level * _repairTimeRatingExponent)) * (Math.exp((_maxHealth - _currentHealth) * _repairTimeDamageExponent));
				}
			}
			
			// TODO - we need to update this if the buff expires
			_repairTime = StatCalcUtil.baseStatCalc("repairSpeed", _repairTime);
		}

		public function GetFleetHealthFromRepairTimeRemaining():Number
		{
			//                 /     time     \
			//             ln |  ------------- | - ratingExponent * rating
			// damage =        \  ratingScale /
			//           ----------------------------------------------------
			//                            damageExponent
			
			//Take care of floating point strangeness by multiplying value by 100 in the round then dividing by 100 to get 2 decimals
			if (PrototypeModel.instance.getConstantPrototypeValueByName("isNewRepairSystemActive"))
			{
				if (PrototypeModel.instance.getConstantPrototypeValueByName("useLogarithmicDamageScale")) 
				{
					return 1 - ( Math.exp( ( ( ( _repairTime ) * Math.exp( -this.level * _repairTimeRatingExponent ) )  / ( _repairTimeDamageScale
						* _repairTimeRatingScale ) ) - ( _repairTimeDamageFactorShift / _repairTimeDamageScale ) ) - _repairTimeDamageAmountShift );
				}
				else
					return Math.round(100 * (1 - ( ( Math.log( (_repairTime) /
						_repairTimeRatingScale ) - (_repairTimeRatingExponent * this.level) ) /	_repairTimeDamageExponent ))) / 100;
			}
			else
				return (_maxHealth - _currentHealth);
			
			
		}
		
		public function getShipIndexByID( id:String ):int
		{
			for (var i:int = 0; i < _ships.length; i++)
			{
				if (_ships[i] && _ships[i].id == id)
					return i;
			}
			return -1;
		}

		public function getShipIDByIndex( index:int ):String
		{
			if (index < _ships.length && _ships[index] != null)
				return _ships[index].id;
			return null;
		}

		public function getValue( key:String ):*  { return null; }
		public function getUnsafeValue( key:String ):*  { return null; }

		public function get asset():String
		{
			var fleetType:String = '';
			var len:uint         = _ships.length;
			for (var i:uint = 0; i < len; ++i)
			{
				if (_ships[i] != null)
				{
					fleetType = _ships[i].prototypeVO.asset;
					break;
				}
			}

			return fleetType;
		}

		public function get cargoPercent():Number  { return _maxCargo ? int(currentCargo / _maxCargo * 100) : 0; }
		public function get currentHealth():Number  { return _currentHealth; }
		public function set currentHealth( curHealth:Number ):void  { _currentHealth = curHealth; }
		public function get healthAmount():Number  { return _healthAmount; }
		public function get damage():int  { return _damage; }
		public function get defendTarget():String  { return _defendTarget; }
		public function set defendTarget( v:String ):void  { _defendTarget = v; }
		public function get fleetGroupData():Object  { return _fleetGroupData; }
		public function get itemClass():String  { return ''; }
		public function get id():String  { return _id; }
		public function get loadSpeed():Number  { return _loadSpeed; }
		public function get maxCargo():int  { return _maxCargo; }
		public function get maxHealth():int  { return _maxHealth; }
		public function get powerUsage():Number  { return _powerUsage; }
		public function get name():String  { return _name; }
		public function set name( v:String ):void  { _name = v; }
		public function get needsRepair():Boolean  { return (_numOfShips > 0) ? _currentHealth < 1.0 : false; }
		public function get numOfShips():int  { return _numOfShips; }
		public function get repairTime():int  { return _repairTime; }
		public function get ships():Vector.<ShipVO>  { return _ships; }
		public function get state():int  { return _state; }
		public function set state( state:int ):void  { _state = state; }
		public function get uiAsset():String  { return ''; }
		public function get sectorSpeed():Number  { return _sectorSpeed; }
		public function get starbaseID():String  { return _starbaseID; }

		public function get sector():String  { return _sector; }
		public function set sector( sector:String ):void
		{
			_sector = sector;
			if (_sector == '' || _sector == null)
				state = FleetStateEnum.DOCKED;
		}

		public function get alloyCost():int  { return _repairAlloyCost; }
		public function get creditsCost():int  { return _repairCreditCost; }
		public function get energyCost():int  { return _repairEnergyCost; }
		public function get syntheticCost():int  { return _repairSyntheticCost; }

		public function get buildTimeSeconds():uint  { return _repairTime; }

		public function destroy():void
		{
		}
	}
}
