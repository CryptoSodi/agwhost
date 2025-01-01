package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.model.player.BookmarkVO;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseBookmarkUpdateRequest extends TransactionRequest
	{
		public var bookmark:BookmarkVO;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUnsignedInt(bookmark.index);
			output.writeUTF(bookmark.name);
			output.writeUTF(bookmark.sector);
			output.writeUTF(bookmark.sectorNamePrototype.name);
			output.writeUTF(bookmark.sectorEnumPrototype.name);
			output.writeUTF(bookmark.sectorPrototype.name);
			output.writeInt(bookmark.x);
			output.writeInt(bookmark.y);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
			super.destroy();
		}
	}
}
