package com.controller.command
{
	import com.Application;
	import com.controller.GameController;
	import com.event.PaywallEvent;
	import com.service.kongregate.KongregateAPI;
	import com.service.facebook.FacebookAPI;
	import com.ui.modal.paywall.PaywallView;
	import com.service.ExternalInterfaceAPI;

	import org.parade.core.IViewFactory;
	import org.robotlegs.extensions.presenter.impl.Command;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	public class PaywallCommand extends Command
	{
		[Inject]
		public var event:PaywallEvent;
		[Inject]
		public var viewFactory:IViewFactory;
		[Inject]
		public var gameController:GameController;
		[Inject]
		public var kongregateAPI:KongregateAPI;
		[Inject]
		public var facebookAPI:FacebookAPI;

		private static const _logger:ILogger = getLogger('PaywallCommand');

		override public function execute():void
		{
			switch (event.type)
			{
				case PaywallEvent.GET_PAYWALL:
					_logger.debug('execute - PaywallEvent.GET_PAYWALL');
					if (gameController)
							gameController.requestPaywallPayouts();
					break;
				case PaywallEvent.OPEN_PAYWALL:
					_logger.debug('execute - PaywallEvent.OPEN_PAYWALL');
					if (viewFactory)
					{
						var paywall:PaywallView = PaywallView(viewFactory.createView(PaywallView));
						viewFactory.notify(paywall);
						paywall.setUp(event.paywallData);
					}
					break;
				case PaywallEvent.BUY_ITEM:
					_logger.debug('execute - PaywallEvent.BUY_ITEM');
					if (gameController)
					{
						if (Application.NETWORK == Application.NETWORK_GOOGLEAPP)
							gameController.requestPaymentVerification(event.externalTrkid, event.payoutId, event.responseData, event.responseSignature);
						else if (Application.NETWORK == Application.NETWORK_KONGREGATE)
							gameController.requestPaymentVerification('', '', '', kongregateAPI.gameAuthToken);
						else if (Application.NETWORK == Application.NETWORK_FACEBOOK)
							gameController.requestPaymentVerification('', '', '', '');
					}
					break;
			}
		}
	}
}
