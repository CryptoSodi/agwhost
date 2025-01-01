package com.model.starbase
{
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.ResearchData;

	public class ResearchVO implements IPrototype
	{
		public var baseID:String;
		public var playerOwnerID:String;
		public var prototype:IPrototype;

		private var _id:String = '';

		internal function init( id:String ):void
		{
			_id = id;
		}

		public function importData( researchData:ResearchData ):void
		{
			baseID = researchData.baseID;
			playerOwnerID = researchData.playerOwnerID;
			prototype = researchData.prototype;
		}

		internal function forceSetID( v:String ):void  { _id = v; }

		public function getUnsafeValue( key:String ):*  { return prototype.getUnsafeValue(key); }
		public function getValue( key:String ):*  { return prototype.getValue(key); }

		public function get id():String  { return _id; }

		public function get name():String  { return prototype.name; }
		public function get itemClass():String  { return prototype.itemClass; }
		public function get level():int  { return prototype.getValue('level'); }
		public function get buildTimeSeconds():uint  { return prototype.buildTimeSeconds; }
		public function get requiredBuildingClass():String  { return prototype.getValue('requiredBuildingClass'); }

		public function get asset():String  { return prototype.asset; }
		public function get uiAsset():String  { return prototype.uiAsset; }

		public function get alloyCost():int  { return prototype.alloyCost; }
		public function get creditsCost():int  { return prototype.creditsCost; }
		public function get energyCost():int  { return prototype.energyCost; }
		public function get syntheticCost():int  { return prototype.syntheticCost; }
	}
}
