package org.parade.core
{
	public interface IViewStack
	{
		function addView( view:IView ):void;

		function addToLayer( object:Object, layer:String ):void;

		function getLayer( layer:String ):*;

		function clearLayer( layer:String ):void;

		function shake( amplitude:Number = 1, time:int = 1, speed:int = 10, direction:int = 3 ):void;

		function update( time:Number ):void;
	}
}
