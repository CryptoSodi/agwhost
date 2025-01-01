package com.model.player
{
	import com.enum.PlayerUpdateEnum;
	import com.model.prototype.IPrototype;

	import org.osflash.signals.Signal;

	public class CurrentUser
	{
		public static var onPlayerUpdate:Signal               = new Signal(int, String, String);
		public static var onPlayerOffersUpdated:Signal        = new Signal(Vector.<OfferVO>);
		public static var onBookmarksUpdated:Signal           = new Signal(Vector.<BookmarkVO>);

		private static var _bookmarks:Vector.<BookmarkVO>     = new Vector.<BookmarkVO>;
		private static var _hasPromptedForBuildAction:Boolean = false;
		private static var _offers:Vector.<OfferVO>           = new Vector.<OfferVO>;
		private static var _user:PlayerVO                     = new PlayerVO(true);
		private static var _battleFaction:String 			  = '';

		public static function initUser( user:PlayerVO ):void
		{
			_user = user;
		}

		public static function get hasPromptedForBuildAction():Boolean  { return _hasPromptedForBuildAction; }
		public static function set hasPromptedForBuildAction( value:Boolean ):void  { _hasPromptedForBuildAction = value; }

		public static function get id():String  { return _user.id; }
		public static function set id( v:String ):void  { _user.id = v; }

		public static function get language():String  { return _user.language; }
		public static function set language( v:String ):void  { _user.language = v; }

		public static function get country():String  { return _user.country; }
		public static function set country( v:String ):void  { _user.country = v; }

		public static function get name():String  { return _user.name; }
		public static function set name( v:String ):void
		{
			var prev:String = _user.name;
			_user.name = v;
			onPlayerUpdate.dispatch(PlayerUpdateEnum.TYPE_NAME, prev, v);
		}

		public static function get naid():String  { return _user.naid; }
		public static function set naid( v:String ):void  { _user.naid = v; }

		public static function set authID( id:String ):void  { _user.authID = id; }
		public static function get authID():String  { return _user.authID; }

		public static function set oAuthID( id:String ):void  { _user.oAuthID = id; }
		public static function get oAuthID():String  { return _user.oAuthID; }

		public static function get level():int  { return _user.level; }
		public static function set level( v:int ):void
		{
			var prev:int = _user.level;
			_user.level = v;
			onPlayerUpdate.dispatch(PlayerUpdateEnum.TYPE_LEVEL, String(prev), String(v));
		}

		public static function get group():int  { return _user.group; }
		public static function set group( v:int ):void
		{
			var prev:int = _user.group;
			_user.group = v;
			onPlayerUpdate.dispatch(PlayerUpdateEnum.TYPE_GROUP, String(prev), String(v));
		}
		
		public static function set battleFaction( v:String ):void
		{
			_battleFaction = v;
		}
		public static function get battleFaction():String  { return _battleFaction; }
		
		public static function get faction():String  { return _user.faction; }
		public static function set faction( v:String ):void
		{
			onPlayerUpdate.dispatch(PlayerUpdateEnum.TYPE_FACTION, String(_user.faction), String(v));
			_user.faction = v;
		}

		public static function get alliance():String  { return _user.alliance; }
		public static function set alliance( v:String ):void
		{
			var prev:String = _user.alliance;
			_user.alliance = v;
			onPlayerUpdate.dispatch(PlayerUpdateEnum.TYPE_ALLIANCE, prev, v);
		}
        
		
		public static function get playerWalletKey():String  { return _user.playerWalletKey; }
		public static function set playerWalletKey( v:String ):void  { _user.playerWalletKey = v; }
		
		public static function get allianceName():String  { return _user.allianceName; }
		public static function set allianceName( v:String ):void  { _user.allianceName = v; }

		public static function get allianceRank():int  { return _user.allianceRank; }
		public static function set allianceRank( v:int ):void  { _user.allianceRank = v; }

		public static function get allowAllianceInvites():Boolean  { return _user.allowAllianceInvites; }
		public static function set allowAllianceInvites( v:Boolean ):void  { _user.allowAllianceInvites = v; }

		public static function get isAllianceOpen():Boolean  { return _user.isAllianceOpen; }
		public static function set isAllianceOpen( v:Boolean ):void  { _user.isAllianceOpen = v; }

		public static function get centerSpaceBase():String  { return _user.centerSpaceBase; }
		public static function set centerSpaceBase( v:String ):void  { _user.centerSpaceBase = v; }

		public static function get homeBase():String  { return _user.homeBase; }
		public static function set homeBase( v:String ):void  { _user.homeBase = v; }

		public static function get wallet():PlayerWallet  { return _user.wallet; }

		public static function get vo():PlayerVO  { return _user; }

		public static function get xp():int  { return _user.xp; }
		public static function set xp( v:int ):void
		{
			var prev:int = _user.xp;
			_user.xp = v;
			onPlayerUpdate.dispatch(PlayerUpdateEnum.TYPE_XP, String(prev), String(v));
		}

		public static function set commendationPointsPVE( v:uint ):void  { _user.commendationPointsPVE = v; }
		public static function get commendationPointsPVE():uint  { return _user.commendationPointsPVE; }

		public static function set commendationPointsPVP( v:uint ):void  { _user.commendationPointsPVP = v; }
		public static function get commendationPointsPVP():uint  { return _user.commendationPointsPVP; }

		public static function get avatarName():String  { return _user.avatarName; }
		public static function set avatarName( v:String ):void  { _user.avatarName = v; }

		public static function get baseRating():int  { return _user.baseRating; }
		public static function set baseRating( v:int ):void
		{
			var prev:int = _user.baseRating;
			_user.baseRating = v;
			onPlayerUpdate.dispatch(PlayerUpdateEnum.TYPE_BASERATING, String(prev), String(v));
		}

		public static function get wins():uint  { return _user.wins; }
		public static function set wins( v:uint ):void  { _user.wins = v; }

		public static function get losses():uint  { return _user.losses; }
		public static function set losses( v:uint ):void  { _user.losses = v; }

		public static function get draws():uint  { return _user.draws; }
		public static function set draws( v:uint ):void  { _user.draws = v; }


		public static function get offers():Vector.<OfferVO>  { return _offers; }
		public static function set offers( v:Vector.<OfferVO> ):void
		{
			if (_offers.length > 0)
				_offers.length = 0;

			_offers = v;

			onPlayerOffersUpdated.dispatch(_offers);
		}

		public static function get user():PlayerVO  { return _user; }

		public static function removeOffer( v:String ):void
		{
			if (_offers.length > 0)
			{
				var len:uint = _offers.length;
				var currentOffer:OfferVO;
				for (var i:uint = 0; i < len; ++i)
				{
					currentOffer = _offers[i];
					if (currentOffer.offerPrototype == v)
					{
						_offers.splice(i, 1);
						currentOffer = null;
						currentOffer
						break;
					}
				}
				onPlayerOffersUpdated.dispatch(_offers);
			}
		}

		public static function addBookmark( name:String, sector:String, sectorPrototype:IPrototype, sectorNamePrototype:IPrototype, sectorEnumPrototype:IPrototype, x:int, y:int, index:int ):void
		{
			var bookmark:BookmarkVO = new BookmarkVO(name, sector, sectorPrototype, sectorNamePrototype, sectorEnumPrototype, x, y, index);
			_bookmarks.push(bookmark);
		}

		public static function addBookmarks( v:Vector.<BookmarkVO> ):void
		{
			_bookmarks.length = 0;
			_bookmarks = v;
		}

		public static function removeBookmark( v:uint ):void
		{
			if (_bookmarks.length > 0)
			{
				var len:uint = _bookmarks.length;
				var currentBookmark:BookmarkVO;
				for (var i:uint = 0; i < len; ++i)
				{
					currentBookmark = _bookmarks[i];
					if (currentBookmark.index == v)
					{
						_bookmarks.splice(i, 1);
						currentBookmark = null;
						break;
					}
				}
			}
		}

		public static function get bookmarks():Vector.<BookmarkVO>  { return _bookmarks; }

		public static function get bookmarkCount():int
		{
			if (_bookmarks)
				return _bookmarks.length;
			else
				return 0;
		}

		public static function get nextBookmarkIndex():uint
		{
			var index:uint;
			var len:uint = _bookmarks.length;
			if (len > 0)
			{
				var currentBookmark:BookmarkVO = _bookmarks[len - 1];
				index = currentBookmark.index + 1;
			} else
				index = 1;
			return index;
		}
		
		public static function get purchasedShipSlots():int  { return _user.purchasedShipSlots; }
		public static function set purchasedShipSlots( v:int ):void
		{
			var prev:int = _user.purchasedShipSlots;
			_user.purchasedShipSlots = v;
			onPlayerUpdate.dispatch(PlayerUpdateEnum.TYPE_PURCHASED_SHIP_SLOTS, String(prev), String(v));
		}
	}
}
