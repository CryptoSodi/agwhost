package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	
	public class LeaderboardPlayerData implements IServerData
	{
		public var playerKey:String;
		public var name:String;
		public var racePrototype:String;
		public var experience:uint;
		public var commendationPointsPvE:uint;
		public var commendationPointsPvP:uint;
		public var wins:uint;
		public var losses:uint;
		public var draws:uint;
		public var allianceKey:String;
		public var allianceName:String;
		public var sectorOwner:String;
		public var baseRating:Number;
		public var highestFleetRating:int;
		public var blueprintPartsCollected:int;
		public var baseRatingRank:int;
		public var experienceRank:int;
		public var commendiationCombinedRank:int;
		public var winsRank:int;
		public var kdrRank:int;
		public var highestFleetRank:int;
		public var blueprintPartsRank:int;
		
		public var qualifiedWinsPvP:Number;
		public var BubbleHoursGranted:Number;
		public var currentPVPEvent:Number;
		public var currentPVPEventQuarter:Number;
		public var CreditsTradeRoute:Number;
		public var ResourcesTradeRoute:Number;
		public var ResourcesSalvaged:Number;
		public var CreditsBounty:Number;
		public var WinsVsBase:Number;
		
		public var qualifiedWinsPvPRank:int;
		public var BubbleHoursGrantedRank:int;
		public var currentPVPEventRank:int;
		public var currentPVPEventQuarterRank:int;
		public var CreditsTradeRouteRank:int;
		public var ResourcesTradeRouteRank:int;
		public var ResourcesSalvagedRank:int;
		public var CreditsBountyRank:int;
		public var WinsVsBaseRank:int;
		
		public function read(input:BinaryInputStream):void
		{
			input.checkToken();
			input.checkToken();
			playerKey = input.readUTF(); // playerKey
			input.checkToken();
			name = input.readUTF(); // name
			
			
			
			racePrototype = input.readUTF(); // racePrototype
			experience = input.readInt64(); // experience
			commendationPointsPvE = input.readInt64();  // commendiation points pve
			commendationPointsPvP = input.readInt64();  // commendiation points pvp
			wins = input.readInt64(); // wins
			losses = input.readInt64(); // losses
			draws = input.readInt64(); // draws
			qualifiedWinsPvP = input.readInt64(); 
			BubbleHoursGranted = input.readInt64();
			currentPVPEvent = input.readInt64();
			currentPVPEventQuarter = input.readInt64();
			CreditsTradeRoute = input.readInt64();
			ResourcesTradeRoute = input.readInt64();
			ResourcesSalvaged = input.readInt64();
			CreditsBounty = input.readInt64();
			WinsVsBase = input.readInt64();
			
			allianceKey = input.readUTF(); // alliance key
			allianceName = input.readUTF(); // alliance name
			sectorOwner = input.readUTF();
			baseRating = input.readInt(); // baseRating
			highestFleetRating = input.readInt();
			blueprintPartsCollected = input.readInt();
			baseRatingRank = input.readInt();
			experienceRank = input.readInt();
			commendiationCombinedRank = input.readInt();
			winsRank = input.readInt();
			kdrRank = input.readInt();
			highestFleetRank = input.readInt();
			blueprintPartsRank = input.readInt();
			
			qualifiedWinsPvPRank = input.readInt(); 
			BubbleHoursGrantedRank = input.readInt();
			currentPVPEventRank = input.readInt();
			currentPVPEventQuarterRank = input.readInt();
			CreditsTradeRouteRank = input.readInt();
			ResourcesTradeRouteRank = input.readInt();
			ResourcesSalvagedRank = input.readInt();
			CreditsBountyRank = input.readInt();
			WinsVsBaseRank = input.readInt();
			
			input.checkToken();
		}
		
		public function readJSON(data:Object):void
		{
			throw new Error("readJSON is not supported");
		}
		
		public function destroy():void
		{
		}
	}
}