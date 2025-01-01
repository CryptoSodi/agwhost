package com.ui.core
{
	import com.enum.ui.ButtonEnum;

	public class ButtonPrototype
	{
		public var type:String;
		public var text:String;
		public var callback:Function;
		public var args:Array = [];
		public var doClose:Boolean;

		public function ButtonPrototype( text:String, callback:Function = null, args:Array = null, doClose:Boolean = true, type:String = 'BtnBlueA' )
		{
			this.text = text;
			this.callback = callback;
			if (args)
				this.args = args;
			this.doClose = doClose;
			this.type = type;
		}
	}
}
