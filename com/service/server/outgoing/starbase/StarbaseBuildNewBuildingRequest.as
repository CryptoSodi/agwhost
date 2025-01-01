package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseBuildNewBuildingRequest extends TransactionRequest
	{
		public var buildingPrototype:String;
		public var locationX:int;
		public var locationY:int;
		public var centerSpaceBase:Boolean; // set this true if building in your centerSpace base

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(buildingPrototype);
			output.writeInt(locationX);
			output.writeInt(locationY);
			output.writeBoolean(centerSpaceBase);
			output.writeInt(purchaseType);
			writeExpectedCosts(output);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
			super.destroy();
		}
	}
}
