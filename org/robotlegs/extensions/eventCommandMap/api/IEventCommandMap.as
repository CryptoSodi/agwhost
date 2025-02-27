//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package org.robotlegs.extensions.eventCommandMap.api
{
	import org.robotlegs.extensions.commandMap.dsl.ICommandMapper;
	import org.robotlegs.extensions.commandMap.dsl.ICommandMappingFinder;
	import org.robotlegs.extensions.commandMap.dsl.ICommandUnmapper;

	public interface IEventCommandMap
	{
		function map(type:String, eventClass:Class = null, once:Boolean = false):ICommandMapper;

		function unmap(type:String, eventClass:Class = null):ICommandUnmapper;

		function getMapping(type:String, eventClass:Class = null):ICommandMappingFinder;
	}
}
