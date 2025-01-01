package com.model.prototype
{
	public class PrototypeVO implements IPrototype
	{
		private var _data:Object;
		private var _overriddenData:Object;

		public function PrototypeVO( data:Object )
		{
			_data = data;
		}

		public function getValue( key:String ):*
		{
			if (_overriddenData && _overriddenData.hasOwnProperty(key))
				return _overriddenData[key];

			if (_data.hasOwnProperty(key))
				return _data[key];
			else
				throw new Error("Parameter " + key + " not found on " + this);
		}

		public function getUnsafeValue( key:String ):*
		{
			if (_overriddenData && _overriddenData.hasOwnProperty(key))
				return _overriddenData[key];

			if (_data.hasOwnProperty(key))
				return _data[key];

			return null;
		}

		public function overrideValue( key:String, newValue:* ):void
		{
			if (_overriddenData == null)
				_overriddenData = new Object();

			_overriddenData[key] = newValue;
		}

		public function removeOverridenValue( key:String ):void
		{
			delete _overriddenData[key];
		}

		public function get asset():String  { return getUnsafeValue('asset'); }
		public function get uiAsset():String  { return getUnsafeValue('uiAsset'); }

		public function get name():String  { return getValue('key'); }
		public function get itemClass():String  { return getValue('itemClass'); }
		public function get buildTimeSeconds():uint  { return getUnsafeValue('buildTimeSeconds'); }

		public function get alloyCost():int
		{
			if (_data.hasOwnProperty('alloyCost'))
				return getValue('alloyCost');
			return 0;
		}
		public function get creditsCost():int
		{
			if (_data.hasOwnProperty('creditsCost'))
				return getValue('creditsCost');
			return 0;
		}
		public function get energyCost():int
		{
			if (_data.hasOwnProperty('energyCost'))
				return getValue('energyCost');
			return 0;
		}
		public function get syntheticCost():int
		{
			if (_data.hasOwnProperty('syntheticCost'))
				return getValue('syntheticCost');
			return 0;
		}
	}
}
