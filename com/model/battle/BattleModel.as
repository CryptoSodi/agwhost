package com.model.battle
{
	import com.controller.ServerController;
	import com.enum.CategoryEnum;
	import com.enum.server.BattleEntityTypeEnum;
	import com.event.BattleEvent;
	import com.model.Model;
	import com.service.server.incoming.data.BattleEntityData;
	import com.service.server.incoming.starbase.StarbaseAvailableRerollResponse;
	import com.service.server.incoming.starbase.StarbaseRerollChanceResultResponse;
	import com.service.server.incoming.starbase.StarbaseRerollReceivedResultResponse;
	import com.service.server.incoming.starbase.StarbaseUnavailableRerollResponse;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;

	
	public class BattleModel extends Model
	{
		public var onRerollAdded:Signal;
		public var onRerollUpdated:Signal;

		public var onParticipantsAdded:Signal;

		public var alloy:uint                               = 0;
		public var credits:uint                             = 0;
		public var energy:uint                              = 0;
		public var synthetic:uint                           = 0;

		public var baseFactionColor:uint;
		public var baseOwnerID:String;
		public var battleEndTick:int;
		public var battleStartTick:int;
		public var battleServerAddress:String;
		public var isReplay:Boolean;
		public var finished:Boolean;
		public var focusLocation:Point                      = new Point();
		public var isBaseCombat:Boolean;
		
		public var mapSizeX:int;
		public var mapSizeY:int;
		
		public var galacticName:String;
		public var backgroundId:int;
		public var planetId:int;
		public var moonQuantity:int;
		public var asteroidQuantity:int;
		public var appearanceSeed:int;
		
		public var isInstancedMission:Boolean;
		public var missionID:String;
		public var oldGameState:String;
		public var oldSector:String;
		public var participants:Vector.<String>             = new Vector.<String>;
		public var participantRatings:Dictionary            = new Dictionary;
		public var wonLastBattle:Boolean;

		private var _availableRerolls:Dictionary;
		private var _unavailableReroll:Dictionary;
		private var _battleEntities:Vector.<BattleEntityVO> = new Vector.<BattleEntityVO>;
		private var _battleEntityLookup:Dictionary;
		private var _currentTick:int;

		[PostConstruct]
		public function init():void
		{
			galacticName = "";
			
			_availableRerolls = new Dictionary();
			_unavailableReroll = new Dictionary();
			onRerollAdded = new Signal(BattleRerollVO);
			onRerollUpdated = new Signal(BattleRerollVO);
			onParticipantsAdded = new Signal(String);
		}

		public function addBattleEntity( data:BattleEntityData ):void
		{
			var vo:BattleEntityVO = new BattleEntityVO();
			vo.category = (data.type == BattleEntityTypeEnum.SHIP) ? CategoryEnum.SHIP : CategoryEnum.BUILDING;
			vo.healthPercent = data.currentHealth / data.maxHealth;
			vo.id = data.id;
			vo.ownerID = data.ownerId;
			vo.prototype = (data.type == BattleEntityTypeEnum.SHIP) ? data.shipPrototype : data.buildingPrototype;
			_battleEntities.push(vo);
			if (_battleEntityLookup == null)
				_battleEntityLookup = new Dictionary(true);
			_battleEntityLookup[data.id] = vo;
		}

		public function getBattleEntitiesByPlayer( playerID:String, category:String = CategoryEnum.SHIP ):Vector.<BattleEntityVO>
		{
			var entities:Vector.<BattleEntityVO> = new Vector.<BattleEntityVO>;
			for (var i:int = 0; i < _battleEntities.length; i++)
			{
				if (_battleEntities[i].ownerID == playerID && _battleEntities[i].category == category)
					entities.push(_battleEntities[i]);
			}
			return entities;
		}

		public function getBattleEntity( id:String ):BattleEntityVO  { return _battleEntityLookup[id]; }

		public function getParticipantRating( id:String ):int
		{
			if (participantRatings.hasOwnProperty(id))
				return participantRatings[id];
			return 1;
		}

		public function addAvailableReroll( v:StarbaseAvailableRerollResponse ):void
		{
			var battleReroll:BattleRerollVO = new BattleRerollVO(v.battleKey, v.blueprintPrototype, v.timeoutDelta);
			_availableRerolls[v.battleKey] = battleReroll;
			onRerollAdded.dispatch(battleReroll);
		}

		public function addUnavailableReroll( v:StarbaseUnavailableRerollResponse ):void
		{
			_unavailableReroll[v.battleKey] = v.reason;
		}

		public function updateRerollFromScan( v:StarbaseRerollChanceResultResponse ):void
		{
			if (v.battleKey in _availableRerolls)
			{
				var currentAvailableReroll:BattleRerollVO = _availableRerolls[v.battleKey];
				currentAvailableReroll.scanned(v.blueprintPrototype, v.alloyReward, v.creditsReward, v.energyReward, v.syntheticReward);
				onRerollUpdated.dispatch(currentAvailableReroll);
			}
		}

		public function updateRerollFromReroll( v:StarbaseRerollReceivedResultResponse ):void
		{
			if (v.battleKey in _availableRerolls)
			{
				var currentAvailableReroll:BattleRerollVO = _availableRerolls[v.battleKey];
				currentAvailableReroll.rerolled(v.blueprintPrototype);
				onRerollUpdated.dispatch(currentAvailableReroll);
			}
		}

		public function removeRerollByID( id:String ):void
		{
			if (id in _availableRerolls)
				delete _availableRerolls[id];
		}

		public function getAvailableRerollByID( id:String ):BattleRerollVO
		{
			if (id in _availableRerolls)
			{
				var currentAvailableReroll:BattleRerollVO = _availableRerolls[id];
				if (currentAvailableReroll.timeRemaining > 0)
					return currentAvailableReroll;
				else
				{
					delete _availableRerolls[id];
					return null
				}
			}

			return null;
		}

		public function getUnavailableRerollByID( id:String ):int
		{
			if (id in _unavailableReroll)
			{
				var reroll:int = _unavailableReroll[id];
				delete _unavailableReroll[id];
				return reroll;
			}
			return 0;
		}

		public function getAllAvailableRerolls():Vector.<BattleRerollVO>
		{
			var battleRerolls:Vector.<BattleRerollVO> = new Vector.<BattleRerollVO>;
			var currentAvailableReroll:BattleRerollVO;
			for (var key:String in _availableRerolls)
			{
				currentAvailableReroll = _availableRerolls[key];
				if (currentAvailableReroll.timeRemaining > 0 && !currentAvailableReroll.hasPaid)
					battleRerolls.push(currentAvailableReroll);
				else
					delete _availableRerolls[key];
			}
			return battleRerolls;
		}

		public function get battleEntities():Vector.<BattleEntityVO>  { return _battleEntities; }

		public function addParticipant( participant:String ):void
		{
			onParticipantsAdded.dispatch(participant);
			participants.push(participant);
		}

		public function reconnect():void
		{
			var event:Event;
			event = new BattleEvent(BattleEvent.BATTLE_JOIN, battleServerAddress);
			dispatch(event);
		}
		
		/**
		 * @return The time remaining in miliseconds
		 */
		public function get timeRemaining():int
		{
			_currentTick = (ServerController.SIMULATED_TICK < battleStartTick) ? battleStartTick : ServerController.SIMULATED_TICK;
			if (_currentTick > battleEndTick)
				_currentTick = battleEndTick;
			return (battleEndTick - _currentTick) * 100;
		}

		public function cleanup():void
		{
			_battleEntities.length = 0;
			_battleEntityLookup = null;
			focusLocation.setTo(0, 0);
			participants.length = 0;
			participantRatings.length = 0;
		}
	}
}


