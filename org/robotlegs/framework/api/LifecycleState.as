//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.framework.api
{

	/**
	 * Robotlegs object lifecycle state
	 */
	public class LifecycleState
	{

		/*============================================================================*/
		/* Public Static Properties                                                   */
		/*============================================================================*/

		public static const UNINITIALIZED:String = "uninitialized";

		public static const INITIALIZING:String = "initializing";

		public static const ACTIVE:String = "active";

		public static const SUSPENDING:String = "suspending";

		public static const SUSPENDED:String = "suspended";

		public static const RESUMING:String = "resuming";

		public static const DESTROYING:String = "destroying";

		public static const DESTROYED:String = "destroyed";
	}
}
