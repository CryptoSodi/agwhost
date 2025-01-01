//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.extensions.messageCommandMap.impl
{
	import flash.utils.Dictionary;
	import org.swiftsuspenders.Injector;
	import org.robotlegs.framework.api.IMessageDispatcher;
	import org.robotlegs.extensions.commandMap.api.ICommandMap;
	import org.robotlegs.extensions.commandMap.api.ICommandTrigger;
	import org.robotlegs.extensions.commandMap.dsl.ICommandMapper;
	import org.robotlegs.extensions.commandMap.dsl.ICommandMappingFinder;
	import org.robotlegs.extensions.commandMap.dsl.ICommandUnmapper;
	import org.robotlegs.extensions.messageCommandMap.api.IMessageCommandMap;

	public class MessageCommandMap implements IMessageCommandMap
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _triggers:Dictionary = new Dictionary();

		private var _injector:Injector;

		private var _dispatcher:IMessageDispatcher;

		private var _commandMap:ICommandMap;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function MessageCommandMap(injector:Injector, dispatcher:IMessageDispatcher, commandMap:ICommandMap)
		{
			_injector = injector;
			_dispatcher = dispatcher;
			_commandMap = commandMap;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function map(message:Object, once:Boolean = false):ICommandMapper
		{
			const trigger:ICommandTrigger =
				_triggers[message] ||=
				createTrigger(message, once);
			return _commandMap.map(trigger);
		}

		public function unmap(message:Object):ICommandUnmapper
		{
			return _commandMap.unmap(getTrigger(message));
		}

		public function getMapping(message:Object):ICommandMappingFinder
		{
			return _commandMap.getMapping(getTrigger(message));
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function createTrigger(message:Object, once:Boolean = false):ICommandTrigger
		{
			return new MessageCommandTrigger(_injector, _dispatcher, message, once);
		}

		private function getTrigger(message:Object):ICommandTrigger
		{
			return _triggers[message];
		}
	}
}
