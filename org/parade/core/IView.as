package org.parade.core
{
	import flash.geom.Rectangle;

	public interface IView
	{
		function onEscapePressed():void;

		function get type():String;
		function get typeUnique():Boolean;
		function get screenshotBlocker():Boolean;

		function get alpha():Number;
		function set alpha( value:Number ):void;
		function get bounds():Rectangle;
		function get height():Number;
		function set height( value:Number ):void;
		function get scaleX():Number;
		function set scaleX( value:Number ):void;
		function get scaleY():Number;
		function set scaleY( value:Number ):void;
		function get visible():Boolean;
		function set visible( value:Boolean ):void;
		function get width():Number;
		function set width( value:Number ):void;
		function get x():Number;
		function set x( value:Number ):void;
		function get y():Number;
		function set y( value:Number ):void;

		function destroy():void;
	}
}
