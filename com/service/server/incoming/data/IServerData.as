package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public interface IServerData
	{
		function read( input:BinaryInputStream ):void;
		function readJSON( data:Object ):void;

		function destroy():void;
	}
}
