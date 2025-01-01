package com.game.entity.factory
{
	import com.game.entity.systems.shared.background.BackgroundItem;

	import org.ash.core.Entity;

	public interface IBackgroundFactory
	{
		function createBackground( item:BackgroundItem ):Entity;

		function destroyBackground( backgroundItem:Entity ):void
	}
}
