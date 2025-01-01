package com.model.starbase
{
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.TradeRouteData;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class TradeRouteVO
	{
		private static var _tempID:int = 0;

		//NEW
		private var _baseID:String;
		private var _contractGroup:String;
		private var _factionPrototype:IPrototype;
		private var _id:String;
		private var _name:String;
		private var _reputation:Number;

		// current contract params
		private var _pointValueRolled:Number;
		private var _offerExpires:uint;
		private var _contractPrototype:IPrototype;
		private var _productivity:Number;
		private var _payout:Number;
		private var _duration:Number;
		private var _frequency:Number;
		private var _security:Number;
		private var _bribe:Number;
		private var _offerRejected:Boolean;
		private var _reputationWhenBegun:Number;
		private var _began:uint;
		private var _end:uint;

		//Resource Modifiers
		private var _creditScale:Number;
		private var _alloyScale:Number;
		private var _energyScale:Number;
		private var _syntheticScale:Number;
		private var _reputationScale:Number;

		//Resource Per Second
		private var _creditsPerSecond:Number;
		private var _alloyPerSecond:Number;
		private var _energyPerSecond:Number;
		private var _syntheticPerSecond:Number;
		private var _reputationPerSecond:Number;

		public function init( id:String, factionPrototype:IPrototype = null ):void
		{
			_id = id;
			_factionPrototype = factionPrototype;
			reset();
		}

		public function importData( tradeRouteData:TradeRouteData ):void
		{
			_baseID = tradeRouteData.baseID;
			_began = tradeRouteData.began;
			_bribe = tradeRouteData.bribe;
			_factionPrototype = tradeRouteData.factionPrototype;
			_contractGroup = _factionPrototype.getValue('contractGroup');
			_contractPrototype = tradeRouteData.contractPrototype;
			_duration = tradeRouteData.duration;
			_end = tradeRouteData.end;
			_frequency = tradeRouteData.frequency;
			_name = tradeRouteData.name;
			_offerExpires = tradeRouteData.offerExpires;
			_offerRejected = tradeRouteData.offerRejected
			_payout = tradeRouteData.payout;
			_productivity = tradeRouteData.productivity;
			_reputation = tradeRouteData.reputation;
			_reputationWhenBegun = tradeRouteData.reputationWhenBegun;
			_security = tradeRouteData.security;

			if (_contractPrototype != null)
			{
				_creditScale = _contractPrototype.getValue('creditScale');
				_alloyScale = _contractPrototype.getValue('alloyScale');
				_energyScale = _contractPrototype.getValue('energyScale');
				_syntheticScale = _contractPrototype.getValue('syntheticsScale');
				_reputationScale = _contractPrototype.getValue('reputationScale');
			}
		}

		public function reset():void
		{
			if (_factionPrototype)
				_contractGroup = _factionPrototype.getValue('contractGroup');
			_pointValueRolled = 0;
			_offerExpires = 0;
			_contractPrototype = null;
			_productivity = 0;
			_payout = 0;
			_duration = 0;
			_frequency = 0;
			_security = 0;
			_began = 0;
			_end = 0;

			_creditScale = 0;
			_alloyScale = 0;
			_energyScale = 0;
			_syntheticScale = 0;
			_reputationScale = 0;

			_bribe = 0;

			_offerRejected = true;
			_reputationWhenBegun = 0;

			_creditsPerSecond = 0;
			_alloyPerSecond = 0;
			_energyPerSecond = 0;
			_syntheticPerSecond = 0;
			_reputationPerSecond = 0;
		}

		public function clone():TradeRouteVO
		{
			var vo:TradeRouteVO     = new TradeRouteVO();
			var data:TradeRouteData = new TradeRouteData();
			data.factionPrototype = _factionPrototype;
			data.id = TEMP_ID;
			data.baseID = _baseID;
			data.reputation = _reputation;
			data.contractPrototype = _contractPrototype;
			data.offerExpires = _offerExpires;
			data.payout = _payout;
			data.duration = _duration;
			data.frequency = _frequency;
			data.security = _security;
			data.began = _began;
			data.end = _end;
			vo.importData(data);
			vo.pointValueRolled = _pointValueRolled;

			return vo;
		}

		internal function forceSetID( v:String ):void  { _id = v; }

		public function get baseID():String  { return _baseID; }
		public function set baseID( baseID:String ):void  { _baseID = baseID; }
		public function get bribe():Number  { return _bribe; }
		public function get contractGroup():String  { return _contractGroup; }
		public function get name():String  { return _name; }
		public function get offerExpires():Number  { return _offerExpires; }
		public function set offerExpires( offerExpires:Number ):void  { _offerExpires = offerExpires; }
		public function get pointValueRolled():Number  { return _pointValueRolled; }
		public function set pointValueRolled( pointValueRolled:Number ):void  { _pointValueRolled = pointValueRolled; }
		public function get rejected():Boolean  { return _offerRejected; }
		public function get reputation():Number  { return _reputation; }
		public function set reputation( reputation:Number ):void  { _reputation = reputation; }
		public function get reputationWhenBegun():Number  { return _reputationWhenBegun; }

		public function set contractPrototype( contractPrototype:IPrototype ):void
		{
			_contractPrototype = contractPrototype;
			if (_contractPrototype != null)
			{
				_creditScale = _contractPrototype.getValue('creditScale');
				_alloyScale = _contractPrototype.getValue('alloyScale');
				_energyScale = _contractPrototype.getValue('energyScale');
				_syntheticScale = _contractPrototype.getValue('syntheticsScale');
				_reputationScale = _contractPrototype.getValue('reputationScale');
			}
		}

		public function get contractPrototype():IPrototype  { return _contractPrototype; }
		public function get corporation():String  { return _factionPrototype.name; }

		public function get factionPrototype():IPrototype  { return _factionPrototype; }

		public function get productivity():Number  { return _productivity; }

		public function set productivity( productivity:Number ):void  { _productivity = productivity; }

		public function get payout():Number  { return _payout; }

		public function set payout( payout:Number ):void  { _payout = payout; }

		public function get duration():Number  { return _duration; }

		public function set duration( duration:Number ):void  { _duration = duration; }

		public function get frequency():Number  { return _frequency; }

		public function set frequency( frequency:Number ):void  { _frequency = frequency; }

		public function get security():Number  { return _security; }

		public function set security( security:Number ):void  { _security = security; }

		public function get began():Number  { return _began; }

		public function set began( began:Number ):void  { _began = began; }

		public function get end():Number  { return _end; }

		public function set end( end:Number ):void  { _end = end; }

		public function get creditScale():Number  { return _creditScale; }

		public function get alloyScale():Number  { return _alloyScale; }

		public function get energyScale():Number  { return _energyScale; }

		public function get syntheticScale():Number  { return _syntheticScale; }

		public function get reputationScale():Number  { return _reputationScale; }

		public function get id():String  { return _id; }

		public static function get TEMP_ID():String  { _tempID++; return "player." + CurrentUser.name + "." + _tempID }

		public function destroy():void
		{

		}
	}
}
