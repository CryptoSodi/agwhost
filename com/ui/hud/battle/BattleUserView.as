package com.ui.hud.battle
{
	import com.Application;
	import com.enum.FactionEnum;
	import com.enum.PositionEnum;
	import com.enum.ToastEnum;
	import com.enum.ui.PanelEnum;
	import com.model.fleet.FleetVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.label.Label;
	import com.ui.core.effects.EffectFactory;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	public class BattleUserView extends BattleBaseView
	{
		private var _battleTimer:Timer;

		private var _hitArea:Sprite;
		private var _leftAttach:Sprite;
		private var _rightAttach:Sprite;

		private var _timeContainer:ScaleBitmap;

		private var _playerFrames:Dictionary;

		private var _overrideFaction:String;

		private var _timeRemainingHeader:Label;
		private var _timeRemaining:Label;

		private var _bubblePrototype:IPrototype;

		private var _isPlayerInvolved:Boolean;
		private var _isBaseCombat:Boolean;
		private var _isPlayersBase:Boolean;
		private var _isInstancedMission:Boolean;

		private var _firstBubbleThreshold:Number;
		private var _secondBubbleThreshold:Number;
		private var _thirdBubbleThreshold:Number;
		private var _tempTime:Number;

		private var _timeRemainingText:String    = 'CodeString.BattleUserView.TimeRemaining'; //TIME REMAINING

		private var _firstThresholdTitle:String  = 'CodeString.Toast.BattleBubbleFirstThresholdTitle'; //Defenses Breached!
		private var _firstThresholdBody:String   = 'CodeString.Toast.BattleBubbleFirstThresholdBody'; //Your opponent gained 18 hours of Base Protection

		private var _secondThresholdTitle:String = 'CodeString.Toast.BattleBubbleSecondThresholdTitle'; //Base Crippled!
		private var _secondThresholdBody:String  = 'CodeString.Toast.BattleBubbleSecondThresholdBody'; //Your opponent gained 24 hours of Base Protection

		private var _thirdThresholdTitle:String  = 'CodeString.Toast.BattleBubbleThirdThresholdTitle'; //Total Devastation!
		private var _thirdThresholdBody:String   = 'CodeString.Toast.BattleBubbleThirdThresholdBody'; //Your opponent gained 36 hours of Base Protection

		private const MIN_WIDTH:Number           = 732;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addListenerVitalPercentUpdates(onHealthUpdated);
			presenter.addStartListener(onBattleStart);

			_leftAttach = new Sprite();
			_leftAttach.x = 2;

			_rightAttach = new Sprite();
			_rightAttach.x = 375;
			_leftAttach.y = _rightAttach.y = 3;

			_battleTimer = new Timer(1000, 0);
			addListener(_battleTimer, TimerEvent.TIMER, onBattleTimer);

			_isPlayerInvolved = presenter.isPlayerInCombat(CurrentUser.id);
			_isBaseCombat = presenter.isBaseCombat;
			_isPlayersBase = presenter.isPlayerBaseOwner(CurrentUser.id);
			_isInstancedMission = presenter.isInstancedMission();

			if (_isBaseCombat)
			{
				_bubblePrototype = presenter.getStoreItemPrototypeByName('Bubble_28d');
				_firstBubbleThreshold = presenter.getConstantPrototypeValueByName('protectionLowDamageThreshold');
				_secondBubbleThreshold = presenter.getConstantPrototypeValueByName('protectionMediumDamageThreshold');
				_thirdBubbleThreshold = presenter.getConstantPrototypeValueByName('protectionHighDamageThreshold');
			}

			_playerFrames = new Dictionary();
			_overrideFaction = '';
			var participantIDs:Vector.<String> = presenter.participants;
			var len:uint                       = participantIDs.length;
			var participants:Vector.<PlayerVO> = new Vector.<PlayerVO>();
			var i:uint;
			var currentPlayer:PlayerVO;
			for (; i < len; ++i)
			{

				currentPlayer = presenter.getPlayer(presenter.participants[i]);
				participants.push(currentPlayer);
				if(_isInstancedMission)
				{
					if(i == 0)
						_overrideFaction = currentPlayer.faction;
				}
				else if (_overrideFaction == '' && !_isPlayerInvolved && currentPlayer.faction != FactionEnum.IMPERIUM && currentPlayer.isNPC == false)
					_overrideFaction = currentPlayer.faction;
			}

			len = participants.length;
			for (i = 0; i < len; ++i)
				addParticipantFrame(participants[i], (_isInstancedMission) ? _overrideFaction : ((_isPlayerInvolved) ? CurrentUser.faction : _overrideFaction));

			layoutParticipants();

			_timeContainer = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_NOTCHED_LEFT_SMALL);
			_timeContainer.width = 90;
			_timeContainer.height = 75;
			_timeContainer.x = 281;
			_timeContainer.y = 3;

			_timeRemainingHeader = new Label(24, 0xf0f0f0, 88, 30);
			_timeRemainingHeader.x = _timeContainer.x;
			_timeRemainingHeader.y = _timeContainer.y + 15;
			_timeRemainingHeader.align = TextFormatAlign.CENTER;
			_timeRemainingHeader.text = _timeRemainingText;

			_timeRemaining = new Label(34, 0xf0f0f0, 88, 40);
			_timeRemaining.useLocalization = false;
			_timeRemaining.x = _timeRemainingHeader.x;
			_timeRemaining.y = _timeRemainingHeader.y + _timeRemainingHeader.textHeight;
			_timeRemaining.align = TextFormatAlign.CENTER;
			_timeRemaining.constrictTextToSize = false;
			_timeRemaining.text = '';z

			addChild(_leftAttach)
			addChild(_rightAttach);
			addChild(_timeContainer);
			addChild(_timeRemainingHeader);
			addChild(_timeRemaining);

			addHitArea();
			addEffects();
			effectsIN();
			onStageResize();

			visible = !presenter.inFTE;

			presenter.addListenerOnParticipantsAdded(onParticipantsAdded);
		}

		private function onHealthUpdated( id:String, percent:Number ):void
		{
			if (_playerFrames.hasOwnProperty(id))
			{
				_isPlayerInvolved = presenter.isPlayerInCombat(CurrentUser.id);

				if (!_playerFrames[id].isNPC && _isBaseCombat && _isPlayerInvolved && !_isPlayersBase && id != CurrentUser.id)
				{
					var currentPercent:Number = _playerFrames[id].percent;
					if (currentPercent > _firstBubbleThreshold && percent <= _firstBubbleThreshold)
						showToast(ToastEnum.BUBBLE_ALERT, _bubblePrototype, _firstThresholdTitle, _firstThresholdBody);
					else if (currentPercent > _secondBubbleThreshold && percent <= _secondBubbleThreshold)
						showToast(ToastEnum.BUBBLE_ALERT, _bubblePrototype, _secondThresholdTitle, _secondThresholdBody);
					else if (currentPercent > _thirdBubbleThreshold && percent <= _thirdBubbleThreshold)
						showToast(ToastEnum.BUBBLE_ALERT, _bubblePrototype, _thirdThresholdTitle, _thirdThresholdBody);
				}


				_playerFrames[id].percent = percent;
			}
		}

		private function onBattleTimer( e:TimerEvent ):void
		{
			if (!presenter.battleRunning)
				_battleTimer.stop();
			else
			{
				_tempTime = presenter.battleTimeRemaining * .001 | 0;
				_timeRemaining.text = (_tempTime / 60 | 0) + ":";
				_tempTime = _tempTime % 60;
				_timeRemaining.text = _timeRemaining.text + ((_tempTime > 9) ? _tempTime : "0" + _tempTime);
			}
		}

		private function onBattleStart():void
		{
			onBattleTimer(null);
			_battleTimer.start();
		}

		private function onParticipantsAdded( id:String ):void
		{
			if (!_playerFrames.hasOwnProperty(id))
			{
				var player:PlayerVO = presenter.getPlayer(id);
				addParticipantFrame(player, (_isPlayerInvolved) ? CurrentUser.faction : _overrideFaction);
				layoutParticipants();
			}
		}

		private function addParticipantFrame( player:PlayerVO, leftAttachFaction:String ):void
		{
			var sameFactionAsCurrentUser:Boolean = (player.faction == CurrentUser.faction);
			if(_isInstancedMission)
				sameFactionAsCurrentUser = (player.faction == leftAttachFaction);
			
			var frame:PlayerBattleFrame          = new PlayerBattleFrame(player, !sameFactionAsCurrentUser);

			if (CurrentUser.id == player.id)
			{
				var fleet:FleetVO = presenter.getSelectedFleet();
				frame.name = (fleet) ? fleet.name : player.name;
			} else
				frame.name = player.name;

			frame.level = String(presenter.getParticipantRating(player.id));
			frame.percent = presenter.getHealthPercentByPlayerID(player.id);
			presenter.loadSmallImage(player.avatarName, frame.onAvatarLoaded);

			if (presenter.isPlayerBaseOwner(player.id))
				frame.setBubbleInformation(_firstBubbleThreshold, _secondBubbleThreshold, _thirdBubbleThreshold);

			_playerFrames[player.id] = frame;

			if (leftAttachFaction == player.faction)
				_leftAttach.addChild(frame);
			else
				_rightAttach.addChild(frame);
		}

		private function layoutParticipants():void
		{
			var i:uint;
			var currentFrame:PlayerBattleFrame;
			var yPos:Number;

			if (_isPlayerInvolved)
				yPos = 84;
			else
				yPos = 3;

			for (; i < _leftAttach.numChildren; ++i)
			{
				currentFrame = PlayerBattleFrame(_leftAttach.getChildAt(i));
				if (currentFrame.id == CurrentUser.id)
					currentFrame.y = 3;
				else
				{
					currentFrame.y = yPos;
					yPos += currentFrame.height + 5;
				}
			}

			yPos = 3;
			for (i = 0; i < _rightAttach.numChildren; ++i)
			{
				currentFrame = PlayerBattleFrame(_rightAttach.getChildAt(i));
				currentFrame.y = yPos;

				yPos += currentFrame.height + 5;
			}
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.LEFT, PositionEnum.TOP, onStageResize));
		}

		private function onStageResize( e:Event = null ):void
		{
			this.scaleX = this.scaleY = Application.SCALE;
		}

		private function sortByFaction( playerOne:PlayerVO, playerTwo:PlayerVO ):int
		{
			if (playerOne.id == CurrentUser.id)
				return -1;

			if (playerTwo.id == CurrentUser.id)
				return -1;

			if (playerOne.faction == CurrentUser.faction)
				return -1;

			if (playerTwo.faction == CurrentUser.faction)
				return -1;

			if (playerOne.faction != playerTwo.faction)
			{
				if (playerOne.faction == FactionEnum.SOVEREIGNTY)
					return -1;
				else if (playerTwo.faction == FactionEnum.SOVEREIGNTY)
					return 1;

				if (playerOne.faction == FactionEnum.TYRANNAR)
					return -1;
				else if (playerTwo.faction == FactionEnum.TYRANNAR)
					return 1;

				if (playerOne.faction == FactionEnum.IGA)
					return -1;
				else if (playerTwo.faction == FactionEnum.IGA)
					return 1;
			}

			return 0;
		}

		override public function destroy():void
		{
			presenter.removeListenerVitalPercentUpdates(onHealthUpdated);
			presenter.removeListenerOnParticipantsAdded(onParticipantsAdded);
			presenter.removeStartListener(onBattleStart);
			super.destroy();

			_battleTimer.stop();
			_battleTimer = null;

			_hitArea = null;

			for (var id:String in _playerFrames)
			{
				_playerFrames[id].destroy();
				_playerFrames[id] = null;
				delete _playerFrames[id];
			}
			_playerFrames = null;

			if (_timeRemainingHeader)
				_timeRemainingHeader.destroy();

			_timeRemainingHeader = null;

			if (_timeRemaining)
				_timeRemaining.destroy();

			_timeRemaining = null;
		}
	}
}
