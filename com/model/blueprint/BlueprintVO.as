package com.model.blueprint
{
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.BlueprintData;

	public class BlueprintVO implements IPrototype
	{
		private var _id:String;
		private var _prototype:IPrototype;
		private var _playerOwner:String;
		private var _partsCollected:int;
		private var _partsCollectedBank:int;
		private var _blueprintPrototype:String;

		public function init( id:String ):void
		{
			_id = id;
		}

		public function importData( blueprintData:BlueprintData ):void
		{
			_id = blueprintData.id
			_prototype = blueprintData.prototype;
			_playerOwner = blueprintData.playerOwner;
			_partsCollected = blueprintData.partsCollected;
			_partsCollectedBank = blueprintData.partsCollectedBank;
			_blueprintPrototype = blueprintData.blueprintPrototype;
		}
		public function get partsCompleted():int
		{
			return _partsCollected;
		}

		public function get partsCollected():int
		{
			return _partsCollectedBank;
		}

		public function get totalParts():int
		{
			return getUnsafeValue('parts');
		}

		public function get partsRemaining():int
		{
			return getUnsafeValue('parts') - _partsCollectedBank;
		}

		public function get complete():Boolean
		{
			return (getUnsafeValue('parts') - _partsCollected <= 0) ? true : false;
		}

		public function get costScale():Number
		{
			return getUnsafeValue('costScale');
		}

		public function get prototype():IPrototype  { return _prototype; }

		public function getUnsafeValue( key:String ):*  { return _prototype.getUnsafeValue(key); }
		public function getValue( key:String ):*  { return _prototype.getValue(key); }

		public function get id():String  { return _id; }
		
		public function get asset():String  { return _prototype.asset; }
		public function get uiAsset():String  { return _prototype.uiAsset; }

		public function get name():String  { return _prototype.name; }
		public function get itemClass():String  { return _prototype.itemClass; }
		public function get buildTimeSeconds():uint  { return _prototype.buildTimeSeconds; }

		public function get alloyCost():int  { return 0; }
		public function get creditsCost():int  { return 0; }
		public function get energyCost():int  { return 0; }
		public function get syntheticCost():int  { return 0; }

		public function destroy():void
		{
			_prototype = null;
		}
	}
}
