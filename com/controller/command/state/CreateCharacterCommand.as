package com.controller.command.state
{
	import com.ui.TransitionView;
	import com.ui.modal.intro.FactionSelectView;

	import org.parade.core.ViewController;
	import org.parade.core.ViewEvent;

	public class CreateCharacterCommand extends StateCommand
	{
		[Inject]
		public var viewController:ViewController;

		override public function execute():void
		{
			var view:TransitionView = TransitionView(viewController.getView(TransitionView));
			if (view)
				view.destroy();

			var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
			viewEvent.targetClass = FactionSelectView;
			dispatch(viewEvent);
		}
	}
}
