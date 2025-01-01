package com.service.server
{
	import flash.utils.ByteArray;

	public interface IResponse
	{
		function read( input:BinaryInputStream ):void;
		function readJSON( input:Object ):void;

		function get isTicked():Boolean;

		function get header():int;
		function set header( v:int ):void;

		function get protocolID():int;
		function set protocolID( v:int ):void;

		function destroy():void;
	}

}
