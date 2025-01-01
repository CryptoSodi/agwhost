package com.game.entity.components.battle
{
	import org.ash.core.Entity;

	public class Drone
	{
		public var ownerID:String;
		public var targetID:String;
		public var fireDuration:Number;
		public var minWeaponTime:Number;
		public var maxWeaponTime:Number;
		public var nextFireTick:Number;
		public var cleanupTick:Number;
		public var currentTick:Number;
		public var weaponProto:String;
		public var weaponAttack:Entity;
		public var isOribiting:Boolean;

		public function init( ownerID:String, targetID:String ):void
		{
			this.ownerID = ownerID;
			this.targetID = targetID;
			this.minWeaponTime = 0.1;
			this.maxWeaponTime = 0.5;
			this.nextFireTick = -1;
			this.cleanupTick = -1;
			this.currentTick = -1;
			this.weaponProto = "";
			this.weaponAttack = null;
			this.isOribiting = false;
		}

		public function destroy():void
		{
			ownerID = targetID = weaponProto = null;
			weaponAttack = null;
		}
	}
}
