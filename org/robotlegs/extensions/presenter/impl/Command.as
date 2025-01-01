package org.robotlegs.extensions.presenter.impl
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	import org.swiftsuspenders.Injector;

	import org.robotlegs.extensions.eventCommandMap.api.IEventCommandMap;

	public class Command
	{
		[Inject]
		public var commandMap:IEventCommandMap;

		[Inject]
		public var eventDispatcher:IEventDispatcher;

		[Inject]
		public var injector:Injector;

		/**
		 * @inheritDoc
		 */
		public function execute():void
		{
		}

		/**
		 * Dispatch helper method
		 *
		 * @param event The <code>Event</code> to dispatch on the <code>IContext</code>'s <code>IEventDispatcher</code>
		 */
		protected function dispatch( event:Event ):Boolean
		{
			//if(eventDispatcher.hasEventListener(event.type))
			return eventDispatcher.dispatchEvent(event);
			return false;
		}
	}
}
