package com.model.prototype
{
	import com.model.Model;
	import com.model.asset.AssetModel;

	import flash.utils.Dictionary;

	public class PrototypeModel extends Model
	{
		public static var instance:PrototypeModel;

		public var attachPoints:Dictionary;
		public var attachGroups:Dictionary;
		public var modulePrototypes:Dictionary;
		public var moduleGroupPrototypes:Dictionary;

		public static var SHIP_REPAIR_TIME_SCALAR:Number;
		public static var SHIP_REPAIR_RESOURCE_COST_SCALAR:Number;
		public static var SHIP_BUILD_TIME_SCALAR:Number;
		public static var SHIP_BUILD_RESOURCE_COST_SCALAR:Number;
		public static var BUILDING_BUILD_TIME_SCALAR:Number;
		public static var BUILDING_RESOURCE_COST_SCALAR:Number;

		private var _assetModel:AssetModel;

		private var _blueprintPrototypes:Dictionary;
		private var _buffPrototypes:Dictionary;
		private var _buildingPrototypes:Dictionary;
		private var _cachedQuery:Dictionary;
		private var _missionObjectivesPrototypes:Dictionary;
		private var _missionPrototypes:Dictionary;
		private var _researchRequirements:Dictionary;
		private var _slotPrototypes:Dictionary;
		private var _constantPrototypes:Dictionary;
		private var _sectorPrototypes:Dictionary;
		private var _sectorNamePrototypes:Dictionary;
		private var _splitTestCohortPrototypes:Dictionary;
		private var _offerPrototypes:Dictionary;
		private var _npcPrototypes:Dictionary;
		private var _statPrototypes:Dictionary;
		private var _commendationRankPrototypes:Dictionary;
		private var _splitTestPrototypes:Dictionary;
		
		private var _loadingScreenPrototypes:Dictionary;
		private var _vLoadingScreenPrototypes:Vector.<IPrototype>;
		
		private var _loadingScreenGroupPrototypes:Dictionary;
		private var _vLoadingScreenGroupPrototypes:Vector.<IPrototype>;
		
		private var _vBuffPrototypes:Vector.<IPrototype>;
		private var _vBuildingPrototypes:Vector.<IPrototype>;
		private var _vBuildableBuildingPrototype:Vector.<IPrototype>;
		private var _vFTESteps:Vector.<IPrototype>;
		private var _vShipPrototypes:Vector.<IPrototype>;
		private var _vFirstNamePrototypes:Vector.<IPrototype>;
		private var _vLastNamePrototypes:Vector.<IPrototype>;
		private var _vBEDialoguePrototypes:Vector.<IPrototype>;
		private var _vLoginBonusPrototypes:Vector.<IPrototype>;
		private var _vEventPrototypes:Vector.<IPrototype>;

		private var _researchPrototypes:Dictionary;
		private var _vResearchPrototypes:Vector.<IPrototype>;

		private var _statmodPrototypes:Dictionary;
		private var _vStatmodPrototypes:Vector.<IPrototype>;

		private var _weaponPrototypes:Dictionary;
		private var _vWeaponPrototypes:Vector.<IPrototype>;
		
		private var _transgateCustomDestinationPrototypes:Dictionary;
		private var _vTransgateCustomDestinationPrototypes:Vector.<IPrototype>;

		private var _transgateCustomDestinationGroupPrototypes:Dictionary;
		private var _vTransgateCustomDestinationGroupPrototypes:Vector.<IPrototype>;

		private var _factionPrototypes:Dictionary;
		private var _vFactionPrototypes:Vector.<IPrototype>

		private var _contractPrototypes:Dictionary;
		private var _vContractPrototypes:Vector.<IPrototype>;

		private var _agentPrototypes:Dictionary;
		private var _vAgentPrototypes:Vector.<IPrototype>;

		private var _dialogPrototypes:Dictionary;
		private var _vDialogPrototypes:Vector.<IPrototype>;

		private var _csRacePrototypes:Dictionary;
		private var _vCsRacePrototypes:Vector.<IPrototype>;

		private var _storeItemPrototypes:Dictionary;
		private var _vStoreItemPrototypes:Vector.<IPrototype>;

		private var _offerItemPrototypes:Dictionary;
		private var _vOfferItemPrototypes:Vector.<IPrototype>;

		private var _faqEntryPrototypes:Dictionary;
		private var _vFAQEntryPrototypes:Vector.<IPrototype>;

		private var _achievementPrototypes:Dictionary;
		private var _vAchievementPrototypes:Vector.<IPrototype>;
		
		private var _filterAchievementPrototypes:Dictionary;
		private var _vFilterAchievementPrototypes:Vector.<IPrototype>;
		
		private var _debuffPrototypes:Dictionary;
		private var _vDebuffPrototypes:Vector.<IPrototype>;
		
		private var _activeSplits:Vector.<IPrototype>;

		private const TOAST_CONGRATS:String         = "CodeString.Toast.Congratulations"; // Congratulations!
		private const TOAST_YOU_WILL_RECEIVE:String = "CodeString.Toast.YouWillReceive"; // YOU WILL RECEIVE:

		[PostConstruct]
		public function init():void
		{
			
			
			attachPoints = new Dictionary();
			attachGroups = new Dictionary();
			_blueprintPrototypes = new Dictionary();
			_buffPrototypes = new Dictionary();
			_vBuffPrototypes = new Vector.<IPrototype>;
			_buildingPrototypes = new Dictionary();
			_vBuildingPrototypes = new Vector.<IPrototype>;
			_vBuildableBuildingPrototype = new Vector.<IPrototype>;
			_debuffPrototypes = new Dictionary();
			_vDebuffPrototypes = new Vector.<IPrototype>;
			_cachedQuery = new Dictionary();
			_vFTESteps = new Vector.<IPrototype>;
			_missionPrototypes = new Dictionary();
			_missionObjectivesPrototypes = new Dictionary();
			modulePrototypes = new Dictionary();
			moduleGroupPrototypes = new Dictionary();
			_researchPrototypes = new Dictionary();
			_vResearchPrototypes = new Vector.<IPrototype>;
			_researchRequirements = new Dictionary();
			_vShipPrototypes = new Vector.<IPrototype>;
			_slotPrototypes = new Dictionary();
			_constantPrototypes = new Dictionary();
			_statmodPrototypes = new Dictionary();
			_vStatmodPrototypes = new Vector.<IPrototype>;
			_weaponPrototypes = new Dictionary();
			_vWeaponPrototypes = new Vector.<IPrototype>;
			_transgateCustomDestinationPrototypes = new Dictionary();
			_vTransgateCustomDestinationPrototypes = new Vector.<IPrototype>;
			_transgateCustomDestinationGroupPrototypes = new Dictionary();
			_vTransgateCustomDestinationGroupPrototypes = new Vector.<IPrototype>;
			_factionPrototypes = new Dictionary();
			_vFactionPrototypes = new Vector.<IPrototype>;
			_contractPrototypes = new Dictionary();
			_vContractPrototypes = new Vector.<IPrototype>;
			_agentPrototypes = new Dictionary();
			_vAgentPrototypes = new Vector.<IPrototype>;
			_dialogPrototypes = new Dictionary();
			_vDialogPrototypes = new Vector.<IPrototype>;
			_csRacePrototypes = new Dictionary();
			_vCsRacePrototypes = new Vector.<IPrototype>;
			_vFirstNamePrototypes = new Vector.<IPrototype>;
			_vLastNamePrototypes = new Vector.<IPrototype>;
			_sectorPrototypes = new Dictionary();
			_sectorNamePrototypes = new Dictionary();
			_splitTestCohortPrototypes = new Dictionary();
			_storeItemPrototypes = new Dictionary();
			_vStoreItemPrototypes = new Vector.<IPrototype>;
			_npcPrototypes = new Dictionary();
			_offerPrototypes = new Dictionary();
			_offerItemPrototypes = new Dictionary();
			_vOfferItemPrototypes = new Vector.<IPrototype>;
			_statPrototypes = new Dictionary();
			_vBEDialoguePrototypes = new Vector.<IPrototype>;
			_faqEntryPrototypes = new Dictionary();
			_vFAQEntryPrototypes = new Vector.<IPrototype>;
			_vFAQEntryPrototypes = new Vector.<IPrototype>;
			_vLoginBonusPrototypes = new Vector.<IPrototype>;
			_commendationRankPrototypes = new Dictionary();
			_vAchievementPrototypes = new Vector.<IPrototype>;
			_achievementPrototypes = new Dictionary;
			_vFilterAchievementPrototypes = new Vector.<IPrototype>;
			_filterAchievementPrototypes = new Dictionary;
			_vEventPrototypes = new Vector.<IPrototype>;
			_splitTestPrototypes = new Dictionary();
			_loadingScreenPrototypes = new Dictionary();
			_vLoadingScreenPrototypes = new Vector.<IPrototype>;
			
			_loadingScreenGroupPrototypes = new Dictionary();
			_vLoadingScreenGroupPrototypes = new Vector.<IPrototype>;
			
			_activeSplits = new Vector.<IPrototype>;

			instance = this;

			var steps:Array = [
				{
					name:"START",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"showTipModal",
					timeDelay:20,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"300000"
				},
				{
					name:"Combat Intro",
					platform:"Browser",
					dialogString:"FTE.CombatIntro",
					voID:"sounds/vo/fte/FTE_001.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"moveToFleet",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:2,
					stepId:"300001"
				},
				{
					name:"Combat Initiated",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"forceMissionComplete,disableNext",
					timeDelay:0,
					missionName:"FTE_IGA_Starting_Mission,FTE_SOV_Starting_Mission,FTE_TYR_Starting_Mission",
					anchor:false,
					mood:0,
					stepId:"300002"
				},
				{
					name:"Combat Initiated",
					platform:"Browser",
					dialogString:"FTE.CombatInitiated",
					voID:"sounds/vo/fte/FTE_002.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"moveToFleet,checkFleetInBattle",
					timeDelay:5,
					missionName:"",
					anchor:false,
					mood:3,
					stepId:"301002"
				},
				{
					name:"Combat Initiated",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.hud.sector.SectorView",
					cutoutCoordinates:"0,100,640,40",
					arrowCoordinates:"320,144,-90",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:3,
					stepId:"301003"
				},
				{
					name:"Combat Movement 2",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"hideDialogue,hideOverlay,progressOnStateChange",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:3,
					stepId:"301004"
				},
				{
					name:"Combat Movement",
					platform:"Browser",
					dialogString:"FTE.CombatSelection",
					voID:"sounds/vo/fte/FTE_003.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"pauseBattle,centerOnFleets,disableNext,pressWASD,toastImage|WASD_Keys.png",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"301005"
				},
				{
					name:"Combat Movement 2",
					platform:"Browser",
					dialogString:"FTE.FiringRange",
					voID:"sounds/vo/fte/FTE_004.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"moveToFleet,disableNext,selectFleet,killToast",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"301006"
				},
				{
					name:"Combat Movement 3",
					platform:"Browser",
					dialogString:"",
					voID:"sounds/vo/fte/VO_FTE_Combat_003_Click_To_Move.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"centerOnFleets,waitForMove,disableNext,pointToCenterOfScreen",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:1,
					stepId:"301007"
				},
				{
					name:"Combat Active",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"centerOnFleets,unpauseBattle,hideDialogue,hideOverlay,notifyOnBattleEnd",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:1,
					stepId:"301008"
				},
				{
					name:"Combat End",
					platform:"Browser",
					dialogString:"FTE.CombatEnd",
					voID:"sounds/vo/fte/FTE_005.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:2,
					stepId:"301009"
				},
				{
					name:"Looting/Rewards",
					platform:"Browser",
					dialogString:"FTE.LootingRewards",
					voID:"sounds/vo/fte/FTE_006.mp3",
					uiID:"com.ui.modal.battle.BattleEndView",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"highlightUI|lootHolder",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"301010"
				},
				{
					name:"Combat Targeting 3",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.modal.battle.BattleEndView",
					cutoutCoordinates:"762,463,138,38",
					arrowCoordinates:"819,460,90",
					trigger:"hideDialogue",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"301011"
				},
				{
					name:"Combat Targeting 3",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"hideOverlay,progressOnStateChange",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"301012"
				},
				{
					name:"Substep",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"checkForMission,disableNext",
					timeDelay:0,
					missionName:"FTE_IGA_Dock,FTE_SOV_Dock,FTE_TYR_Dock",
					anchor:false,
					mood:0,
					stepId:"301013"
				},
				{
					name:"Recall",
					platform:"Browser",
					dialogString:"FTE.Recall",
					voID:"sounds/vo/fte/FTE_007.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"moveToFleet,selectFleet,disableNext",
					timeDelay:5,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"302014"
				},
				{
					name:"Substep",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.core.component.contextmenu.ContextMenu",
					cutoutCoordinates:"15,33,122,17",
					arrowCoordinates:"0,40,0",
					trigger:"selectContextMenu,followFleet",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"302015"
				},
				{
					name:"Substep",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"hideDialogue,checkForMission",
					timeDelay:0,
					missionName:"FTE_TYR_Upgrade_Shipyard_Begin,FTE_IGA_Upgrade_Shipyard_Begin,FTE_SOV_Upgrade_Shipyard_Begin",
					anchor:false,
					mood:0,
					stepId:"302016"
				},
				{
					name:"Enter Base",
					platform:"Browser",
					dialogString:"FTE.EnterBase",
					voID:"sounds/vo/fte/FTE_008.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"selectBase,disableNext",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:2,
					stepId:"303017"
				},
				{
					name:"Substep",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.core.component.contextmenu.ContextMenu",
					cutoutCoordinates:"15,33,122,17",
					arrowCoordinates:"0,40,0",
					trigger:"selectContextMenu",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:2,
					stepId:"303018"
				},
				{
					name:"Substep",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"progressOnStateChange,hideDialogue,hideOverlay",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:2,
					stepId:"303019"
				},
				{
					name:"Greeting",
					platform:"Browser",
					dialogString:"FTE.Greeting",
					voID:"sounds/vo/fte/FTE_009.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:2,
					stepId:"303020"
				},
				{
					name:"Base Intro",
					platform:"Browser",
					dialogString:"FTE.RewardIntro",
					voID:"sounds/vo/fte/FTE_010.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"highlightUI|HardCurrency",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:1,
					stepId:"303021"
				},
				{
					name:"Shipyard Upgrade",
					platform:"Browser",
					dialogString:"FTE.ShipyardIntro",
					voID:"sounds/vo/fte/FTE_011.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"disableNext,selectBuilding|ConstructionBay",
					timeDelay:5,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"303022"
				},
				{
					name:"Subtask",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.core.component.contextmenu.ContextMenu",
					cutoutCoordinates:"14,70,122,20",
					arrowCoordinates:"0,80,0",
					trigger:"selectContextMenu",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"303023"
				},
				{
					name:"Shipyard Upgrade 1 Click",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.modal.construction.ConstructionInfoView",
					cutoutCoordinates:"401,464,119,50",
					arrowCoordinates:"460,470,90",
					trigger:"hideDialogue",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"303024"
				},
				{
					name:"Interlude",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"checkForMission,disableNext",
					timeDelay:0,
					missionName:"FTE_TYR_Upgrade_Shipyard,FTE_IGA_Upgrade_Shipyard,FTE_SOV_Upgrade_Shipyard",
					anchor:false,
					mood:0,
					stepId:"303025"
				},
				{
					name:"Shipyard Upgrade 2",
					platform:"Browser",
					dialogString:"FTE.ShipyardInstant",
					voID:"sounds/vo/fte/FTE_012.mp3",
					uiID:"com.ui.hud.shared.PlayerView",
					cutoutCoordinates:"238,81,126,53",
					arrowCoordinates:"290,134,-90",
					trigger:"",
					timeDelay:5,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"304026"
				},
				{
					name:"Shipyard Upgrade 4 Click",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.modal.store.StoreView",
					cutoutCoordinates:"310,430,395,85",
					arrowCoordinates:"500,440,90",
					trigger:"hideDialogue",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"304027"
				},
				{
					name:"Subtask",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"closeView|com.ui.modal.store.StoreView,forceNextStep",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"304028"
				},
				{
					name:"Interlude",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"checkForMission,disableNext",
					timeDelay:5,
					missionName:"FTE_TYR_Build_Ship_Begin,FTE_IGA_Build_Ship_Begin,FTE_SOV_Build_Ship_Begin",
					anchor:false,
					mood:0,
					stepId:"304029"
				},
				{
					name:"Trade Routes Intro",
					platform:"Browser",
					dialogString:"FTE.Palladium",
					voID:"sounds/vo/fte/FTE_013.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"highlightUI|HardCurrency",
					timeDelay:5,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"305030"
				},
				{
					name:"Ship Intro",
					platform:"Browser",
					dialogString:"FTE.ShipBuildIntro",
					voID:"sounds/vo/fte/FTE_014.mp3",
					uiID:"com.ui.hud.shared.engineering.EngineeringView",
					cutoutCoordinates:"322,0,155,41",
					arrowCoordinates:"395,32,-90",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"305031"
				},
				{
					name:"Ship Intro 2",
					platform:"Browser",
					dialogString:"FTE.HullIntro",
					voID:"sounds/vo/fte/FTE_015.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"305032"
				},
				{
					name:"Weapon Slot",
					platform:"Browser",
					dialogString:"FTE.WeaponSlot",
					voID:"sounds/vo/fte/FTE_016.mp3",
					uiID:"com.ui.modal.shipyard.ShipyardView",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"selectShipSlot|Weapon",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"305033"
				},
				{
					name:"Weapon Slot Select",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.modal.construction.ConstructionView",
					cutoutCoordinates:"280,83,590,113",
					arrowCoordinates:"280,123,0",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"305034"
				},
				{
					name:"Defense Slot",
					platform:"Browser",
					dialogString:"FTE.DefenseSlot",
					voID:"sounds/vo/fte/FTE_017.mp3",
					uiID:"com.ui.modal.shipyard.ShipyardView",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"selectShipSlot|Defense",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"305035"
				},
				{
					name:"Defense Slot 02",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.modal.construction.ConstructionView",
					cutoutCoordinates:"280,83,590,113",
					arrowCoordinates:"280,123,0",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"305036"
				},
				{
					name:"Power Capacity",
					platform:"Browser",
					dialogString:"FTE.PowerCapacity",
					voID:"sounds/vo/fte/FTE_018.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"305037"
				},
				{
					name:"Ship Build",
					platform:"Browser",
					dialogString:"FTE.ShipBuild",
					voID:"sounds/vo/fte/FTE_019.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"305038"
				},
				{
					name:"Ship Build Click",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.modal.shipyard.ShipyardView",
					cutoutCoordinates:"551,549,120,52",
					arrowCoordinates:"611,550,90",
					trigger:"hideDialogue",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"305039"
				},
				{
					name:"Subtask",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"closeView|com.ui.modal.shipyard.ShipyardView,checkForMission,disableNext",
					timeDelay:0,
					missionName:"FTE_TYR_Build_Ship,FTE_IGA_Build_Ship,FTE_SOV_Build_Ship",
					anchor:false,
					mood:2,
					stepId:"305040"
				},
				{
					name:"Subtask",
					platform:"Browser",
					dialogString:"FTE.Palladium2",
					voID:"sounds/vo/fte/FTE_020.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"",
					timeDelay:5,
					missionName:"",
					anchor:false,
					mood:2,
					stepId:"306041"
				},
				{
					name:"Shipyard Accelerate 01",
					platform:"Browser",
					dialogString:"FTE.DashboardIntro",
					voID:"sounds/vo/fte/FTE_021.mp3",
					uiID:"com.ui.hud.shared.engineering.EngineeringView",
					cutoutCoordinates:"343,46,114,13",
					arrowCoordinates:"395,57,-90",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"306042"
				},
				{
					name:"Shipyard Accelerate 02",
					platform:"Browser",
					dialogString:"FTE.DashboardIntro2",
					voID:"sounds/vo/fte/FTE_022.mp3",
					uiID:"com.ui.hud.shared.engineering.EngineeringView",
					cutoutCoordinates:"336,95,60,60",
					arrowCoordinates:"365,143,-90",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"306042"
				},
				{
					name:"Shipyard Accelerate 03",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.modal.store.StoreView",
					cutoutCoordinates:"308,108,400,90",
					arrowCoordinates:"508,102,90",
					trigger:"enableHUD",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"306044"
				},
				{
					name:"Subtask",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"closeView|com.ui.modal.store.StoreView,checkForMission,disableNext",
					timeDelay:0,
					missionName:"FTE_TYR_Repair_Fleet_Begin,FTE_IGA_Repair_Fleet_Begin,FTE_SOV_Repair_Fleet_Begin",
					anchor:false,
					mood:0,
					stepId:"306045"
				},
				{
					name:"Ship Complete",
					platform:"Browser",
					dialogString:"FTE.Kabam",
					voID:"sounds/vo/fte/FTE_023.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"closeView|com.ui.modal.shipyard.ShipyardView",
					timeDelay:5,
					missionName:"",
					anchor:true,
					mood:3,
					stepId:"307046"
				},
				{
					name:"Fleet Tab",
					platform:"Browser",
					dialogString:"FTE.Messing",
					voID:"sounds/vo/fte/FTE_024.mp3",
					uiID:"com.ui.hud.shared.engineering.EngineeringView",
					cutoutCoordinates:"483,0,155,41",
					arrowCoordinates:"558,32,-90",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:1,
					stepId:"307047"
				},
				{
					name:"Repair Fleet",
					platform:"Browser",
					dialogString:"FTE.FleetIntro",
					voID:"sounds/vo/fte/FTE_025.mp3",
					uiID:"com.ui.modal.dock.DockView",
					cutoutCoordinates:"700,260,118,50",
					arrowCoordinates:"760,310,-90",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"307048"
				},
				{
					name:"Subtask",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"checkForMission,disableNext",
					timeDelay:0,
					missionName:"FTE_TYR_Repair_Fleet,FTE_IGA_Repair_Fleet,FTE_SOV_Repair_Fleet",
					anchor:false,
					mood:0,
					stepId:"307049"
				},
				{
					name:"Click speed up",
					platform:"Browser",
					dialogString:"FTE.FleetIntro",
					voID:"",
					uiID:"com.ui.modal.dock.DockView",
					cutoutCoordinates:"683,260,118,50",
					arrowCoordinates:"750,310,-90",
					trigger:"",
					timeDelay:5,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"308050"
				},
				{
					name:"Repair Fleet 2",
					platform:"Browser",
					dialogString:"FTE.InstantReminder",
					voID:"sounds/vo/fte/FTE_026.mp3",
					uiID:"com.ui.modal.store.StoreView",
					cutoutCoordinates:"305,108,404,90",
					arrowCoordinates:"507,102,90",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:false,
					mood:2,
					stepId:"308051"
				},
				{
					name:"Repair Fleet 2",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"31,135,225,35",
					arrowCoordinates:"584,150,90",
					trigger:"checkForMission,disableNext",
					timeDelay:0,
					missionName:"FTE_TYR_Update_Fleet,FTE_IGA_Update_Fleet,FTE_SOV_Update_Fleet",
					anchor:false,
					mood:0,
					stepId:"308052"
				},
				{
					name:"Repair Fleet 2",
					platform:"Browser",
					dialogString:"FTE.ProgressPanel",
					voID:"sounds/vo/fte/FTE_027.mp3",
					uiID:"com.ui.modal.store.StoreView",
					cutoutCoordinates:"31,135,225,35",
					arrowCoordinates:"143,130,90",
					trigger:"ignoreStoreOffset",
					timeDelay:5,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"309053"
				},
				{
					name:"Fleet slots",
					platform:"Browser",
					dialogString:"FTE.LaunchFleet",
					voID:"sounds/vo/fte/FTE_028.mp3",
					uiID:"com.ui.modal.dock.DockView",
					cutoutCoordinates: "157,400,115,105",//"265,220,115,105",
					arrowCoordinates: "215,398,90",//"315,318,-90",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:2,
					stepId:"309054"
				},
				{
					name:"Fleet slots 02",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"com.ui.modal.dock.ShipSelectionView",
					cutoutCoordinates:"22,135,590,105",
					arrowCoordinates:"315,244,-90",
					trigger:"",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:2,
					stepId:"309055"
				},
				{
					name:"Switch to Sector View",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"checkForMission,disableNext",
					timeDelay:0,
					missionName:"FTE_TYR_Launch_Fleet,FTE_IGA_Launch_Fleet,FTE_SOV_Launch_Fleet",
					anchor:false,
					mood:0,
					stepId:"309056"
				},
				{
					name:"Launch Fleet",
					platform:"Browser",
					dialogString:"",
					voID:"sounds/vo/fte/VO_FTE_Main_010_Tiger.mp3",
					uiID:"com.ui.modal.dock.DockView",
					cutoutCoordinates:"731,585,233,38",
					arrowCoordinates:"868,591,90",
					trigger:"hideDialogue",
					timeDelay:5,
					missionName:"",
					anchor:true,
					mood:2,
					stepId:"310057"
				},
				{
					name:"Switch to Sector View",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"hideDialogue,hideOverlay,progressOnStateChange",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"310058"
				},
				{
					name:"Repair Fleet 2",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"checkForMission,disableNext",
					timeDelay:0,
					missionName:"FTE_TYR_Reward,FTE_IGA_Reward,FTE_SOV_Reward",
					anchor:false,
					mood:0,
					stepId:"411060"
				},
				{
					name:"Transgate Intro 2",
					platform:"Browser",
					dialogString:"FTE.FleetButton",
					voID:"sounds/vo/fte/FTE_029.mp3",
					uiID:"com.ui.hud.shared.command.CommandView",
					cutoutCoordinates:"163,-66,186,60",
					arrowCoordinates:"160,-40,0",
					trigger:"forceMissionComplete,disableNext",
					timeDelay:10,
					missionName:"",
					anchor:true,
					mood:0,
					stepId:"411060"
				},
				{
					name:"AI Intro",
					platform:"Browser",
					dialogString:"FTE.Reward",
					voID:"sounds/vo/fte/FTE_030.mp3",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"moveToFleet",
					timeDelay:0,
					missionName:"",
					anchor:true,
					mood:1,
					stepId:"411061"
				},
				{
					name:"Switch to Sector View",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"checkForMission,disableNext",
					timeDelay:0,
					missionName:"TYR_Ch1_M1,IGA_Ch1_M1,SOV_Ch1_M1,TYR_Ch0_M1,IGA_Ch0_M1,SOV_Ch0_M1,TYR_Test_Mission,IGA_Test_Mission,SOV_Test_Mission",
					anchor:false,
					mood:0,
					stepId:"411062"
				},
				{
					name:"Combat Initiated",
					platform:"Browser",
					dialogString:"FTE.GoodLuck",
					voID:"sounds/vo/fte/FTE_031.mp3",
					uiID:"com.ui.hud.shared.bridge.BridgeView",
					cutoutCoordinates:"12,130,60,60",
					arrowCoordinates:"100,154,180",
					trigger:"disableNext",
					timeDelay:5,
					missionName:"",
					anchor:true,
					mood:2,
					stepId:"411063"
				},
				{
					name:"END",
					platform:"Browser",
					dialogString:"",
					voID:"",
					uiID:"",
					cutoutCoordinates:"",
					arrowCoordinates:"",
					trigger:"forceNextStep",
					timeDelay:20,
					missionName:"",
					anchor:false,
					mood:0,
					stepId:"411064"
				}
				];


			for (var i:int = 0; i < steps.length; i++)
			{
				_vFTESteps.push(new PrototypeVO(steps[i]));
			}
		}

		public function addPrototypeData( data:Object ):void
		{
			for (var key:String in data)
			{
				if (this.hasOwnProperty(key))
				{
					this[key] = data[key];
				}
			}
		}
		
		/*
			Returns a loading screen prototype by its key.
		*/
		public function getLoadingScreenPrototype(key:String):IPrototype{
			return _loadingScreenPrototypes[key];
		}
		
		/*
			Returns a vector list containing all loading screen prototypes.
		*/
		public function getLoadingScreenPrototypes():Vector.<IPrototype>{
			return _vLoadingScreenPrototypes;
		}
		
		/*
			Returns a vector list containing all loading screen prototypes by group.
		*/
		public function getLoadingScreenPrototypesByGroup(group:String):Vector.<IPrototype>{
			var loadingScreenGroupPrototypes:Vector.<IPrototype> = new Vector.<IPrototype>;
			
			for each (var loadingScreenPrototype:IPrototype in _loadingScreenPrototypes)
			{
				if (loadingScreenPrototype.getValue('loadingScreenGroup') == group)
					loadingScreenGroupPrototypes.push(loadingScreenPrototype);
			}
			return loadingScreenGroupPrototypes;
		}
		
		
		/*
			Returns a loading screen group prototype by its key *Note* this is different than LoadingScreenPrototypes?.
		*/
		public function getLoadingScreenGroupPrototype(key:String):IPrototype{
			return _loadingScreenPrototypes[key];
		}
		
		/*
			Returns a vector list containing all loading screen group prototypes *Note* this is different than LoadingScreenPrototypes or LoadingScreenPrototype Groups?.
		*/
		public function getLoadingScreenGroupPrototypes():Vector.<IPrototype>{
			return _vLoadingScreenGroupPrototypes;
		}
		
		
		public function getBlueprintPrototype( key:String ):IPrototype  { return _blueprintPrototypes[key]; }
		public function getBuffPrototype( key:String ):IPrototype  { return _buffPrototypes[key]; }
		public function getBuffPrototypes():Vector.<IPrototype>  { return _vBuffPrototypes; }
		
		public function getDebuffPrototype( key:String ):IPrototype  { return _debuffPrototypes[key]; }
		public function getDebuffPrototypes():Vector.<IPrototype>  { return _vDebuffPrototypes; }

		public function getBuildingPrototype( key:String ):IPrototype
		{
			return _buildingPrototypes[key];
		}
		public function getBuildingPrototypeByClassAndLevel( buildingClass:String, level:int ):IPrototype
		{
			for (var i:int = 0; i < _vBuildingPrototypes.length; i++)
			{
				if (_vBuildingPrototypes[i].getValue('itemClass') == buildingClass && _vBuildingPrototypes[i].getValue('level') == level)
					return _vBuildingPrototypes[i];
			}
			return null;
		}

		public function getBuildableBuildingPrototypes():Vector.<IPrototype>  { return _vBuildableBuildingPrototype; }
		public function getBuildingPrototypes():Vector.<IPrototype>  { return _vBuildingPrototypes; }
		public function getAttachPoint( key:String ):IPrototype  { return attachPoints[key]; }
		public function getAttachGroup( key:String ):Array  { return attachGroups[key]; }

		public function getAttachPointByType( attachGroup:String, attachPointType:String ):PrototypeVO
		{
			var attachPointSet:Array = attachGroups[attachGroup];
			for each (var attachPoint:PrototypeVO in attachPointSet)
			{
				if (attachPoint.getValue('attachPointType') == attachPointType)
					return attachPoint;
			}
			return null;
		}

		public function getFTEStepsByPlatform( platform:String ):Vector.<IPrototype>
		{
			if (!_cachedQuery['FTE' + platform])
			{
				var steps:Vector.<IPrototype> = new Vector.<IPrototype>;
				for (var i:int = 0; i < _vFTESteps.length; i++)
				{
					if (_vFTESteps[i].getValue("platform") == platform)
						steps.push(_vFTESteps[i]);
				}
				_cachedQuery['FTE' + platform] = steps;
			}
			return _cachedQuery['FTE' + platform];
		}

		public function getMissionPrototye( id:String ):IPrototype  { return _missionPrototypes[id]; }
		public function getMissionObjective( id:String ):IPrototype  { return _missionObjectivesPrototypes[id]; }

		public function getResearchPrototypeByName( key:String ):IPrototype  { return _researchPrototypes[key]; }
		public function getResearchPrototypes():Vector.<IPrototype>  { return _vResearchPrototypes; }
		public function getResearchPrototypesByBuilding( buildingClass:String ):Vector.<IPrototype>  { if (_researchPrototypes.hasOwnProperty(buildingClass)) return _researchPrototypes[buildingClass]; return null; }
		public function getResearchPrototypesDict():Dictionary  { return _researchPrototypes; }

		public function getStatModPrototypeByName( key:String ):IPrototype  { return _statmodPrototypes[key]; }
		public function getStatModPrototypes():Vector.<IPrototype>  { return _vStatmodPrototypes; }
		public function getStatModPrototypesByGroup( group:String ):Vector.<IPrototype>
		{
			var mods:Vector.<IPrototype> = new Vector.<IPrototype>;
			for each (var statMod:IPrototype in _statmodPrototypes)
			{
				if (statMod.getValue('modGroup') == group)
					mods.push(statMod);
			}

			return mods;
		}

		public function getConstantPrototypeByName( key:String ):IPrototype  { return _constantPrototypes[key]; }
		public function getConstantPrototypeValueByName( key:String ):*  { return _constantPrototypes[key]; }
		public function getConstantPrototypes():Dictionary  { return _constantPrototypes; }

		public function getFactionPrototypeByName( key:String ):IPrototype  { return _factionPrototypes[key]; }
		public function getFactionPrototypes():Vector.<IPrototype>  { return _vFactionPrototypes }

		public function getContractPrototypeByName( key:String ):IPrototype  { return _contractPrototypes[key]; }
		public function getContractPrototypes():Vector.<IPrototype>  { return _vContractPrototypes; }

		public function getAgentPrototypeByName( key:String ):IPrototype  { return _agentPrototypes[key]; }
		public function getAgentPrototypes():Vector.<IPrototype>  { return _vAgentPrototypes; }

		public function getDialogPrototypeByName( key:String ):IPrototype  { return _dialogPrototypes[key]; }
		public function getDialogPrototypes():Vector.<IPrototype>  { return _vDialogPrototypes; }

		public function getNPCPrototypeByName( key:String ):IPrototype  { return _npcPrototypes[key]; }
		public function getOfferPrototypeByName( key:String ):IPrototype  { return _offerPrototypes[key]; }

		public function getStatPrototypeByName( key:String ):IPrototype  { return _statPrototypes[key]; }

		public function getOfferItemsByItemGroup( key:String ):Vector.<IPrototype>
		{
			var groupItems:Vector.<IPrototype> = new Vector.<IPrototype>;

			for (var i:int = 0; i < _vOfferItemPrototypes.length; i++)
			{
				if (_vOfferItemPrototypes[i].getValue('itemGroup') == key)
					groupItems.push(_vOfferItemPrototypes[i]);
			}
			return groupItems;
		}

		public function getSectorPrototypeByName( key:String ):IPrototype  { return _sectorPrototypes[key]; }

		public function getSectorNamePrototypeByName( key:String ):IPrototype  { return _sectorNamePrototypes[key]; }

		public function getSplitTestCohortPrototypeByName( key:String ):IPrototype  { return _splitTestCohortPrototypes[key]; }

		public function getStoreItemPrototypeByName( key:String ):IPrototype  { return _storeItemPrototypes[key]; }
		public function getStoreItemPrototypes():Vector.<IPrototype>  { return _vStoreItemPrototypes; }

		public function getShipPrototype( type:String ):IPrototype
		{
			for (var i:int = 0; i < _vShipPrototypes.length; i++)
			{
				if (_vShipPrototypes[i].name == type)
					return _vShipPrototypes[i];
			}

			return null;
		}
		public function getShipPrototypesByFaction( faction:String ):Vector.<IPrototype>
		{
			var ships:Vector.<IPrototype> = new Vector.<IPrototype>;
			for (var i:int = 0; i < _vShipPrototypes.length; i++)
			{
				if (_vShipPrototypes[i].getValue('faction') == faction)
					ships.push(_vShipPrototypes[i]);
			}

			return ships;
		}
		public function getSlotPrototype( key:String ):IPrototype  { return _slotPrototypes[key]; }
		public function getModulesBySlotType( slotType:String ):Vector.<IPrototype>
		{
			var key:String                  = "shipComponent" + slotType;
			if (_cachedQuery[key])
				return _cachedQuery[key];
			var modules:Vector.<IPrototype> = new Vector.<IPrototype>;
			for each (var vo:IPrototype in _weaponPrototypes)
			{
				if (vo.getValue('slotType') == slotType)
					modules.push(vo);
			}
			_cachedQuery[key] = modules;
			return modules;
		}

		public function getWeaponPrototype( key:String ):IPrototype  { return _weaponPrototypes[key]; }

		public function getWeaponPrototypes():Vector.<IPrototype>  { return _vWeaponPrototypes; }
		
		public function getTransgateCustomDestinationPrototype( key:String ):IPrototype  { return _transgateCustomDestinationPrototypes[key]; }

		public function getTransgateCustomDestinationGroupByCustomDestinationGroup( group:String ):Vector.<IPrototype>
		{
			var key:String                  = "transgateCustomDestination" + group;
			if (_cachedQuery[key])
				return _cachedQuery[key];
			var customDestinations:Vector.<IPrototype> = new Vector.<IPrototype>;
			for each (var vo:IPrototype in _transgateCustomDestinationGroupPrototypes)
			{
				if (vo.getValue('transgateCustomDestinationGroup') == group)
					customDestinations.push(vo);
			}
			_cachedQuery[key] = customDestinations;
			return customDestinations;
		}

		public function getRacePrototypesByFaction( faction:String, race:String ):Vector.<IPrototype>
		{
			var races:Vector.<IPrototype> = new Vector.<IPrototype>;
			var currentRace:IPrototype;
			for (var i:int = 0; i < _vCsRacePrototypes.length; i++)
			{
				currentRace = _vCsRacePrototypes[i];
				if (currentRace.getValue('faction') == faction && currentRace.getValue('race') == race && currentRace.getValue('isPc') == true && currentRace.getValue('isActive') == true)
					races.push(currentRace);
			}
			return races;
		}

		public function getRacePrototypeByName( key:String ):IPrototype  { return _csRacePrototypes[key]; }

		public function getFirstNamePrototypes():Vector.<IPrototype>  { return _vFirstNamePrototypes; }
		public function getLastNamePrototypes():Vector.<IPrototype>  { return _vLastNamePrototypes; }

		public function getBEDialogueByFaction( faction:String, result:String = 'Victory' ):Vector.<IPrototype>
		{
			var options:Vector.<IPrototype> = new Vector.<IPrototype>;
			//Result is either Victory or Taunt
			for each (var option:IPrototype in _vBEDialoguePrototypes)
			{
				if (option.getValue('faction') == faction && option.getValue('resultType') == result)
					options.push(option);
			}
			return options;
		}

		public function getFirstNameOptions( race:String, gender:String ):Vector.<IPrototype>
		{
			//Total hack until I sort the data out
			if (race == "Ares Magna")
				race = "AresMagna";
			var options:Vector.<IPrototype> = new Vector.<IPrototype>;
			for each (var name:IPrototype in _vFirstNamePrototypes)
			{
				if (name.getValue('race') == race && (name.getValue('gender') == gender || name.getValue('gender') == 'Unisex'))
					options.push(name);
			}
			return options;
		}

		public function getLastNameOptions( race:String, gender:String ):Vector.<IPrototype>
		{
			//Total hack until I sort the data out
			if (race == "Ares Magna")
				race = "AresMagna";
			var options:Vector.<IPrototype> = new Vector.<IPrototype>;
			for each (var name:IPrototype in _vLastNamePrototypes)
			{
				if (name.getValue('race') == race && (name.getValue('gender') == gender || name.getValue('gender') == 'Unisex'))
					options.push(name);
			}
			return options;
		}

		public function getFAQEntryPrototypesByName( key:String ):IPrototype
		{
			return _faqEntryPrototypes[key];
		}

		public function getFAQEntryPrototypes():Vector.<IPrototype>
		{
			return _vFAQEntryPrototypes;
		}

		public function getLoginBonusPrototypeByDay( day:int ):IPrototype
		{
			for each (var p:IPrototype in _vLoginBonusPrototypes)
			{
				if (p.getValue('escalationReq') == day)
					return p;
			}

			return null;
		}

		public function getCommendationRankPrototypesByName( key:String ):IPrototype
		{
			return _commendationRankPrototypes[key];
		}

		public function getAchievementPrototypes():Vector.<IPrototype>
		{
			return _vAchievementPrototypes;
		}
		
		public function getFilterAchievementPrototypes():Vector.<IPrototype>
		{
			return _vFilterAchievementPrototypes;
		}

		public function getAchievementPrototypeByName( name:String ):IPrototype
		{
			return _achievementPrototypes[name];
		}

		public function getSplitTestPrototypeByName( name:String ):IPrototype
		{
			return _splitTestPrototypes[name];
		}

		public function set AttachPointPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				attachPoints[key] = vo;
				var group:String = vo.getValue("attachGroup");
				attachGroups[group] ||= [];
				attachGroups[group].push(vo);
			}
		}

		public function set ActiveDefensePrototypes( v:Object ):void
		{
			WeaponPrototypes = v;
		}

		public function set BlueprintPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_blueprintPrototypes[key] = vo;
			}
		}

		public function getEventPrototypes():Vector.<IPrototype>
		{
			return _vEventPrototypes;
		}

		public function set EventPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_vEventPrototypes.push(vo);
			}
		}

		public function set SplitTestPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_splitTestPrototypes[key] = vo;
			}

		}

		public function set BuffPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_buffPrototypes[key] = vo;
				_vBuffPrototypes.push(vo);
			}
		}
		
		public function set DebuffPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_debuffPrototypes[key] = vo;
				_vDebuffPrototypes.push(vo);
			}
		}

		public function set BuildingPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_vBuildingPrototypes.push(vo);
				_buildingPrototypes[key] = vo;

				if (vo.getValue('level') == 1)
					_vBuildableBuildingPrototype.push(vo);
			}
		}

		public function set AssetPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_assetModel.addGameAssetData(vo);
			}
		}

		public function set MissionPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_missionPrototypes[key] = vo;
			}
		}

		public function set ModulePrototypes( v:Object ):void
		{
			WeaponPrototypes = v;
			// TODO - Delete this maybe? This just seems to break things when run...
		}

		public function set ModuleGroupPrototypes( v:Object ):void
		{

		}

		public function set ObjectivesPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_missionObjectivesPrototypes[key] = vo;
			}
		}

		public function set ShipPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_vShipPrototypes.push(vo);
			}
		}

		public function set SlotPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_slotPrototypes[key] = vo;
			}
		}

		public function set StatModPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_statmodPrototypes[key] = vo;
			}
		}

		public function set ConstantPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_constantPrototypes[key] = vo;
			}
			updateScalars();
		}

		public function set StoreItemPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_storeItemPrototypes[key] = vo;
				_vStoreItemPrototypes.push(vo);
			}
		}

		public function set FactionPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_factionPrototypes[key] = vo;
				_vFactionPrototypes.push(vo);
			}
		}

		public function set ContractPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_contractPrototypes[key] = vo;
				_vContractPrototypes.push(vo);
			}
		}

		public function set AgentPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_agentPrototypes[key] = vo;
				_vAgentPrototypes.push(vo);
			}
		}

		public function set DialogPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_dialogPrototypes[key] = vo;
				_vDialogPrototypes.push(vo);
			}
		}

		public function set WeaponPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_weaponPrototypes[key] = vo;
				_vWeaponPrototypes.push(vo);
			}
		}
		
		public function set TransgateCustomDestinationPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_transgateCustomDestinationPrototypes[key] = vo;
				_vTransgateCustomDestinationPrototypes.push(vo);
			}
		}

		public function set TransgateCustomDestinationGroupPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_transgateCustomDestinationGroupPrototypes[key] = vo;
				_vTransgateCustomDestinationGroupPrototypes.push(vo);
			}
		}

		public function set RacePrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_csRacePrototypes[key] = vo;
				_vCsRacePrototypes.push(vo);
			}
		}

		public function set UIAssetPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_assetModel.addUIAssetData(vo);
			}
		}

		public function set AudioAssetPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_assetModel.addAudioAssetData(vo);
			}
		}

		public function set FilterAssetPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_assetModel.addFilterAssetData(vo);
			}
		}

		public function set FilterAchievementPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_filterAchievementPrototypes[key] = vo;
				_vFilterAchievementPrototypes.push(vo);
			}
		}
		
		public function set ResearchPrototypes( v:Object ):void
		{
			var buildingClass:String;
			var vectorKey:String;
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				buildingClass = vo.getValue('requiredBuildingClass');
				vectorKey = buildingClass + vo.getValue("filterCategory");
				_researchPrototypes[key] = vo;
				if (!_researchPrototypes.hasOwnProperty(buildingClass))
					_researchPrototypes[buildingClass] = new Vector.<IPrototype>;
				if (!_researchPrototypes.hasOwnProperty(vectorKey))
					_researchPrototypes[vectorKey] = new Vector.<IPrototype>;
				_researchPrototypes[buildingClass].push(vo);
				_researchPrototypes[vectorKey].push(vo);
				_vResearchPrototypes.push(vo);

				var requiredTech:String = vo.getValue("requiredResearch");
				if (requiredTech.length > 0)
				{
					_researchRequirements[requiredTech] ||= [];
					_researchRequirements[requiredTech].push(key);
				}
			}
		}

		public function set CommendationRankPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_commendationRankPrototypes[key] = vo;
			}
		}

		public function getResearchThatRequires( tech:String ):Vector.<IPrototype>
		{
			var result:Vector.<IPrototype> = new Vector.<IPrototype>();
			var keys:Array                 = _researchRequirements[tech];
			if (keys)
			{
				for each (var key:String in keys)
				{
					result.push(getResearchPrototypeByName(key));
				}
			}
			return result;
		}

		public function set FirstNamePrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_vFirstNamePrototypes.push(vo);
			}
		}

		public function set LastNamePrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_vLastNamePrototypes.push(vo);
			}
		}

		public function set FTEPrototypes( v:Object ):void
		{
		/*var vo:IPrototype;
		   for (var key:String in v)
		   {
		   vo = new PrototypeVO(v[key]);
		   _fteSteps.push(vo);
		   }
		   _fteSteps.sort(sortByID);*/
		}

		public function set NPCPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_npcPrototypes[key] = vo;
			}
		}

		public function set OfferPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_offerPrototypes[key] = vo;
			}
		}

		public function set OfferItemPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_offerItemPrototypes[key] = vo;
				_vOfferItemPrototypes.push(vo);
			}
		}

		public function set FAQEntryPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_faqEntryPrototypes[key] = vo;
				_vFAQEntryPrototypes.push(vo);
			}
		}

		public function set SectorPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_sectorPrototypes[key] = vo;
			}
		}

		public function set AchievementPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_achievementPrototypes[key] = vo;
				_vAchievementPrototypes.push(vo);
			}
		}

		public function set SectorNamePrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_sectorNamePrototypes[key] = vo;
			}
		}

		public function set SplitTestCohortPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_splitTestCohortPrototypes[key] = vo;
			}
		}

		public function set StatPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_statPrototypes[key] = vo;
			}
		}

		public function set BEDialoguePrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_vBEDialoguePrototypes.push(vo);
			}
		}

		public function set LoginBonusPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_vLoginBonusPrototypes.push(vo);
			}
		}
		
		/*
			Sets our loading screen prototype Dictionary Map and Vector List
		*/
		public function set LoadingScreenPrototypes( v:Object ):void
		{
			//trace(new Error().getStackTrace());
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_loadingScreenPrototypes[key] = vo;
				_vLoadingScreenPrototypes.push(vo);
			}
		}
		
		/*
			Sets our loading screen group prototype Dictionary Map and Vector List *Note* this is different from
			loadingScreenPrototypes?
		*/
		public function set LoadingScreenGroupPrototypes( v:Object ):void
		{
			var vo:IPrototype;
			for (var key:String in v)
			{
				vo = new PrototypeVO(v[key]);
				_loadingScreenGroupPrototypes[key] = vo;
				_vLoadingScreenGroupPrototypes.push(vo);
			}
		}
		
		private function sortByID( protoA:IPrototype, protoB:IPrototype ):int
		{
			if (protoA.getValue("id") < protoB.getValue("id"))
				return -1;
			return 1;
		}

		public function setSplits( v:Vector.<String> ):void
		{
			var len:uint;
			var i:uint;
			var key:String;
			var currentSplitTestPrototype:IPrototype;
			var prototype:PrototypeVO;
			if (_activeSplits)
			{
				len = _activeSplits.length;
				for (; i < len; ++i)
				{
					currentSplitTestPrototype = _activeSplits[i];
					key = currentSplitTestPrototype.getValue('targetKey');
					prototype = getPrototypeVO(currentSplitTestPrototype.getValue('targetClass'), key);
					prototype.removeOverridenValue(key);
				}
				_activeSplits.length = 0;
			}

			len = v.length;
			var value:*;
			for (i = 0; i < len; ++i)
			{
				//SPLIT
				currentSplitTestPrototype = getSplitTestPrototypeByName(v[i]);
				key = currentSplitTestPrototype.getValue('targetKey');
				value = currentSplitTestPrototype.getValue('valueStr');
				if (value == null || value == '')
					value = currentSplitTestPrototype.getValue('valueFloat');

				prototype = getPrototypeVO(currentSplitTestPrototype.getValue('targetClass'), key);
				prototype.overrideValue(currentSplitTestPrototype.getValue('targetColumn'), value);
				_activeSplits.push(currentSplitTestPrototype);
			}
			updateScalars();
		}

		private function getPrototypeVO( prototypeClass:String, key:String ):PrototypeVO
		{
			switch (prototypeClass)
			{
				case 'AchievementPrototype':
					if (_achievementPrototypes.hasOwnProperty(key))
						return _achievementPrototypes[key];

					break;
				case 'FilterAchievementPrototype':
					if (_filterAchievementPrototypes.hasOwnProperty(key))
						return _filterAchievementPrototypes[key];
					
					break;
				case 'AgentPrototype':
					if (_agentPrototypes.hasOwnProperty(key))
						return _agentPrototypes[key];

					break;
				case 'BlueprintPrototype':
					if (_blueprintPrototypes.hasOwnProperty(key))
						return _blueprintPrototypes[key];

					break;
				case 'BuffPrototype':
					if (_buffPrototypes.hasOwnProperty(key))
						return _buffPrototypes[key];

					break;
				case 'BuildingPrototype':
					if (_buildingPrototypes.hasOwnProperty(key))
						return _buildingPrototypes[key];

					break;
				case 'DebuffPrototype':
					if (_debuffPrototypes.hasOwnProperty(key))
						return _debuffPrototypes[key];
					
					break;
				case 'ConstantPrototype':
					if (_constantPrototypes.hasOwnProperty(key))
						return _constantPrototypes[key];

					break;
				case 'ContractPrototype':
					if (_contractPrototypes.hasOwnProperty(key))
						return _contractPrototypes[key];

					break;
				case 'CommendationRankPrototype':
					if (_commendationRankPrototypes.hasOwnProperty(key))
						return _commendationRankPrototypes[key];

					break;
				case 'FactionPrototype':
					if (_factionPrototypes.hasOwnProperty(key))
						return _factionPrototypes[key];

					break;
				case 'MissionPrototype':
					if (_missionPrototypes.hasOwnProperty(key))
						return _missionPrototypes[key];

					break;
				case 'NPCPrototype':
					if (_npcPrototypes.hasOwnProperty(key))
						return _npcPrototypes[key];

					break;
				case 'ObjectivesPrototype':
					if (_missionObjectivesPrototypes.hasOwnProperty(key))
						return _missionObjectivesPrototypes[key];

					break;
				case 'OfferItemPrototype':
					if (_offerItemPrototypes.hasOwnProperty(key))
						return _offerItemPrototypes[key];

					break;
				case 'OfferPrototype':
					if (_offerPrototypes.hasOwnProperty(key))
						return _offerPrototypes[key];

					break;
				case 'RacePrototype':
					if (_csRacePrototypes.hasOwnProperty(key))
						return _csRacePrototypes[key];

					break;
				case 'ResearchPrototype':
					if (_researchPrototypes.hasOwnProperty(key))
						return _researchPrototypes[key];

					break;
				case 'SectorNamePrototype':
					if (_sectorNamePrototypes.hasOwnProperty(key))
						return _sectorNamePrototypes[key];

					break;
				case 'SplitTestCohortPrototype':
					if (_splitTestCohortPrototypes.hasOwnProperty(key))
						return _splitTestCohortPrototypes[key];

					break;
				case 'SectorPrototype':
					if (_sectorPrototypes.hasOwnProperty(key))
						return _sectorPrototypes[key];

					break;
				case 'ShipPrototypes':
					for (var i:uint = 0; i < _vShipPrototypes.length; ++i)
					{
						if (_vShipPrototypes[i].name == key)
							return PrototypeVO(_vShipPrototypes[i]);
					}

					break;
				case 'SlotPrototype':
					if (_slotPrototypes.hasOwnProperty(key))
						return _slotPrototypes[key];

					break;
				case 'StatModPrototype':
					if (_statmodPrototypes.hasOwnProperty(key))
						return _statmodPrototypes[key];

					break;
				case 'StatPrototype':
					if (_statPrototypes.hasOwnProperty(key))
						return _statPrototypes[key];

					break;
				case 'StoreItemPrototype':
					if (_storeItemPrototypes.hasOwnProperty(key))
						return _storeItemPrototypes[key];

					break;
				case 'WeaponPrototype':
				case 'ActiveDefensePrototype':
				case 'ModulePrototype':
					if (_weaponPrototypes.hasOwnProperty(key))
						return _weaponPrototypes[key];

					break;
			}

			return null;
		}

		private function updateScalars():void
		{
			SHIP_REPAIR_TIME_SCALAR = getConstantPrototypeValueByName('shipRepairTimeScalar');
			SHIP_REPAIR_RESOURCE_COST_SCALAR = getConstantPrototypeValueByName('shipRepairResourceCostScalar');
			SHIP_BUILD_TIME_SCALAR = getConstantPrototypeValueByName('shipBuildTimeScalar');
			SHIP_BUILD_RESOURCE_COST_SCALAR = getConstantPrototypeValueByName('shipBuildResourceCostScalar');
			BUILDING_BUILD_TIME_SCALAR = getConstantPrototypeValueByName('buildingBuildTimeScalar');
			BUILDING_RESOURCE_COST_SCALAR = getConstantPrototypeValueByName('buildingResourceCostScalar');
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
	}
}


