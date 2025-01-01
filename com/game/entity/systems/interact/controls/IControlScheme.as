package com.game.entity.systems.interact.controls
{
	import com.controller.keyboard.KeyboardController;
	import com.game.entity.systems.interact.InteractSystem;

	public interface IControlScheme
	{
		function init( interactSystem:InteractSystem, layer:*, keyController:KeyboardController ):void;

		function addDownKey( keyCode:uint ):void;
		function removeDownKey( keyCode:uint ):void;
		function addUpKey( keyCode:uint ):void;
		function removeUpKey( keyCode:uint ):void;

		function set notifyOnMove( v:Boolean ):void;

		function destroy():void;
	}
}
