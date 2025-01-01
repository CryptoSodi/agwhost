package com.event
{
	import flash.events.Event;

	public class TransitionEvent extends Event
	{
		public static const TRANSITION_BEGIN:String    = 'transitionBegin';

		public static const TRANSITION_FAILED:String   = 'transitionFailed';

		public static const TRANSITION_COMPLETE:String = 'transitionComplete';

		public var initEvent:StateEvent;
		public var cleanupEvent:StateEvent;

		public function TransitionEvent( type:String )
		{
			super(type, false, false);
		}

		public function addEvents( initEvent:StateEvent, cleanupEvent:StateEvent ):void
		{
			this.initEvent = initEvent;
			this.cleanupEvent = cleanupEvent;
		}
	}
}
