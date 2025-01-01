package com.ui.core.effects
{
	import flash.utils.Dictionary;

	import org.shared.ObjectPool;

	public class EffectFactory
	{
		private static var callbacksIN:Dictionary;
		private static var callbacksOUT:Dictionary;

		public function EffectFactory()  {}

		public static function alphaEffect( start:Number, middle:Number, end:Number, timeIN:Number, timeOUT:Number ):Effect
		{
			var effect:AlphaEffect = ObjectPool.get(AlphaEffect);
			effect.init(start, middle, end, timeIN, timeOUT);
			return effect;
		}

		public static function fullScreenFadeEffect( timeIN:Number, timeOUT:Number ):Effect
		{
			var effect:FullscreenFadeEffect = ObjectPool.get(FullscreenFadeEffect);
			effect.init(timeIN, timeOUT);
			return effect;
		}

		public static function genericMoveEffect( start:String, end:String, timeIN:Number, timeOUT:Number, ei:Function = null, eo:Function = null ):Effect
		{
			var effect:GenericMoveEffect = ObjectPool.get(GenericMoveEffect);
			effect.init(start, end, timeIN, timeOUT, ei, eo);
			return effect;
		}

		public static function resizeEffect( callback:Function = null ):Effect
		{
			var effect:ResizeEffect = ObjectPool.get(ResizeEffect);
			effect.init(callback);
			return effect;
		}

		public static function simpleMoveEffect( start:String, end:String, timeIN:Number, timeOUT:Number, ei:Function = null, eo:Function = null ):Effect
		{
			var effect:SimpleMoveEffect = ObjectPool.get(SimpleMoveEffect);
			effect.init(start, end, timeIN, timeOUT, ei, eo);
			return effect;
		}

		public static function simpleBackingEffect( a:Number, timeIN:Number, timeOUT:Number, clickCallback:Function = null ):Effect
		{
			var effect:SimpleBackingEffect = ObjectPool.get(SimpleBackingEffect);
			effect.init(a, timeIN, timeOUT, clickCallback);
			return effect;
		}

		public static function scaleEffect( start:Number, end:Number, timeIN:Number, timeOUT:Number, reposition:Boolean = false ):Effect
		{
			var effect:ScaleEffect = ObjectPool.get(ScaleEffect);
			effect.init(start, end, timeIN, timeOUT, reposition);
			return effect;
		}

		public static function repositionEffect( positionX:String, positionY:String, callback:Function = null, screenX:Number = 0, screenY:Number = 0 ):Effect
		{
			var effect:StageRepositionEffect = ObjectPool.get(StageRepositionEffect);
			effect.init(positionX, positionY, callback, screenX, screenY);
			return effect;
		}

		public static function stageLetterboxEffect( timeIn:Number, timeOut:Number, isTop:Boolean, boxHeight:int = 130, clickCallback:Function = null ):Effect
		{
			var effect:StageLetterboxEffect = ObjectPool.get(StageLetterboxEffect);
			effect.init(timeIn, timeOut, isTop, boxHeight, clickCallback);
			return effect;
		}
	}

}
