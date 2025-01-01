package com.util {
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	public class FileHelper {

		public static function loadObject(filepath:String):Object{
			var file:File = new File(filepath);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var objString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
			
			return JSON.parse(objString);
		}

	}
	
}
