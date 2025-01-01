package com.controller.command.load
{
	import com.controller.sound.SoundController;
	import com.enum.TimeLogEnum;
	import com.event.LoadEvent;
	import com.model.asset.AssetModel;
	import com.model.asset.ISpriteSheet;
	import com.model.prototype.PrototypeModel;
	import com.service.loading.LoadingTypes;
	import com.service.loading.loaditems.BatchLoadItem;
	import com.service.loading.loaditems.ILoadItem;
	import com.util.TimeLog;
	
	import flash.display.Bitmap;
	import flash.media.Sound;
	
	import org.robotlegs.extensions.presenter.impl.Command;

	public class LoadCompleteCommand extends Command
	{
		[Inject]
		public var assetModel:AssetModel;
		[Inject]
		public var event:LoadEvent;
		[Inject]
		public var prototypeModel:PrototypeModel;
		[Inject]
		public var soundController:SoundController;

		override public function execute():void
		{
			var loadItem:ILoadItem = event.loadItem;
			var asset:Object       = loadItem.asset;
			var batchLoad:BatchLoadItem;
			var i:int;
			var items:Vector.<ILoadItem>;
			switch (loadItem.type)
			{
				case LoadingTypes.BITMAP:
					asset = Bitmap(loadItem.asset).bitmapData;
					assetModel.cache(loadItem.url, asset);
					break;
				case LoadingTypes.MESH:
					break;
				case LoadingTypes.SOUND:
					asset = loadItem.asset;
					soundController.addAudio(loadItem.url, Sound(asset));
					break;
				case LoadingTypes.SWF:
					assetModel.cache(loadItem.url, asset);
					break;
				case LoadingTypes.TEXT:
					try
					{
						TimeLog.startTimeLog(TimeLogEnum.JSON_PARSE, loadItem.url);
						asset = JSON.parse(String(loadItem.asset));
						TimeLog.endTimeLog(TimeLogEnum.JSON_PARSE, loadItem.url);
					}
					catch( e:Error )
					{
						asset = AssetModel.FAILED;
						assetModel.cache(loadItem.url, asset);
						TimeLog.endTimeLog(TimeLogEnum.JSON_PARSE, loadItem.url);
						break;
					}
					//we know what this data is, so skip caching it
					if (asset.format == "Not Loc")
					{
						//assetModel.addGameAssetData(asset);
					} else
					{
						if (asset.ShipPrototypes || asset.EventPrototypes)
							prototypeModel.addPrototypeData(asset);
						else
							assetModel.cache(loadItem.url, asset); //dont know what type it is so cache for now
					}
					break;
				case LoadingTypes.XML:
					assetModel.cache(loadItem.url, XML(asset));
					break;
				case LoadingTypes.BATTLEREPLAY:
					assetModel.cache(loadItem.url, asset);
					break;
				case LoadingTypes.SPRITE_SHEET:
					batchLoad = BatchLoadItem(loadItem);
					items = batchLoad.items;
					for (i = 0; i < items.length; i += 2)
					{
						assetModel.removeFromCache(items[i].url);
						assetModel.removeFromCache(items[i + 1].url);
						assetModel.initSpriteSheet(items[i].url, Bitmap(items[i].asset).bitmapData, XML(items[i + 1].asset));
					}
					break;
				case LoadingTypes.SPRITE_SHEET_MESH:
					batchLoad = BatchLoadItem(loadItem);
					items = batchLoad.items;
					for (i = 0; i < items.length; i++)
					{
						assetModel.removeFromCache(items[i].url);
						assetModel.initSpriteSheet(items[i].url, items[i].asset, null);
					}
					break;
			}
		}
	}
}
