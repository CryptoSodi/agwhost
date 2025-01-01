package com.controller
{
	import com.enum.EventStateEnum;
	import com.model.event.EventModel;
	import com.model.event.EventVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BuffVO;
	import com.model.starbase.StarbaseModel;
	import com.service.server.incoming.data.BuffData;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import org.shared.ObjectPool;

	public class EventController
	{
		private var _eventModel:EventModel;
		private var _starbaseModel:StarbaseModel;
		private var _prototypeModel:PrototypeModel;

		private var _timer:Timer;

		private var _currentRunningEvent:EventVO;

		public function EventController()
		{
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, onUpdateEvents, false, 0, true);
		}

		public function addEvents( active:Vector.<IPrototype>, upcoming:Vector.<IPrototype>, now:Number ):void
		{
			var i:uint;
			var len:uint;

			var activeEvents:Vector.<EventVO>   = new Vector.<EventVO>;
			var upcomingEvents:Vector.<EventVO> = new Vector.<EventVO>;
			var currentEvent:EventVO;
			var currentProto:IPrototype;
			var currentActiveEvent:EventVO;
			var currentActiveEventHolder:EventVO;

			len = active.length;
			for (i = 0; i < len; ++i)
			{
				currentProto = active[i];
				currentEvent = new EventVO(currentProto, EventStateEnum.RUNNING, currentProto.getValue('eventEnds') - now);

				if (currentEvent.isUiTracking && (currentActiveEventHolder == null || (currentActiveEventHolder && currentEvent.timeRemainingMS < currentActiveEventHolder.timeRemainingMS)))
					currentActiveEventHolder = currentEvent;

				addBuffs(currentEvent);
				activeEvents.push(currentEvent);
			}

			len = upcoming.length;
			for (i = 0; i < len; ++i)
			{
				currentProto = upcoming[i];
				currentEvent = new EventVO(currentProto, EventStateEnum.UPCOMING, currentProto.getValue('eventBegins') - now);

				if (currentActiveEvent == null && currentEvent.isUiTracking && currentEvent.timeRemainingMS < 345600000 && (currentActiveEventHolder == null || (currentActiveEventHolder && currentEvent.
					timeRemainingMS <
					currentActiveEventHolder.timeRemainingMS)))
					currentActiveEventHolder = currentEvent;

				upcomingEvents.push(currentEvent);
			}

			currentActiveEvent = currentActiveEventHolder;

			_eventModel.addEvents(currentActiveEvent, activeEvents, upcomingEvents);
			_timer.start();
		}



		private function onUpdateEvents( e:TimerEvent ):void
		{
			var activeEvents:Vector.<EventVO>   = _eventModel.activeEvents;
			var upcomingEvents:Vector.<EventVO> = _eventModel.upcomingEvents;

			var i:uint;
			var len:uint;
			var currentEvent:EventVO;
			var currentActiveEvent:EventVO;
			var currentActiveEventHolder:EventVO;

			var updated:Boolean;

			len = activeEvents.length;
			for (i = 0; i < len; ++i)
			{
				currentEvent = activeEvents[i];
				if (currentEvent.timeRemainingMS <= 0)
				{
					updated = true;
					currentEvent.state = EventStateEnum.ENDED;
					removeBuffs(currentEvent);
					activeEvents.splice(i, 1);
					--i;
					--len;
				} else
				{
					if (currentEvent.isUiTracking && (currentActiveEventHolder == null || (currentActiveEventHolder && currentEvent.timeRemainingMS < currentActiveEventHolder.timeRemainingMS)))
						currentActiveEventHolder = currentEvent;
				}
			}

			len = upcomingEvents.length;
			for (i = 0; i < len; ++i)
			{
				currentEvent = upcomingEvents[i];
				if (currentEvent.timeRemainingMS <= 0)
				{
					updated = true;
					currentEvent.state = EventStateEnum.RUNNING;
					currentEvent.timeRemainingMS = currentEvent.ends - currentEvent.begins;
					addBuffs(currentEvent);
					upcomingEvents.splice(i, 1);
					--i;
					--len;
					activeEvents.push(currentEvent);
				} else
				{
					if (currentActiveEvent == null && currentEvent.isUiTracking && currentEvent.timeRemainingMS < 345600000 && (currentActiveEventHolder == null || (currentActiveEventHolder && currentEvent.
						timeRemainingMS <
						currentActiveEventHolder.timeRemainingMS)))
						currentActiveEventHolder = currentEvent;
				}
			}

			currentActiveEvent = currentActiveEventHolder;

			if (updated)
				_eventModel.addEvents(currentActiveEvent, activeEvents, upcomingEvents, true);
		}

		public function addBuffs( v:EventVO ):void
		{
			var buffs:Array = v.buffsGranted;
			var len:uint    = buffs.length;
			var buffData:BuffData;
			for (var i:uint = 0; i < len; ++i)
			{
				buffData = ObjectPool.get(BuffData);
				buffData.baseID = _starbaseModel.currentBaseID;
				buffData.began = v.begins;
				buffData.ends = v.ends;
				buffData.id = buffs[i];
				buffData.playerOwnerID = CurrentUser.id;
				buffData.prototype = _prototypeModel.getBuffPrototype(buffs[i]);
				buffData.timeRemaining = v.timeRemainingMS;
				_starbaseModel.importBuffData(buffData);
			}


		}

		public function removeBuffs( v:EventVO ):void
		{
			var buffs:Array = v.buffsGranted;
			var len:uint    = buffs.length;
			var currentBuff:String;
			for (var i:uint = 0; i < len; ++i)
			{
				currentBuff = buffs[i];
				_starbaseModel.removeBuffByID(currentBuff);
			}
		}

		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set eventModel( v:EventModel ):void  { _eventModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
	}
}
