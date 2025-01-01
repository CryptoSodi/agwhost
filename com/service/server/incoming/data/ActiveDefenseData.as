package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class ActiveDefenseData extends ModuleData
	{

		override public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			super.read(input);
			input.checkToken();
		}

		override public function readJSON( data:Object ):void
		{
			for (var key:String in data)
			{
				if (this.hasOwnProperty(key))
				{
					this[key] = data[key];
				} else
				{
					// TODO - complain about missing key?
				}
			}
		}

		override public function destroy():void
		{

		}
	}
}
