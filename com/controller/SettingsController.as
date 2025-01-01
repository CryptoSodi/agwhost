package com.controller
{
	import com.Application;
	import com.controller.sound.SoundController;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.model.chat.ChatModel;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.service.server.outgoing.starbase.StarbaseSetClientSettingsRequest;
	import com.ui.core.component.label.Label;

	import flash.display.StageDisplayState;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import org.console.Cc;
	import org.starling.core.Starling;

	public class SettingsController
	{
		private var _agentGreetingsViewed:int;
		private var _chatModel:ChatModel;
		private var _fleetModel:FleetModel;
		private var _sendTimer:Timer;
		private var _serverController:ServerController;
		private var _soundController:SoundController;

		[PostConstruct]
		public function init():void
		{
			_sendTimer = new Timer(1000)
			_sendTimer.addEventListener(TimerEvent.TIMER, onTimerFinished, false, 0, true);
			Cc.addSlashCommand('fullscreen', toggleFullScreen);
			Cc.addSlashCommand('loc', onLoc);
		}

		public function toggleFullScreen():void
		{
			if (Application.STAGE.displayState == StageDisplayState.NORMAL)
				Application.STAGE.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			else
				Application.STAGE.displayState = StageDisplayState.NORMAL;

			startTimer();
		}

		public function toggleSFXMute():void
		{
			_soundController.toggleSFXMute();
			startTimer();
		}

		public function toggleMusicMute():void
		{
			_soundController.toggleMusicMute();
			startTimer();
		}

		public function setSFXVolume( v:Number ):void
		{
			_soundController.setSFXVolume(v);
			startTimer();
		}

		public function setMusicVolume( v:Number ):void
		{
			_soundController.setMusicVolume(v);
			startTimer();
		}

		public function save( stuff:* = null ):void  { startTimer(); }

		private function startTimer():void
		{
			if (_sendTimer.running)
				_sendTimer.reset();

			_sendTimer.start();
		}

		private function onTimerFinished( e:TimerEvent ):void
		{
			_sendTimer.stop();
			sendSettings();
		}

		private function writeFleetGroupsToSettings():Object
		{
			var fleetGroups:Object = {};

			for each (var fleetVO:FleetVO in _fleetModel.fleets)
			{
				if (fleetVO.fleetGroupData.length == 0)
					continue;

				fleetGroups[fleetVO.id] = {};

				for (var groupKey:String in fleetVO.fleetGroupData)
				{
					var groupIdxs:String = fleetVO.fleetGroupData[groupKey];
					if (groupIdxs && groupIdxs.length > 0)
						fleetGroups[fleetVO.id][groupKey] = groupIdxs;
				}
			}

			return fleetGroups;
		}

		private function readFleetGroupsFromSettings( settings:Object ):void
		{
			if (!settings.hasOwnProperty("fleetGroups"))
				return;
			var fleetGroups:Object = settings["fleetGroups"];
			for each (var fleetVO:FleetVO in _fleetModel.fleets)
			{
				if (fleetGroups.hasOwnProperty(fleetVO.id))
				{
					for (var groupKey:String in fleetGroups[fleetVO.id])
					{
						var groupIdxsString:String = fleetGroups[fleetVO.id][groupKey];
						if (groupIdxsString && groupIdxsString.length > 0)
						{
							if (groupIdxsString.indexOf(',') != -1)
								fleetVO.fleetGroupData[groupKey] = groupIdxsString.split(',').join('');
							else
								fleetVO.fleetGroupData[groupKey] = groupIdxsString;
						}
					}
				}
			}
		}

		private function sendSettings():void
		{
			var areSFXMuted:Boolean                           = _soundController.areSFXMuted;
			var sfxVolume:Number                              = _soundController.sfxVolume;
			var isMusicMuted:Boolean                          = _soundController.isMusicMuted;
			var musicVolume:Number                            = _soundController.musicVolume;
			var stageState:String                             = Application.STAGE.displayState;
			var defaultChatChannel:int                        = -1;

			if (_chatModel.defaultChannel != null)
				defaultChatChannel = _chatModel.defaultChannel.channelID;

			var agentGreetingsViewed:int                      = _agentGreetingsViewed;

			var settings:Object                               =
				{
					'areSFXMuted':areSFXMuted,
					'sfxVolume':sfxVolume,
					'isMusicMuted':isMusicMuted,
					'musicVolume':musicVolume,
					'stageState':stageState,
					'defaultChatChannel':defaultChatChannel,
					'agentGreetingsViewed':agentGreetingsViewed,
					'fleetGroups':writeFleetGroupsToSettings()
				};

			//var sendSettings:StarbaseSetClientSettingsRequest = StarbaseSetClientSettingsRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_SET_CLIENT_SETTINGS));
			//sendSettings.settings = JSON.stringify(settings);
			//_serverController.send(sendSettings);
		}

		public function setSettings( settings:Object ):void
		{
			if (settings)
			{
				var areSFXMuted:Boolean      = Boolean(settings['areSFXMuted']);
				var sfxVolume:Number         = Number(settings['sfxVolume']);
				var isMusicMuted:Boolean     = Boolean(settings['isMusicMuted']);
				var musicVolume:Number       = Number(settings['musicVolume']);

				var stageState:String        = String(settings['stageState']);
				//var defaultChatChannel:int   = int(settings['defaultChatChannel']);
				var agentGreetingsViewed:int = int(settings['agentGreetingsViewed']);

				readFleetGroupsFromSettings(settings);

				if (areSFXMuted != _soundController.areSFXMuted)
					_soundController.toggleSFXMute();

				if (!isNaN(sfxVolume))
				{
					if (sfxVolume != _soundController.sfxVolume)
						_soundController.setSFXVolume(sfxVolume);
				} else
					_soundController.setSFXVolume(0.5)


				if (isMusicMuted != _soundController.isMusicMuted)
					_soundController.toggleMusicMute();

				if (!isNaN(musicVolume))
				{
					if (musicVolume != _soundController.musicVolume)
					{
						_soundController.setMusicVolume(musicVolume);
					}
				} else
					_soundController.setMusicVolume(0.5);

				//_chatModel.overrideDefaultChannelByChannelID(defaultChatChannel);
				_agentGreetingsViewed = agentGreetingsViewed;
			} else
				_agentGreetingsViewed = 0;

			_chatModel.onDefaultChannelUpdated.add(save);
		}

		public function hasAgentGreetingBeenViewed( agentID:int ):Boolean
		{
			var bit:int = _agentGreetingsViewed & (1 << agentID);

			if (bit != 0)
				return true;
			else
				return false;
		}

		public function setAgentGreetingViewed( agentID:int ):void
		{
			_agentGreetingsViewed |= 1 << agentID;
			save();
		}

		private function onLoc( cmd:String ):void
		{
			if (cmd == 'on')
				Label.showUnlocalizedString = true;
			else if (cmd == 'off')
				Label.showUnlocalizedString = false;
		}

		public function giveServerController( v:ServerController ):void  { _serverController = v; }

		public function get agentGreetingsViewed():int  { return _agentGreetingsViewed; }

		[Inject]
		public function set chatModel( v:ChatModel ):void  { _chatModel = v; }

		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }

		[Inject]
		public function set soundController( v:SoundController ):void  { _soundController = v; }
	}
}


