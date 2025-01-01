package com.enum
{
	public class TooltipEnum
	{
		public static const AREA:Array               = ['itemClass', 'powerCost', 'activated', 'damage', 'outerWidth', 'outerDistance', 'radius', 'targeting', 'resolution', 'penetration', 'tracking', 'attackType',
														'damageType', 'chargeTime', 'fireTime', 'reloadTime', 'duration', 'tickRate'];
		public static const AREA_ABBR:Array          = ['damage', 'outerWidth', 'outerDistance', 'radius', 'damageType'];

		public static const ARMOR:Array              = ['itemClass', 'powerCost', 'forceArmor', 'explosiveArmor', 'energyArmor'];
		public static const ARMOR_ABBR:Array         = ['forceArmor', 'explosiveArmor', 'energyArmor'];

		public static const BEAM:Array               = ['itemClass', 'powerCost', 'activated', 'damage', 'minRange', 'maxRange', 'targeting', 'resolution', 'penetration', 'tracking',
														'attackType', 'damageType', 'chargeTime', 'fireTime', 'reloadTime', 'burstSize'];
		public static const BEAM_ABBR:Array          = ['damage', 'minRange', 'maxRange', 'damageType'];

		public static const BUILDING:Array           = ['health', 'profile', 'armor', 'masking', 'canBeRecycled'];
		public static const BUILDING_ABBR:Array      = ['health', 'armor'];

		public static const DEFENSE:Array            = ['itemClass', 'powerCost', 'guidedIntercept', 'projectileIntercept', 'beamIntercept', 'droneIntercept', 'fireDelay', 'fireRange', 'droneDamage', 'smartTargeting'];
		public static const DEFENSE_ABBR:Array       = ['guidedIntercept', 'projectileIntercept', 'beamIntercept', 'droneIntercept', 'fireDelay', 'fireRange', 'droneDamage', 'smartTargeting'];

		public static const DRONE:Array              = ['itemClass', 'powerCost', 'activated', 'damage', 'maxRange', 'targeting', 'resolution', 'penetration', 'tracking', 'attackType', 'damageType', 'launchTime',
														'rebuildTime', 'maxDrones', 'damageTime', 'speed', 'lifeTime', 'droneHealth'];
		public static const DRONE_ABBR:Array         = ['damage', 'maxRange', 'damageType', 'maxDrones'];

		public static const PROJECTILE:Array         = ['itemClass', 'powerCost', 'activated', 'damage', 'minRange', 'maxRange', 'targeting', 'resolution', 'penetration', 'tracking', 'attackType', 'damageType',
														'chargeTime', 'fireTime', 'reloadTime', 'burstSize', 'volleySize', 'speed', 'turnSpeed', 'splashRadius', 'splashDamage','fuseRadius'];
		public static const PROJECTILE_ABBR:Array    = ['damage', 'minRange', 'maxRange', 'damageType'];

		public static const SHIELD:Array             = ['itemClass', 'powerCost', 'forceShielding', 'explosiveShielding', 'energyShielding'];
		public static const SHIELD_ABBR:Array        = ['forceShielding', 'explosiveShielding', 'energyShielding'];

		public static const SHIP_RESEARCH:Array      = ['health', 'mapSpeed', 'maxSpeed', 'rotationSpeed', 'allowPivot', 'shieldThreshold', 'shieldResetTime', 'profile', 'evasion', 'armor',
														'masking', 'loadSpeed', 'cargo', 'power', 'specialSlots', 'weaponSlots', 'defenseSlots', 'techSlots', 'structureSlots'];
		public static const SHIP_RESEARCH_ABBR:Array = ['health', 'maxSpeed', 'cargo', 'power'];

		public static const SHIP_BUILT:Array         = ['health', 'shipDps', 'shipRange'];

		public static const TECH:Array               = ['itemClass', 'powerCost'];
		public static const TECH_ABBR:Array          = [];
	}
}
