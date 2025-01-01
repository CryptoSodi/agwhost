package com.service.server.incoming.alliance
{
	import com.model.alliance.AllianceVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class AllianceBaselineResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;

		public var alliance:AllianceVO;

		public var currentUserAllianceKey:String;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			input.checkToken();
			input.checkToken();
			var key:String                  = input.readUTF(); // key
			input.checkToken();

			var name:String                 = input.readUTF(); // name
			var factionPrototype:IPrototype = PrototypeModel.instance.getFactionPrototypeByName(input.readUTF()); // factionPrototype
			var motd:String                 = input.readUTF(); // motd
			var description:String          = input.readUTF(); // description
			var isPublic:Boolean            = input.readBoolean(); // publicAlliance


			input.checkToken();

			// data about the player himself
			CurrentUser.alliance = input.readUTF(); // your alliance key
			CurrentUser.allianceRank = input.readInt(); // your rank
			CurrentUser.isAllianceOpen = input.readBoolean(); // your alliance is public
			CurrentUser.allowAllianceInvites = input.readBoolean(); // ignore invites

			input.checkToken();

			alliance = new AllianceVO(key, name, factionPrototype, motd, description, isPublic);
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
			alliance = null;
		}
	}
}
