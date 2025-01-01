package com.service.server
{
	import com.enum.server.EncodingEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.enum.server.ResponseEnum;
	import com.service.server.incoming.alliance.AllianceBaselineResponse;
	import com.service.server.incoming.alliance.AllianceGenericResponse;
	import com.service.server.incoming.alliance.AllianceInviteResponse;
	import com.service.server.incoming.alliance.AllianceRosterResponse;
	import com.service.server.incoming.alliance.PublicAlliancesResponse;
	import com.service.server.incoming.battle.BattleDataResponse;
	import com.service.server.incoming.battle.BattleDebugLinesResponse;
	import com.service.server.incoming.battle.BattleHasEndedResponse;
	import com.service.server.incoming.battlelog.BattleLogDetailsResponse;
	import com.service.server.incoming.battlelog.BattleLogListResponse;
	import com.service.server.incoming.chat.ChatBaselineResponse;
	import com.service.server.incoming.chat.ChatEventResponse;
	import com.service.server.incoming.chat.ChatResponse;
	import com.service.server.incoming.leaderboard.LeaderboardResponse;
	import com.service.server.incoming.leaderboard.PlayerProfileResponse;
	import com.service.server.incoming.leaderboard.WarfrontUpdateResponse;
	import com.service.server.incoming.mail.MailDetailResponse;
	import com.service.server.incoming.mail.MailInboxResponse;
	import com.service.server.incoming.mail.MailUnreadResponse;
	import com.service.server.incoming.proxy.ProxyBattleDisconnectedResponse;
	import com.service.server.incoming.proxy.ProxySectorDisconnectedResponse;
	import com.service.server.incoming.proxy.ProxyStarbaseDisconnectedResponse;
	import com.service.server.incoming.proxy.TimeSyncResponse;
	import com.service.server.incoming.sector.SectorAlwaysVisibleBaselineResponse;
	import com.service.server.incoming.sector.SectorAlwaysVisibleUpdateResponse;
	import com.service.server.incoming.sector.SectorBaselineResponse;
	import com.service.server.incoming.sector.SectorFleetTravelAlertResponse;
	import com.service.server.incoming.universe.UniverseSectorListResponse;
	import com.service.server.incoming.sector.SectorUpdateResponse;
	import com.service.server.incoming.starbase.StarbaseAchievementsResponse;
	import com.service.server.incoming.starbase.StarbaseAllScoresResponse;
	import com.service.server.incoming.starbase.StarbaseAvailableRerollResponse;
	import com.service.server.incoming.starbase.StarbaseBaselineResponse;
	import com.service.server.incoming.starbase.StarbaseBattleAlertResponse;
	import com.service.server.incoming.starbase.StarbaseBountyRewardResponse;
	import com.service.server.incoming.starbase.StarbaseDailyResponse;
	import com.service.server.incoming.starbase.StarbaseDailyRewardResponse;
	import com.service.server.incoming.starbase.StarbaseFleetDockedResponse;
	import com.service.server.incoming.starbase.StarbaseGetPaywallPayoutsResponse;
	import com.service.server.incoming.starbase.StarbaseInstancedMissionAlertResponse;
	import com.service.server.incoming.starbase.StarbaseMissionCompleteResponse;
	import com.service.server.incoming.starbase.StarbaseMotdListResponse;
	import com.service.server.incoming.starbase.StarbaseMoveStarbaseResponse;
	import com.service.server.incoming.starbase.StarbaseOfferRedeemedResponse;
	import com.service.server.incoming.starbase.StarbaseRerollChanceResultResponse;
	import com.service.server.incoming.starbase.StarbaseRerollReceivedResultResponse;
	import com.service.server.incoming.starbase.StarbaseTransactionResponse;
	import com.service.server.incoming.starbase.StarbaseUnavailableRerollResponse;
	import com.service.server.incoming.universe.UniverseNeedCharacterCreateResponse;
	import com.service.server.outgoing.alliance.AllianceCreateAllianceRequest;
	import com.service.server.outgoing.alliance.AllianceDemoteRequest;
	import com.service.server.outgoing.alliance.AllianceIgnoreInvitesRequest;
	import com.service.server.outgoing.alliance.AllianceJoinRequest;
	import com.service.server.outgoing.alliance.AllianceKickRequest;
	import com.service.server.outgoing.alliance.AllianceLeaveRequest;
	import com.service.server.outgoing.alliance.AlliancePromoteRequest;
	import com.service.server.outgoing.alliance.AllianceRequestBaselineRequest;
	import com.service.server.outgoing.alliance.AllianceRequestPublicsRequest;
	import com.service.server.outgoing.alliance.AllianceRequestRosterRequest;
	import com.service.server.outgoing.alliance.AllianceSendInviteRequest;
	import com.service.server.outgoing.alliance.AllianceSetDescriptionRequest;
	import com.service.server.outgoing.alliance.AllianceSetMOTDRequest;
	import com.service.server.outgoing.alliance.AllianceSetPublicRequest;
	import com.service.server.outgoing.battle.BattleAttackOrderRequest;
	import com.service.server.outgoing.battle.BattleMoveOrderRequest;
	import com.service.server.outgoing.battle.BattlePauseRequest;
	import com.service.server.outgoing.battle.BattleRetreatRequest;
	import com.service.server.outgoing.battle.BattleToggleModuleOrderRequest;
	import com.service.server.outgoing.battlelog.BattleLogDetailRequest;
	import com.service.server.outgoing.battlelog.BattleLogListRequest;
	import com.service.server.outgoing.chat.ChatChangeRoomRequest;
	import com.service.server.outgoing.chat.ChatIgnoreChatRequest;
	import com.service.server.outgoing.chat.ChatReportChatRequest;
	import com.service.server.outgoing.chat.ChatSendChatRequest;
	import com.service.server.outgoing.leaderboard.LeaderboardRequest;
	import com.service.server.outgoing.leaderboard.LeaderboardRequestPlayerProfileRequest;
	import com.service.server.outgoing.mail.MailDeleteMailRequest;
	import com.service.server.outgoing.mail.MailReadMailRequest;
	import com.service.server.outgoing.mail.MailRequestInboxRequest;
	import com.service.server.outgoing.mail.MailSendAllianceMailRequest;
	import com.service.server.outgoing.mail.MailSendMailRequest;
	import com.service.server.outgoing.proxy.AuthRequest;
	import com.service.server.outgoing.proxy.ClientLoginRequest;
	import com.service.server.outgoing.proxy.ProxyConnectToBattleRequest;
	import com.service.server.outgoing.proxy.ProxyConnectToSectorRequest;
	import com.service.server.outgoing.proxy.ProxyReportCrashRequest;
	import com.service.server.outgoing.proxy.ProxyReportLoginDataRequest;
	import com.service.server.outgoing.proxy.ProxyTutorialStepCompletedMessage;
	import com.service.server.outgoing.proxy.TimeSyncRequest;
	import com.service.server.outgoing.sector.SectorOrderRequest;
	import com.service.server.outgoing.sector.SectorRequestBaselineRequest;
	import com.service.server.outgoing.sector.SectorSetViewLocationRequest;
	import com.service.server.outgoing.starbase.StarbaseBookmarkDeleteRequest;
	import com.service.server.outgoing.starbase.StarbaseBookmarkSaveRequest;
	import com.service.server.outgoing.starbase.StarbaseBookmarkUpdateRequest;
	import com.service.server.outgoing.starbase.StarbaseBribeContractRequest;
	import com.service.server.outgoing.starbase.StarbaseBuildNewBuildingRequest;
	import com.service.server.outgoing.starbase.StarbaseBuildShipRequest;
	import com.service.server.outgoing.starbase.StarbaseBuyResourceRequest;
	import com.service.server.outgoing.starbase.StarbaseBuyStoreItemRequest;
	import com.service.server.outgoing.starbase.StarbaseBuyOtherStoreItemRequest;
	import com.service.server.outgoing.starbase.StarbaseBuyoutBlueprintRequest;
	import com.service.server.outgoing.starbase.StarbaseCancelContractRequest;
	import com.service.server.outgoing.starbase.StarbaseCancelTransactionRequest;
	import com.service.server.outgoing.starbase.StarbaseClaimAchievementRewardRequest;
	import com.service.server.outgoing.starbase.StarbaseMintNFTRequest;
	import com.service.server.outgoing.starbase.StarbaseClaimDailyRequest;
	import com.service.server.outgoing.starbase.StarbaseExtendContractRequest;
	import com.service.server.outgoing.starbase.StarbaseGetPaywallPayoutsRequest;
	import com.service.server.outgoing.starbase.StarbaseInstancedMissionStartRequest;
	import com.service.server.outgoing.starbase.StarbaseLaunchFleetRequest;
	import com.service.server.outgoing.starbase.StarbaseMissionAcceptRequest;
	import com.service.server.outgoing.starbase.StarbaseMissionAcceptRewardsRequest;
	import com.service.server.outgoing.starbase.StarbaseCompleteBlueprintResearchRequest;
	import com.service.server.outgoing.starbase.StarbaseMissionStepRequest;
	import com.service.server.outgoing.starbase.StarbaseMotDReadRequest;
	import com.service.server.outgoing.starbase.StarbaseMoveBuildingRequest;
	import com.service.server.outgoing.starbase.StarbaseMoveStarbaseRequest;
	import com.service.server.outgoing.starbase.StarbaseMoveStarbaseToTransgateRequest;
	
	import com.service.server.outgoing.starbase.StarbaseNegotiateContractRequest;
	import com.service.server.outgoing.starbase.StarbaseRecallFleetRequest;
	import com.service.server.outgoing.starbase.StarbaseRecycleBuildingRequest;
	import com.service.server.outgoing.starbase.StarbaseRecycleShipRequest;
	import com.service.server.outgoing.starbase.StarbaseRefitBuildingRequest;
	import com.service.server.outgoing.starbase.StarbaseRefitShipRequest;
	import com.service.server.outgoing.starbase.StarbaseRenameFleetRequest;
	import com.service.server.outgoing.starbase.StarbaseRenamePlayerRequest;
	import com.service.server.outgoing.starbase.StarbaseRepairBaseRequest;
	import com.service.server.outgoing.starbase.StarbaseRepairFleetRequest;
	import com.service.server.outgoing.starbase.StarbaseAllScoresRequest;
	import com.service.server.outgoing.starbase.StarbaseRequestAchievementsRequest;
	import com.service.server.outgoing.starbase.StarbaseRerollBlueprintChanceRequest;
	import com.service.server.outgoing.starbase.StarbaseRerollBlueprintReceivedRequest;
	import com.service.server.outgoing.starbase.StarbaseResearchRequest;
	import com.service.server.outgoing.starbase.StarbaseResecureContractRequest;
	import com.service.server.outgoing.starbase.StarbaseSetClientSettingsRequest;
	import com.service.server.outgoing.starbase.StarbaseSkipTrainingRequest;
	import com.service.server.outgoing.starbase.StarbaseSpeedUpTransactionRequest;
	import com.service.server.outgoing.starbase.StarbaseUpdateFleetRequest;
	import com.service.server.outgoing.starbase.StarbaseUpgradeBuildingRequest;
	import com.service.server.outgoing.starbase.StarbaseVerifyPaymentRequest;
	import com.service.server.outgoing.universe.UniverseCreateCharacterRequest;

	import org.shared.ObjectPool;

	public class PacketFactory
	{
		public static function getResponse( input:BinaryInputStream, protocolID:int, header:int, encoding:int ):IResponse
		{
			var packet:IResponse = null;
			switch (protocolID)
			{
				case ProtocolEnum.PROXY_CLIENT:
					switch (header)
					{
						case ResponseEnum.PROXY_TIME_SYNC:
							packet = ObjectPool.get(TimeSyncResponse);
							break;
						case ResponseEnum.PROXY_BATTLE_DISCONNECTED:
							packet = ObjectPool.get(ProxyBattleDisconnectedResponse);
							break;
						case ResponseEnum.PROXY_SECTOR_DISCONNECTED:
							packet = ObjectPool.get(ProxySectorDisconnectedResponse);
							break;
						case ResponseEnum.PROXY_STARBASE_DISCONNECTED:
							packet = ObjectPool.get(ProxyStarbaseDisconnectedResponse);
							break;
					}
					break;
				case ProtocolEnum.SECTOR_CLIENT:
					switch (header)
					{
						case ResponseEnum.SECTOR_BASELINE:
							packet = ObjectPool.get(SectorBaselineResponse);
							break;
						case ResponseEnum.SECTOR_UPDATE:
							packet = ObjectPool.get(SectorUpdateResponse);
							break;
						case ResponseEnum.SECTOR_ALWAYS_VISIBLE_BASELINE:
							packet = ObjectPool.get(SectorAlwaysVisibleBaselineResponse);
							break;
						case ResponseEnum.SECTOR_ALWAYS_VISIBLE_UPDATE:
							packet = ObjectPool.get(SectorAlwaysVisibleUpdateResponse);
							break;
						case ResponseEnum.SECTOR_FLEET_TRAVEL_ALERT:
							packet = ObjectPool.get(SectorFleetTravelAlertResponse);
							break;
					}
					break;
				case ProtocolEnum.BATTLE_CLIENT:
					switch (header)
					{
						case ResponseEnum.BATTLE_BASELINE:
						case ResponseEnum.BATTLE_UPDATE:
							packet = ObjectPool.get(BattleDataResponse);
							break;
						case ResponseEnum.BATTLE_DEBUG_LINES:
							packet = ObjectPool.get(BattleDebugLinesResponse);
							break;
						case ResponseEnum.BATTLE_HAS_ENDED:
							packet = ObjectPool.get(BattleHasEndedResponse);
							break;
					}
					break;
				case ProtocolEnum.STARBASE_CLIENT:
					switch (header)
					{
						case ResponseEnum.STARBASE_TRANSACTION_RESPONSE:
							packet = ObjectPool.get(StarbaseTransactionResponse);
							break;
						case ResponseEnum.STARBASE_BASELINE:
							packet = ObjectPool.get(StarbaseBaselineResponse);
							break;
						case ResponseEnum.STARBASE_BATTLE_ALERT:
							packet = ObjectPool.get(StarbaseBattleAlertResponse);
							break;
						case ResponseEnum.STARBASE_MISSION_COMPLETE:
							packet = ObjectPool.get(StarbaseMissionCompleteResponse);
							break;
						case ResponseEnum.STARBASE_FLEET_DOCKED:
							packet = ObjectPool.get(StarbaseFleetDockedResponse);
							break;
						case ResponseEnum.STARBASE_BOUNTY_REWARD:
							packet = ObjectPool.get(StarbaseBountyRewardResponse);
							break;
						case ResponseEnum.STARBASE_BATTLELOG_LIST:
							packet = ObjectPool.get(BattleLogListResponse);
							break;
						case ResponseEnum.STARBASE_BATTLELOG_DETAILS:
							packet = ObjectPool.get(BattleLogDetailsResponse);
							break;
						case ResponseEnum.STARBASE_OFFER_REDEEMED:
							packet = ObjectPool.get(StarbaseOfferRedeemedResponse);
							break;
						case ResponseEnum.STARBASE_MOTD_LIST:
							packet = ObjectPool.get(StarbaseMotdListResponse);
							break;
						case ResponseEnum.STARBASE_DAILY:
							packet = ObjectPool.get(StarbaseDailyResponse);
							break;
						case ResponseEnum.STARBASE_DAILY_REWARD:
							packet = ObjectPool.get(StarbaseDailyRewardResponse);
							break;
						case ResponseEnum.STARBASE_AVAILABLE_REROLL:
						case ResponseEnum.STARBASE_AVAILABLE_CREWMEMBER_REROLL:
							packet = ObjectPool.get(StarbaseAvailableRerollResponse);
							break;
						case ResponseEnum.STARBASE_REROLL_CHANCE_RESULT:
							packet = ObjectPool.get(StarbaseRerollChanceResultResponse);
							break;
						case ResponseEnum.STARBASE_REROLL_RECEIVED_RESULT:
						case ResponseEnum.STARBASE_REROLL_CREWMEMBER_RECEIVED_RESULT:
							packet = ObjectPool.get(StarbaseRerollReceivedResultResponse);
							break;
						case ResponseEnum.STARBASE_MOVE_STARBASE_RESPONSE:
							packet = ObjectPool.get(StarbaseMoveStarbaseResponse);
							break;
						case ResponseEnum.STARBASE_ACHIEVEMENTS_RESPONSE:
							packet = ObjectPool.get(StarbaseAchievementsResponse);
							break;
						case ResponseEnum.STARBASE_ALL_SCORES_RESPONSE:
							packet = ObjectPool.get(StarbaseAllScoresResponse);
							break;
						case ResponseEnum.STARBASE_UNAVAILABLE_REROLL:
						case ResponseEnum.STARBASE_UNAVAILABLE_CREWMEMBER_REROLL:
							packet = ObjectPool.get(StarbaseUnavailableRerollResponse);
							break;
						case ResponseEnum.STARBASE_GET_PAYWALL_PAYOUTS_RESPONSE:
							packet = ObjectPool.get(StarbaseGetPaywallPayoutsResponse);
							break;
						case ResponseEnum.STARBASE_INSTANCED_MISSION_ALERT:
							packet = ObjectPool.get(StarbaseInstancedMissionAlertResponse);
							break;
					}
					break;
				case ProtocolEnum.MAIL_CLIENT:
					switch (header)
					{
						case ResponseEnum.MAIL_UNREAD:
							packet = ObjectPool.get(MailUnreadResponse);
							break;
						case ResponseEnum.MAIL_INBOX:
							packet = ObjectPool.get(MailInboxResponse);
							break;
						case ResponseEnum.MAIL_DETAIL:
							packet = ObjectPool.get(MailDetailResponse);
							break;
					}
					break;
				case ProtocolEnum.ALLIANCE_CLIENT:
					switch (header)
					{
						case ResponseEnum.ALLIANCE_BASELINE:
							packet = ObjectPool.get(AllianceBaselineResponse);
							break;
						case ResponseEnum.ALLIANCE_ROSTER:
							packet = ObjectPool.get(AllianceRosterResponse);
							break;
						case ResponseEnum.GENERIC_ALLIANCE_RESPONSE:
							packet = ObjectPool.get(AllianceGenericResponse);
							break;
						case ResponseEnum.PUBLIC_ALLIANCES_RESPONSE:
							packet = ObjectPool.get(PublicAlliancesResponse);
							break;
						case ResponseEnum.ALLIANCE_INVITE:
							packet = ObjectPool.get(AllianceInviteResponse);
							break;
					}
					break;
				case ProtocolEnum.CHAT_CLIENT:
					switch (header)
					{
						case ResponseEnum.CHAT_RESPONSE:
							packet = ObjectPool.get(ChatResponse);
							break;
						case ResponseEnum.CHAT_BASELINE:
							packet = ObjectPool.get(ChatBaselineResponse);
							break;
						case ResponseEnum.CHAT_EVENT:
							packet = ObjectPool.get(ChatEventResponse);
							break;
					}
					break;
				case ProtocolEnum.LEADERBOARD_CLIENT:
					switch (header)
					{
						case ResponseEnum.LEADERBOARD:
							packet = ObjectPool.get(LeaderboardResponse);
							break;
						case ResponseEnum.PLAYER_PROFILE:
							packet = ObjectPool.get(PlayerProfileResponse);
							break;
						case ResponseEnum.WARFRONT_UPDATE:
							packet = ObjectPool.get(WarfrontUpdateResponse);
							break;
					}
					break;

				case ProtocolEnum.UNIVERSE_CLIENT:
					switch (header)
					{
						case ResponseEnum.UNIVERSE_NEED_CHARACTER_CREATE:
							packet = ObjectPool.get(UniverseNeedCharacterCreateResponse);
							break;
						case ResponseEnum.UNIVERSE_SECTOR_LIST:
							packet = ObjectPool.get(UniverseSectorListResponse);
							break;
					}
					break;
			}

			if (packet)
			{
				packet.header = header;
				packet.protocolID = protocolID;
				switch (encoding)
				{
					case EncodingEnum.BINARY:
						packet.read(input);
						break;
					case EncodingEnum.JSON:
						var jsonString:String = String(input.readUTFBytes(input.length - 4));
						var data:Object       = JSON.parse(jsonString);
						packet.readJSON(data);
						break;
				}
			}
			return packet;
		}

		public static function getRequest( protocolID:int, header:int ):IRequest
		{
			var packet:IRequest = null;
			switch (protocolID)
			{
				case ProtocolEnum.PROXY_CLIENT:
					switch (header)
					{
						case RequestEnum.AUTHORIZATION:
							packet = ObjectPool.get(AuthRequest);
							break;
						case RequestEnum.PROXY_TIME_SYNC:
							packet = ObjectPool.get(TimeSyncRequest);
							break;
						case RequestEnum.PROXY_CONNECT_TO_BATTLE:
							packet = ObjectPool.get(ProxyConnectToBattleRequest);
							break;
						case RequestEnum.PROXY_CONNECT_TO_SECTOR:
							packet = ObjectPool.get(ProxyConnectToSectorRequest);
							break;
						case RequestEnum.PROXY_LOGIN:
							packet = ObjectPool.get(ClientLoginRequest);
							break;
						case RequestEnum.PROXY_REPORT_CRASH:
							packet = ObjectPool.get(ProxyReportCrashRequest);
							break;
						case RequestEnum.PROXY_REPORT_LOGIN_DATA:
							packet = ObjectPool.get(ProxyReportLoginDataRequest);
							break;
						case RequestEnum.PROXY_TUTORIAL_STEP_COMPLETED:
							packet = ObjectPool.get(ProxyTutorialStepCompletedMessage);
							break;
					}
					break;
				case ProtocolEnum.SECTOR_CLIENT:
					switch (header)
					{
						case RequestEnum.SECTOR_SET_VIEW_LOCATION:
							packet = ObjectPool.get(SectorSetViewLocationRequest);
							break;
						case RequestEnum.SECTOR_ISSUE_ORDER:
							packet = ObjectPool.get(SectorOrderRequest);
							break;
						case RequestEnum.SECTOR_REQUEST_BASELINE:
							packet = ObjectPool.get(SectorRequestBaselineRequest);
							break;
					}
					break;
				case ProtocolEnum.BATTLE_CLIENT:
					switch (header)
					{
						case RequestEnum.BATTLE_MOVE_ORDER:
							packet = ObjectPool.get(BattleMoveOrderRequest);
							break;
						case RequestEnum.BATTLE_ATTACK_ORDER:
							packet = ObjectPool.get(BattleAttackOrderRequest);
							break;
						case RequestEnum.BATTLE_TOGGLE_MODULE_ORDER:
							packet = ObjectPool.get(BattleToggleModuleOrderRequest);
							break;
						case RequestEnum.BATTLE_PAUSE:
							packet = ObjectPool.get(BattlePauseRequest);
							break;
						case RequestEnum.BATTLE_RETREAT:
							packet = ObjectPool.get(BattleRetreatRequest);
							break;
					}
					break;
				case ProtocolEnum.STARBASE_CLIENT:
					switch (header)
					{
						case RequestEnum.STARBASE_BUILD_SHIP:
							packet = ObjectPool.get(StarbaseBuildShipRequest);
							break;
						case RequestEnum.STARBASE_UPDATE_FLEET:
							packet = ObjectPool.get(StarbaseUpdateFleetRequest);
							break;
						case RequestEnum.STARBASE_LAUNCH_FLEET:
							packet = ObjectPool.get(StarbaseLaunchFleetRequest);
							break;
						case RequestEnum.STARBASE_RECALL_FLEET:
							packet = ObjectPool.get(StarbaseRecallFleetRequest);
							break;
						case RequestEnum.STARBASE_REPAIR_FLEET:
							packet = ObjectPool.get(StarbaseRepairFleetRequest);
							break;
						case RequestEnum.STARBASE_RENAME_FLEET:
							packet = ObjectPool.get(StarbaseRenameFleetRequest);
							break;
						case RequestEnum.STARBASE_BUILD_NEW_BUILDING:
							packet = ObjectPool.get(StarbaseBuildNewBuildingRequest);
							break;
						case RequestEnum.STARBASE_SET_CLIENT_SETTINGS:
							packet = ObjectPool.get(StarbaseSetClientSettingsRequest);
							break;
						case RequestEnum.STARBASE_UPGRADE_BUILDING:
							packet = ObjectPool.get(StarbaseUpgradeBuildingRequest);
							break;
						case RequestEnum.STARBASE_RECYCLE_BUILDING:
							packet = ObjectPool.get(StarbaseRecycleBuildingRequest);
							break;
						case RequestEnum.STARBASE_REFIT_BUILDING:
							packet = ObjectPool.get(StarbaseRefitBuildingRequest);
							break;
						case RequestEnum.STARBASE_REPAIR_BASE:
							packet = ObjectPool.get(StarbaseRepairBaseRequest);
							break;
						case RequestEnum.STARBASE_SPEED_UP_TRANSACTION:
							packet = ObjectPool.get(StarbaseSpeedUpTransactionRequest);
							break;
						case RequestEnum.STARBASE_CANCEL_TRANSACTION:
							packet = ObjectPool.get(StarbaseCancelTransactionRequest);
							break;
						case RequestEnum.STARBASE_MOVE_BUILDING:
							packet = ObjectPool.get(StarbaseMoveBuildingRequest);
							break;
						case RequestEnum.STARBASE_RESEARCH:
							packet = ObjectPool.get(StarbaseResearchRequest);
							break;
						case RequestEnum.STARBASE_BUY_RESOURCE:
							packet = ObjectPool.get(StarbaseBuyResourceRequest);
							break;
						case RequestEnum.STARBASE_BUY_STORE_ITEM:
							packet = ObjectPool.get(StarbaseBuyStoreItemRequest);
							break;
						case RequestEnum.STARBASE_BUY_OTHER_STORE_ITEM:
							packet = ObjectPool.get(StarbaseBuyOtherStoreItemRequest);
							break;					
						case RequestEnum.STARBASE_RECYCLE_SHIP:
							packet = ObjectPool.get(StarbaseRecycleShipRequest);
							break;
						case RequestEnum.STARBASE_REFIT_SHIP:
							packet = ObjectPool.get(StarbaseRefitShipRequest);
							break;
						case RequestEnum.STARBASE_NEGOTIATE_CONTRACT:
							packet = ObjectPool.get(StarbaseNegotiateContractRequest);
							break;
						case RequestEnum.STARBASE_BRIBE_CONTRACT:
							packet = ObjectPool.get(StarbaseBribeContractRequest);
							break;
						case RequestEnum.STARBASE_CANCEL_CONTRACT:
							packet = ObjectPool.get(StarbaseCancelContractRequest);
							break;
						case RequestEnum.STARBASE_EXTEND_CONTRACT:
							packet = ObjectPool.get(StarbaseExtendContractRequest);
							break;
						case RequestEnum.STARBASE_RESECURE_CONTRACT:
							packet = ObjectPool.get(StarbaseResecureContractRequest);
							break;
						case RequestEnum.STARBASE_INSTANCED_MISSION_START:
							packet = ObjectPool.get(StarbaseInstancedMissionStartRequest);
							break;
						case RequestEnum.STARBASE_MISSION_STEP:
							packet = ObjectPool.get(StarbaseMissionStepRequest);
							break;
						case RequestEnum.STARBASE_MISSION_ACCEPT:
							packet = ObjectPool.get(StarbaseMissionAcceptRequest);
							break;
						case RequestEnum.STARBASE_MISSION_ACCEPT_REWARDS:
							packet = ObjectPool.get(StarbaseMissionAcceptRewardsRequest);
							break;
						case RequestEnum.STARBASE_BUYOUT_BLUEPRINT:
							packet = ObjectPool.get(StarbaseBuyoutBlueprintRequest);
							break;
						case RequestEnum.STARBASE_COMPLETE_BLUEPRINT_RESEARCH:
							packet = ObjectPool.get(StarbaseCompleteBlueprintResearchRequest);
							break;
						case RequestEnum.STARBASE_BATTLELOG_LIST:
							packet = ObjectPool.get(BattleLogListRequest);
							break;
						case RequestEnum.STARBASE_BATTLELOG_DETAILS:
							packet = ObjectPool.get(BattleLogDetailRequest);
							break;
						case RequestEnum.STARBASE_BOOKMARK_SAVE:
							packet = ObjectPool.get(StarbaseBookmarkSaveRequest);
							break;
						case RequestEnum.STARBASE_BOOKMARK_DELETE:
							packet = ObjectPool.get(StarbaseBookmarkDeleteRequest);
							break;
						case RequestEnum.STARBASE_BOOKMARK_UPDATE:
							packet = ObjectPool.get(StarbaseBookmarkUpdateRequest);
							break;
						case RequestEnum.STARBASE_MARK_MOTD_READ_MESSAGE:
							packet = ObjectPool.get(StarbaseMotDReadRequest);
							break;
						case RequestEnum.STARBASE_CLAIM_DAILY_MESSAGE:
							packet = ObjectPool.get(StarbaseClaimDailyRequest);
							break;
						case RequestEnum.STARBASE_SKIP_TRAINING_MESSAGE:
							packet = ObjectPool.get(StarbaseSkipTrainingRequest);
							break;
						case RequestEnum.STARBASE_REROLL_BLUEPRINT_CHANCE_MESSAGE:
							packet = ObjectPool.get(StarbaseRerollBlueprintChanceRequest);
							break;
						case RequestEnum.STARBASE_REROLL_BLUEPRINT_RECEIVED_MESSAGE:
							packet = ObjectPool.get(StarbaseRerollBlueprintReceivedRequest);
							break;
						case RequestEnum.STARBASE_RENAME_PLAYER:
							packet = ObjectPool.get(StarbaseRenamePlayerRequest);
							break;
						case RequestEnum.STARBASE_MOVE_STARBASE:
							packet = ObjectPool.get(StarbaseMoveStarbaseRequest);
							break;
						case RequestEnum.STARBASE_MOVE_STARBASE_TO_TRANSGATE:
							packet = ObjectPool.get(StarbaseMoveStarbaseToTransgateRequest);
							break;
						case RequestEnum.STARBASE_REQUEST_ACHIEVEMENTS:
							packet = ObjectPool.get(StarbaseRequestAchievementsRequest);
							break;
						case RequestEnum.STARBASE_REQUEST_ALL_SCORES:
							packet = ObjectPool.get(StarbaseAllScoresRequest);
							break;
						case RequestEnum.STARBASE_CLAIM_ACHIEVEMENT_REWARD:
							packet = ObjectPool.get(StarbaseClaimAchievementRewardRequest);
							break;
						case RequestEnum.STARBASE_GET_PAYWALL_PAYOUTS:
							packet = ObjectPool.get(StarbaseGetPaywallPayoutsRequest);
							break;
						case RequestEnum.STARBASE_VERIFY_PAYMENT:
							packet = ObjectPool.get(StarbaseVerifyPaymentRequest);
							break;
						case RequestEnum.STARBASE_MINT_NFT:
							packet = ObjectPool.get(StarbaseMintNFTRequest);
							break;
					}
					break;

				case ProtocolEnum.MAIL_CLIENT:
					switch (header)
					{
						case RequestEnum.MAIL_REQUEST_INBOX:
							packet = ObjectPool.get(MailRequestInboxRequest);
							break;
						case RequestEnum.MAIL_SEND_MAIL:
							packet = ObjectPool.get(MailSendMailRequest);
							break;
						case RequestEnum.MAIL_DELETE_MAIL:
							packet = ObjectPool.get(MailDeleteMailRequest);
							break;
						case RequestEnum.MAIL_READ_MAIL:
							packet = ObjectPool.get(MailReadMailRequest);
							break;
						case RequestEnum.MAIL_SEND_ALLIANCE_MAIL:
							packet = ObjectPool.get(MailSendAllianceMailRequest);
							break;
					}
					break;

				case ProtocolEnum.ALLIANCE_CLIENT:
					switch (header)
					{
						case RequestEnum.ALLIANCE_REQUEST_BASELINE:
							packet = ObjectPool.get(AllianceRequestBaselineRequest);
							break;
						case RequestEnum.ALLIANCE_REQUEST_ROSTER:
							packet = ObjectPool.get(AllianceRequestRosterRequest);
							break;
						case RequestEnum.ALLIANCE_CREATE_ALLIANCE:
							packet = ObjectPool.get(AllianceCreateAllianceRequest);
							break;
						case RequestEnum.ALLIANCE_SET_MOTD:
							packet = ObjectPool.get(AllianceSetMOTDRequest);
							break;
						case RequestEnum.ALLIANCE_SET_DESCRIPTION:
							packet = ObjectPool.get(AllianceSetDescriptionRequest);
							break;
						case RequestEnum.ALLIANCE_SET_PUBLIC:
							packet = ObjectPool.get(AllianceSetPublicRequest);
							break;
						case RequestEnum.ALLIANCE_PROMOTE:
							packet = ObjectPool.get(AlliancePromoteRequest);
							break;
						case RequestEnum.ALLIANCE_DEMOTE:
							packet = ObjectPool.get(AllianceDemoteRequest);
							break;
						case RequestEnum.ALLIANCE_KICK:
							packet = ObjectPool.get(AllianceKickRequest);
							break;
						case RequestEnum.ALLIANCE_LEAVE_ALLIANCE:
							packet = ObjectPool.get(AllianceLeaveRequest);
							break;
						case RequestEnum.ALLIANCE_JOIN_ALLIANCE:
							packet = ObjectPool.get(AllianceJoinRequest);
							break;
						case RequestEnum.ALLIANCE_SEND_INVITE:
							packet = ObjectPool.get(AllianceSendInviteRequest);
							break;
						case RequestEnum.ALLIANCE_IGNORE_INVITES:
							packet = ObjectPool.get(AllianceIgnoreInvitesRequest);
							break;
						case RequestEnum.ALLIANCE_REQUEST_PUBLICS:
							packet = ObjectPool.get(AllianceRequestPublicsRequest);
							break;
					}
					break;

				case ProtocolEnum.CHAT_CLIENT:
					switch (header)
					{
						case RequestEnum.CHAT_SEND_CHAT:
							packet = ObjectPool.get(ChatSendChatRequest);
							break;
						case RequestEnum.CHAT_IGNORE_CHAT:
							packet = ObjectPool.get(ChatIgnoreChatRequest);
							break;
						case RequestEnum.CHAT_REPORT_CHAT:
							packet = ObjectPool.get(ChatReportChatRequest);
							break;
						case RequestEnum.CHAT_CHANGE_ROOM:
							packet = ObjectPool.get(ChatChangeRoomRequest);
							break;
					}
					break;

				case ProtocolEnum.LEADERBOARD_CLIENT:
					switch (header)
					{
						case RequestEnum.LEADERBOARD_REQUEST_LEADERBOARD:
							packet = ObjectPool.get(LeaderboardRequest);
							break;
						case RequestEnum.LEADERBOARD_REQUEST_PLAYER_PROFILE:
							packet = ObjectPool.get(LeaderboardRequestPlayerProfileRequest);
							break;
					}
					break;

				case ProtocolEnum.UNIVERSE_CLIENT:
					switch (header)
					{
						case RequestEnum.UNIVERSE_CHARACTER_CREATION_REQUEST:
							packet = ObjectPool.get(UniverseCreateCharacterRequest);
							break;
					}
					break;
			}
			if (packet)
				packet.init(protocolID, header);
			return packet;
		}

		public static function isImportant( protocolID:int, header:int ):Boolean
		{
			if (protocolID == ProtocolEnum.PROXY_CLIENT)
				return true;
			if (header == 1)
				return true;
			if (protocolID > 2)
				return true;
			return false;
		}
	}

}
