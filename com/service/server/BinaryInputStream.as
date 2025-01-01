package com.service.server
{
	import com.enum.server.RequestEnum;
	
	import flash.utils.ByteArray;

	public class BinaryInputStream extends ByteArray
	{
		public var validToken:Boolean = true;
		public var sequenceToken:int                                    = RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_START;

		private var stringInputCache:StringInputCache; // Current cache as set by setProtocol
		private var stringInputCacheByProtocol:Array                    = new Array;
		public var battleStringInputCache:StringInputCache              = new StringInputCache;
		public var sectorAlwaysVisibleStringInputCache:StringInputCache = new StringInputCache;
		public var starbaseBaselineStringInputCache:StringInputCache    = new StringInputCache;

		public function BinaryInputStream()
		{
			super();
		}

		public function setStringInputCache( stringCache:StringInputCache ):void
		{
			this.stringInputCache = stringCache;
		}

		public function checkToken():void
		{
			var token:int = this.readInt();
			if (token != sequenceToken)
			{
				//validToken = false;
				//++sequenceToken;
				//return;
				throw new Error("Bad BinaryInputStream sequence token, the calling read() function does not match the Server data sent.");
			}
			++sequenceToken;
		}

		public function readStringCacheBaseline():void
		{
			if(!validToken)
				return;
			
			if (this.stringInputCache)
			{
				return this.stringInputCache.readBaseline(this);
			}
		}

		public override function readUTF():String
		{
			if(!validToken)
				return "";
			
			if (this.stringInputCache)
			{
				return this.stringInputCache.readUTF(this);
			}
			return super.readUTF();
		}

		public override function readDouble():Number
		{
			if(!validToken)
				return 0;
			
			return super.readFloat();
		}

		public override function clear():void
		{
			super.clear();
			sequenceToken = RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_START;
			validToken = true;
			this.stringInputCache = null;
		}

		public function readInt64():Number
		{
			if(!validToken)
				return 0;
			
			var high:int      = this.readInt();
			var low:uint      = this.readUnsignedInt();
			var retval:Number = Number(high) * Number(4294967296) + Number(low);
			return retval;
		}
	}
}
