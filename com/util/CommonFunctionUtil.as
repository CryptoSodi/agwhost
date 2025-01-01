// Collection of commonly used functions
package com.util
{
	import com.Application;
	import com.enum.FactionEnum;
	import com.enum.server.AllianceRankEnum;
	import com.event.PaywallEvent;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.ExternalInterfaceAPI;
	
	import com.event.ServerEvent;

	import flash.events.IEventDispatcher;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;

	public class CommonFunctionUtil
	{
		private static var _eventDispatcher:IEventDispatcher;

		private static var _greyScaleColorMatrixFilter:ColorMatrixFilter;

		private static const COMMON_GLOW:GlowFilter    = new GlowFilter(0xe7e7e7, 1, 5, 5, 2, 1, true);
		private static const UNCOMMON_GLOW:GlowFilter  = new GlowFilter(0x6adb4c, 1, 5, 5, 2, 1, true);
		private static const RARE_GLOW:GlowFilter      = new GlowFilter(0x5285f7, 1, 5, 5, 2, 1, true);
		private static const EPIC_GLOW:GlowFilter      = new GlowFilter(0xab58ff, 1, 5, 5, 2, 1, true);
		private static const LEGENDARY_GLOW:GlowFilter = new GlowFilter(0xfa9d2f, 1, 5, 5, 2, 1, true);
		private static const ADVANCED_GLOW:GlowFilter  = new GlowFilter(0xfafa66, 1, 5, 5, 2, 1, true);

		public static function getRarityGlow( rarity:String ):GlowFilter
		{
			switch (rarity)
			{
				case 'Uncommon':
					return UNCOMMON_GLOW;
				case 'Rare':
					return RARE_GLOW;
				case 'Epic':
					return EPIC_GLOW;
				case 'Legendary':
					return LEGENDARY_GLOW;
				case 'Advanced1':
					return ADVANCED_GLOW;
				case 'Advanced2':
					return ADVANCED_GLOW;
				case 'Advanced3':
					return ADVANCED_GLOW;
			}
			return COMMON_GLOW;
		}

		public static function getRarityColor( rarity:String ):uint
		{
			var color:uint = 0xf0f0f0;
			switch (rarity)
			{
				case 'Common':
					color = 0xe7e7e7;
					break;
				case 'Uncommon':
					color = 0x6adb4c;
					break;
				case 'Rare':
					color = 0x5285f7;
					break;
				case 'Epic':
					color = 0xab58ff;
					break;
				case 'Legendary':
					color = 0xfa9d2f;
					break;
				case 'Advanced1':
					color = 0xfafa66;
					break;
				case 'Advanced2':
					color = 0xfafa66;
					break;
				case 'Advanced3':
					color = 0xfafa66;
					break;
			}
			return color;
		}

		public static function getFactionColor( faction:String ):uint
		{
			var color:uint = 0xea8440;
			switch (faction)
			{
				case FactionEnum.IGA:
					color = 0x6bd7ff;
					break;
				case FactionEnum.IMPERIUM:
					color = 0x00ff00;
					break;
				case FactionEnum.SOVEREIGNTY:
					color = 0xc96bff;
					break;
				case FactionEnum.TYRANNAR:
					color = 0xff7d4f;
					break;
			}
			return color;
		}

		public static function findPlayerLevel( xp:int, min:int = 1, max:int = 0 ):int
		{
			if (max == 0)
				return findPlayerLevel(xp, 1, int(2));
			else
			{
				var minXP:int;
				if (min == max)
					return min;
				if (max - min == 1)
				{
					minXP = int(PrototypeModel.instance.getConstantPrototypeValueByName(getLevelProtoName(max)));
					return (xp < minXP) ? min : max;
				}
				var between:int = Math.floor((max - min) / 2 + min);
				minXP = int(PrototypeModel.instance.getConstantPrototypeValueByName(getLevelProtoName(between)));
				if (xp < minXP)
					return findPlayerLevel(xp, min, between);
				else if (xp > minXP)
					return findPlayerLevel(xp, between, max);
				else
					return between;
			}
			return 0;
		}

		public static function getLevelProtoName( level:int ):String
		{
			var levelApend:String;
			if (level < 10)
				levelApend = '00';
			else if (level > 9 && level < 100)
				levelApend = '0';
			else
				levelApend = '';

			return "playerLevelMinExperience" + levelApend + level;
		}

		public static function getCommendationRank( points:int ):int
		{
			var minScore:Number;
			var maxScore:Number;
			var proto:IPrototype;
			var prototypeModel:PrototypeModel = PrototypeModel.instance;
			var currentRank:int               = 0;

			while (true)
			{
				proto = prototypeModel.getCommendationRankPrototypesByName(getCommendationProtoName(++currentRank));
				if (proto)
				{
					minScore = proto.getUnsafeValue('minScore');
					maxScore = proto.getUnsafeValue('maxScore');
					if (minScore <= points && points <= maxScore)
						break;
				} else
				{
					currentRank = 20;
					break;
				}

			}
			return currentRank;
		}

		public static function getCommendationProtoName( rank:int ):String
		{
			var levelApend:String;
			if (rank < 10)
				levelApend = '0';
			else
				levelApend = '';

			return "Rank_" + levelApend + rank;
		}

		public static function getRankScoreDisplayPosition( rank:int, currentScore:uint ):int
		{
			var proto:IPrototype   = PrototypeModel.instance.getCommendationRankPrototypesByName(getCommendationProtoName(rank));
			var minScore:Number    = proto.getUnsafeValue('minScore');
			var maxScore:Number    = proto.getUnsafeValue('maxScore');
			var fifth:Number       = (maxScore - minScore) / 5
			var secondScore:Number = minScore + fifth;
			var thirdScore:Number  = minScore + fifth * 2;
			var fourthScore:Number = minScore + fifth * 3;
			var fifthScore:Number  = minScore + fifth * 4;


			if (minScore <= currentScore && currentScore < secondScore)
				return 1;
			else if (secondScore <= currentScore && currentScore < thirdScore)
				return 2;
			else if (thirdScore <= currentScore && currentScore < fourthScore)
				return 3;
			else if (fourthScore <= currentScore && currentScore < fifthScore)
				return 4;
			else
				return 5;

		}

		public static function getRankColorBasedOnScore( PVE:uint, PVP:uint ):uint
		{
			var diff:Number;
			var color:uint;
			if (PVE > PVP)
			{
				diff = PVE - PVP;

				if (diff > PVE * 0.2)
					color = 0xacffb4
				else
					color = 0xffe3b1;
			} else
			{
				diff = PVP - PVE;
				if (diff > PVP * 0.2)
					color = 0xffacac
				else
					color = 0xffe3b1;
			}
			return color;
		}

		public static function getBuildingVisualLevel( level:int ):int
		{
			if (level < 2)
				return 1;
			if (level < 4)
				return 2;
			if (level < 6)
				return 3;
			if (level < 10)
				return 4;
			return 5;
		}

		public static function getAllianceRankName( rank:int ):String
		{
			switch (rank)
			{
				case AllianceRankEnum.UNAFFILIATED:
					return 'None';
				case AllianceRankEnum.RECRUIT:
					return 'CodeString.Alliance.Rank.Recruit';
				case AllianceRankEnum.MEMBER:
					return 'CodeString.Alliance.Rank.Member';
				case AllianceRankEnum.OFFICER:
					return 'CodeString.Alliance.Rank.Officer';
				case AllianceRankEnum.LEADER:
					return 'CodeString.Alliance.Rank.Leader';
			}

			return '';
		}

		public static function getGreyScaleFilter():ColorMatrixFilter
		{
			if (_greyScaleColorMatrixFilter == null)
			{
				var LUMA_R2:Number = 0.212671; //0.3086;
				var LUMA_G2:Number = 0.71516; //0.6094;
				var LUMA_B2:Number = 0.072169; //0.0820;

				var sInv:Number;
				var irlum:Number;
				var iglum:Number;
				var iblum:Number;
				var s:Number       = .1;

				sInv = (1 - s);
				irlum = (sInv * LUMA_R2);
				iglum = (sInv * LUMA_G2);
				iblum = (sInv * LUMA_B2);

				var matrix:Array   = new Array();
				matrix = matrix.concat([(irlum + s), iglum, iblum, 0, 0]); // red
				matrix = matrix.concat([irlum, (iglum + s), iblum, 0, 0]); // green
				matrix = matrix.concat([irlum, iglum, (iblum + s), 0, 0]); // blue
				matrix = matrix.concat([0, 0, 0, 0.5, 0]); // alpha
				_greyScaleColorMatrixFilter = new ColorMatrixFilter(matrix);
			}
			return _greyScaleColorMatrixFilter;
		}

		public static function getColorMatrixFilter( color:uint = 0xf0f0f0 ):ColorMatrixFilter
		{
			var r:int         = (color >> 16) & 0xff;
			var g:int         = (color >> 8) & 0xff;
			var b:int         = color & 0xff;
			var rValue:Number = (r / 255);
			var gValue:Number = (g / 255);
			var bValue:Number = (b / 255);
			var matrix:Array  = new Array();
			matrix = matrix.concat([rValue, 0, 0, 0, 0]); // red
			matrix = matrix.concat([0, gValue, 0, 0, 0]); // green
			matrix = matrix.concat([0, 0, bValue, 0, 0]); // blue
			matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
			return new ColorMatrixFilter(matrix);
		}

		public static function createGlow( rgb:uint, innerGlow:Boolean = true, blurX:Number = 5, blurY:Number = 5 ):GlowFilter
		{
			var glow:GlowFilter = new GlowFilter()
			glow.inner = innerGlow;
			glow.color = rgb;
			glow.blurX = blurX;
			glow.blurY = blurY;

			return glow;
		}

		public static function ratingToModifier( rating:Number ):Number
		{
			var protos:PrototypeModel = PrototypeModel.instance;
			var ratingScale:Number    = protos.getConstantPrototypeByName("statRatingScale").getValue("value");
			var ratingExponent:Number = protos.getConstantPrototypeByName("statRatingExponent").getValue("value");
			var ratingBase:Number     = protos.getConstantPrototypeByName("statRatingBase").getValue("value");

			var modifier:Number       = Math.log(Math.max(ratingBase, rating) / ratingScale) / ratingExponent;
			return Math.min(Math.max(0.0, modifier), 100.0) - 1.0;
		}

		public static function popPaywall():void
		{
			if (Application.NETWORK == Application.NETWORK_KONGREGATE)
			{
				ExternalInterfaceAPI.logConsole("Open Kongregate Payment");
				var paywall:PaywallEvent = new PaywallEvent(PaywallEvent.GET_PAYWALL);
				_eventDispatcher.dispatchEvent(paywall);
			}
			else if (Application.NETWORK == Application.NETWORK_FACEBOOK)
			{
				ExternalInterfaceAPI.logConsole("Open Facebook Payment");
				var paywall:PaywallEvent = new PaywallEvent(PaywallEvent.GET_PAYWALL);
				_eventDispatcher.dispatchEvent(paywall);
			}
			else if (Application.NETWORK == Application.NETWORK_XSOLLA)
			{
				ExternalInterfaceAPI.logConsole("Open Xsolla Payment");
				var serverEvent:ServerEvent
				serverEvent = new ServerEvent(ServerEvent.OPEN_PAYMENT);
				_eventDispatcher.dispatchEvent(serverEvent);
			}
			else if (Application.NETWORK == Application.NETWORK_GUEST)
			{
				ExternalInterfaceAPI.logConsole("Guest Payment Restriction");
				var serverEvent:ServerEvent
				serverEvent = new ServerEvent(ServerEvent.GUEST_RESTRICTION);
				_eventDispatcher.dispatchEvent(serverEvent);
			}
			else
			{
				ExternalInterfaceAPI.logConsole("Payment Unavailable");
			}
		}

		public static function randomMinMax( min:Number, max:Number ):Number  { return min + (max - min) * Math.random(); }

		[Inject]
		public function set eventDispatcher( value:IEventDispatcher ):void  { _eventDispatcher = value; }

	}
}
