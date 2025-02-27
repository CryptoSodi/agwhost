//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.framework.api
{

	/**
	 * A hook is expected to expose a "hook" method
	 *
	 * <p>Note: a hook does not need to implement this interface.</p>
	 */
	public interface IHook
	{
		function hook():void;
	}
}
