//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.extensions.localEventMap
{
	import org.robotlegs.extensions.localEventMap.api.IEventMap;
	import org.robotlegs.extensions.localEventMap.impl.EventMap;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.api.IExtension;
	import org.robotlegs.framework.impl.UID;

	/**
	 * This extension creates local EventMaps on request
	 */
	public class LocalEventMapExtension implements IExtension
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _uid:String = UID.create(LocalEventMapExtension);

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function extend( context:IContext ):void
		{
			context.injector.map(IEventMap).toType(EventMap);
		}

		public function toString():String
		{
			return _uid;
		}
	}
}
