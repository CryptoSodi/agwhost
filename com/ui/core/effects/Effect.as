package com.ui.core.effects
{
	import org.parade.core.IView;

	public class Effect
	{
		protected var _inCallback:Function;
		protected var _outCallback:Function;
		protected var _name:String;

		internal function goIn( screen:IView ):void  {}
		internal function goOut( screen:IView ):void  {}

		internal function doneIn():void  { if (_inCallback != null) _inCallback(_name); }
		internal function doneOut():void  { if (_outCallback != null) _outCallback(_name); }

		internal function addCallbacks( inCall:Function, outCall:Function ):void
		{
			_inCallback = inCall;
			_outCallback = outCall;
		}

		public function destroy():void
		{
			_inCallback = _outCallback = null;
		}
	}
}
