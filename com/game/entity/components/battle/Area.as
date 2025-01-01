package com.game.entity.components.battle
{
	import com.model.prototype.IPrototype;

	public class Area
	{
		public var duration:Number;
		public var ownerID:String;
		public var strength:Number;
		public var sourceAttachPoint:String;
		public var maxRange:Number;
		public var moveWithSource:Boolean;
		public var rotateWithSource:Boolean;
		public var useBeamDynamics:Boolean;
		public var startScaleX:Number;
		public var startScaleY:Number;
		public var startAlpha:Number;
		public var animLength:Number;
		public var animTime:Number;

		private var _alphaDelta:Number;
		private var _prototype:IPrototype;
		private var _scaleDeltaX:Number;
		private var _scaleDeltaY:Number;

		public function init( ownerID:String, sourceAttachPt:String, maxRange:Number, prototype:IPrototype ):void
		{
			this.ownerID = ownerID;
			this.strength = 0;
			this.sourceAttachPoint = sourceAttachPt;
			this.maxRange = maxRange;
			this.animTime = 0;
			_prototype = prototype;
			resetAnimation();
		}

		public function resetAnimation():void
		{
			animTime = 0;
			strength = 0;
			moveWithSource = _prototype.getValue("moveWithSource");
			rotateWithSource = _prototype.getValue("rotateWithSource");
			useBeamDynamics = _prototype.getValue("useBeamDynamics");
			startScaleX = _prototype.getValue("startScaleX");
			endScaleX = _prototype.getValue("endScaleX");
			startScaleY = _prototype.getValue("startScaleY");
			startAlpha = _prototype.getValue("startAlpha");
			endAlpha = _prototype.getValue("endAlpha");
			endScaleY = _prototype.getValue("endScaleY");
			animLength = _prototype.getValue("animLength");
			duration = _prototype.getUnsafeValue("duration") == null ? 0 : _prototype.getUnsafeValue("duration");
		}

		public function set endScaleX( v:Number ):void  { _scaleDeltaX = v - startScaleX; }
		public function set endScaleY( v:Number ):void  { _scaleDeltaY = v - startScaleY; }
		public function set endAlpha( v:Number ):void  { _alphaDelta = v - startAlpha; }

		public function get scaleDeltaX():Number  { return _scaleDeltaX; }
		public function get scaleDeltaY():Number  { return _scaleDeltaY; }
		public function get alphaDelta():Number  { return _alphaDelta; }

		public function destroy():void
		{
			_prototype = null;
		}
	}
}
