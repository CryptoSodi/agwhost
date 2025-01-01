package com.event
{
	import com.model.prototype.IPrototype;
	import com.model.transaction.TransactionVO;

	import flash.events.Event;

	public class ToastEvent extends Event
	{
		public static const SHOW_TOAST:String = "showToast";

		public var data:*;
		public var prototype:IPrototype;
		public var strings:Vector.<String>    = new Vector.<String>;
		public var transaction:TransactionVO;
		public var toastType:Object;

		public function ToastEvent()
		{
			super(SHOW_TOAST, false, false);
		}

		public function addStrings( ... text ):void
		{
			for (var i:int = 0; i < text.length; i++)
			{
				strings.push(text[i]);
			}
		}

		public function addStringsFromArray( text:Array ):void
		{
			for (var i:int = 0; i < text.length; i++)
			{
				strings.push(text[i]);
			}
		}

		public function get nextString():String
		{
			if (strings.length > 0)
				return strings.shift();
			return '';
		}

		public function destroy():void
		{
			prototype = null;
			strings.length = 0;
			toastType = null;
		}
	}
}
