package com.game.entity.components.battle
{
	import flash.geom.Point;

	import org.ash.core.Entity;

	public class Ship
	{
		public var attachments:Vector.<Entity>;
		public var position1:Point;
		public var position2:Point;
		public var position3:Point;
		public var lastUpdate:Number;
		public var rangeReference:String;
		public var thrustersFront:Boolean;
		public var thrustersRight:Boolean;
		public var thrustersBack:Boolean;
		public var thrustersLeft:Boolean;
		public var accelThreshold:Number;

		public var damageState:Number;
		public var damageEffects:Vector.<Entity>;

		public function Ship()
		{
			thrustersFront = thrustersRight = thrustersBack = thrustersLeft = false;
			attachments = new Vector.<Entity>();
			lastUpdate = 0;
			position1 = new Point();
			position2 = new Point();
			position3 = new Point();
			accelThreshold = 0.1;

			damageState = 0;
			damageEffects = new Vector.<Entity>();
		}

		public function destroy( final:Boolean = true ):void
		{
			accelThreshold = 0.1;
			lastUpdate = 0;
			position1.setTo(0, 0);
			position2.setTo(0, 0);
			position3.setTo(0, 0);
			attachments.length = 0;
			thrustersFront = thrustersRight = thrustersBack = thrustersLeft = false;

			damageState = 0;
			damageEffects.length = 0;
			if (final)
				rangeReference = null;
		}
	}
}
