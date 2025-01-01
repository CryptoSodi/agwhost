package com.service.server
{
	import flash.utils.ByteArray;

	public interface IRequest
	{
		function init( protocolID:int, header:int ):void;

		function write( output:ByteArray ):void;

		function destroy():void;
	}

}
