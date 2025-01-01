package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class SubsystemData implements IServerData
	{
		//public var id:int;
		public var subsystemPrototype:String;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			subsystemPrototype = input.readUTF();
			input.checkToken();
		}

		public function readJSON( data:Object ):void
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

		public function destroy():void
		{

		}
	}
}
