package com.service.server.incoming.data
{
	import com.model.player.BookmarkVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;

	public class BookmarksData implements IServerData
	{
		public var bookmarks:Vector.<BookmarkVO>;

		public function BookmarksData()
		{
			bookmarks = new Vector.<BookmarkVO>;
		}

		public function read( input:BinaryInputStream ):void
		{
			var prototypeModel:PrototypeModel = PrototypeModel.instance;

			var bookmarksContainer:String     = input.readUTF();
			if (bookmarksContainer && bookmarksContainer != '')
			{
				var bookmarksBlob:Object = JSON.parse(bookmarksContainer);
				var bookmark:BookmarkVO;
				var sectorPrototypeName:String;
				var sectorNamePrototypeName:String;
				var sectorEnumPrototypeName:String;
				var sectorPrototype:IPrototype;
				var sectorNamePrototype:IPrototype;
				var sectorEnumPrototype:IPrototype;
				var index:uint;
				for each (var currentBookmark:Object in bookmarksBlob.bookmarks)
				{
					sectorPrototypeName = (currentBookmark.hasOwnProperty('SectorProto')) ? currentBookmark.SectorProto : '';
					sectorNamePrototypeName = (currentBookmark.hasOwnProperty('NameProto')) ? currentBookmark.NameProto : '';
					sectorEnumPrototypeName = (currentBookmark.hasOwnProperty('EnumProto')) ? currentBookmark.EnumProto : '';

					if (sectorPrototypeName != null && sectorPrototypeName != '')
						sectorPrototype = prototypeModel.getSectorPrototypeByName(sectorPrototypeName);

					if (sectorNamePrototypeName != null && sectorNamePrototypeName != '')
						sectorNamePrototype = prototypeModel.getSectorNamePrototypeByName(sectorNamePrototypeName);

					if (sectorEnumPrototypeName != null && sectorEnumPrototype != '')
						sectorEnumPrototype = prototypeModel.getSectorNamePrototypeByName(sectorEnumPrototypeName);

					bookmark = new BookmarkVO(currentBookmark.name, currentBookmark.sector, sectorPrototype, sectorNamePrototype, sectorEnumPrototype, currentBookmark.x, currentBookmark.y, index);
					bookmarks.push(bookmark);
					++index;
				}
			}
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in BookmarksData is not supported");
		}

		public function destroy():void
		{
			bookmarks.length = 0;
		}
	}
}
