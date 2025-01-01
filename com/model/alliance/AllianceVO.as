package com.model.alliance
{
	import com.model.prototype.IPrototype;

	public class AllianceVO
	{
		private var _key:String;
		private var _name:String;
		private var _faction:IPrototype;
		private var _motd:String;
		private var _description:String;
		private var _isPublic:Boolean;
		private var _memberCount:int;
		private var _members:Vector.<AllianceMemberVO>;

		public function AllianceVO( key:String, name:String, faction:IPrototype, motd:String, description:String, isPublic:Boolean )
		{
			_key = key;
			_name = name;
			_faction = faction;
			_motd = motd;
			_description = description;
			_isPublic = isPublic;
		}

		public function get key():String  { return _key; }
		public function get name():String  { return _name; }
		public function get faction():IPrototype  { return _faction; }
		public function get motd():String  { return _motd; }
		public function get description():String  { return _description; }
		public function get isPublic():Boolean  { return _isPublic; }
		public function set memberCount( v:int ):void  { _memberCount = v; }
		public function get memberCount():int  { return _memberCount; }
		public function set members( v:Vector.<AllianceMemberVO> ):void
		{
			_members = v;
			if (_members && _members.length > 0)
				_memberCount = _members.length;
		}
		public function get members():Vector.<AllianceMemberVO>  { return _members; }
	}
}
