package com.model.event
{
	import com.model.Model;

	import org.osflash.signals.Signal;

	public class EventModel extends Model
	{
		public var onEventsUpdated:Signal;

		private var _currentActiveEvent:EventVO;
		private var _activeEvents:Vector.<EventVO>;
		private var _upcomingEvents:Vector.<EventVO>;

		public function EventModel()
		{
			super();
			onEventsUpdated = new Signal(EventVO, Vector.<EventVO>, Vector.<EventVO>);
		}

		public function addEvents( currentActiveEvent:EventVO, activeEvent:Vector.<EventVO>, upcomingEvents:Vector.<EventVO>, update:Boolean = false ):void
		{
			_currentActiveEvent = currentActiveEvent;
			_activeEvents = activeEvent;
			_upcomingEvents = upcomingEvents;

			if (update)
				onEventsUpdated.dispatch(_currentActiveEvent, _activeEvents, _upcomingEvents);
		}

		public function get currentActiveEvent():EventVO  { return _currentActiveEvent; }
		public function get activeEvents():Vector.<EventVO>  { return _activeEvents; }
		public function get upcomingEvents():Vector.<EventVO>  { return _upcomingEvents; }
	}
}
