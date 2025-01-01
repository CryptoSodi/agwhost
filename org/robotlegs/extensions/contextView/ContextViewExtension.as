//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.extensions.contextView
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;

	import org.hamcrest.object.instanceOf;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.api.IExtension;
	import org.robotlegs.framework.impl.UID;
	import org.swiftsuspenders.Injector;

	/**
	 * <p>This Extension waits for a DisplayObjectContainer to be added as a configuration
	 * and maps that container into the context's injector.</p>
	 *
	 * <p>It should be installed before context initialization.</p>
	 */
	public class ContextViewExtension implements IExtension
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _uid:String = UID.create(ContextViewExtension);

		private var _injector:Injector;

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		// todo: accept contextView via constructor and use that if provided

		public function extend( context:IContext ):void
		{
			_injector = context.injector;
			context.addConfigHandler(instanceOf(DisplayObjectContainer), handleContextView);
		}

		public function toString():String
		{
			return _uid;
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function handleContextView( view:DisplayObjectContainer ):void
		{
			if (!_injector.satisfiesDirectly(DisplayObjectContainer))
			{
				_injector.map(DisplayObjectContainer).toValue(view);
				_injector.map(Stage).toValue(view.stage);
			}
		}
	}
}
