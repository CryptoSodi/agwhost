package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	import org.starling.utils.Color;

	public class DebugLineData implements IServerData
	{
		public var id:uint;
		public var startX:Number;
		public var startY:Number;
		public var endX:Number;
		public var endY:Number;
		public var startColorR:uint;
		public var startColorG:uint;
		public var startColorB:uint;
		public var endColorR:uint;
		public var endColorG:uint;
		public var endColorB:uint;
		public var relativeToKey:String;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			id = input.readUnsignedInt();
			startX = input.readDouble();
			startY = input.readDouble();
			endX = input.readDouble();
			endY = input.readDouble();
			startColorR = input.readUnsignedByte();
			startColorG = input.readUnsignedByte();
			startColorB = input.readUnsignedByte();
			endColorR = input.readUnsignedByte();
			endColorG = input.readUnsignedByte();
			endColorB = input.readUnsignedByte();
			relativeToKey = input.readUTF();
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
		}

		public function destroy():void
		{
		}

		public function get startColor():uint
		{
			return Color.rgb(startColorR, startColorG, startColorB);
		}

		public function get endColor():uint
		{
			return Color.rgb(endColorR, endColorG, endColorB);
		}
	}
}
