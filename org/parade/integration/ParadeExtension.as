//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.parade.integration
{
	import org.parade.core.ViewCommand;
	import org.parade.core.ViewController;
	import org.parade.core.ViewEvent;
	import org.robotlegs.extensions.eventCommandMap.api.IEventCommandMap;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.api.IExtension;
	import org.robotlegs.framework.impl.UID;
	import org.swiftsuspenders.Injector;

	/**
	 *
	 */
	public class ParadeExtension implements IExtension
	{
		[Inject]
		public var commandMap:IEventCommandMap;

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _injector:Injector;

		private const _uid:String = UID.create(ParadeExtension);

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function ParadeExtension()
		{

		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function extend( context:IContext ):void
		{
			_injector = context.injector;
			context.lifecycle.whenInitializing(handleContextSelfInitialize);
		}

		public function toString():String
		{
			return _uid;
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function handleContextSelfInitialize():void
		{
			_injector.map(ViewController).toSingleton(ViewController);
			_injector.injectInto(this);

			commandMap.map(ViewEvent.SHOW_VIEW, ViewEvent).toCommand(ViewCommand);
			commandMap.map(ViewEvent.DESTROY_VIEW, ViewEvent).toCommand(ViewCommand);
			commandMap.map(ViewEvent.DESTROY_ALL_VIEWS, ViewEvent).toCommand(ViewCommand);
			commandMap.map(ViewEvent.HIDE_VIEWS, ViewEvent).toCommand(ViewCommand);
			commandMap.map(ViewEvent.UNHIDE_VIEWS, ViewEvent).toCommand(ViewCommand);
		}
	}
}
