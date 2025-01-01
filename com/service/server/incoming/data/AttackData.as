package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	import com.service.server.replicable.ReplicableStruct;

	import flash.geom.Point;

	public class AttackData extends ReplicableStruct implements IServerData
	{
		public var playerOwnerId:String;
		public var entityOwnerId:String;
		public var id:int; // raw int Id used by replication
		private var _attackId:String; // "Attack" prefixed Id used externally
		public var start:Point;
		public var startTick:int;
		public var subsystemTarget:int;
		public var targetPointIndex:int;
		public var targetEntityId:String;
		public var weaponPrototype:String;
		public var location:Point;
		public var _rotation:Number;

		public override function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			playerOwnerId = input.readUTF();
			entityOwnerId = input.readUTF();
			id = input.readUnsignedInt();
			attackId = String(id);
			start = readLocation(input);
			startTick = input.readInt();
			targetEntityId = input.readUTF();
			weaponPrototype = input.readUTF();
			subsystemTarget = input.readInt();
			rotation = input.readUnsignedByte();
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
		}

		public function destroy():void
		{

		}

		public function set rotation( value256:Number ):void
		{
			_rotation = value256 * Math.PI / 128;
		}

		public function get rotation():Number
		{
			return _rotation;
		}

		public function set attackId( value:String ):void
		{
			_attackId = "Attack" + value;
		}

		public function get attackId():String
		{
			return _attackId;
		}


	}
}
