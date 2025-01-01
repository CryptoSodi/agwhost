package com.model.alliance
{
	public class AllianceMemberVO
	{
		private var _key:String;
		private var _name:String;
		private var _xp:uint;
		private var _lastOnline:uint;
		private var _rank:int;

		public function AllianceMemberVO( key:String, name:String, xp:uint, lastOnline:uint, rank:int )
		{
			_key = key;
			_name = name;
			_xp = xp;
			_lastOnline = lastOnline;
			_rank = rank;
		}

		public function get key():String  { return _key; }
		public function get name():String  { return _name; }
		public function get xp():uint  { return _xp; }
		public function get lastOnline():uint  { return _lastOnline; }
		public function get rank():int  { return _rank; }
	}
}
