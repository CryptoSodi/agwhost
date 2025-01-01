package com.ui.modal.mission.captainslog
{
	import com.enum.ToastEnum;
	import com.model.mission.MissionVO;
	import com.presenter.starbase.IMissionPresenter;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.accordian.AccordianButton;
	import com.ui.core.component.accordian.AccordianComponent;
	
	import flash.events.MouseEvent;
	
	import org.shared.ObjectPool;

	public class CaptainsLogView extends View
	{
		public static const STORY:String       = "Story";
		public static const DAILIES:String     = "Dailies";
		public static const RACIAL:String      = "Racial";
		public static const EVENTS:String      = "Events";
		public static const INSTANCED_MISSION:String      = "InstancedMissions";
		public static const INSTANCED_MISSION_1:String      = "InstancedMissions1";
		public static const INSTANCED_MISSION_2:String      = "InstancedMissions2";
		public static const INSTANCED_MISSION_3:String      = "InstancedMissions3";
		public static const INSTANCED_MISSION_4:String      = "InstancedMissions4";
		public static const INSTANCED_MISSION_5:String      = "InstancedMissions5";

		private var _accordian:AccordianComponent;
		private var _bg:DefaultWindowBG;
		private var _missionOverview:MissionOverview;

		private var _titleText:String          = 'CodeString.CaptainsLog.Title'; //CAPTAIN'S LOG
		private var _storyMissionsText:String  = 'CodeString.CaptainsLog.StoryMissions'; //STORY MISSIONS
		private var _trainingText:String       = 'CodeString.CaptainsLog.Training'; //TRAINING
		private var _chapter1Text:String       = 'CodeString.CaptainsLog.Chapter1'; //CHAPTER I
		private var _chapter2Text:String       = 'CodeString.CaptainsLog.Chapter2'; //CHAPTER II
		private var _chapter3Text:String       = 'CodeString.CaptainsLog.Chapter3'; //CHAPTER III
		private var _chapter4Text:String       = 'CodeString.CaptainsLog.Chapter4'; //CHAPTER IV
		private var _chapter5Text:String       = 'CodeString.CaptainsLog.Chapter5'; //CHAPTER V
		private var _chapter6Text:String       = 'CodeString.CaptainsLog.Chapter6'; //CHAPTER VI
		private var _chapter7Text:String       = 'CodeString.CaptainsLog.Chapter7'; //CHAPTER VII
		private var _chapter8Text:String       = 'CodeString.CaptainsLog.Chapter8'; //CHAPTER VIII
		private var _chapter9Text:String       = 'CodeString.CaptainsLog.Chapter9'; //CHAPTER IX
		private var _chapter10Text:String      = 'CodeString.CaptainsLog.Chapter10'; //CHAPTER X
		private var _dailyMissionsText:String  = 'CodeString.CaptainsLog.Dailies'; //DAILIES
		private var _racialMissionsText:String = 'CodeString.CaptainsLog.RacialMissions'; //RACIAL MISSIONS
		private var _EventMissionsText:String  = 'CodeString.CaptainsLog.Events'; //EVENTS
		private var _instancedMissionsText:String  = 'CodeString.CaptainsLog.InstancedMissions'; //INSTANCED MISSIONS
	
		
		[PostConstruct]
		override public function init():void
		{
			super.init();
			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(970, 534);
			_bg.addTitle(_titleText, 300);

			_accordian = ObjectPool.get(AccordianComponent);
			_accordian.init(244, 52);
			_accordian.addGroup(STORY, _storyMissionsText);
			_accordian.addSubItemToGroup(STORY, "0", _trainingText, 0);
			_accordian.addSubItemToGroup(STORY, "1", _chapter1Text, 0);
			_accordian.addSubItemToGroup(STORY, "2", _chapter2Text, 0);
			_accordian.addSubItemToGroup(STORY, "3", _chapter3Text, 0);
			_accordian.addSubItemToGroup(STORY, "4", _chapter4Text, 0);
			_accordian.addSubItemToGroup(STORY, "5", _chapter5Text, 0);
			_accordian.addSubItemToGroup(STORY, "6", _chapter6Text, 0);
			_accordian.addSubItemToGroup(STORY, "7", _chapter7Text, 0);
			_accordian.addSubItemToGroup(STORY, "8", _chapter8Text, 0);
			_accordian.addSubItemToGroup(STORY, "9", _chapter9Text, 0);
			_accordian.addSubItemToGroup(STORY, "10", _chapter10Text, 0);
			_accordian.addGroup(INSTANCED_MISSION, _instancedMissionsText);
			/*_accordian.addGroup(INSTANCED_MISSION_1, _instancedMissionsText);
			for (var i:int = 1; i <= 10; i++)
			{
				var num:Number = i;
				var str:String = num.toString();
				_accordian.addSubItemToGroup(INSTANCED_MISSION_1, str, "M" + str, 0);
			}
			_accordian.addGroup(INSTANCED_MISSION_2, _instancedMissionsText);
			for (var i:int = 11; i <= 20; i++)
			{
				var num:Number = i;
				var str:String = num.toString();
				_accordian.addSubItemToGroup(INSTANCED_MISSION_2, str, "M" + str, 0);
			}
			_accordian.addGroup(INSTANCED_MISSION_3, _instancedMissionsText);
			for (var i:int = 21; i <= 30; i++)
			{
				var num:Number = i;
				var str:String = num.toString();
				_accordian.addSubItemToGroup(INSTANCED_MISSION_3, str, "M" + str, 0);
			}
			_accordian.addGroup(INSTANCED_MISSION_4, _instancedMissionsText);
			for (var i:int = 31; i <= 40; i++)
			{
				var num:Number = i;
				var str:String = num.toString();
				_accordian.addSubItemToGroup(INSTANCED_MISSION_4, str, "M" + str, 0);
			}
			_accordian.addGroup(INSTANCED_MISSION_5, _instancedMissionsText);
			for (var i:int = 41; i <= 50; i++)
			{
				var num:Number = i;
				var str:String = num.toString();
				_accordian.addSubItemToGroup(INSTANCED_MISSION_5, str, "M" + str, 0);
			}*/
			_accordian.addGroup(DAILIES, _dailyMissionsText);
			_accordian.addGroup(RACIAL, _racialMissionsText);
			_accordian.addGroup(EVENTS, _EventMissionsText);
			
			_accordian.x = _bg.bg.x + 14;
			_accordian.y = _bg.bg.y + 5;
			_accordian.addListener(onAccordianSelected);

			_missionOverview = ObjectPool.get(MissionOverview);
			_missionOverview.init(presenter);
			_missionOverview.x = _accordian.x + 248;
			_missionOverview.y = _accordian.y;

			addChild(_bg);
			addChild(_accordian);
			addChild(_missionOverview);
			
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);
			addListener(_missionOverview.gotoMissionButton, MouseEvent.CLICK, onGotoMission);
			
			addListener(_missionOverview.gotoInstancedMissionButton, MouseEvent.CLICK, onStartInstanceMission);

			onAccordianSelected(STORY, null, null);
			addEffects();
			effectsIN();
		}

		private function onAccordianSelected( groupID:String, subItemID:String, data:* ):void
		{
			var mission:MissionVO;
			if (_missionOverview.selectedGroupID != groupID)
			{
				_missionOverview.setGroupID(groupID);
				switch (groupID)
				{
					case STORY:
						mission = presenter.currentMission;
						_accordian.setSelected(STORY, mission.chapter + '');
						subItemID = mission.chapter + '';
						for (var i:int = 0; i <= 10; i++)
						{
							_accordian.setSubItemState(STORY, i + '', (i < mission.chapter || i == mission.chapter && mission.complete && mission.rewardAccepted) ? AccordianButton.COMPLETED : ((mission.
													   chapter == i) ? AccordianButton.
													   NOT_COMPLETED : AccordianButton.LOCKED));
						}
						break;
					case DAILIES:
						break;
					case RACIAL:
						break;
					case EVENTS:
						break;
					case INSTANCED_MISSION:
						break;
					case CaptainsLogView.INSTANCED_MISSION_1:
						break;
						_accordian.setSelected(INSTANCED_MISSION_1, _missionOverview.currentInstancedMission);
						break;
					case CaptainsLogView.INSTANCED_MISSION_2:
						_accordian.setSelected(INSTANCED_MISSION_2, _missionOverview.currentInstancedMission);
						break;
					case CaptainsLogView.INSTANCED_MISSION_3:
						_accordian.setSelected(INSTANCED_MISSION_3, _missionOverview.currentInstancedMission);
						break;
					case CaptainsLogView.INSTANCED_MISSION_4:
						_accordian.setSelected(INSTANCED_MISSION_4, _missionOverview.currentInstancedMission);
						break;
					case CaptainsLogView.INSTANCED_MISSION_5:
						_accordian.setSelected(INSTANCED_MISSION_5, _missionOverview.currentInstancedMission);
						break;
				}
			}
			if (_missionOverview.selectedSubItemID != subItemID)
				_missionOverview.setSubItemID(subItemID);
		}
		
		private function onStartInstanceMission( e:MouseEvent ):void
		{
			var missionId:String = 'M' + _missionOverview.currentInstancedMission;
			presenter.startInstancedMission(missionId);
			destroy();
			//showToast(ToastEnum.WRONG, null, true);
		}
		
		
		private function onGotoMission( e:MouseEvent ):void
		{
			var result:String = presenter.moveToMissionTarget();
			if (result)
				showToast(ToastEnum.WRONG, null, result);
			else
				destroy();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IMissionPresenter ):void  { _presenter = value; }
		public function get presenter():IMissionPresenter  { return IMissionPresenter(_presenter); }

		override public function destroy():void
		{
			super.destroy();

			ObjectPool.give(_accordian);
			_accordian = null;
			ObjectPool.give(_bg);
			_bg = null;
			ObjectPool.give(_missionOverview);
			_missionOverview = null;
		}
	}
}
