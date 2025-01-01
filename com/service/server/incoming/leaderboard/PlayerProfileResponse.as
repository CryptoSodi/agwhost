package com.service.server.incoming.leaderboard
{
	import com.model.player.PlayerVO;
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class PlayerProfileResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;

		public var players:Vector.<PlayerVO>;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			var currentPlayer:PlayerVO;
			players = new Vector.<PlayerVO>;
			var num:int = input.readUnsignedInt();
			for (var idx:int = 0; idx < num; ++idx)
			{
				currentPlayer = new PlayerVO();
				input.checkToken();
				currentPlayer.id = input.readUTF(); // playerKey
				currentPlayer.name = input.readUTF(); // name
				currentPlayer.avatarName = input.readUTF(); // racePrototype
				currentPlayer.faction = input.readUTF(); //factionPrototype
				currentPlayer.xp = input.readInt64(); // experience
				currentPlayer.commendationPointsPVE = input.readInt64(); // commendiation points pve
				currentPlayer.commendationPointsPVP = input.readInt64(); // commendiation points pvp
				currentPlayer.wins = input.readInt64(); // wins
				currentPlayer.losses = input.readInt64(); // losses
				currentPlayer.draws = input.readInt64(); // draws
				currentPlayer.lastOnline = input.readInt64(); // last online utc millis
				currentPlayer.baseRating = input.readInt(); // baseRating
				currentPlayer.baseSector = input.readUTF(); // baseSector
				currentPlayer.baseXPos = input.readDouble(); // sectorX
				currentPlayer.baseYPos = input.readDouble(); // sectorY
				currentPlayer.alliance = input.readUTF(); // allianceKey
				currentPlayer.allianceName = input.readUTF(); // allianceName
				currentPlayer.isAllianceOpen = input.readBoolean(); // alliance is public
				input.checkToken();
				players.push(currentPlayer);
			}
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON is not supported");
		}

		public function get isTicked():Boolean  { return false; }

		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }

		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }

		public function destroy():void
		{
			players = null;
		}
	}
}
