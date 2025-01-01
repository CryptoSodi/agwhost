package com.service.server.incoming.starbase
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	import org.shared.ObjectPool;

	public class StarbaseMoveStarbaseResponse implements IResponse
	{
		public var status:int;
		/*
		   enum class MoveBaseStatus
		   {
		   Started = 0,
		   TargetSectorFull = 1,
		   };
		 */

		private var _header:int;
		private var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			status = input.readInt(); // MoveBaseStatus
		}

		public function readJSON( data:Object ):void
		{
			// Unimplemented.
		}

		public function get isTicked():Boolean  { return false; }

		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }

		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }


		public function destroy():void
		{
		}
	}
}
