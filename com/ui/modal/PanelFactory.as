package com.ui.modal
{
	import com.ui.core.ScaleBitmap;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	public class PanelFactory
	{
		private static const _bmdStore:Dictionary = new Dictionary();

		public static function getScaleBitmapPanel( name:String, width:Number = -1, height:Number = -1, scale9Rect:Rectangle = null ):ScaleBitmap
		{
			var panel:ScaleBitmap = new ScaleBitmap();
			if (!_bmdStore[name])
				getBitmapData(name);
			panel.bitmapData = _bmdStore[name];
			if (scale9Rect)
				panel.scale9Grid = scale9Rect;
			if (width > -1)
				panel.width = width;
			if (height > -1)
				panel.height = height;
			return panel;
		}

		public static function getPanel( name:String ):Bitmap
		{
			var panel:Bitmap = new Bitmap();
			if (!_bmdStore[name])
				getBitmapData(name);
			panel.bitmapData = _bmdStore[name];
			return panel;
		}

		public static function getBitmapData( name:String ):BitmapData
		{
			var bmdClass:Class = Class(getDefinitionByName(name));
			var bmd:BitmapData = BitmapData(new bmdClass());
			_bmdStore[name] = bmd;
			return bmd;
		}
	}
}
