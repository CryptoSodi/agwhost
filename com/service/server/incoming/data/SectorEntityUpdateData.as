package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class SectorEntityUpdateData implements IServerData
	{
		public var id:String;
		public var bubbled:Boolean;
		public var cargo:Number;
		public var cloaked:Boolean;
		public var currentHealthPct:Number;
		public var rating:Number;
		public var baseRatingTech:Number;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			bubbled = input.readBoolean();
			cargo = input.readInt64();
			cloaked = input.readBoolean();
			currentHealthPct = input.readDouble();

			var numChargeups:int = input.readUnsignedInt();
			for (var i:int = 0; i < numChargeups; i++)
			{
				var orderType:int = input.readInt();
				var startTick:int = input.readInt();
				var endTick:int   = input.readInt();
			}

			rating = input.readInt64();
			baseRatingTech = input.readInt64();
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
		}

		public function destroy():void
		{

		}
	}
}
