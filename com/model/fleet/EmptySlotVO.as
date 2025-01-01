package com.model.fleet
{
	import com.model.prototype.IPrototype;

	public final class EmptySlotVO implements IPrototype
	{
		public function EmptySlotVO()
		{
		}

		public function getValue( key:String ):*
		{
			return null;
		}

		public function getUnsafeValue( key:String ):*
		{
			return null;
		}

		public function get asset():String
		{
			return '';
		}

		public function get uiAsset():String
		{
			return '';
		}

		public function get name():String
		{
			return '';
		}

		public function get itemClass():String
		{
			return '';
		}

		public function get buildTimeSeconds():uint
		{
			return 0;
		}

		public function get alloyCost():int
		{
			return 0;
		}

		public function get creditsCost():int
		{
			return 0;
		}

		public function get energyCost():int
		{
			return 0;
		}

		public function get syntheticCost():int
		{
			return 0;
		}
	}
}
