package com.model.transaction
{
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.service.server.BinaryInputStream;

	import flash.utils.getTimer;

	public class TransactionVO
	{
		public var id:String;
		public var type:String;

		private var _baseID:String;
		private var _began:uint;
		private var _clientTime:int;
		private var _ends:uint;
		private var _messageID:int;
		private var _reason:String;
		private var _serverKey:String;
		private var _state:int;
		private var _success:Boolean;
		private var _temp:Number;
		private var _timeMS:Number;
		private var _timeRemainingMS:Number;
		private var _token:int;

		public function init( id:String, type:String, token:int ):void
		{
			this.id = id;
			this.type = type;
			_token = token;
			setPendingState();
		}

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			_token = input.readInt();
			_serverKey = input.readUTF();
			id = input.readUTF();
			_messageID = input.readByte(); // should match the original message used to create this transaction
			_success = input.readBoolean();
			_state = input.readInt(); // see StarbaseTransactionStateEnum
			_timeMS = input.readInt(); // Total time Cost
			_began = input.readInt64(); // Begin Time Stamp
			_ends = input.readInt64(); //End Time Stamp
			_timeRemainingMS = input.readInt(); // Total time left
			_baseID = input.readUTF();
			_reason = input.readUTF(); // debug string, will probably go away eventually
			input.checkToken();

			_clientTime = getTimer();
		}

		public function readJSON( data:Object ):void
		{
			_baseID = data.basePersistence;
			_began = data.began; // Begin Time Stamp
			_clientTime = getTimer();
			_ends = data.ends; //End Time Stamp
			id = data.key;
			_messageID = data.messageId; // should match the original message used to create this transaction
			_reason = data.reason; // debug string, will probably go away eventually
			_serverKey = data.transactionKey;
			_state = data.state; // see StarbaseTransactionStateEnum
			_success = data.succes;
			_timeMS = data.time_cost_milliseconds; // Total time Cost
			_timeRemainingMS = data.timeRemainingMS; // Total time left
			_token = data.token;
		}

		public function importData( vo:TransactionVO ):void
		{
			_baseID = vo.baseID;
			_began = vo.began;
			_clientTime = getTimer();
			_ends = vo.ends;
			id = vo.id;
			_messageID = vo.messageID;
			_reason = vo.reason;
			_serverKey = vo.serverKey;
			_state = vo.state;
			_success = vo.success;
			_timeMS = vo.timeMS;
			_timeRemainingMS = vo.serverTimeRemainingMS;
			_token = vo.token;
		}

		public function setPendingState():void
		{
			_began = _ends = _clientTime = 0;
			_timeMS = _timeRemainingMS = -1;
			_state = StarbaseTransactionStateEnum.PENDING;
		}

		public function get baseID():String  { return _baseID; }

		public function get began():uint  { return _began; }

		public function get ends():uint  { return _ends; }

		public function get messageID():int  { return _messageID; }

		public function get percentComplete():Number
		{
			var percent:Number = 1 - (timeRemainingMS / _timeMS);
			if (percent < 0)
				percent = 0;
			return (percent > 1) ? 1 : percent;
		}

		public function get reason():String  { return _reason; }

		public function get serverKey():String  { return _serverKey; }

		public function get state():int  { return _state; }

		public function get success():Boolean  { return _success; }

		public function get timeMS():Number  { return _timeMS; }

		public function get serverTimeRemainingMS():Number  { return _timeRemainingMS; }

		public function get timeRemainingMS():Number
		{
			if (_state == StarbaseTransactionStateEnum.PENDING)
				return -1;
			_temp = _timeRemainingMS - (getTimer() - _clientTime);
			if (_temp < 0)
				_temp = 0;
			return _temp;
		}

		public function get token():int  { return _token; }

		public function destroy():void
		{

		}
	}
}
