package com.model.leaderboards
{
	import com.service.server.incoming.data.LeaderboardAllianceData;
	import com.service.server.incoming.data.LeaderboardPlayerData;

	public class LeaderboardEntryVO
	{
		private var _isAlliance:Boolean;

		private var _key:String;
		private var _name:String;
		private var _racePrototype:String;

		private var _sectorOwner:String;
		private var _allianceKey:String;
		private var _allianceName:String;

		private var _experience:uint;
		private var _experienceRank:int;

		private var _commendationPointsPvE:uint;
		private var _commendationPointsPvP:uint;
		private var _commendiationCombinedRank:int;
		private var _totalCommendationScore:uint;

		private var _KTDR:Number;
		private var _kdrRank:int;

		private var _baseRating:Number;
		private var _baseRatingRank:int;

		private var _wins:uint;
		private var _winsRank:int;

		private var _losses:uint;

		private var _highestFleetRating:int;
		private var _highestFleetRank:int;

		private var _avgHighestFleetRating:int;
		private var _avgHighestFleetRank:int;

		private var _highestBaseRating:int;
		private var _highestBaseRanking:int;

		private var _blueprintPartsCollected:int;
		private var _blueprintPartsRank:int;

		private var _numOfMembers:int;
		private var _numOfMembersRank:int;
		
		
		private var _qualifiedWinsPvP:Number;
		private var _BubbleHoursGranted:Number;
		private var _currentPVPEvent:Number;
		private var _currentPVPEventQuarter:Number;
		private var _CreditsTradeRoute:Number;
		private var _ResourcesTradeRoute:Number;
		private var _ResourcesSalvaged:Number;
		private var _CreditsBounty:Number;
		private var _WinsVsBase:Number;
		
		
		private var _qualifiedWinsPvPRank:int;
		private var _BubbleHoursGrantedRank:int;
		private var _currentPVPEventRank:int;
		private var _currentPVPEventQuarterRank:int;
		private var _CreditsTradeRouteRank:int;
		private var _ResourcesTradeRouteRank:int;
		private var _ResourcesSalvagedRank:int;
		private var _CreditsBountyRank:int;
		private var _WinsVsBaseRank:int;

		public function setUpFromPlayerData( leaderboardPlayerData:LeaderboardPlayerData ):void
		{
			_key = leaderboardPlayerData.playerKey;
			_name = leaderboardPlayerData.name;
			_racePrototype = leaderboardPlayerData.racePrototype;
			_sectorOwner = leaderboardPlayerData.sectorOwner;
			_allianceKey = leaderboardPlayerData.allianceKey;
			_allianceName = leaderboardPlayerData.allianceName;

			_experience = leaderboardPlayerData.experience;
			_experienceRank = leaderboardPlayerData.experienceRank;

			_commendationPointsPvE = leaderboardPlayerData.commendationPointsPvE;
			_commendationPointsPvP = leaderboardPlayerData.commendationPointsPvP;
			_commendiationCombinedRank = leaderboardPlayerData.commendiationCombinedRank;

			_baseRating = leaderboardPlayerData.baseRating;
			_baseRatingRank = leaderboardPlayerData.baseRatingRank;

			_wins = leaderboardPlayerData.wins;
			_winsRank = leaderboardPlayerData.winsRank;

			_losses = leaderboardPlayerData.losses;
			_kdrRank = leaderboardPlayerData.kdrRank;

			_highestFleetRating = leaderboardPlayerData.highestFleetRating;
			_highestFleetRank = leaderboardPlayerData.highestFleetRank;

			_blueprintPartsCollected = leaderboardPlayerData.blueprintPartsCollected;
			_blueprintPartsRank = leaderboardPlayerData.blueprintPartsRank;
			
			
			_qualifiedWinsPvP = leaderboardPlayerData.qualifiedWinsPvP;
			_BubbleHoursGranted = leaderboardPlayerData.BubbleHoursGranted;
			_currentPVPEvent = leaderboardPlayerData.currentPVPEvent;
			_currentPVPEventQuarter = leaderboardPlayerData.currentPVPEventQuarter;
			_CreditsTradeRoute = leaderboardPlayerData.CreditsTradeRoute;
			_ResourcesTradeRoute = leaderboardPlayerData.ResourcesTradeRoute;
			_ResourcesSalvaged = leaderboardPlayerData.ResourcesSalvaged;
			_CreditsBounty = leaderboardPlayerData.CreditsBounty;
			_WinsVsBase = leaderboardPlayerData.WinsVsBase;
			
			_qualifiedWinsPvPRank = leaderboardPlayerData.qualifiedWinsPvPRank;
			_BubbleHoursGrantedRank = leaderboardPlayerData.BubbleHoursGrantedRank;
			_currentPVPEventRank = leaderboardPlayerData.currentPVPEventRank;
			_currentPVPEventQuarterRank = leaderboardPlayerData.currentPVPEventQuarterRank;
			_CreditsTradeRouteRank = leaderboardPlayerData.CreditsTradeRouteRank;
			_ResourcesTradeRouteRank = leaderboardPlayerData.ResourcesTradeRouteRank;
			_ResourcesSalvagedRank = leaderboardPlayerData.ResourcesSalvagedRank;
			_CreditsBountyRank = leaderboardPlayerData.CreditsBountyRank;
			_WinsVsBaseRank = leaderboardPlayerData.WinsVsBaseRank;


			if (_losses != 0)
				_KTDR = Math.round(_wins * 100 / _losses) / 100;
			else
				_KTDR = _wins;
		}

		public function setUpFromAllianceData( leaderboardAllianceData:LeaderboardAllianceData ):void
		{
			_isAlliance = true;

			_key = leaderboardAllianceData.key;
			_name = leaderboardAllianceData.name;
			_racePrototype = leaderboardAllianceData.factionPrototype;

			_experience = leaderboardAllianceData.totalExperience;
			_experienceRank = leaderboardAllianceData.totalExperienceRank;

			_commendationPointsPvE = leaderboardAllianceData.totalCommendationPointsPvE;
			_commendationPointsPvP = leaderboardAllianceData.totalCommendationPointsPvP;
			_commendiationCombinedRank = leaderboardAllianceData.totalCommendiationCombinedRank;
			_totalCommendationScore = _commendationPointsPvE + _commendationPointsPvP;

			_baseRating = leaderboardAllianceData.avgRating;
			_baseRatingRank = leaderboardAllianceData.avgBaseRatingRank;

			_highestBaseRating = leaderboardAllianceData.totalRating;
			_highestBaseRanking = leaderboardAllianceData.totalBaseRatingRank

			_wins = leaderboardAllianceData.totalWins;
			_winsRank = leaderboardAllianceData.totalWinsRank;

			_losses = leaderboardAllianceData.totalLosses;
			_kdrRank = leaderboardAllianceData.totalKdrRank;

			_avgHighestFleetRank = leaderboardAllianceData.avgHighestFleetRank;
			_avgHighestFleetRating = leaderboardAllianceData.avgHighestFleetRating;

			_highestFleetRating = leaderboardAllianceData.totalHighestFleetRating;
			_highestFleetRank = leaderboardAllianceData.totalHighestFleetRank;

			_blueprintPartsCollected = leaderboardAllianceData.totalBlueprintPartsCollected;
			_blueprintPartsRank = leaderboardAllianceData.totalBlueprintPartsRank;

			_numOfMembers = leaderboardAllianceData.numMembers;
			_numOfMembersRank = leaderboardAllianceData.numMembersRank;
			
			_qualifiedWinsPvP = leaderboardAllianceData.totalqualifiedWinsPvP;
			_BubbleHoursGranted = leaderboardAllianceData.totalBubbleHoursGranted;
			_currentPVPEvent = leaderboardAllianceData.totalcurrentPVPEvent;
			_currentPVPEventQuarter = leaderboardAllianceData.totalcurrentPVPEventQuarter;
			_CreditsTradeRoute = leaderboardAllianceData.totalCreditsTradeRoute;
			_ResourcesTradeRoute = leaderboardAllianceData.totalResourcesTradeRoute;
			_ResourcesSalvaged = leaderboardAllianceData.totalResourcesSalvaged;
			_CreditsBounty = leaderboardAllianceData.totalCreditsBounty;
			_WinsVsBase = leaderboardAllianceData.totalWinsVsBase;
			
			_qualifiedWinsPvPRank = leaderboardAllianceData.totalqualifiedWinsPvPRank;
			_BubbleHoursGrantedRank = leaderboardAllianceData.totalBubbleHoursGrantedRank;
			_currentPVPEventRank = leaderboardAllianceData.totalcurrentPVPEventRank;
			_currentPVPEventQuarterRank = leaderboardAllianceData.totalcurrentPVPEventQuarterRank;
			_CreditsTradeRouteRank = leaderboardAllianceData.totalCreditsTradeRouteRank;
			_ResourcesTradeRouteRank = leaderboardAllianceData.totalResourcesTradeRouteRank;
			_ResourcesSalvagedRank = leaderboardAllianceData.totalResourcesSalvagedRank;
			_CreditsBountyRank = leaderboardAllianceData.totalCreditsBountyRank;
			_WinsVsBaseRank = leaderboardAllianceData.totalWinsVsBaseRank;
			
			if (_losses != 0)
				_KTDR = Math.round(_wins * 100 / _losses) / 100;
			else
				_KTDR = _wins;
		}


		public function get isAlliance():Boolean  { return _isAlliance; }
		public function get key():String  { return _key; }
		public function get name():String  { return _name; }
		public function get racePrototype():String  { return _racePrototype; }
		public function get sectorOwner():String  { return _sectorOwner; }
		public function get allianceKey():String  { return _allianceKey; }
		public function get allianceName():String  { return _allianceName; }

		public function get commendationPointsPvE():uint  { return _commendationPointsPvE; }
		public function get commendationPointsPvP():uint  { return _commendationPointsPvP; }
		public function get losses():Number  { return _losses; }

		public function get wins():Number  { return _wins; }
		public function get winsRank():Number  { return _winsRank; }

		public function get baseRating():Number  { return _baseRating; }
		public function get baseRatingRank():Number  { return _baseRatingRank; }

		public function get highestBaseRating():Number  { return _highestBaseRating; }
		public function get highestBaseRanking():Number  { return _highestBaseRanking; }

		public function get experience():uint  { return _experience; }
		public function get experienceRank():Number  { return _experienceRank; }

		public function get commendationScore():uint  { return _commendationPointsPvE + _commendationPointsPvP; }
		public function get commendiationCombinedRank():Number  { return _commendiationCombinedRank; }

		public function get totalCommendationScore():uint  { return _totalCommendationScore; }

		public function get ktdRatio():Number  { return _KTDR; }
		public function get kdrRank():Number  { return _kdrRank; }

		public function get highestFleetRating():Number  { return _highestFleetRating; }
		public function get highestFleetRank():Number  { return _highestFleetRank; }

		public function get avgHighestFleetRank():int  { return _avgHighestFleetRank; }
		public function get avgHighestFleetRating():int  { return _avgHighestFleetRating; }

		public function get blueprintPartsCollected():Number  { return _blueprintPartsCollected; }
		public function get blueprintPartsRank():Number  { return _blueprintPartsRank; }
		
		

		public function get numOfMembers():Number  { return _numOfMembers; }
		public function get numOfMembersRank():Number  { return _numOfMembersRank; }
		
		
		public function get qualifiedWinsPvP():Number  { return _qualifiedWinsPvP; }
		public function get BubbleHoursGranted():Number  { return _BubbleHoursGranted; }
		public function get currentPVPEvent():Number  { return _currentPVPEvent; }
		public function get currentPVPEventQuarter():Number  { return _currentPVPEventQuarter; }
		public function get CreditsTradeRoute():Number  { return _CreditsTradeRoute; }
		public function get ResourcesTradeRoute():Number  { return _ResourcesTradeRoute; }
		public function get ResourcesSalvaged():Number  { return _ResourcesSalvaged; }
		public function get CreditsBounty():Number  { return _CreditsBounty; }
		public function get WinsVsBase():Number  { return _WinsVsBase; }
		
		
		
		public function get qualifiedWinsPvPRank():int  { return _qualifiedWinsPvPRank; }
		public function get BubbleHoursGrantedRank():int  { return _BubbleHoursGrantedRank; }
		public function get currentPVPEventRank():int  { return _currentPVPEventRank; }
		public function get currentPVPEventQuarterRank():int  { return _currentPVPEventQuarterRank; }
		public function get CreditsTradeRouteRank():int  { return _CreditsTradeRouteRank; }
		public function get ResourcesTradeRouteRank():int  { return _ResourcesTradeRouteRank; }
		public function get ResourcesSalvagedRank():int  { return _ResourcesSalvagedRank; }
		public function get CreditsBountyRank():int  { return _CreditsBountyRank; }
		public function get WinsVsBaseRank():int  { return _WinsVsBaseRank; }
	}
}
