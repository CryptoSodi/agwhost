package com.game.entity.components.sector
{
	import org.ash.core.Entity;

	public class Fleet
	{
		public var thrusterBackLeft:Entity;
		public var thrusterBackRight:Entity;
		public var thrustersEngaged:Boolean;

		public function Fleet()
		{
			thrustersEngaged = false;
		}

		public function disengageThrusters():void
		{
			thrusterBackLeft = thrusterBackRight = null;
			thrustersEngaged = false;
		}

		public function destroy():void
		{
			disengageThrusters();
		}
	}
}
