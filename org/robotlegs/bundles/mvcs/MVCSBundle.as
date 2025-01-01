//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.bundles.mvcs
{
	import org.ash.integration.robotlegs.AshExtension;
	import org.robotlegs.extensions.commandMap.CommandMapExtension;
	import org.robotlegs.extensions.contextView.ContextViewExtension;
	import org.robotlegs.extensions.eventCommandMap.EventCommandMapExtension;
	import org.robotlegs.extensions.eventDispatcher.EventDispatcherExtension;
	import org.robotlegs.extensions.localEventMap.LocalEventMapExtension;
	import org.parade.integration.ParadeExtension;
	import org.robotlegs.extensions.presenter.PresenterExtension;
	import org.robotlegs.extensions.stageSync.StageSyncExtension;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.api.IExtension;

	/**
	 * For that Classic Robotlegs flavour
	 *
	 * <p>This bundle installs a number of extensions commonly used in typical Robotlegs
	 * applications and modules.</p>
	 */
	public class MVCSBundle implements IExtension
	{

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function extend( context:IContext ):void
		{
			context.extend(
				ContextViewExtension,
				EventDispatcherExtension,
				CommandMapExtension,
				EventCommandMapExtension,
				LocalEventMapExtension,
				StageSyncExtension,
				PresenterExtension,
				AshExtension,
				ParadeExtension);
		}
	}
}
