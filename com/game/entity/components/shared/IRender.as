package com.game.entity.components.shared
{
	public interface IRender
	{
		/**
		 *
		 * @param image
		 * @param animation
		 * @param forceResize Only applicable in starling but forces an image to resize to fit a texture
		 *
		 */
		function updateFrame( image:*, animation:Animation, forceResize:Boolean = false ):void;

		function applyTransform( rot:Number, sx:Number, sy:Number, scaleFirst:Boolean, offsetX:Number, offsetY:Number ):void;

		function addGlow( color:uint, strength:Number = 1, blur:Number = 1, resolution:Number = .5 ):void;
		function removeGlow():void;

		function get alpha():Number;
		function set alpha( v:Number ):void;

		function get blendMode():String;
		function set blendMode( v:String ):void;

		function get color():uint;
		function set color( value:uint ):void;

		function get rotation():Number;
		function set rotation( v:Number ):void;

		function get width():Number;
		function get height():Number;

		function set width( v:Number ):void;
		function set height( v:Number ):void;

		function get scaleX():Number;
		function get scaleY():Number;

		function set scaleX( v:Number ):void;
		function set scaleY( v:Number ):void;

		function get x():Number;
		function get y():Number;

		function set x( v:Number ):void;
		function set y( v:Number ):void;

		function destroy():void;
	}
}
