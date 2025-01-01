package com.service.server.incoming.chat
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	
	import com.model.player.CurrentUser;
	
	public class ChatBaselineResponse implements IResponse
	{
		public var ignoredPlayers:Vector.<String> = new Vector.<String>;
		private var _header:int;
		private var _protocolID:int;
		
		public function read( input:BinaryInputStream ):void
		{
			var i:int                         = 0;
			var numIgnores:int = input.readUnsignedInt();
			for(i=0; i<numIgnores; i++)
			{
				ignoredPlayers.push(input.readUTF());
			}
			
			CurrentUser.allianceRank = input.readInt(); // your rank
		}
		
		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in ChatBaselineResponse is not supported");
		}
		
		public function get isTicked():Boolean  { return false; }
		
		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }
		
		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }
		
		
		public function destroy():void
		{
			ignoredPlayers.length = 0;
		}
	}
}