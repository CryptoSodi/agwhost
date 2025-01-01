package com.ui.core.component.label
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	
	import com.StartupConfig;
	
	public class RequirementLabel extends Sprite
	{
		private var _bullet:Bitmap;
		private var _checkMark:Bitmap;

		private var _lbl:Label;

		private var _showLink:Boolean;

		public function RequirementLabel( dx:int = 0, dy:int = 0, fontSize:Number = 12, color:uint = 0, maxWidth:Number = 100, maxHeight:Number = 20, useLocalization:Boolean = true, fontNr:int = 0 )
		{
			_lbl = new Label(fontSize, color, maxWidth, maxHeight, useLocalization, StartupConfig.FontArray[fontNr]);
			_lbl.x = 14; //dx;
			_lbl.y = dy;
			_lbl.useLocalization = false;
			addChild(_lbl);

			var checkMarkClass:Class = Class(getDefinitionByName('CheckMarkBMD'));
			var bulletClass:Class    = Class(getDefinitionByName('BulletBMD'));

			_checkMark = new Bitmap(BitmapData(new checkMarkClass()))
			//			_checkMark.x = _lbl.x - 5;
			//			_checkMark.y = _lbl.y;
			_checkMark.visible = true;
			addChild(_checkMark);

			_bullet = new Bitmap(BitmapData(new bulletClass()))
			//			_bullet.x = _lbl.x - 14;
			//			_bullet.y = _lbl.y;
			_bullet.visible = true;
			addChild(_bullet);

			_showLink = false;
		}

		public function formatObject():void
		{
			_bullet.x = _lbl.x - 14;
			_bullet.y = _lbl.y + _lbl.textHeight * 0.5 - 2;

			_checkMark.x = _lbl.x + _lbl.textWidth + 15;
			_checkMark.y = _lbl.y + _lbl.textHeight - _checkMark.height;

		}

		public function get lbl():Label  { return _lbl; }
		public function set lbl( value:Label ):void  { _lbl = value; }

		public function get checkMark():Bitmap  { return _checkMark; }

		public function get showLink():Boolean  { return _showLink; }
		public function set showLink( value:Boolean ):void  { _showLink = value; }

		public function destroy():void
		{
			_bullet = null;
			_checkMark = null;

			_lbl.destroy();
			_lbl = null;
		}

	}
}
