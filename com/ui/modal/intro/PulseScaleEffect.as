package com.ui.modal.intro
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import org.greensock.TweenManual;

	public class PulseScaleEffect extends Sprite
	{
		protected var _obj:DisplayObject;
		protected var _end:Number;
		protected var _speed:Number;
		protected var _start:Number;

		public function PulseScaleEffect( obj:DisplayObject, start:Number, end:Number, speed:Number = 1 )
		{
			_obj = obj;
			_end = end;
			_speed = speed;
			_start = start;
			scaleUp();
		}

		protected function scaleDown():void
		{
			TweenManual.to(_obj, _speed, {scaleX:_start, scaleY:_start, onComplete:scaleUp});
		}

		protected function scaleUp():void
		{
			TweenManual.to(_obj, _speed, {scaleX:_end, scaleY:_end, onComplete:scaleDown});
		}

		public function destroy():void
		{
			TweenManual.killTweensOf(_obj);
			_obj.scaleX = _obj.scaleY = 1;
			_obj = null;
		}

	}
}
