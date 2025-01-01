package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	
	public class LeaderboardAllianceData implements IServerData
	{
		public var key:String;
		public var name:String;
		public var factionPrototype:String;
		public var publicAlliance:Boolean;
		public var numMembers:int;
		public var totalCommendationPointsPvE:uint;
		public var totalCommendationPointsPvP:uint;
		public var totalWins:uint;
		public var totalLosses:uint;
		
		public var totalHighestFleetRating:Number;
		public var avgHighestFleetRating:Number;
		public var totalBlueprintPartsCollected:Number;
		
		public var totalRating:Number;
		public var avgRating:Number;
		public var totalExperience:Number;
		
		public var numMembersRank:int;
		public var totalBaseRatingRank:int;
		public var avgBaseRatingRank:int;
		public var totalExperienceRank:int;
		public var totalCommendiationCombinedRank:int;
		public var totalWinsRank:int;
		public var totalKdrRank:int;
		public var totalHighestFleetRank:int;
		public var avgHighestFleetRank:int;
		public var totalBlueprintPartsRank:int;
		
		public var totalqualifiedWinsPvP:Number;
		public var totalBubbleHoursGranted:Number;
		public var totalcurrentPVPEvent:Number;
		public var totalcurrentPVPEventQuarter:Number;
		public var totalCreditsTradeRoute:Number;
		public var totalResourcesTradeRoute:Number;
		public var totalResourcesSalvaged:Number;
		public var totalCreditsBounty:Number;
		public var totalWinsVsBase:Number;
		
		public var totalqualifiedWinsPvPRank:int;
		public var totalBubbleHoursGrantedRank:int;
		public var totalcurrentPVPEventRank:int;
		public var totalcurrentPVPEventQuarterRank:int;
		public var totalCreditsTradeRouteRank:int;
		public var totalResourcesTradeRouteRank:int;
		public var totalResourcesSalvagedRank:int;
		public var totalCreditsBountyRank:int;
		public var totalWinsVsBaseRank:int;
		
		public function read(input:BinaryInputStream):void
		{
			input.checkToken();
			input.checkToken();
			key = input.readUTF(); // playerKey
			input.checkToken();
			name = input.readUTF(); // name
			factionPrototype = input.readUTF();
			publicAlliance = input.readBoolean();
			numMembers = input.readInt();
			totalRating = input.readInt();
			avgRating = input.readDouble();
			totalExperience = input.readInt64();
			totalCommendationPointsPvE = input.readInt64();
			totalCommendationPointsPvP = input.readInt64();
			totalWins = input.readInt64();
			totalLosses = input.readInt64();
			totalHighestFleetRating = input.readInt64();
			avgHighestFleetRating = input.readDouble();
			totalBlueprintPartsCollected = input.readInt64();
			
			totalqualifiedWinsPvP = input.readInt64(); 
			totalBubbleHoursGranted = input.readInt64();
			totalcurrentPVPEvent = input.readInt64();
			totalcurrentPVPEventQuarter = input.readInt64();
			totalCreditsTradeRoute = input.readInt64();
			totalResourcesTradeRoute = input.readInt64();
			totalResourcesSalvaged = input.readInt64();
			totalCreditsBounty = input.readInt64();
			totalWinsVsBase = input.readInt64();
			
			numMembersRank = input.readInt();
			totalBaseRatingRank = input.readInt();
			avgBaseRatingRank = input.readInt();
			totalExperienceRank = input.readInt();
			totalCommendiationCombinedRank = input.readInt();
			totalWinsRank = input.readInt();
			totalKdrRank = input.readInt();
			totalHighestFleetRank = input.readInt();
			avgHighestFleetRank = input.readInt();
			totalBlueprintPartsRank = input.readInt();
			
			totalqualifiedWinsPvPRank = input.readInt(); 
			totalBubbleHoursGrantedRank = input.readInt();
			totalcurrentPVPEventRank = input.readInt();
			totalcurrentPVPEventQuarterRank = input.readInt();
			totalCreditsTradeRouteRank = input.readInt();
			totalResourcesTradeRouteRank = input.readInt();
			totalResourcesSalvagedRank = input.readInt();
			totalCreditsBountyRank = input.readInt();
			totalWinsVsBaseRank = input.readInt();
			
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