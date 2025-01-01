package com.model
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class Model
	{
		protected var _eventDispatcher:IEventDispatcher;

		/**
		 * Dispatch helper method
		 *
		 * @param event The Event to dispatch on the <code>IContext</code>'s <code>IEventDispatcher</code>
		 */
		protected function dispatch( event:Event ):Boolean
		{
			if (_eventDispatcher.hasEventListener(event.type))
				return _eventDispatcher.dispatchEvent(event);
			return false;
		}

		[Inject]
		public function set eventDispatcher( value:IEventDispatcher ):void  { _eventDispatcher = value; }
	}
}
