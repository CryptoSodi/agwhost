package org.parade.core
{

	import org.robotlegs.extensions.presenter.impl.Command;

	public class ViewCommand extends Command
	{
		[Inject]
		public var viewController:ViewController;
		[Inject]
		public var viewEvent:ViewEvent;
		[Inject]
		public var viewFactory:IViewFactory;
		[Inject]
		public var viewStack:IViewStack;

		override public function execute():void
		{
			switch (viewEvent.type)
			{
				case ViewEvent.DESTROY_ALL_VIEWS:
					destroyAllViews();
					break;
				case ViewEvent.DESTROY_VIEW:
					destroyView();
					break;
				case ViewEvent.SHOW_VIEW:
					createView();
					break;
				case ViewEvent.HIDE_VIEWS:
					hideShowViews(false);
					break;
				case ViewEvent.UNHIDE_VIEWS:
					hideShowViews(true);
					break;
			}
		}

		private function createView():void
		{
			if (viewEvent.targetClass)
			{
				if (viewEvent.targetClass is Array)
				{
					while (viewEvent.targetClass.length > 0)
					{
						viewEvent.targetView = viewFactory.createView(viewEvent.targetClass.shift());
						showView();
					}
				} else
				{
					viewEvent.targetView = viewFactory.createView(viewEvent.targetClass);
					showView();
				}
			} else
				showView();
			viewEvent.destroy();
		}

		private function showView():void
		{
			if (viewEvent.targetView)
			{
				//ensure that ViewController will allow this view to be shown
				if (viewController.addView(viewEvent.targetView))
				{
					viewStack.addView(viewEvent.targetView);
					injector.injectInto(viewEvent.targetView);
				}
			}
		}

		private function hideShowViews( show:Boolean ):void
		{
			if (viewEvent.targetClass)
			{
				var targetView:IView;
				if (viewEvent.targetClass is Array)
				{
					while (viewEvent.targetClass.length > 0)
					{
						targetView = viewController.getView(viewEvent.targetClass.shift());
						if (targetView)
							viewController.showView(targetView,show);
					}
				} else
				{
					targetView = viewController.getView(viewEvent.targetClass);
					if (targetView)
						viewController.showView(targetView,show);
				}
			}
		}

		private function destroyView():void
		{
			if (viewEvent.targetView)
			{
				viewController.destroyView(viewEvent.targetView);
			}
			viewEvent.destroy();
		}

		private function destroyAllViews():void
		{
			viewController.emptyQueue();

			//shittily cloning the current views
			var views:Vector.<IView> = viewController.currentViews;
			for (var i:int = views.length - 1; i >= 0; i--)
				views[i].destroy();
		}
	}
}
