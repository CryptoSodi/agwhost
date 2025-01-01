package com.game.entity.components.shared
{
	import com.controller.ServerController;

	import flash.geom.Point;

	public class Move
	{
		public var delta:Point           = new Point();
		public var destination:Point     = new Point();
		public var destroyOnComplete:Boolean;
		public var directionChanged:Boolean;
		public var endTick:int;
		public var lerping:Boolean;
		public var lerpDestination:Point = new Point();
		public var moving:Boolean;
		public var relative:Boolean;
		public var rotation:Number;
		public var start:Point           = new Point();
		public var startTick:int;
		public var time:Number;
		public var totalTime:Number;
		public var type:int;
		public var velocity:Point        = new Point();
		public var fadeOut:int;

		private var _updates:Array       = [];

		public function init( speed:int, type:int ):void
		{
			delta.setTo(0, 0);
			destination.setTo(0, 0);
			lerpDestination.setTo(0, 0);
			start.setTo(0, 0);
			endTick = time = startTick = totalTime = 0;
			destroyOnComplete = directionChanged = lerping = moving = relative = false;
			fadeOut = 0;
			this.type = type;
		}

		public function setDelta( x:Number, y:Number ):void
		{
			delta.x = x;
			delta.y = y;
		}

		public function setLerpDestination( x:Number, y:Number, velocityX:Number, velocityY:Number, rotation:Number, startTick:int, endTick:int ):void
		{
			lerpDestination.x = x;
			lerpDestination.y = y;
			this.rotation = rotation;
			directionChanged = true;
			this.endTick = endTick;
			this.startTick = startTick;
			time = (startTick < ServerController.SIMULATED_TICK) ? ((Math.min(ServerController.SIMULATED_TICK, endTick) - startTick) * .1) : 0; //(moving && type == EntityMoveEnum.FREE) ? time -= totalTime : 0;
			totalTime = (endTick - startTick) * .1;
			if (totalTime == 0)
				totalTime = .1;
			velocity.setTo(velocityX, velocityY);
			moving = true;
		}

		public function setPointToPoint( x:Number, y:Number, startTick:int, endTick:int, relative:Boolean = false ):void
		{
			setDestination(x, y);
			directionChanged = true;
			this.endTick = endTick;
			moving = true;
			this.relative = relative;
			this.startTick = startTick;
			time = (startTick < ServerController.SIMULATED_TICK) ? ((Math.min(ServerController.SIMULATED_TICK, endTick) - startTick) * .1) : 0;
			totalTime = (endTick - startTick) * .1;
			if (totalTime == 0)
				totalTime = .1;
		}

		public function setDestination( x:Number, y:Number ):void
		{
			destination.x = x;
			destination.y = y;
		}

		public function setStart( position:Point ):void
		{
			start.x = position.x;
			start.y = position.y;
		}

		public function addUpdate( targetX:Number, targetY:Number, velocityX:Number, velocityY:Number, rotation:Number, startTick:int, endTick:int ):void
		{
			_updates.push(targetX, targetY, velocityX, velocityY, rotation, startTick, endTick);
		}

		public function setNextUpdate():void
		{
			setLerpDestination(_updates[0], _updates[1], _updates[2], _updates[3], _updates[4], _updates[5], _updates[6]);
			_updates.splice(0, 7);
			lerping = true;
		}

		public function get hasUpdate():Boolean  { return _updates.length > 0; }

		public function destroy():void
		{
			_updates.length = 0;
		}
	}
}
