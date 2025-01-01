package com.event
{
	import com.service.server.IResponse;

	import flash.events.Event;

	public class ServerEvent extends Event
	{
		public static const NOT_CONNECTED:String         = "NotConnected";

		public static const CONNECT_TO_PROXY:String      = "ConnectToProxy";

		public static const LOGIN_TO_ACCOUNT:String      = "LoginToAccount";

		public static const AUTHORIZED:String            = "Authorized";

		public static const NEED_CHARACTER_CREATE:String = "NeedCharacterCreate";

		public static const FAILED_TO_CONNECT:String     = "FailedToConnect";

		public static const MAINTENANCE:String           = "Maintenance";

		public static const SUSPENSION:String            = "Suspension";

		public static const BANNED:String                = "Banned";
		
		public static const OPEN_PAYMENT:String          = "OpenPayment";
		
		public static const GUEST_RESTRICTION:String          = "GuestRestriction";

		private var _response:IResponse;

		public function ServerEvent( type:String, response:IResponse = null )
		{
			super(type, false, false);
			_response = response;
		}

		public function get response():IResponse  { return _response; }
	}
}
