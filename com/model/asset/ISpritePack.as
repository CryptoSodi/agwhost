package com.model.asset
{
	public interface ISpritePack
	{
		function getFrame( label:String, frame:int ):*;

		function getFrames( label:String ):Array;

		function addSpriteSheet( sheet:ISpriteSheet ):void;

		function get is3D():Boolean;
		function get ready():Boolean;
		function get spriteSheets():Vector.<ISpriteSheet>;
		function get type():String;
		function get usedBy():int;

		function destroy():void;
	}
}
