package com.ui.core.component
{
	public interface IComponent
	{
		function get enabled():Boolean;
		function set enabled( value:Boolean ):void;

		function destroy():void;
	}
}
