package com.service.server.incoming.data
{
	import com.enum.FactionEnum;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.service.server.BinaryInputStream;

	public class SectorBattleData implements IServerData
	{
		public var id:String;
		public var locationX:Number;
		public var locationY:Number;
		public var mapSizeX:int;
		public var mapSizeY:int;
		public var participantPlayers:Array = [];
		public var participantFleets:Array  = [];
		public var participantBase:String;
		public var observerIds:Array        = [];
		public var serverIdentifier:String;
		public var joinable:Boolean;
		public var maxPlayersPerFaction:int;
		public var maxFactions:int;
		public var pvp:int;
		public var firstJoiningFactionPrototype:String;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			id = input.readUTF();
			locationX = input.readDouble();
			locationY = input.readDouble();
			
			mapSizeX = input.readInt();
			mapSizeY = input.readInt();

			var numParticipants:int = input.readUnsignedInt();
			var playerId:String;
			var currentUser:PlayerVO;
			for (var i:int = 0; i < numParticipants; i++)
			{
				playerId = input.readUTF();
				participantPlayers.push(playerId);
			}

			numParticipants = input.readUnsignedInt();
			for (i = 0; i < numParticipants; i++)
			{
				participantFleets.push(input.readUTF());
			}

			participantBase = input.readUTF();

			var numObservers:int    = input.readUnsignedInt();
			for (i = 0; i < numObservers; i++)
			{
				observerIds.push(input.readUTF());
			}
			serverIdentifier = input.readUTF();
			joinable = input.readBoolean();
			maxPlayersPerFaction = input.readUnsignedShort();
			maxFactions = input.readUnsignedShort();
			input.readUTF();
			pvp = input.readInt64();
			firstJoiningFactionPrototype = input.readUTF();
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
		public function destroy():void
		{
			participantPlayers.length = 0;
			participantFleets.length = 0;
			observerIds.length = 0;
		}
	}
}
