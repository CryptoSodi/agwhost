package com.ui.core
{
	import com.Application;
	import com.ui.alert.AlertView;
	import com.event.PaywallEvent;
	import com.service.ExternalInterfaceAPI;
	
	import flash.events.IEventDispatcher;

	import org.parade.core.IView;
	import org.parade.core.IViewFactory;
	import org.parade.core.ViewEvent;
	import com.event.ServerEvent;

	public class ViewFactory implements IViewFactory
	{
		private var _eventDispatcher:IEventDispatcher;

		public function createView( targetClass:Class ):IView
		{
			var view:IView;
			switch (targetClass)
			{
				default:
					view = new targetClass();
					break;
			}
			return view;
		}

		public function createAlert( alertTitle:String, alertBody:String, btnOneText:String, btnOneCallback:Function, btnOneArgs:Array, btnTwoText:String, btnTwoCallback:Function, btnTwoArgs:Array,
									 onCloseUseBtnTwo:Boolean = false, maxCharacters:int = 12, defaultInputText:String = '', clearInputOnFocus:Boolean = false, restrict:String = '', shouldNotify:Boolean =
									 true, view:Class =
									 null ):IView
		{
			if (view == null)
				view = AlertView;

			var nAlertview:AlertView = view(createView(view));
			var alertArgs:Array      = new Array(alertTitle, alertBody, btnOneText, btnOneCallback, btnOneArgs, btnTwoText, btnTwoCallback, btnTwoArgs, onCloseUseBtnTwo, maxCharacters, defaultInputText,
												 clearInputOnFocus);
			nAlertview.setUp(alertArgs);
			if (shouldNotify)
				notify(nAlertview);

			return nAlertview;
		}

		public function notify( view:IView ):void
		{
			var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
			viewEvent.targetView = view;
			_eventDispatcher.dispatchEvent(viewEvent);
		}

		public function destroyView( targetView:IView ):void
		{
			var viewEvent:ViewEvent = new ViewEvent(ViewEvent.DESTROY_VIEW);
			viewEvent.targetView = targetView;
			_eventDispatcher.dispatchEvent(viewEvent);

			Application.STAGE.focus = Application.STAGE;
		}
		
		public function openPayment():void
		{
			ExternalInterfaceAPI.logConsole("Open Payment");
			if (Application.NETWORK == Application.NETWORK_KONGREGATE)
			{
				ExternalInterfaceAPI.logConsole("Kongregate payments");
				var paywall:PaywallEvent = new PaywallEvent(PaywallEvent.GET_PAYWALL);
				_eventDispatcher.dispatchEvent(paywall);
			} 
			else if (Application.NETWORK == Application.NETWORK_FACEBOOK)
			{
				ExternalInterfaceAPI.logConsole("Facebook payments");
				var paywall:PaywallEvent = new PaywallEvent(PaywallEvent.GET_PAYWALL);
				_eventDispatcher.dispatchEvent(paywall);
			} 
			else if (Application.NETWORK == Application.NETWORK_XSOLLA)
			{
				ExternalInterfaceAPI.logConsole("Xsolla payments");
				var serverEvent:ServerEvent
				serverEvent = new ServerEvent(ServerEvent.OPEN_PAYMENT);
				_eventDispatcher.dispatchEvent(serverEvent);
				//_viewFactory.openPayment();
				//ExternalInterfaceAPI.popPayWall();
			}
			else if (Application.NETWORK == Application.NETWORK_GUEST)
			{
				ExternalInterfaceAPI.logConsole("Guest Payment Restriction");
				var serverEvent:ServerEvent
				serverEvent = new ServerEvent(ServerEvent.GUEST_RESTRICTION);
				_eventDispatcher.dispatchEvent(serverEvent);
			}
			else if (Application.NETWORK == Application.NETWORK_STEAM)
			{
				//todo steam payments
			}
			//var serverEvent:ServerEvent
			//serverEvent = new ServerEvent(ServerEvent.OPEN_PAYMENT);
			//_eventDispatcher.dispatchEvent(serverEvent);
		}

		[Inject]
		public function set eventDispatcher( value:IEventDispatcher ):void  { _eventDispatcher = value; }
	}
}
