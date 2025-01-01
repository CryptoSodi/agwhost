package com.service.server.incoming.mail
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.data.MailInboxData;
	
	import org.shared.ObjectPool;

	public class MailInboxResponse implements IResponse
	{
		public var nowMillis:Number;
		public var mailData:Vector.<MailInboxData> = new Vector.<MailInboxData>;

		private var _header:int;
		private var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			nowMillis = input.readInt64();
			
			var mailInboxData:MailInboxData;
			var numMails:int = input.readUnsignedInt();
			for ( var idx:int = 0; idx < numMails; ++idx )
			{
				// TODO - mail object, this reads summary fields for inbox display
				mailInboxData = ObjectPool.get(MailInboxData);
				mailInboxData.read(input);
				mailData.push(mailInboxData);
			}
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
		}

		public function get isTicked():Boolean  { return false; }

		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }

		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }

		public function destroy():void
		{
		}
	}
}
