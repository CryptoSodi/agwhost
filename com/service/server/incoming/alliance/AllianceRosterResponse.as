package com.service.server.incoming.alliance
{
	import com.model.alliance.AllianceMemberVO;
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class AllianceRosterResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;

		public var allianceKey:String;
		public var members:Vector.<AllianceMemberVO>;

		public function read( input:BinaryInputStream ):void
		{
			members = new Vector.<AllianceMemberVO>;
			input.checkToken();
			allianceKey = input.readUTF(); // alliance key
			var member:AllianceMemberVO;
			var numRoster:int = input.readUnsignedInt();
			for (var i:int = 0; i < numRoster; ++i)
			{
				input.checkToken();
				member = new AllianceMemberVO(input.readUTF(), input.readUTF(), input.readInt64(), input.readInt64(), input.readInt());
				input.checkToken();
				members.push(member);
			}
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON is not supported");
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
