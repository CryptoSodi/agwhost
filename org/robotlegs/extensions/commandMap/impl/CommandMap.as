//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.extensions.commandMap.impl
{
	import flash.utils.Dictionary;
	import org.robotlegs.extensions.commandMap.api.ICommandMap;
	import org.robotlegs.extensions.commandMap.dsl.ICommandMapper;
	import org.robotlegs.extensions.commandMap.dsl.ICommandMappingFinder;
	import org.robotlegs.extensions.commandMap.api.ICommandTrigger;
	import org.robotlegs.extensions.commandMap.dsl.ICommandUnmapper;

	public class CommandMap implements ICommandMap
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _mappers:Dictionary = new Dictionary();

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function map(trigger:ICommandTrigger):ICommandMapper
		{
			return _mappers[trigger] ||= new CommandMapper(trigger);
		}

		public function unmap(trigger:ICommandTrigger):ICommandUnmapper
		{
			return _mappers[trigger];
		}

		public function getMapping(trigger:ICommandTrigger):ICommandMappingFinder
		{
			return _mappers[trigger];
		}
	}
}
