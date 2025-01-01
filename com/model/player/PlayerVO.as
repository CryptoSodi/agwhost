package com.model.player
{
	import com.service.server.BinaryInputStream;
	import com.util.CommonFunctionUtil;

	public class PlayerVO
	{
		private var _alliance:String              = '';
		private var _allianceName:String          = '';
		private var _allianceRank:int             = -1;
		private var _allowAllianceInvites:Boolean = true;
		private var _isAllianceOpen:Boolean       = true;
		private var _avatarName:String            = '';
		private var _authID:String; //kabamID used for authorization with the servers
		private var _oAuthID:String; //OAuthID needed for payment!
		private var _centerspace:int              = -1;
		private var _centerSpaceBase:String;
		private var _faction:String               = '';
		private var _group:int                    = -1;
		private var _homeBase:String;
		private var _id:String; //id on the game servers
		private var _isNPC:Boolean;
		private var _level:int                    = 1;
		private var _language:String              = '';
		private var _country:String               = '';
		private var _naid:String                  = ''; //chat id
		private var _name:String;
		private var _baseRating:int               = 0;
		private var _wallet:PlayerWallet;
		private var _xp:int;
		private var _commendationPointsPVE:uint   = 0;
		private var _commendationPointsPVP:uint   = 0;
		private var _wins:uint                    = 0;
		private var _losses:uint                  = 0;
		private var _draws:uint                   = 0;
		private var _lastOnline:uint              = 0;
		private var _baseSector:String            = '';
		private var _baseXPos:Number              = 0;
		private var _baseYPos:Number              = 0;
		private var _purchasedShipSlots:int		  = 0;
		private var _playerWalletKey:String       = '';

		public function PlayerVO( isCurrentUser:Boolean = false )
		{
			if (isCurrentUser)
				_wallet = new PlayerWallet();
		}

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			id = input.readUTF();
			name = input.readUTF();
			faction = input.readUTF();
			_avatarName = input.readUTF();
			_xp = input.readInt64();
			_isNPC = input.readBoolean();
			_level = 1;
			_alliance = input.readUTF(); // allianceKey
			_allianceName = input.readUTF(); // allianceName
			_purchasedShipSlots = input.readInt64();
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON is not supported");
		}

		public function get alliance():String  { return _alliance; }
		public function set alliance( value:String ):void  { _alliance = value; }

		public function get allianceName():String  { return _allianceName; }
		public function set allianceName( value:String ):void  { _allianceName = value; }

		public function get allianceRank():int  { return _allianceRank; }
		public function set allianceRank( value:int ):void  { _allianceRank = value; }

		public function get allowAllianceInvites():Boolean  { return _allowAllianceInvites; }
		public function set allowAllianceInvites( value:Boolean ):void  { _allowAllianceInvites = value; }

		public function set authID( id:String ):void  { _authID = id; }
		public function get authID():String  { return _authID; }

		public function set oAuthID( id:String ):void  { _oAuthID = id; }
		public function get oAuthID():String  { return _oAuthID; }

		public function get centerSpaceBase():String  { return _centerSpaceBase; }
		public function set centerSpaceBase( value:String ):void  { _centerSpaceBase = value; }

		public function get faction():String  { return _faction; }
		public function set faction( value:String ):void  { _faction = value; }

		public function get group():int  { return _group; }
		public function set group( value:int ):void  { _group = value; }

		public function get homeBase():String  { return _homeBase; }
		public function set homeBase( value:String ):void  { _homeBase = value; }

		public function get id():String  { return _id; }
		public function set id( v:String ):void  { _id = v; }

		public function get isNPC():Boolean  { return _isNPC; }

		public function get level():int  { if (_level == 1) _level = CommonFunctionUtil.findPlayerLevel(_xp); return _level; }
		public function set level( value:int ):void  { _level = value; }

		public function set language( value:String ):void  { _language = value; }
		public function get language():String  { return _language; }
		
		public function set country( value:String ):void  { _country = value; }
		public function get country():String  { return _country; }

		public function set naid( naid:String ):void  { _naid = naid; }
		public function get naid():String  { return _naid; }

		public function set name( name:String ):void  { _name = name; }
		public function get name():String  { return _name; }

		public function get wallet():PlayerWallet  { return _wallet; }

		public function get xp():int  { return _xp; }
		public function set xp( value:int ):void  { _xp = value; }

		public function set commendationPointsPVE( v:uint ):void  { _commendationPointsPVE = v; }
		public function get commendationPointsPVE():uint  { return _commendationPointsPVE; }

		public function set commendationPointsPVP( v:uint ):void  { _commendationPointsPVP = v; }
		public function get commendationPointsPVP():uint  { return _commendationPointsPVP; }

		public function get avatarName():String  { return _avatarName; }
		public function set avatarName( value:String ):void  { _avatarName = value; }

		public function get baseRating():int  { return _baseRating; }
		public function set baseRating( v:int ):void  { _baseRating = v; }

		public function get isAllianceOpen():Boolean  { return _isAllianceOpen; }
		public function set isAllianceOpen( v:Boolean ):void  { _isAllianceOpen = v; }

		public function get wins():uint  { return _wins; }
		public function set wins( v:uint ):void  { _wins = v; }

		public function get losses():uint  { return _losses; }
		public function set losses( v:uint ):void  { _losses = v; }

		public function get draws():uint  { return _draws; }
		public function set draws( v:uint ):void  { _draws = v; }

		public function get lastOnline():uint  { return _lastOnline; }
		public function set lastOnline( v:uint ):void  { _lastOnline = v; }

		public function get baseSector():String  { return _baseSector; }
		public function set baseSector( v:String ):void  { _baseSector = v; }

		public function get baseXPos():Number  { return _baseXPos; }
		public function set baseXPos( v:Number ):void  { _baseXPos = v; }

		public function get baseYPos():Number  { return _baseYPos; }
		public function set baseYPos( v:Number ):void  { _baseYPos = v; }
		
		public function get purchasedShipSlots():int  { return _purchasedShipSlots; }
		public function set purchasedShipSlots( v:int ):void  { _purchasedShipSlots = v; }
		
		public function get playerWalletKey():String  { return _playerWalletKey; }
		public function set playerWalletKey( v:String ):void  { _playerWalletKey = v; }
		
		

		public function destroy():void
		{

		}
	}
}
