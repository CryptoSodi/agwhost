package com.service.xsolla
{
	import com.service.ExternalInterfaceAPI;
	
	public class XsollaAPI
	{
		public function get gameAuthToken():String
		{
			return ExternalInterfaceAPI.getPlayerXsollaGameAuthToken();
		}
	}
}