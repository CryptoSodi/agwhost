package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseBookmarkSaveRequest extends TransactionRequest
	{
		public var name:String;
		public var sector:String;
		public var nameProto:String;
		public var enumProto:String;
		public var sectorProto:String;
		public var x:int;
		public var y:int;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(name);
			output.writeUTF(sector);
			output.writeUTF(nameProto);
			output.writeUTF(enumProto);
			output.writeUTF(sectorProto);
			output.writeInt(x);
			output.writeInt(y);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
			super.destroy();
		}
	}
}
