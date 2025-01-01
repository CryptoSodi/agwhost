package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class SectorEntityData implements IServerData
	{
		public var id:String;
		public var ownerId:String;
		public var name:String;
		public var type:int;
		public var state:int;
		public var locationX:Number;
		public var locationY:Number;
		public var travelSpeed:int          = 10;
		public var currentHealthPct:Number;
		public var shipPrototype:String;
		public var factionPrototype:String;
		public var bubbled:Boolean;
		public var mission:Boolean;
		public var isPositiveWarp:Boolean;
		public var level:Number;
		public var cargo:Number;
		public var cloaked:Boolean;
		public var eventSpawn:Boolean;
		public var alertSector:Boolean;
		public var baseRatingTech:Number;
		public var maxPlayersPerFaction:Number;
		public var additionalInfo:String;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			id = input.readUTF();
			ownerId = input.readUTF();
			name = input.readUTF();
			type = input.readInt();
			state = input.readInt();
			locationX = input.readDouble();
			locationY = input.readDouble();
			travelSpeed = input.readDouble();
			currentHealthPct = input.readDouble();
			shipPrototype = input.readUTF();
			factionPrototype = input.readUTF();
			bubbled = input.readBoolean();
			mission = input.readBoolean();
			isPositiveWarp = input.readBoolean();
			level = input.readInt64();
			cargo = input.readInt64();
			cloaked = input.readBoolean();
			eventSpawn = input.readBoolean();
			alertSector = input.readBoolean();
			baseRatingTech = input.readInt64();
			maxPlayersPerFaction = input.readInt();
			additionalInfo = input.readUTF();
			var numChargeups:int    = input.readUnsignedInt();
			for (var i:int = 0; i < numChargeups; i++)
			{
				var orderType:int = input.readInt();
				input.checkToken();
				var startTick:int = input.readInt();
				var endTick:int   = input.readInt();
				input.checkToken();
			}
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
		}

		public function destroy():void
		{
		}
	}
}
