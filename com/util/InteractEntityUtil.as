package com.util
{
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeVO;

	public class InteractEntityUtil
	{
		public static function createPrototype( type:String, usedBy:int = 7, spriteSheets:String = "", isJPG:Boolean = false ):IPrototype
		{
			return new PrototypeVO({
									   key:type,
									   jpg:isJPG,
									   spriteName:type,
									   spriteSheets:spriteSheets,
									   spriteSheetsMobile:'',
									   usedBy:usedBy
								   });
		}

		public static function updateXML( xml:XML, name:String, x:int, y:int, width:Number, height:Number ):void
		{
			xml.appendChild(new XML(<SubTexture name={name} x={x} y={y} width={width} height={height}/>));
		}
	}
}
