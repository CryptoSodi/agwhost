package com.service.server.incoming.starbase
{
	import com.enum.CurrencyEnum;
	import com.model.player.CurrentUser;
	import com.model.player.OfferVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.data.BaseData;
	import com.service.server.incoming.data.BlueprintData;
	import com.service.server.incoming.data.BookmarksData;
	import com.service.server.incoming.data.BuffData;
	import com.service.server.incoming.data.BuildingData;
	import com.service.server.incoming.data.CrewMemberData;
	import com.service.server.incoming.data.FleetData;
	import com.service.server.incoming.data.MissionData;
	import com.service.server.incoming.data.ResearchData;
	import com.service.server.incoming.data.ShipData;
	import com.service.server.incoming.data.TradeRouteData;
	
	import flash.utils.getTimer;
	
	import org.shared.ObjectPool;

	public class StarbaseBaselineResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;
		
		public var validData:Boolean					 = false;

		public var bases:Vector.<BaseData>               = new Vector.<BaseData>;
		public var blueprints:Vector.<BlueprintData>     = new Vector.<BlueprintData>;
		public var buffs:Vector.<BuffData>               = new Vector.<BuffData>;
		public var buildings:Vector.<BuildingData>       = new Vector.<BuildingData>;
		public var fleets:Vector.<FleetData>             = new Vector.<FleetData>;
		public var missions:Vector.<MissionData>         = new Vector.<MissionData>;
		public var research:Vector.<ResearchData>        = new Vector.<ResearchData>;
		public var ships:Vector.<ShipData>               = new Vector.<ShipData>;
		public var tradeRoutes:Vector.<TradeRouteData>   = new Vector.<TradeRouteData>;
		public var bookmarks:BookmarksData               = new BookmarksData();
		public var upcomingEvents:Vector.<IPrototype>    = new Vector.<IPrototype>;
		public var activeEvents:Vector.<IPrototype>      = new Vector.<IPrototype>;
		public var activeSplitPrototypes:Vector.<String> = new Vector.<String>;
		public var settings:Object;
		public var update:Boolean;
		public var updateReason:String;
		public var nowMillis:Number;
		public var baselineType:Number;
		
		public static const BASELINE_ALL:Number                    = 0;
		public static const BASELINE_PLAYER:Number                 = 1 << 0;
		public static const BASELINE_SHIP:Number                   = 1 << 1;
		public static const BASELINE_FLEET:Number                  = 1 << 2;
		public static const BASELINE_MISSION:Number                = 1 << 3;
		public static const BASELINE_BLUEPRINT:Number              = 1 << 4;
		public static const BASELINE_CREW:Number                   = 1 << 5;
		public static const BASELINE_BASE:Number                   = 1 << 6;
		public static const BASELINE_BUILDING:Number               = 1 << 7;
		public static const BASELINE_RESEARCH:Number               = 1 << 8;
		public static const BASELINE_TRADE_ROUTE:Number            = 1 << 9;
		public static const BASELINE_BUFF:Number                   = 1 << 10;
		public static const BASELINE_OFFER:Number                  = 1 << 11;
		public static const BASELINE_SETTING:Number                = 1 << 12;

		public function read( input:BinaryInputStream ):void
		{
			var prototypeModel:PrototypeModel = PrototypeModel.instance;

			input.setStringInputCache(input.starbaseBaselineStringInputCache);
			input.checkToken();
			
			if(!input.validToken)
				return;
			
			update = input.readBoolean();
			var i:int                         = 0;
			if (!update)
			{
				input.readStringCacheBaseline();

				var activeSplit:String;
				var numSplits:int = input.readUnsignedInt();
				for (i = 0; i < numSplits; ++i)
				{
					activeSplit = input.readUTF(); // split test prototype
					if (activeSplit != '')
						activeSplitPrototypes.push(activeSplit);
				}
			}

			nowMillis = input.readInt64();

			if (!update)
			{
				// get event prototypes
				var eventProtos:Vector.<IPrototype> = prototypeModel.getEventPrototypes();
				var event:IPrototype;

				var begins:Number;
				var ends:Number;
				for (i = 0; i < eventProtos.length; ++i)
				{
					// now... stuff
					event = eventProtos[i];

					begins = event.getValue("eventBegins");
					ends = event.getValue("eventEnds");
					if (ends < nowMillis)
						continue;
					if (begins > nowMillis)
					{
						upcomingEvents.push(event);
							// this event starts in the future
							// timer ? start at (begins - nowMillis)
							// TODO
					} else
					{
						activeEvents.push(event);
							// this event is happening now
							// timer to end event at (ends - nowMillis)
							// apply buffs to buff calcs
							// TODO
					}
				}
			}

			updateReason = input.readUTF();
			
			baselineType = input.readInt64();
			
			if(!input.validToken)
				return;

			// players
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_PLAYER)
			{
				// there should only be one entry in this map
				var numPlayers:int                = input.readUnsignedInt();
				for (i = 0; i < numPlayers; ++i)
				{
					input.readUTF(); // key
					input.checkToken();
					input.checkToken();
					input.readUTF(); // player key (already assigned to CurrentUser.id from login)
					input.checkToken();
	
					CurrentUser.faction = input.readUTF();
					CurrentUser.avatarName = input.readUTF(); // (racePrototype)
					CurrentUser.name = input.readUTF();
					CurrentUser.xp = input.readInt64();
					var premium:uint = input.readInt64();
					if (update && CurrentUser.wallet.premium < premium)
						CurrentUser.wallet.deposit(premium - CurrentUser.wallet.premium, CurrencyEnum.PREMIUM);
					else
						CurrentUser.wallet.overridePremium = premium;
	
					CurrentUser.alliance = input.readUTF();
	
					CurrentUser.homeBase = input.readUTF();
					CurrentUser.centerSpaceBase = input.readUTF();
					bookmarks.read(input);
	
					CurrentUser.commendationPointsPVE = input.readInt64();
					CurrentUser.commendationPointsPVP = input.readInt64();
	
					CurrentUser.allianceName = input.readUTF(); // allianceName
					
					CurrentUser.purchasedShipSlots = input.readInt64();
	
					input.checkToken();
				}
				
				CurrentUser.playerWalletKey = input.readUTF();
				
				if(!input.validToken)
					return;
			}

			// ships
			
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_SHIP)
			{
				var shipData:ShipData;
				var numShips:int                  = input.readUnsignedInt();
				for (i = 0; i < numShips; i++)
				{
					shipData = ObjectPool.get(ShipData);
					input.readUTF(); // key
					shipData.read(input);
					ships.push(shipData);
				}
				
				if(!input.validToken)
					return;
			}

			// fleets
			
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_FLEET)
			{
				var fleetData:FleetData;
				var numFleets:int                 = input.readUnsignedInt();
				for (i = 0; i < numFleets; i++)
				{
					fleetData = ObjectPool.get(FleetData);
					input.readUTF(); // key
					fleetData.read(input);
					fleets.push(fleetData);
				}
				
				fleets.sort(fleet_comparator);
				
				if(!input.validToken)
					return;
			}

			// missions
			
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_MISSION)
			{
				var missionData:MissionData;
				var numMissions:int               = input.readUnsignedInt();
				for (i = 0; i < numMissions; ++i)
				{
					missionData = ObjectPool.get(MissionData);
					input.readUTF(); // key
					missionData.read(input);
					missionData.prototype = prototypeModel.getMissionPrototye(missionData.missionPrototype);
					missions.push(missionData);
				}
				
				if(!input.validToken)
					return;
			}

			// blueprints
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_BLUEPRINT)
			{
				var blueprintData:BlueprintData;
				var numBlueprints:int             = input.readUnsignedInt();
				for (i = 0; i < numBlueprints; ++i)
				{
					blueprintData = ObjectPool.get(BlueprintData);
					input.readUTF(); // key
					blueprintData.read(input);
					blueprintData.prototype = prototypeModel.getBlueprintPrototype(blueprintData.blueprintPrototype);
					blueprints.push(blueprintData);
				}
				
				if(!input.validToken)
					return;
			}
			
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_CREW)
			{
				var crewMemberData:CrewMemberData;
				var numCrewMembers:int            = input.readUnsignedInt();
				for (i = 0; i < numCrewMembers; ++i)
				{
					crewMemberData = ObjectPool.get(CrewMemberData);
					input.readUTF(); // key
					crewMemberData.read(input);
						//Do whatever else you need to do here, I guess.
				}
				
				if(!input.validToken)
					return;
			}

			// bases
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_BASE)
			{
				var baseData:BaseData;
				var numBases:int                  = input.readUnsignedInt();
				var timeRemaining:Number;
				for (i = 0; i < numBases; ++i)
				{
					baseData = ObjectPool.get(BaseData);
					input.readUTF(); // key
					baseData.read(input);
					baseData.lastUpdateTimeUTCMillis = getTimer() - (nowMillis - baseData.lastUpdateTimeUTCMillis);
					timeRemaining = baseData.bubbleEnds - nowMillis;
					baseData.bubbleTimeRemaining = (timeRemaining > 0) ? timeRemaining : 0;
					bases.push(baseData);
				}
				
				if(!input.validToken)
					return;
			}

			// buildings
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_BUILDING)
			{
				var buildingData:BuildingData;
				var numBuildings:int              = input.readUnsignedInt();
				for (i = 0; i < numBuildings; ++i)
				{
					buildingData = ObjectPool.get(BuildingData);
					input.readUTF(); // key
					buildingData.read(input);
					if (buildingData.prototype)
						buildings.push(buildingData);
				}
				
				if(!input.validToken)
					return;
			}

			// research
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_RESEARCH)
			{
				var researchData:ResearchData;
				var numResearch:int               = input.readUnsignedInt();
				for (i = 0; i < numResearch; ++i)
				{
					researchData = ObjectPool.get(ResearchData);
					input.readUTF(); // key
					researchData.read(input);
					research.push(researchData);
				}
				
				if(!input.validToken)
					return;
			}

			// trade routes
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_TRADE_ROUTE)
			{
				var tradeRouteData:TradeRouteData;
				var numTradeRoutes:int            = input.readUnsignedInt();
				for (i = 0; i < numTradeRoutes; ++i)
				{
					tradeRouteData = ObjectPool.get(TradeRouteData);
					input.readUTF(); // key
					tradeRouteData.read(input);
					tradeRoutes.push(tradeRouteData);
				}
				
				if(!input.validToken)
					return;
			}

			// buffs
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_BUFF)
			{
				var buffData:BuffData;
				var numBuffs:int                  = input.readUnsignedInt();
				for (i = 0; i < numBuffs; ++i)
				{
					buffData = ObjectPool.get(BuffData);
					input.readUTF(); // key
					buffData.read(input);
					buffData.now = nowMillis;
					buffs.push(buffData);
				}
				
				if(!input.validToken)
					return;
			}

			// offers
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_OFFER)
			{
				var offers:Vector.<OfferVO>       = new Vector.<OfferVO>;
				var currentOffer:OfferVO;
				var numOffers:int                 = input.readUnsignedInt();
				for (i = 0; i < numOffers; ++i)
				{
					currentOffer = new OfferVO(input.readUTF(), input.readInt64(), input.readInt64());
					offers.push(currentOffer)
				}
				
				if(!input.validToken)
					return;
				
				CurrentUser.offers = offers;
			}

			// settings
			if(baselineType == BASELINE_ALL || baselineType & BASELINE_SETTING)
			{
				var numSettings:int               = input.readUnsignedInt();
				for (i = 0; i < numSettings; ++i)
				{
					input.readUTF(); // key
					input.checkToken();
					input.checkToken();
					/*id =*/
					input.readUTF();
					input.checkToken();
					/* playerOwnerID = */
					input.readUTF();
					var settingsText:String = input.readUTF();
					input.checkToken();
	
					try
					{
						if (settingsText != '')
							settings = JSON.parse(settingsText);
					} catch ( e:Error )
					{
	
					}
	
						// as with player data, we only expect one entry in this map
				}
				
				if(!input.validToken)
					return;
			}

			input.checkToken();
			
			if(!input.validToken)
				return;
			
			validData = true;
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in StarbaseBaselineResponse is not supported");
		}

		public function get isTicked():Boolean  { return false; }

		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }

		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }

		public function destroy():void
		{
			//cleanup bases
			for (var i:int = 0; i < bases.length; i++)
				ObjectPool.give(bases[i]);
			bases.length = 0;
			//cleanup blueprints
			for (i = 0; i < blueprints.length; i++)
				ObjectPool.give(blueprints[i]);
			blueprints.length = 0;
			//cleanup buffs
			for (i = 0; i < buffs.length; i++)
				ObjectPool.give(buffs[i]);
			buffs.length = 0;
			//cleanup buildings
			for (i = 0; i < buildings.length; i++)
				ObjectPool.give(buildings[i]);
			buildings.length = 0;
			//cleanup fleets
			for (i = 0; i < fleets.length; i++)
				ObjectPool.give(fleets[i]);
			fleets.length = 0;
			//cleanup missions
			for (i = 0; i < missions.length; i++)
				ObjectPool.give(missions[i]);
			missions.length = 0;
			//cleanup research
			for (i = 0; i < research.length; i++)
				ObjectPool.give(research[i]);
			research.length = 0;
			//cleanup ships
			for (i = 0; i < ships.length; i++)
				ObjectPool.give(ships[i]);
			ships.length = 0;
			//cleanup traderoutes
			for (i = 0; i < tradeRoutes.length; i++)
				ObjectPool.give(tradeRoutes[i]);
			tradeRoutes.length = 0;
		}

		private function fleet_comparator( f1:FleetData, f2:FleetData ):Number
		{
			if (f1.id == f2.id)
				return 0;
			else if (f1.id < f2.id)
				return -1;
			return 1;
		}
	}
}


