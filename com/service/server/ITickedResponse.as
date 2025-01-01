package com.service.server
{
	public interface ITickedResponse extends IResponse
	{
		function get isBaseline():Boolean;
		
		function get addTick():Boolean;

		function get tick():int;

		function get timeStep():int;
	}
}
