package com.game.entity.systems.shared
{
	import org.ash.core.Game;
	import org.ash.core.System;
	import org.greensock.TweenManual;

	public class TweenSystem extends System
	{
		override public function update( time:Number ):void
		{
			TweenManual.updateAll(time);
		}

		override public function removeFromGame( game:Game ):void
		{
			TweenManual.killAll();
		}
	}
}
