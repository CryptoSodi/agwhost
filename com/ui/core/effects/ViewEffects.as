package com.ui.core.effects
{
	import org.osflash.signals.Signal;
	import org.parade.core.IView;
	import org.shared.ObjectPool;

	public class ViewEffects
	{
		private var _doneIn:Boolean          = false;
		private var _doneOut:Boolean         = false;
		private var _effects:Vector.<Effect> = new Vector.<Effect>;
		private var _finishCount:int;
		private var _onEffectIn:Signal       = new Signal();
		private var _onEffectOut:Signal      = new Signal();

		public function addEffect( effect:Effect ):void
		{
			effect.addCallbacks(doneIn, doneOut);
			_effects.push(effect);
		}

		public function effectsIn( screen:IView ):void
		{
			_finishCount = 0;
			for (var i:int = 0; i < _effects.length; i++)
			{
				_effects[i].goIn(screen);
			}
			if (_effects.length == 0)
				doneIn('');
		}

		public function effectsOut( screen:IView ):void
		{
			_finishCount = 0;
			for (var i:int = 0; i < _effects.length; i++)
			{
				_effects[i].goOut(screen);
			}
			if (_effects.length == 0)
				doneOut('');
		}

		private function doneIn( name:String ):void
		{
			_doneIn = true;
			_finishCount++;
			if (_finishCount >= _effects.length)
				_onEffectIn.dispatch();
		}

		private function doneOut( name:String ):void
		{
			_doneOut = true;
			_finishCount++;
			if (_finishCount >= _effects.length)
				_onEffectOut.dispatch();
		}

		public function addInListener( listener:Function ):void  { _onEffectIn.add(listener); }
		public function addOutListener( listener:Function ):void  { _onEffectOut.add(listener); }
		public function removeInListener( listener:Function ):void  { _onEffectIn.remove(listener); }
		public function removeOutListener( listener:Function ):void  { _onEffectOut.remove(listener); }

		public function get isDoneIn():Boolean  { return _doneIn; }
		public function get isDoneOut():Boolean  { return _doneOut; }
		public function get numEffects():int  { return _effects.length; }

		public function destroy():void
		{
			for (var i:int = 0; i < _effects.length; i++)
			{
				ObjectPool.give(_effects[i]);
			}
			_doneIn = _doneOut = false;
			_effects.length = 0;
			_onEffectIn.removeAll();
			_onEffectOut.removeAll();
		}
	}
}
