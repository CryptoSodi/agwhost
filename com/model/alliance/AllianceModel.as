package com.model.alliance
{
	import com.enum.server.AllianceResponseEnum;
	import com.model.Model;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	public class AllianceModel extends Model
	{
		private var _alliances:Dictionary;
		private var _openAlliances:Dictionary;
		private var _invitedAlliances:Dictionary;
		private var _emailInvites:Dictionary;

		public var onOpenAlliancesUpdated:Signal;
		public var onInvitedAlliancesUpdated:Signal;
		public var onAllianceUpdated:Signal;
		public var onAllianceMembersUpdated:Signal;
		public var onGenericAllianceMessageRecieved:Signal;

		public function AllianceModel()
		{
			super();

			_alliances = new Dictionary();
			_openAlliances = new Dictionary();
			_invitedAlliances = new Dictionary();
			onOpenAlliancesUpdated = new Signal(Dictionary);
			onInvitedAlliancesUpdated = new Signal(Dictionary);
			onAllianceUpdated = new Signal(String, AllianceVO);
			onAllianceMembersUpdated = new Signal(String, Vector.<AllianceMemberVO>);
			onGenericAllianceMessageRecieved = new Signal(int, String);
		}

		public function addAlliance( alliance:AllianceVO ):void
		{
			if (alliance)
			{
				var key:String = alliance.key;
				if (key != '')
				{
					if (key in _alliances)
					{
						var oldAllianceData:AllianceVO = _alliances[key];
						alliance.members = oldAllianceData.members;
					}
					_alliances[key] = alliance;
					onAllianceUpdated.dispatch(key, alliance);
				}
			}
		}

		public function addOpenAlliances( alliances:Vector.<AllianceVO> ):void
		{
			if (alliances && alliances.length > 0)
			{
				var len:uint = alliances.length;
				var alliance:AllianceVO;
				var key:String;
				var oldAllianceData:AllianceVO;
				for (var i:uint = 0; i < len; ++i)
				{
					alliance = alliances[i];
					key = alliance.key;
					if (key != '')
					{
						if (key in alliances)
						{
							oldAllianceData = alliances[key];
							alliance.members = oldAllianceData.members;
						}
						_openAlliances[key] = alliance;
						onAllianceUpdated.dispatch(key, alliance);
					}
				}
				onOpenAlliancesUpdated.dispatch(_openAlliances);
			}
		}

		public function addInvitedAlliance( alliance:AllianceInviteVO ):void
		{
			if (alliance)
			{
				var oldAllianceData:AllianceInviteVO;
				var key:String = alliance.allianceKey;
				if (key != '')
				{
					if (key in _invitedAlliances)
					{
						oldAllianceData = _invitedAlliances[key];
						alliance.allianceMembers = oldAllianceData.allianceMembers;
					}
					_invitedAlliances[key] = alliance;
				}
				onInvitedAlliancesUpdated.dispatch(_invitedAlliances);
				onGenericAllianceMessageRecieved.dispatch(AllianceResponseEnum.INVITED, key);
			}
		}


		public function updateMembers( key:String, members:Vector.<AllianceMemberVO> ):void
		{
			if (key != '')
			{
				if (key in _alliances)
				{
					var allianceData:AllianceVO = _alliances[key];
					allianceData.members = members;
					_alliances[key] = allianceData;
					onAllianceUpdated.dispatch(key, allianceData);
				}

				if (key in _openAlliances)
				{
					var openAllianceData:AllianceVO = _openAlliances[key];
					openAllianceData.members = members;
					_openAlliances[key] = openAllianceData;
					onAllianceUpdated.dispatch(key, openAllianceData);
				}

				if (key in _invitedAlliances)
				{
					var inviteAllianceData:AllianceInviteVO = _invitedAlliances[key];
					inviteAllianceData.allianceMembers = members;
					_invitedAlliances[key] = inviteAllianceData;

				}
				onAllianceMembersUpdated.dispatch(key, members);
			}
		}

		public function handleGenericMessage( messageEnum:int, allianceKey:String ):void
		{
			onGenericAllianceMessageRecieved.dispatch(messageEnum, allianceKey);
		}

		public function getAllianceInvites():Dictionary  { return _invitedAlliances; }
		
		public function setEmailInvites ( emailInvites:Dictionary ):void
		{
			_emailInvites = emailInvites;
		}
		
		public function addEmailInvites( ):void
		{
			for (var key:Object in _emailInvites) 
			{
				if (!(_emailInvites[key] in _invitedAlliances))
				{		
					var alliance:AllianceVO = _alliances[key];
					if(alliance)
					{
						// inviterKey and _inviterName are unused now so let's leave it empty so we won't have to fetch this data
						var allianceInvite:AllianceInviteVO = new AllianceInviteVO("","",alliance);
						addInvitedAlliance(allianceInvite);
					}
				}
			}
		}
		
		public function getAlliances():Dictionary  { return _alliances; }
	}
}
