package com.util {
	import com.model.prototype.IPrototype;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.net.URLRequest;
	import flash.display.Stage;
	import flash.events.Event;
	import com.ui.TransitionView;
	import flash.events.IOErrorEvent;
	public class LoadingScreenHelper {

		public static var WEIGHT:String = "weight";
		
		/*
			Returns a prototype from a list of prototypes, randomly by weight.
		*/
		public static function chooseRandomPrototypeByWeight(prototypes: Vector.<IPrototype> ): IPrototype {
			// Calculate the total weight of all items
			var totalWeight: Number = 0;
			var len:int = prototypes.length;
			for (var i: int = 0; i < len; i++) {
				totalWeight += prototypes[i].getValue(WEIGHT);
			}

			// Generate a random number between 0 and the total weight
			var rng: Number = Math.random() * totalWeight;
			// Iterate through the prototypes and subtract their weights from the random number
			// until the random number becomes negative, then return the current prototype
			
			for (i = 0; i < len; i++) {
				var prototype:IPrototype = prototypes[i];
				rng -= prototype.getValue(WEIGHT);
				if (rng < 0) {
					return prototype;
				}
			}
			// If we haven't returned an item yet, return the last prototype in the list
			return prototypes[len - 1];
		}
		
		public static function getBitmap(path:String):Bitmap{
			
			var loader:Loader = new Loader();
			var request:URLRequest = new URLRequest(path);
			var bitmapData:BitmapData = new BitmapData(1920, 1080, false, 0x0);
			var bitmap:Bitmap = new Bitmap(bitmapData, "auto", true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event){
				bitmap.bitmapData = Bitmap(e.target.content).bitmapData;
				
			});
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event){
				bitmap.bitmapData = (new TransitionView.LoadingScreenBG()).bitmapData;
			});
			loader.load(request);
			
			return bitmap;
		}
		
		
		public static function getApplicationPath(stage:Stage):String{
			var swfUrl:String = stage.loaderInfo.url;
			var swfDir:String = swfUrl.substring(0, swfUrl.lastIndexOf("/"));

			return swfDir;
		}

					
	}

}

