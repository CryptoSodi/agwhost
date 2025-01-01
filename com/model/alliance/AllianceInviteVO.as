package com.model.alliance
{
	public class AllianceInviteVO
	{
		private var _inviterKey:String;
		private var _inviterName:String;
		private var _alliance:AllianceVO;

		public function AllianceInviteVO( inviterKey:String, inviterName:String, alliance:AllianceVO )
		{
			_inviterKey = inviterKey;
			_inviterName = inviterName;
			_alliance = alliance;
		}

		public function get inviterKey():String  { return _inviterKey; }
		public function get inviterName():String  { return _inviterName; }
		public function get alliance():AllianceVO  { return _alliance; }
		public function set alliance( v:AllianceVO ):void  { _alliance = v; }
		public function get allianceMembers():Vector.<AllianceMemberVO>  { return _alliance.members; }
		public function set allianceMembers( v:Vector.<AllianceMemberVO> ):void  { _alliance.members = v; }
		public function get allianceKey():String  { return (_alliance != null) ? _alliance.key : ''; }
	}
}
