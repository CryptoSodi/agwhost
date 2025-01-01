package org.ash.integration.robotlegs
{
	import org.ash.core.Game;
	import org.ash.integration.swiftsuspenders.SwiftSuspendersGame;
	import org.ash.tick.FrameTickProvider;
	import org.ash.tick.ITickProvider;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.api.IExtension;
	import org.robotlegs.framework.impl.UID;

	/**
	 * A Robotlegs extension to enable the use of Ash inside a Robotlegs project. This
	 * wraps the SwiftSuspenders integration, passing the Robotlegs context's injector to
	 * the game for injecting into systems.
	 */
	public class AshExtension implements IExtension
	{
		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _uid:String = UID.create(AshExtension);

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function AshExtension()
		{

		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function extend( context:IContext ):void
		{
			context.injector.map(Game).toValue(new SwiftSuspendersGame(context.injector));
			context.injector.map(ITickProvider).toSingleton(FrameTickProvider);
		}

		public function toString():String
		{
			return _uid;
		}
	}
}
