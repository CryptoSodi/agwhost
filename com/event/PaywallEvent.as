package com.event
{
	import flash.events.Event;

	public class PaywallEvent extends Event
	{
		public static const GET_PAYWALL:String  = "PayWallGet";
		public static const OPEN_PAYWALL:String = "PayWallOpen";
		public static const BUY_ITEM:String     = 'PayWallBuyItem'

		//Paywall Open
		public var paywallData:String;

		//Paywall Purchase
		public var externalTrkid:String;
		public var payoutId:String;
		public var responseData:String;
		public var responseSignature:String;

		public function PaywallEvent( type:String )
		{
			super(type, false, false);
		}
	}
}
