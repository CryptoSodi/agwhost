package org.ash.integration.swiftsuspenders
{
	import flash.utils.Dictionary;

	public class NodeLookup
	{
		private static var _lookup:Dictionary = new Dictionary();

		public function NodeLookup()
		{
			_lookup = new Dictionary();
		}

		public static function addLookup( key:String, nodeClass:String ):void
		{
			_lookup[key] = nodeClass;
		}

		public static function lookupNode( key:String ):String
		{
			if (_lookup[key])
				return _lookup[key];
			return key;
		}
	}
}
