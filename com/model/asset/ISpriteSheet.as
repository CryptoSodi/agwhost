package com.model.asset
{
	public interface ISpriteSheet
	{
		function init( sprite:*, xml:XML, url:String ):void;

		function getFrame( label:String, frame:int ):*;

		function getFrames( label:String ):Array;

		function build():Boolean;

		function incReferenceCount():void;
		function decReferenceCount():void;

		function get built():Boolean;
		function get begunLoad():Boolean;
		function set begunLoad( v:Boolean ):void;
		function set format( v:String ):void;
		function get is3D():Boolean;
		function get referenceCount():int;
		function get url():String;

		function destroy():void;
	}
}
