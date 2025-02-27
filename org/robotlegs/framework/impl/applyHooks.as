//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.framework.impl
{
	import org.swiftsuspenders.Injector;

	/*============================================================================*/
	/* Public Functions                                                           */
	/*============================================================================*/

	/**
	 * <p>A hook can be a function, object or class.</p>
	 *
	 * <p>When an object is passed it is expected to expose a "hook" method.</p>
	 *
	 * <p>When a class is passed, an instance of that class will be instantiated and called.
	 * If an injector is provided the instance will be created using that injector,
	 * otherwise the instance will be created manually.</p>
	 *
	 * @param hooks An array of hooks
	 * @param injector An optional Injector
	 */
	public function applyHooks(hooks:Array, injector:Injector = null):void
	{
		for each (var hook:Object in hooks)
		{
			if (hook is Class)
			{
				hook = injector
					? injector.getInstance(hook as Class)
					: new hook();
				hook.hook();
			}
			else if (hook is Function)
			{
				hook();
			}
			else
			{
				hook.hook();
			}
		}
	}
}
