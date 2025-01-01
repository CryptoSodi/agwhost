//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.extensions.eventDispatcher
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.api.IExtension;
	import org.robotlegs.framework.impl.UID;

	/**
	 * This extension maps an IEventDispatcher into a context's injector.
	 */
	public class EventDispatcherExtension implements IExtension
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _uid:String = UID.create(EventDispatcherExtension);

		private var _eventDispatcher:IEventDispatcher;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function EventDispatcherExtension(eventDispatcher:IEventDispatcher = null)
		{
			_eventDispatcher = eventDispatcher || IEventDispatcher(new EventDispatcher());
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function extend(context:IContext):void
		{
			context.injector.map(IEventDispatcher).toValue(_eventDispatcher);
		}

		public function toString():String
		{
			return _uid;
		}
	}
}
