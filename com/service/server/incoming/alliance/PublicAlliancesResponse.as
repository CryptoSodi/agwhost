package com.service.server.incoming.alliance
{
	import com.model.alliance.AllianceVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class PublicAlliancesResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;

		public var alliances:Vector.<AllianceVO>;

		public function read( input:BinaryInputStream ):void
		{
			alliances = new Vector.<AllianceVO>;
			input.checkToken();
			var alliance:AllianceVO;
			var num:int                     = input.readUnsignedShort();
			var factionPrototype:IPrototype = PrototypeModel.instance.getFactionPrototypeByName(CurrentUser.faction);
			for (var i:int = 0; i < num; ++i)
			{
				input.checkToken();
				var key:String      = input.readUTF(); // key
				var name:String     = input.readUTF(); // name
				var membercount:int = input.readInt();
				var motd:String		= input.readUTF(); // motd
				var description:String	 = input.readUTF(); // description
				
				input.checkToken();

				alliance = new AllianceVO(key, name, factionPrototype, motd, description, true);
				alliance.memberCount = membercount;
				alliances.push(alliance);
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
