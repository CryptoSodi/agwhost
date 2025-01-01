package com.model.starbase
{
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.BuffData;

	import flash.utils.getTimer;

	public class BuffVO implements IPrototype
	{
		public var baseID:String;
		public var playerOwnerID:String;
		public var prototypeVO:IPrototype;
		public var began:Number;
		public var ends:Number;
		public var timeRemaining:Number;

		private var _timeRemainingMS:Number;
		private var _clientTime:Number;
		private var _id:String;

		internal function importData( buffData:BuffData ):void
		{
			_id = buffData.id;
			prototypeVO = buffData.prototype;
			baseID = buffData.baseID;
			playerOwnerID = buffData.playerOwnerID;
			began = buffData.began;
			ends = buffData.ends;
			timeRemaining = buffData.timeRemaining;

			_clientTime = getTimer();
		}

		internal function forceSetID( v:String ):void  { _id = v; }

		public function getUnsafeValue( key:String ):*  { return prototypeVO.getUnsafeValue(key); }
		public function getValue( key:String ):*  { return prototypeVO.getValue(key); }

		public function get asset():String  { return prototypeVO.asset; }
		public function get uiAsset():String  { return prototypeVO.uiAsset; }

		public function get name():String  { return prototypeVO.name; }
		public function get id():String  { return _id }
		public function get itemClass():String  { return prototypeVO.itemClass; }
		public function get buildTimeSeconds():uint  { return prototypeVO.buildTimeSeconds; }

		public function get timeRemainingMS():Number
		{
			_timeRemainingMS = timeRemaining - (getTimer() - _clientTime);
			if (_timeRemainingMS < 0)
				_timeRemainingMS = 0;
			return _timeRemainingMS;
		}
		
		public function get buffType():String { return getValue('buffType'); }
		
		public function get alloyCost():int  { return 0; }
		public function get creditsCost():int  { return 0; }
		public function get energyCost():int  { return 0; }
		public function get syntheticCost():int  { return 0; }
	}
}
