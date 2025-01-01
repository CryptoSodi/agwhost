package com.service.server.incoming.data
{
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;
	import com.service.server.replicable.ReplicableStruct;
	import com.service.server.replicable.ReplicableVector;
	import com.service.server.incoming.data.DebuffMapByType;

	import flash.geom.Point;

	import org.shared.ObjectPool;

	public class BattleEntityData extends ReplicableStruct implements IServerData
	{
		public var id:String;
		public var ownerId:String;
		public var factionId:String;
		public var type:int;

		public var _location:Point                         = new Point();
		public var gridLocationX:int;
		public var gridLocationY:int;
		public var targetLocation:Point                    = new Point();
		public var _rotation:Number; // float
		public var _velocity:Point                         = new Point();
		public var currentHealth:int;
		public var maxHealth:int;
		public var organicTargetId:String;
		public var radius:int;
		public var selectedTargetId:String;
		public var shieldsEnabled:Boolean;
		public var shieldsCurrentHealth:int;
		public var currentTargetId:String;
		public var subsystemTarget:int;

		public var shipPrototype:IPrototype;
		public var buildingPrototype:IPrototype;
		public var factionPrototype:String;

		public var debuffs:DebuffMapByType                 = new DebuffMapByType;

		private var _connectedPylons:Vector.<String>;
		private var _modules:Vector.<ModuleData>;
		private var _subsystems:Vector.<SubsystemData>;
		private var _weapons:ReplicableVector; // just the weapons portion of _modules
		private var _activeDefenses:ReplicableVector; // just the active defenses portion of _modules

		public function get rotation():Number
		{
			return _rotation;
		}

		public function set rotation( rot360:Number ):void
		{
			_rotation = rot360 * Math.PI / 180;
		}

		public function get velocity():Point
		{
			return _velocity;
		}

		public function set velocity( newVel:Point ):void
		{
			_velocity = newVel;
			//trace( "set velocity for "+id+" to "+String(newVel) );
		}

		public function get location():Point
		{
			return _location;
		}

		public function set location( newVel:Point ):void
		{
			_location = newVel;
			//trace( "set location for "+id+" to "+String(newVel) );
		}

		override public function decode( input:BinaryInputStream ):int
		{
			//trace( "decoding changes for "+id );
			return super.decode(input);
		}


		public function BattleEntityData()
		{
			_connectedPylons = new Vector.<String>;
			_modules = new Vector.<ModuleData>;
			_weapons = new ReplicableVector;
			_weapons.elementType = WeaponData;
			_activeDefenses = new ReplicableVector;
			_activeDefenses.elementType = ActiveDefenseData;
			_subsystems = new Vector.<SubsystemData>;
		}

		public override function read( input:BinaryInputStream ):void
		{
			var pm:PrototypeModel = PrototypeModel.instance;
			input.checkToken();
			id = input.readUTF();
			ownerId = input.readUTF();
			factionId = input.readUTF();
			type = input.readInt();
			location = readLocation(input);
			gridLocationX = input.readInt();
			gridLocationY = input.readInt();
			targetLocation = readLocation(input);
			//targetRotation = input.readDouble();
			rotation = input.readFloat();
			velocity = readLocation(input);
			radius = input.readDouble();
			currentHealth = input.readInt();
			if (currentHealth < 0)
				currentHealth = 0;
			maxHealth = input.readInt();
			shieldsEnabled = input.readBoolean();
			shieldsCurrentHealth = input.readInt();
			selectedTargetId = input.readUTF();
			organicTargetId = input.readUTF();
			subsystemTarget = input.readInt();
			//executingPlayerMoveOrder = input.readBoolean();
			shipPrototype = pm.getShipPrototype(input.readUTF());
			buildingPrototype = pm.getBuildingPrototype(input.readUTF());
			factionPrototype = input.readUTF();
			//shipPersistence = input.readUTF();
			//buildingPersistence = input.readUTF();
			basicModules = input;
			weaponsTemp = input;
			activeDefensesTemp = input;
			subsystems = input;

			var numPylons:int     = input.readUnsignedInt();
			for (var i:int = 0; i < numPylons; i++)
			{
				_connectedPylons.push(input.readUTF());
			}
			//orbitingDrones 
			//minRange = input.readDouble();
			//maxRange = input.readDouble();
			debuffs.read(input);
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			for (var key:String in data)
			{
				if (this.hasOwnProperty(key))
				{
					this[key] = data[key];
				} else
				{
					// TODO - complain about missing key?
				}
			}
		}

		public static var _propertyNames:Vector.<String>   = new <String>[
			"location", // 0
			"targetLocation", // 1
			"rotation", // 2
			"velocity", // 3
			"radius", // 4
			"currentHealth", // 5
			"maxHealth", // 6
			"shieldsEnabled", // 7
			"selectedTargetId", // 8
			"organicTargetId", // 9
			"shieldsCurrentHealth", // 10
			"weapons", // 11
			"activeDefenses", // 12
			"debuffs", // 13
			];


		public static var _propertyReaders:Vector.<String> = new <String>[
			"readLocation", // 0
			"readLocation", // 1
			"readFloat", // 2
			"readLocation", // 3
			"readFloat", // 4
			"readInt", // 5
			"readInt", //6
			"readBoolean", // 7
			"readUTF", // 8
			"readUTF", // 9
			"readInt", // 10
			];

		override public function get propertyNames():Vector.<String>
		{
			return _propertyNames;
		}
		override public function get propertyReaders():Vector.<String>
		{
			return _propertyReaders;
		}

		override public function resetDeltas():void
		{
			_weapons.resetDeltas();
			_activeDefenses.resetDeltas();
			debuffs.resetDeltas();
		}

		public function get activeDefenses():ReplicableVector  { return _activeDefenses; }
		public function set activeDefensesTemp( data:* ):void
		{
			var obj:IServerData;
			if (data is BinaryInputStream)
			{
				var num:int = data.readUnsignedInt();
				for (var i:int = 0; i < num; i++)
				{
					obj = ObjectPool.get(ActiveDefenseData);
					obj.read(data);
					_modules.push(obj);
					_activeDefenses.push(obj);
				}
			} else
			{
				for (var key:String in data)
				{
					obj = ObjectPool.get(ActiveDefenseData);
					obj.readJSON(data[key]);
					_modules.push(obj);
					_activeDefenses.push(obj);
				}
			}
		}
		public function set basicModules( data:* ):void
		{
			var obj:IServerData;
			if (data is BinaryInputStream)
			{
				var num:int = data.readUnsignedInt();
				for (var i:int = 0; i < num; i++)
				{
					obj = ObjectPool.get(ModuleData);
					obj.read(data);
					_modules.push(obj);
				}
			} else
			{
				for (var key:String in data)
				{
					obj = ObjectPool.get(ModuleData);
					obj.readJSON(data[key]);
					_modules.push(obj);
				}
			}
		}
		public function get connectedPylons():Vector.<String>  { return _connectedPylons; }
		public function get modules():Vector.<ModuleData>  { return _modules; }

		public function get weapons():ReplicableVector  { return _weapons; }
		public function set weaponsTemp( data:* ):void
		{
			var obj:IServerData;
			if (data is BinaryInputStream)
			{
				var num:int = data.readUnsignedInt();
				for (var i:int = 0; i < num; i++)
				{
					obj = ObjectPool.get(WeaponData);
					obj.read(data);
					_modules.push(obj);
					_weapons.push(obj);
				}
			} else
			{
				for (var key:String in data)
				{
					obj = ObjectPool.get(WeaponData);
					obj.readJSON(data[key]);
					_modules.push(obj);
					_weapons.push(obj);
				}
			}
		}
		public function get subsystemsList():Vector.<SubsystemData>  { return _subsystems; }
		public function set subsystems( data:* ):void
		{
			var obj:IServerData;
			if (data is BinaryInputStream)
			{
				var num:int = data.readUnsignedInt();
				for (var i:int = 0; i < num; i++)
				{
					obj = ObjectPool.get(SubsystemData);
					obj.read(data);
					_subsystems.push(obj);
				}
			} else
			{
				for (var key:String in data)
				{
					obj = ObjectPool.get(SubsystemData);
					obj.readJSON(data[key]);
					_subsystems.push(obj);
				}
			}
		}

		public function destroy():void
		{
			buildingPrototype = null;
			shipPrototype = null;
			for (var i:int = 0; i < _modules.length; i++)
			{
				ObjectPool.give(_modules[i]);
			}
			_modules.length = 0;
			for (i = 0; i < _subsystems.length; i++)
			{
				ObjectPool.give(_subsystems[i]);
			}
			_subsystems.length = 0;
			_connectedPylons.length = 0;
		}
	}
}
