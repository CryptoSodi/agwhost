package com.controller
{
	import com.Application;
	import com.enum.TimeLogEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.enum.server.ResponseEnum;
	import com.event.ServerEvent;
	import com.model.asset.AssetModel;
	import com.service.loading.LoadPriority;
	import com.service.server.EightTrack;
	import com.service.server.IRequest;
	import com.service.server.IResponse;
	import com.service.server.ITickedResponse;
	import com.service.server.ITransactionResponse;
	import com.service.server.PacketFactory;
	import com.service.server.TinCan;
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
	import com.service.server.incoming.sector.SectorAlwaysVisibleBaselineResponse;
	import com.service.server.incoming.sector.SectorAlwaysVisibleUpdateResponse;
	import com.service.server.incoming.sector.SectorBaselineResponse;
	import com.service.server.incoming.sector.SectorFleetTravelAlertResponse;
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
	import com.service.server.incoming.starbase.StarbaseUnavailableRerollResponse;
	import com.service.server.incoming.universe.UniverseNeedCharacterCreateResponse;
	import com.service.server.incoming.universe.UniverseSectorListResponse;
	import com.service.server.outgoing.proxy.ProxyConnectToBattleRequest;
	import com.service.server.outgoing.proxy.TimeSyncRequest;
	import com.ui.modal.server.DisconnectedView;
	import com.util.TimeLog;
	
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	import flash.utils.Timer;
	
	import org.parade.core.IViewFactory;
	import org.parade.core.ViewEvent;
	
	import com.service.ExternalInterfaceAPI;

	public class ServerController
	{
		public static var INTERPOLATION:Number   = 0;
		public static var SERVER_TICK:int        = 0;
		public static var SIMULATED_TICK:int     = 100;
		public static var TIME_STEP:int          = 0;
		public static const TARGET_TIME_STEP:int = 100;

		private var _chatController:ChatController;
		private var _eventDispatcher:IEventDispatcher;
		private var _gameController:GameController;
		private var _settingsController:SettingsController;
		private var _tickedResponses:Vector.<ITickedResponse>;
		private var _viewFactory:IViewFactory;
		private var _temp:Number;
		private var _tempInterp:Number;
		private var _ticks:Array;
		private var _time:Number;
		private var _t:Number;
		private var _proxy:TinCan;
		private var _replayDecoder:EightTrack;
		private var _keepAliveTimer:Timer;


		[PostConstruct]
		public function init():void
		{
			_proxy = new TinCan();
			_tickedResponses = new Vector.<ITickedResponse>;
			_ticks = [];
			_time = 0;

			_keepAliveTimer = new Timer(60000);
			_keepAliveTimer.addEventListener(TimerEvent.TIMER, onKeepAliveTick, false, 0, true);
			TimeLog.serverController = this;

			_gameController.give(this);
			_chatController.give(this);
		}

		public function connect( ip:String, port:int, policy:String, devConnection:Boolean = false ):void
		{
			trace("Imperium IP proxy = " + ip + " , port = " + port.toString());
			TimeLog.startTimeLog(TimeLogEnum.CONNECT_TO_PROXY);
			//connect to the game's proxy server
			_proxy.init(ip, port, policy, TinCan.GAME, devConnection);
			_proxy.addResponseListener(handleResponse);
			_proxy.addConnectionListener(onProxyConnect);
			_proxy.serverController = this;

			//_settingsController.giveServerController(this);
		}

		private function onKeepAliveTick( e:TimerEvent ):void
		{
			var keepAliveTick:TimeSyncRequest = TimeSyncRequest(getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_TIME_SYNC));
			_proxy.send(keepAliveTick);
		}

		private function handleResponse( response:IResponse ):void
		{
			trace(response);
			//ExternalInterfaceAPI.logConsole("Imperium - response handling");
			switch (response.protocolID)
			{
				case ProtocolEnum.PROXY_CLIENT:
					switch (response.header)
					{
						case ResponseEnum.AUTHORIZATION:
							//ExternalInterfaceAPI.logConsole("Imperium - authorization");
							var serverEvent:ServerEvent = new ServerEvent(ServerEvent.AUTHORIZED, response);
							_eventDispatcher.dispatchEvent(serverEvent);
							break;
						case ResponseEnum.PROXY_BATTLE_DISCONNECTED:
							//ExternalInterfaceAPI.logConsole("Imperium - dc");
							_gameController.handleProxyBattleDisconnected(ProxyBattleDisconnectedResponse(response));
							break;
						case ResponseEnum.PROXY_SECTOR_DISCONNECTED:
							//ExternalInterfaceAPI.logConsole("Imperium - dc 1");
							_gameController.handleProxySectorDisconnected(ProxySectorDisconnectedResponse(response));
							break;
						case ResponseEnum.PROXY_STARBASE_DISCONNECTED:
							//ExternalInterfaceAPI.logConsole("Imperium - dc 2");
							_gameController.handleProxyStarbaseDisconnected(ProxyStarbaseDisconnectedResponse(response));
							break;
					}
					break;
				case ProtocolEnum.SECTOR_CLIENT:
					switch (response.header)
					{
						case ResponseEnum.SECTOR_ALWAYS_VISIBLE_BASELINE:
							//ExternalInterfaceAPI.logConsole("Imperium - visible");
							_gameController.handleSectorAlwaysVisibleBaselineResponse(SectorAlwaysVisibleBaselineResponse(response));
							break;
						case ResponseEnum.SECTOR_FLEET_TRAVEL_ALERT:
							//ExternalInterfaceAPI.logConsole("Imperium - alert");
							_gameController.sectorFleetTravelAlert(SectorFleetTravelAlertResponse(response));
							break;
					}
					break;
				case ProtocolEnum.STARBASE_CLIENT:
					switch (response.header)
					{
						case ResponseEnum.STARBASE_TRANSACTION_RESPONSE:
							_gameController.handleStarbaseTransactionResponse(ITransactionResponse(response));
							break;
						case ResponseEnum.STARBASE_BASELINE:
							_gameController.handleStarbaseBaselineResponse(StarbaseBaselineResponse(response));
							break;
						case ResponseEnum.STARBASE_BATTLE_ALERT:
							_gameController.starbaseBattleAlert(StarbaseBattleAlertResponse(response));
							break;
						case ResponseEnum.STARBASE_MISSION_COMPLETE:
							_gameController.handleStarbaseMissionCompleteResponse(StarbaseMissionCompleteResponse(response))
							break;
						case ResponseEnum.STARBASE_FLEET_DOCKED:
							_gameController.handleStarbaseFleetDockedResponse(StarbaseFleetDockedResponse(response))
							break;
						case ResponseEnum.STARBASE_BOUNTY_REWARD:
							_gameController.handleStarbaseBountyRewardResponse(StarbaseBountyRewardResponse(response));
							break;
						case ResponseEnum.STARBASE_BATTLELOG_LIST:
							_gameController.handleStarbaseBattleLogListResponse(BattleLogListResponse(response));
							break;
						case ResponseEnum.STARBASE_BATTLELOG_DETAILS:
							_gameController.handleStarbaseBattleLogDetailsResponse(BattleLogDetailsResponse(response));
							break;
						case ResponseEnum.STARBASE_OFFER_REDEEMED:
							_gameController.handleStarbaseOfferRedeemed(StarbaseOfferRedeemedResponse(response));
							break;
						case ResponseEnum.STARBASE_MOTD_LIST:
							_gameController.handleMessageOftheDayResponse(StarbaseMotdListResponse(response));
							break;
						case ResponseEnum.STARBASE_DAILY:
							_gameController.handleStarbaseDailyResponse(StarbaseDailyResponse(response));
							break;
						case ResponseEnum.STARBASE_DAILY_REWARD:
							_gameController.handleStarbaseDailyRewardResponse(StarbaseDailyRewardResponse(response));
							break;
						case ResponseEnum.STARBASE_AVAILABLE_REROLL:
							_gameController.handleStarbaseAvailableRerollResponse(StarbaseAvailableRerollResponse(response));
							break;
						case ResponseEnum.STARBASE_REROLL_CHANCE_RESULT:
							_gameController.handleStarbaseRerollChanceResponse(StarbaseRerollChanceResultResponse(response));
							break;
						case ResponseEnum.STARBASE_REROLL_RECEIVED_RESULT:
							_gameController.handleStarbaseRerollReceivedResponse(StarbaseRerollReceivedResultResponse(response));
							break;
						case ResponseEnum.STARBASE_MOVE_STARBASE_RESPONSE:
							_gameController.handleStarbaseMoveStarbaseResponse(StarbaseMoveStarbaseResponse(response));
							break;
						case ResponseEnum.STARBASE_ACHIEVEMENTS_RESPONSE:
							_gameController.handleStarbaseAchievementsResponse(StarbaseAchievementsResponse(response));
							break;
						case ResponseEnum.STARBASE_ALL_SCORES_RESPONSE:
							_gameController.handleStarbaseAllScoresResponse(StarbaseAllScoresResponse(response));
							break;
						case ResponseEnum.STARBASE_GET_PAYWALL_PAYOUTS_RESPONSE:
							_gameController.handleStarbaseGetPaywallPayoutsResponse(StarbaseGetPaywallPayoutsResponse(response));
							break;
						case ResponseEnum.STARBASE_UNAVAILABLE_REROLL:
							_gameController.handleStarbaseUnavailableRerollResponse(StarbaseUnavailableRerollResponse(response));
							break;
						case ResponseEnum.STARBASE_INSTANCED_MISSION_ALERT:
							_gameController.starbaseInstancedMissionAlert(StarbaseInstancedMissionAlertResponse(response));
							break;
					}
					break;
				case ProtocolEnum.MAIL_CLIENT:
					switch (response.header)
					{
						case ResponseEnum.MAIL_UNREAD:
							_gameController.handleUnreadResponse(MailUnreadResponse(response));
							break;
						case ResponseEnum.MAIL_INBOX:
							_gameController.handleMailInboxResponse(MailInboxResponse(response));
							break;
						case ResponseEnum.MAIL_DETAIL:
							_gameController.handleMailDetailResponse(MailDetailResponse(response));
							break;
					}
					break;
				case ProtocolEnum.CHAT_CLIENT:
					switch (response.header)
					{
						case ResponseEnum.CHAT_RESPONSE:
							_chatController.recievedMessage(ChatResponse(response));
							break;
						case ResponseEnum.CHAT_BASELINE:
							_gameController.handleChatBaselineResponse(ChatBaselineResponse(response));
							break;
						case ResponseEnum.CHAT_EVENT:
							//Do your own stuff here, Louis.
							break;
					}
					break;
				case ProtocolEnum.LEADERBOARD_CLIENT:
					switch (response.header)
					{
						case ResponseEnum.LEADERBOARD:
							_gameController.handleLeaderboardUpdate(LeaderboardResponse(response));
							break;
						case ResponseEnum.PLAYER_PROFILE:
							_gameController.handlePlayerProfile(PlayerProfileResponse(response));
							break;
						case ResponseEnum.WARFRONT_UPDATE:
							_gameController.handleWarfrontUpdate(WarfrontUpdateResponse(response));
							break;
					}
					break;
				case ProtocolEnum.ALLIANCE_CLIENT:
					switch (response.header)
					{
						case ResponseEnum.ALLIANCE_BASELINE:
							_gameController.handleAllianceBaselineResponse(AllianceBaselineResponse(response));
							break;
						case ResponseEnum.ALLIANCE_ROSTER:
							_gameController.handleAllianceRosterResponse(AllianceRosterResponse(response));
							break;
						case ResponseEnum.PUBLIC_ALLIANCES_RESPONSE:
							_gameController.handleAlliancePublicResponse(PublicAlliancesResponse(response));
							break;
						case ResponseEnum.GENERIC_ALLIANCE_RESPONSE:
							_gameController.handleAllianceGenericResponse(AllianceGenericResponse(response));
							break;
						case ResponseEnum.ALLIANCE_INVITE:
							_gameController.handleAllianceInviteResponse(AllianceInviteResponse(response));
					}
					break;
				case ProtocolEnum.UNIVERSE_CLIENT:
					switch (response.header)
					{
						case ResponseEnum.UNIVERSE_NEED_CHARACTER_CREATE:
							//ExternalInterfaceAPI.logConsole("Imperium - a");
							_gameController.handleUniverseNeedCharacterCreateResponse(UniverseNeedCharacterCreateResponse(response));
							break;
						case ResponseEnum.UNIVERSE_SECTOR_LIST:
							//ExternalInterfaceAPI.logConsole("Imperium - b");
							_gameController.handleUniverseSectorListResponse(UniverseSectorListResponse(response));
							break;
					}
					break;
			}
			if (response.isTicked)
			{
				//ExternalInterfaceAPI.logConsole("Imperium - response ticked");
				var tickedResponse:ITickedResponse = ITickedResponse(response);
				if (tickedResponse.isBaseline)
				{
					//we are listening to a new server
					//clear out the old responses and ticks
					_tickedResponses.length = 0;
					_ticks.length = 0;
					_time = 0;
					_ticks.push(tickedResponse.tick, tickedResponse.timeStep);
					//server tick to match the new server
					SERVER_TICK = tickedResponse.tick;
					updateSimulationTick();
					INTERPOLATION = .5; //slow things down for the first frame to give the server a chance to send the next update
					handleTickedResponse(tickedResponse);
				} else
				{
					if (tickedResponse.addTick)
						addTick(tickedResponse.tick, tickedResponse.timeStep);
					if (tickedResponse.tick <= SIMULATED_TICK)
						handleTickedResponse(tickedResponse);
					else
						_tickedResponses.push(tickedResponse);
				}
			}
		}

		private function handleTickedResponse( response:ITickedResponse ):void
		{
			switch (response.protocolID)
			{
				case ProtocolEnum.SECTOR_CLIENT:
					switch (response.header)
					{
						case ResponseEnum.SECTOR_BASELINE:
							_gameController.handleSectorBaselineResponse(SectorBaselineResponse(response));
							break;
						case ResponseEnum.SECTOR_ALWAYS_VISIBLE_UPDATE:
							_gameController.handleSectorAlwaysVisibleUpdateResponse(SectorAlwaysVisibleUpdateResponse(response));
							break;
						case ResponseEnum.SECTOR_UPDATE:
							_gameController.handleSectorUpdateResponse(SectorUpdateResponse(response));
							break;
					}
					break;
				case ProtocolEnum.BATTLE_CLIENT:
					switch (response.header)
					{
						case ResponseEnum.BATTLE_BASELINE:
						case ResponseEnum.BATTLE_UPDATE:
							_gameController.handleBattleDataResponse(BattleDataResponse(response));
							break;
						case ResponseEnum.BATTLE_DEBUG_LINES:
							_gameController.handleBattleDebugLinesResponse(BattleDebugLinesResponse(response));
							break;
						case ResponseEnum.BATTLE_HAS_ENDED:
							_gameController.handleBattleEnded(BattleHasEndedResponse(response));
							break;
					}
					break;
			}
		}

		public function getRequest( protocolID:int, header:int ):IRequest
		{
			return PacketFactory.getRequest(protocolID, header);
		}

		public function send( request:IRequest ):void
		{
			if (_proxy)
			{
				_proxy.send(request);
				_keepAliveTimer.reset();
				_keepAliveTimer.start();
			}
		}

		public function updateSimulationTime( time:Number ):Number
		{
			if (SIMULATED_TICK > SERVER_TICK)
				return 0;
			_tempInterp = time * INTERPOLATION;
			if (_tempInterp > .1)
				_tempInterp = .1;
			_time += _tempInterp;
			if (_time >= .1)
			{
				_time = _time - .1;
				updateSimulationTick();
			}
			return _tempInterp;
		}

		public function disconnect():void
		{
			_tickedResponses = new Vector.<ITickedResponse>;
			_ticks = [];
			_time = 0;

			_proxy.destroy();
			_proxy = null;

			_keepAliveTimer.reset();
			_keepAliveTimer.stop();
		}

		private function addTick( tick:int, tickTime:int ):void
		{
			if (tick <= SERVER_TICK)
				return;
			/*trace(tick, tickTime, SIMULATED_TICK, getTimer() - _t);
			   _t = getTimer();*/
			_ticks.push(tick, tickTime);
			if (SIMULATED_TICK > SERVER_TICK)
			{
				SERVER_TICK = tick;
				updateSimulationTick();
			} else
				SERVER_TICK = tick;
		}

		private function updateSimulationTick():void
		{
			if (_ticks.length > 0)
			{
				if (SIMULATED_TICK >= SERVER_TICK)
					_time = 0;
				SIMULATED_TICK = _ticks.shift();
				TIME_STEP = _ticks.shift();
				_temp = SERVER_TICK - SIMULATED_TICK;
				if (_temp <= 1)
					_temp = 0;
				_temp = _temp * .09; //Math.log(_temp) * .25;
				INTERPOLATION = _replayDecoder ? 1.0 : ((TARGET_TIME_STEP / TIME_STEP) + _temp);
				//trace(_temp, SERVER_TICK, SIMULATED_TICK, TARGET_TIME_STEP / TIME_STEP, INTERPOLATION, TIME_STEP);

				//check stored tick responses
				var response:ITickedResponse;
				while (_tickedResponses.length > 0 && _tickedResponses[0].tick <= SIMULATED_TICK)
				{
					response = _tickedResponses.shift();
					if (response.protocolID == _proxy.protocolListener)
						handleTickedResponse(response);
				}
			} else
				SIMULATED_TICK++;
		}

		private function onProxyConnect( state:int ):void
		{
			if (state == TinCan.CONNECTED)
			{
				//ExternalInterfaceAPI.logConsole("Imperium IP proxy connected");
				TimeLog.endTimeLog(TimeLogEnum.CONNECT_TO_PROXY);
				var serverEvent:ServerEvent = new ServerEvent(ServerEvent.LOGIN_TO_ACCOUNT);
				_eventDispatcher.dispatchEvent(serverEvent);
				_keepAliveTimer.start();
			} else if (state == TinCan.CONNECTION_LOST || state == TinCan.CONNECTION_FAILED)
			{
				//ExternalInterfaceAPI.logConsole("Imperium IP proxy connection lost...");
				var viewEvent:ViewEvent              = new ViewEvent(ViewEvent.SHOW_VIEW);
				var nDisconnectView:DisconnectedView = DisconnectedView(_viewFactory.createView(DisconnectedView));
				nDisconnectView.titleText = 'CONNECTION LOST';
				nDisconnectView.messageText = 'Your connection was no match for the Imperium!\nPlease refresh your browser.\n\nError Message: 3025 Proxy Error';
				viewEvent.targetView = nDisconnectView;
				_eventDispatcher.dispatchEvent(viewEvent);
			}
		}
		
		public function requestAllScores():void
		{
			_gameController.requestAllScores();
		}

		public function requestReplay( battleId:String ):void
		{
			if( Application.BATTLE_WEB_PATH == null )
			{
				return;
			}
			var absoluteUrl:String = Application.BATTLE_WEB_PATH + "?id="+battleId+".battle";
			trace( "request", absoluteUrl );
			AssetModel.instance.getFromCache( absoluteUrl, onBattleReplayData, LoadPriority.HIGH, true );
		}
		
		private function onBattleReplayData( data:ByteArray ):void
		{
			trace( "received battle replay data" );
			if( data.position==0)
			{
				// only uncompress once, the original data is changed
				// after the first replay, data position will be at the end of the stream
				data.uncompress();
			}
			data.position = 0;
			
			_replayDecoder = new EightTrack();
			_replayDecoder.init( data ); 
			
			_replayDecoder.addResponseListener(handleResponse);
			_replayDecoder.serverController = this;
			_replayDecoder.onReceive(null); // TODO: this will immediately dispatch and parse all the data
		}

		public function cleanupBattle():void
		{
			if( _replayDecoder )
			{
				_replayDecoder.destroy();
				_replayDecoder = null;
			}
			else
			{
				var battleDisconnect:ProxyConnectToBattleRequest = ProxyConnectToBattleRequest(getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_CONNECT_TO_BATTLE));
				send(battleDisconnect);
			}
		}
		
		public function set lockRead( v:Boolean ):void  { _proxy.lockRead = v; }

		[Inject]
		public function set chatController( v:ChatController ):void  { _chatController = v; }

		[Inject]
		public function set eventDispatcher( v:IEventDispatcher ):void  { _eventDispatcher = v; }

		[Inject]
		public function set gameController( v:GameController ):void  { _gameController = v; }

		[Inject]
		public function set settingsController( v:SettingsController ):void  { _settingsController = v; }

		[Inject]
		public function set viewFactory( v:IViewFactory ):void  { _viewFactory = v }

		public function set protocolListener( protocolID:int ):void
		{
			if (_proxy.protocolListener != protocolID)
				_tickedResponses.length = 0;
			_proxy.protocolListener = protocolID;
		}
	}
}
