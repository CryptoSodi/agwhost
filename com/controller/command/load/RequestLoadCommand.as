package com.controller.command.load
{
	import com.event.RequestLoadEvent;
	import com.service.loading.ILoadService;

	import org.robotlegs.extensions.presenter.impl.Command;

	public class RequestLoadCommand extends Command
	{
		[Inject]
		public var event:RequestLoadEvent;

		[Inject]
		public var loadService:ILoadService;

		override public function execute():void
		{
			if (event.url != null)
			{
				loadService.lazyLoad(event.url, event.priority, true, event.absoluteURL);
			}
			if (event.urls != null)
			{
				loadService.loadBatch(event.batchType, event.urls, event.priority);
			}
		}
	}
}
