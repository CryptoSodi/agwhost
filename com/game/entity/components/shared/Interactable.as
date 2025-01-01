package com.game.entity.components.shared
{
	public class Interactable
	{
		public var selected:Boolean = false;

		public function destroy():void
		{
			selected = false;
		}
	}
}
