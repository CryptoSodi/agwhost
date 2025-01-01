package com.controller.command
{
	import com.event.TransitionEvent;
	import com.presenter.shared.ITransitionPresenter;

	import org.robotlegs.extensions.presenter.impl.Command;

	public class TransitionCoreCommand extends Command
	{
		[Inject]
		public var transitionPresenter:ITransitionPresenter;

		[Inject]
		public var event:TransitionEvent;

		override public function execute():void
		{
			if (event.type == TransitionEvent.TRANSITION_BEGIN)
				transitionPresenter.addEvents(event.initEvent, event.cleanupEvent);
			else if (event.type == TransitionEvent.TRANSITION_FAILED)
				transitionPresenter.failed = true;
			else
				transitionPresenter.transitionComplete();
		}

	}
}
