package com.controller.command
{
	import com.event.TransitionEvent;
	import com.ui.TransitionView;

	import org.parade.core.ViewController;
	import org.parade.core.ViewEvent;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class TransitionCommand extends Command
	{
		[Inject]
		public var event:TransitionEvent;
		[Inject]
		public var viewController:ViewController;

		override public function execute():void
		{
			if (event.type == TransitionEvent.TRANSITION_BEGIN)
			{
				var view:TransitionView = TransitionView(viewController.getView(TransitionView));
				if (!view)
				{
					var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
					viewEvent.targetClass = TransitionView;
					dispatch(viewEvent);
				} else
					view.resetEvents();
			}
		}
	}
}
