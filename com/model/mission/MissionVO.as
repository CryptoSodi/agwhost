package com.model.mission
{
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.MissionData;

	public class MissionVO implements IPrototype
	{
		public var accepted:Boolean;
		public var progress:int;
		public var rewardAccepted:Boolean;
		public var sector:String;

		private var _chapter:int;
		private var _id:String;
		private var _mission:int;
		private var _prototype:IPrototype;

		public function init( id:String ):void
		{
			_id = id;
		}

		public function importData( missionData:MissionData ):void
		{
			accepted = missionData.accepted;
			progress = missionData.progress;
			rewardAccepted = missionData.rewardAccepted;
			sector = missionData.sector;
			_prototype = missionData.prototype;
			var temp:Array = name.split("_");
			_chapter = int(temp[1].substr(2));
			_mission = int(temp[2].substr(1));
			if (_mission < 0)
				_mission = 1;
		}

		public function getUnsafeValue( key:String ):*  { return _prototype.getUnsafeValue(key); }
		public function getValue( key:String ):*  { return _prototype.getValue(key); }

		public function get category():String  { return _prototype.getValue("category"); }
		public function get complete():Boolean  { return progress >= progressRequired; }
		public function get id():String  { return _id; }

		public function get briefingDialogue():String  { return _prototype.getValue("briefingDialogue"); }
		public function get chapter():int  { return _chapter; }
		public function get failDialogue():String  { return _prototype.getValue("failDialogue"); }
		public function get greetingDialogue():String  { return _prototype.getValue("greetingDialogue"); }
		public function get mission():int  { return _mission; }
		public function get objectives():String  { return _prototype.getValue('objectives'); }
		public function get progressEvent():String  { return _prototype.getValue("progressEvent"); }
		public function get progressRequired():int  { return _prototype.getValue("progressRequired"); }
		public function get situationDialogue():String  { return _prototype.getValue("situationDialogue"); }
		public function get victoryDialogue():String  { return _prototype.getValue("victoryDialogue"); }

		public function get asset():String  { return _prototype.asset; }
		public function get uiAsset():String  { return _prototype.uiAsset; }

		public function get name():String  { return _prototype.name; }
		public function get itemClass():String  { return _prototype.itemClass; }
		public function get buildTimeSeconds():uint  { return _prototype.buildTimeSeconds; }

		public function get alloyCost():int  { return 0; }
		public function get creditsCost():int  { return 0; }
		public function get energyCost():int  { return 0; }
		public function get syntheticCost():int  { return 0; }

		public function get alloyReward():int  { return _prototype.getValue("alloyReward"); }
		public function get creditsReward():int  { return _prototype.getValue("creditsReward"); }
		public function get energyReward():int  { return _prototype.getValue("energyReward"); }
		public function get syntheticReward():int  { return _prototype.getValue("syntheticReward"); }
		public function get palladiumCurrencyReward():int  { return _prototype.getValue("hardCurrencyReward"); }

		public function get blueprintReward():Boolean  { return _prototype.getValue("blueprintReward"); }

		public function get isFTE():Boolean  { return name.indexOf("FTE_") == 0; }

		public function destroy():void
		{
			_prototype = null;
		}
	}
}
