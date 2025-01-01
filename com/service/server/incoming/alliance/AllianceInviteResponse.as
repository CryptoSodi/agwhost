package com.service.server.incoming.alliance
{
	import com.model.alliance.AllianceInviteVO;
	import com.model.alliance.AllianceVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class AllianceInviteResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;

		public var inviteVO:AllianceInviteVO;

		public function read( input:BinaryInputStream ):void
		{
			var factionPrototype:IPrototype = PrototypeModel.instance.getFactionPrototypeByName(CurrentUser.faction);
			input.checkToken();
			var key:String                  = input.readUTF(); // alliance key
			var allianceName:String         = input.readUTF(); // alliance name
			var memberCount:int             = input.readInt(); // num members
			var inviterKey:String           = input.readUTF(); // inviter key
			var inviterName:String          = input.readUTF(); // inviter name
			input.checkToken();
			var alliance:AllianceVO         = new AllianceVO(key, allianceName, factionPrototype, '', '', false);
			alliance.memberCount = memberCount;
			inviteVO = new AllianceInviteVO(inviterKey, inviterName, alliance);
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
			inviteVO = null;
		}
	}
}
