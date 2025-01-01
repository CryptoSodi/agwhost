package com.service.server.incoming.data
{
	import com.model.player.PlayerVO;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.battle.BattleDataResponse;
	import com.service.server.incoming.battle.BattleParticipantInfo;
	import com.service.server.replicable.ReplicableSet;
	import com.service.server.replicable.ReplicableStruct;

	import flash.utils.Dictionary;

	import org.shared.ObjectPool;

	public class BattleData extends ReplicableStruct implements IResponse
	{
		public static var globalInstance:BattleData          = new BattleData;

		public var tick:int;
		public var timeStep:int;

		public var hasBeenBaselined:Boolean                  = false;

		// serialized data
		public var activeSplitPrototypes:Vector.<String>     = new Vector.<String>;
		public var battleKey:String;
		public var sector:SectorData;
		
		public var maxSizeX:int;
		public var maxSizeY:int;
		
		public var galacticName:String;
		public var backgroundId:int;
		public var planetId:int;
		public var moonQuantity:int;
		public var asteroidQuantity:int;
		public var appearanceSeed:int;
		
		
		public var battleStartTick:int;
		public var battleEndTick:int;
		public var loadTimeoutTick:int;
		public var _battleState:int;
		public var battleStateChanged:Boolean;
		public var isBaseCombat:Boolean;
		public var isInstancedMission:Boolean;
		public var baseOwner:String;
		public var alloy:Number;
		public var synthetic:Number;
		public var energy:Number;
		public var credits:Number;
		public var missionPersistence:String;
		public var players:ReplicableSet                     = new ReplicableSet;
		public var entities:ReplicableSet                    = new ReplicableSet;
		public var deadEntities:ReplicableSet                = new ReplicableSet;
		public var areaAttacks:ReplicableSet                 = new ReplicableSet;
		public var beamAttacks:ReplicableSet                 = new ReplicableSet;
		public var droneAttacks:ReplicableSet                = new ReplicableSet;
		public var projectileAttacks:ReplicableSet           = new ReplicableSet;
		public var participants:ReplicableSet                = new ReplicableSet;

		public var areaAttackHits:Vector.<AreaAttackHitData> = new Vector.<AreaAttackHitData>;
		public var adMisses:Array; // unused for now
		public var adHits:Object                             = new Object();

		public function readAreaAttackHits( input:BinaryInputStream ):Vector.<AreaAttackHitData>
		{
			areaAttackHits.length = 0;
			var numAreaCollisions:int = input.readUnsignedInt();
			for (var i:int = 0; i < numAreaCollisions; i++)
			{
				input.checkToken();
				//Data on area attacks that have made contact, do something with this too.
				var data:AreaAttackHitData = ObjectPool.get(AreaAttackHitData);
				data.attackId = "Attack" + input.readUnsignedInt();
				data.target = input.readUTF();
				data.locationX = input.readDouble();
				data.locationY = input.readDouble();
				areaAttackHits.push(data);
				input.checkToken();
			}
			return areaAttackHits;
		}

		public function readADMisses( input:BinaryInputStream ):void
		{
			var numADMisses:int = input.readUnsignedInt();
			for (var i:int = 0; i < numADMisses; i++)
			{
				//Target here may not be unique, multiple attempts may have been made on the same target.
				//In C++-land this is a vector of target/attachPoint/owningShip objects
				var target:uint    = input.readUnsignedInt();
				var attachPoint:String = input.readUTF();
				var owningShip:String = input.readUTF();
			}
		}

		public function readADHits( input:BinaryInputStream ):Object
		{
			var adHit:ActiveDefenseHitData;
			var numADHits:int = input.readUnsignedInt();
			for (var i:int = 0; i < numADHits; i++)
			{
				adHit = ObjectPool.get(ActiveDefenseHitData);
				adHit.read(input);
				if (adHit.attachPoint != "")
					adHits[adHit.target] = adHit;
				else
					ObjectPool.give(adHit);
			}
			return adHits;
		}

		public function decodeResponse( response:BattleDataResponse ):int
		{
			// clear out old deltas
			battleStateChanged = false;
			players.resetDeltas();
			for (var i:int = 0; i < entities.modified.length; ++i)
			{
				entities.modified[i].resetDeltas();
			}
			entities.resetDeltas();

			deadEntities.resetDeltas();
			areaAttacks.resetDeltas();
			beamAttacks.resetDeltas();
			droneAttacks.resetDeltas();
			projectileAttacks.resetDeltas();
			participants.resetDeltas();
			areaAttackHits.length = 0;
			adMisses = null;

			// start reading stuff
			tick = response.tick;
			timeStep = response.timeStep;
			if (response.isBaseline)
			{
				response.input.readStringCacheBaseline();
			}
			decode(response.input);
			response.input.readUnsignedInt(); // this is the data modification number, which the flash client doesn't (yet) track
			return 0;
		}


		private function readPlayerKey( input:BinaryInputStream ):String
		{
			return input.readUTF();
		}

		private function readAttackKey( input:BinaryInputStream ):int
		{
			return input.readInt();
		}

		private function readRemovedObjectData( input:BinaryInputStream ):RemovedObjectData
		{
			var removedData:RemovedObjectData = ObjectPool.get(RemovedObjectData);
			removedData.read(input);
			return removedData;
		}

		private function readRemovedAttackData( input:BinaryInputStream ):RemovedAttackData
		{
			var removedData:RemovedAttackData = ObjectPool.get(RemovedAttackData);
			removedData.read(input);
			return removedData;
		}

		public function BattleData()
		{
			players.readKey = readPlayerKey;
			players.readRemove = readRemovedObjectData;
			players.elementType = PlayerVO;

			entities.readKey = readPlayerKey;
			entities.readRemove = readRemovedObjectData;
			entities.elementType = BattleEntityData;

			deadEntities.readKey = readPlayerKey;
			deadEntities.readRemove = readRemovedObjectData;
			deadEntities.elementType = BattleEntityData;

			areaAttacks.readKey = readAttackKey;
			areaAttacks.readRemove = readRemovedAttackData;
			areaAttacks.elementType = AreaAttackData;

			beamAttacks.readKey = readAttackKey;
			beamAttacks.readRemove = readRemovedAttackData;
			beamAttacks.elementType = BeamAttackData;

			droneAttacks.readKey = readAttackKey;
			droneAttacks.readRemove = readRemovedAttackData;
			droneAttacks.elementType = DroneAttackData;

			projectileAttacks.readKey = readAttackKey;
			projectileAttacks.readRemove = readRemovedAttackData;
			projectileAttacks.elementType = ProjectileAttackData;

			participants.readKey = readPlayerKey;
			participants.readRemove = null; // participants are never removed
			participants.elementType = BattleParticipantInfo;
		}

		override public function read( input:BinaryInputStream ):void
		{
			hasBeenBaselined = true;

			input.checkToken();


			var activeSplit:String;
			var numSplits:int = input.readUnsignedInt();
			for (var i:int = 0; i < numSplits; ++i)
			{
				activeSplit = input.readUTF(); // split test prototype
				if (activeSplit != '')
					activeSplitPrototypes.push(activeSplit);
			}

			sector = ObjectPool.get(SectorData);
			sector.id = input.readUTF();
			sector.prototype = PrototypeModel.instance.getSectorPrototypeByName(input.readUTF());
			sector.appearanceSeed = input.readInt();
			maxSizeX = input.readInt();
			maxSizeY = input.readInt();
			
			galacticName = input.readUTF();
			backgroundId = input.readInt();
			planetId = input.readInt();
			moonQuantity = input.readInt();
			asteroidQuantity = input.readInt();
			appearanceSeed = input.readInt64();
			
			battleStartTick = input.readInt();
			battleEndTick = input.readInt();
			loadTimeoutTick = input.readInt();
			battleState = input.readInt();
			isBaseCombat = input.readBoolean();
			isInstancedMission = input.readBoolean();
			baseOwner = input.readUTF();
			alloy = input.readInt64();
			synthetic = input.readInt64();
			energy = input.readInt64();
			credits = input.readInt64();
			missionPersistence = input.readUTF();
			players.read(input);
			entities.read(input);
			deadEntities.read(input);
			areaAttacks.read(input);
			beamAttacks.read(input);
			droneAttacks.read(input);
			input.checkToken();
			projectileAttacks.read(input);
			input.checkToken();

			participants.read(input);
			readAreaAttackHits(input);
			readADMisses(input);
			readADHits(input);

			input.checkToken();
		}

		public function readVictors( input:BinaryInputStream ):Dictionary
		{
			var victors:Dictionary = new Dictionary();
			var numVictors:int     = input.readUnsignedInt();
			for (var i:int = 0; i < numVictors; i++)
			{
				var key:String = input.readUTF();
				victors[key] = true;
			}
			return victors;
		}

		public static var _propertyNames:Vector.<String>     = new <String>[
			"battleStartTick", // 0
			"battleEndTick", // 1
			"battleState", // 2
			"players", // 3
			"entities", // 4
			"deadEntities", // 5
			"areaAttacks", // 6
			"beamAttacks", // 7
			"droneAttacks", // 8
			"projectileAttacks", // 9
			"participants", // 10
			"areaAttackHits", // 11
			"adMisses", // 12
			"adHits" // 13
			];

		public static var _propertyReaders:Vector.<String>   = new <String>[
			"readInt", // 0
			"readInt", // 1
			"readInt", // 2
			null, // 3
			null, // 4
			null, // 5
			null, // 6
			null, // 7
			null, // 8
			null, // 9
			null, // 10
			"readAreaAttackHits", // 11
			"readADMisses", // 12
			"readADHits", // 13
			];

		override public function get propertyNames():Vector.<String>
		{
			return _propertyNames;
		}
		override public function get propertyReaders():Vector.<String>
		{
			return _propertyReaders;
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in BattleBaselineResponse is not supported");
		}


		public function get battleState():int
		{
			return _battleState;
		}

		public function set battleState( newState:int ):void
		{
			_battleState = newState;
			battleStateChanged = true;
		}

		public function get isTicked():Boolean  { return false; }

		public function get header():int
		{
			throw new Error("header in BattleData is not supported");
			return 0;
		}

		public function set header( v:int ):void  {}

		public function get protocolID():int
		{
			throw new Error("protocolID in BattleData is not supported");
			return 0;
		}

		public function set protocolID( v:int ):void  {}

		public function destroy():void
		{
			hasBeenBaselined = false;
			if (sector)
				ObjectPool.give(sector);
			sector = null;

			for (var i:int = 0; i < entities.length; i++)
				ObjectPool.give(entities[i]);
			entities.length = 0;

			for (i = 0; i < deadEntities.length; i++)
				ObjectPool.give(deadEntities[i]);
			deadEntities.length = 0;

			for (var id:String in adHits)
			{
				ObjectPool.give(adHits[id]);
				delete adHits[id];
			}
			players.length = 0;
			for (i = 0; i < areaAttacks.length; i++)
				ObjectPool.give(areaAttacks[i]);
			areaAttacks.length = 0;
			for (i = 0; i < beamAttacks.length; i++)
				ObjectPool.give(beamAttacks[i]);
			beamAttacks.length = 0;
			for (i = 0; i < droneAttacks.length; i++)
				ObjectPool.give(droneAttacks[i]);
			droneAttacks.length = 0;
			for (i = 0; i < projectileAttacks.length; i++)
				ObjectPool.give(projectileAttacks[i]);
			projectileAttacks.length = 0;
			for (i = 0; i < participants.length; i++)
				ObjectPool.give(participants[i]);
			participants.length = 0;
		}
	}
}

