//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.extensions.messageCommandMap
{
	import org.robotlegs.extensions.messageCommandMap.api.IMessageCommandMap;
	import org.robotlegs.extensions.messageCommandMap.impl.MessageCommandMap;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.api.IExtension;
	import org.robotlegs.framework.impl.UID;

	public class MessageCommandMapExtension implements IExtension
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _uid:String = UID.create(MessageCommandMapExtension);

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function extend(context:IContext):void
		{
			context.injector.map(IMessageCommandMap).toSingleton(MessageCommandMap);
		}

		public function toString():String
		{
			return _uid;
		}
	}
}
