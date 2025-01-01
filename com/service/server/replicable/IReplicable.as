package com.service.server.replicable
{
	import com.service.server.BinaryInputStream;

	public interface IReplicable
	{
		function decode( input:BinaryInputStream ):int;
		function read( input:BinaryInputStream ):void;
		function resetDeltas( ):void;
	}
}