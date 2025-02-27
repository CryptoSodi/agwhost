//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.extensions.stageSync
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import org.hamcrest.object.instanceOf;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.api.IExtension;
	import org.robotlegs.framework.impl.UID;

	/**
	 * <p>This Extension waits for a DisplayObjectContainer to be added as a configuration,
	 * and initializes and destroys the context based on that container's stage presence.</p>
	 *
	 * <p>It should be installed before context initialization.</p>
	 */
	public class StageSyncExtension implements IExtension
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _uid:String = UID.create(StageSyncExtension);

		private var _context:IContext;

		private var _contextView:DisplayObjectContainer;

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function extend(context:IContext):void
		{
			_context = context;
			_context.addConfigHandler(instanceOf(DisplayObjectContainer), handleContextView);
		}

		public function toString():String
		{
			return _uid;
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function handleContextView(view:DisplayObjectContainer):void
		{
			_contextView = view;
			if (_contextView.stage)
			{
				initializeContext();
			}
			else
			{
				_contextView.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}

		private function onAddedToStage(event:Event):void
		{
			_contextView.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			initializeContext();
		}

		private function initializeContext():void
		{
			_context.lifecycle.initialize();
			_contextView.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}

		private function onRemovedFromStage(event:Event):void
		{
			_contextView.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			_context.lifecycle.destroy();
		}
	}
}
