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
	 * <p>A guard can be a function, object or class.</p>
	 * 
	 * <p>When a function is provided it is expected to return a Boolean when called.</p>
	 *
	 * <p>When an object is provided it is expected to expose an "approve" method
	 * that returns a Boolean.</p>
	 *
	 * <p>When a class is provided, an instance of that class will be instantiated and tested.
	 * If an injector is provided the instance will be created using that injector,
	 * otherwise the instance will be created manually.</p>
	 *
	 * @param guards An array of guards
	 * @param injector An optional Injector
	 *
	 * @return A Boolean value of false if any guard returns false
	 */
	public function guardsApprove(guards:Array, injector:Injector = null):Boolean
	{
		for each (var guard:Object in guards)
		{
			if (guard is Function)
			{
				if (guard() == true)
					continue;
				return false;
			}
			if (guard is Class)
			{
				guard = injector
					? injector.getInstance(guard as Class)
					: new guard();
			}
			if (guard.approve() == false)
				return false;
		}
		return true;
	}
}
