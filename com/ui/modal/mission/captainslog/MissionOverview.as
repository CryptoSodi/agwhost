package com.ui.modal.mission.captainslog
{
	import com.Application;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.event.MissionEvent;
	import com.model.mission.MissionInfoVO;
	import com.model.mission.MissionVO;
	import com.presenter.starbase.IMissionPresenter;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	
	import org.shared.ObjectPool;

	public class MissionOverview extends Sprite
	{
		private var _maxInstancedMission:Number = 10000000;
		private var _minInstancedMission:Number = 1;
		
		private var _comingSoon:Sprite;
		private var _description:MissionOverviewDescription;
		private var _gotoMissionButton:BitmapButton;
		private var _gotoInstancedMissionButton:BitmapButton;
		private var _missionSelection:MissionSelection;
		private var _objectives:MissionOverviewObjectives;
		private var _presenter:IMissionPresenter;
		private var _reward:MissionOverviewReward;
		private var _selectedGroupID:String;
		private var _selectedSubItemID:String;
		
		private var _inputDescription:Label;
		private var _inputWarning:Label;
		private var _inputText:Label;
		private var _inputBG:Sprite;

		private var _goToMissionText:String = 'CodeString.CaptainsLog.GoToMission'; //GO TO MISSION
		private var _goToInstancedMissionText:String = 'CodeString.CaptainsLog.GoToInstancedMission'; //GO TO INSTANCED MISSION
		private var _writeInstancedMissionNumberText:String = 'CodeString.CaptainsLog.WriteInstancedMissionNumberText'; //WRITE INSTANCED MISSION NUMBER
		private var _warningInstancedMissionOnText:String = 'CodeString.CaptainsLog.WarningInstancedMissionOnText'; //WRITE INSTANCED MISSION NUMBER
		private var _comingSoonText:String  = 'CodeString.CaptainsLog.ComingSoon'; //COMING SOON!
		
		static function myRandom(minVal, maxVal):Number {
			return minVal + Math.floor(Math.random( ) * (maxVal + 1 - minVal));
		}
		
		static public var lastInstancedMission:String = String(myRandom(9000, 9800));
		public var currentInstancedMission:String = lastInstancedMission;

		public function init( presenter:IMissionPresenter ):void
		{
			_presenter = presenter;

			_missionSelection = ObjectPool.get(MissionSelection);
			_missionSelection.init();
			_missionSelection.addChangeListener(onMissionSelectionChanged);

			_comingSoon = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED, PanelEnum.HEADER_NOTCHED, 700, 490, 30, 0, 0, _comingSoonText, LabelEnum.H2);
			_comingSoon.visible = false;

			_objectives = ObjectPool.get(MissionOverviewObjectives);
			_objectives.init();
			_objectives.y = _missionSelection.y + 42;

			_description = ObjectPool.get(MissionOverviewDescription);
			addChild(_description);
			_description.init();
			_description.y = _objectives.y + _objectives.height + 4;

			_reward = ObjectPool.get(MissionOverviewReward);
			_reward.init();
			_reward.y = _description.y + 174;

			_gotoMissionButton = UIFactory.getButton(ButtonEnum.BLUE_A, 240, 40, 465, _reward.y + _reward.height + 10, _goToMissionText);
			_gotoInstancedMissionButton = UIFactory.getButton(ButtonEnum.BLUE_A, 240, 40, 465, _reward.y + _reward.height + 10, _goToInstancedMissionText);

			_inputDescription = new Label(22, 0xffffff,400,25);
			_inputDescription.x = 110;
			_inputDescription.y = 120;
			_inputDescription.text = _writeInstancedMissionNumberText;
			_inputDescription.align = TextFormatAlign.LEFT;
			_inputDescription.constrictTextToSize = false;
			
			_inputWarning = new Label(22, 0xff0000,400,25);
			_inputWarning.x = 110;
			_inputWarning.y = 220;
			_inputWarning.text = _warningInstancedMissionOnText;
			_inputWarning.align = TextFormatAlign.LEFT;
			_inputWarning.constrictTextToSize = false;
			
			var frameBGClass:Class = Class(getDefinitionByName(('TextInputFieldMC')));
			_inputBG = Sprite(new frameBGClass());
			_inputBG.x = _inputDescription.x + 30;
			_inputBG.y = _inputDescription.y + 30;
			
			_inputText = new Label(20, 0xffffff, 300, 25);
			_inputText.width = _inputBG.width - 2;
			_inputText.x = _inputBG.x + 15;
			_inputText.y = _inputBG.y + 2;
			_inputText.constrictTextToSize = false;
			_inputText.letterSpacing = .8;
			_inputText.align = TextFormatAlign.LEFT;
			_inputText.addLabelColor(0xbdfefd, 0x000000);
			_inputText.maxChars = 4;
			_inputText.text = currentInstancedMission;
			_inputText.allowInput = true;
			_inputText.clearOnFocusIn = false;
			_inputText.restrict = "0123456789";
			_inputText.addEventListener(Event.CHANGE, onTextChanged, false, 0, true);
			
			
			
			addChild(_comingSoon);
			addChild(_gotoMissionButton);
			addChild(_gotoInstancedMissionButton);
			addChild(_objectives);
			addChild(_reward);
			addChild(_missionSelection);
			
			addChild(_inputWarning);
			addChild(_inputDescription);
			addChild(_inputBG);
			addChild(_inputText);
			
			
			_presenter.onAddAllScoresUpdatedListener(onAllScoresUpdated);
		}
		
		private function onTextChanged( e:Event ):void
		{
			var currentTextLen:uint = e.currentTarget.length;
			
			currentInstancedMission = _inputText.text;
			lastInstancedMission = currentInstancedMission;
			var num:Number = Number(currentInstancedMission);
			
			if (/*currentTextLen != 0 &&*/ num >= _minInstancedMission && num <= _maxInstancedMission)
			{
				_gotoInstancedMissionButton.enabled = true;
			} 
			else
			{
				_gotoInstancedMissionButton.enabled = false;
			}
		}
		public function textFocus( e:MouseEvent ):void
		{
			Application.STAGE.focus = _inputText;
			_inputText.setSelection(_inputText.length, _inputText.length);
		}
		public function setGroupID( groupID:String ):void
		{
			_selectedGroupID = groupID;
			switch (groupID)
			{
				case CaptainsLogView.STORY:
					_comingSoon.visible = false;
					_missionSelection.visible = true;
					_description.visible = true;
					_objectives.visible = true;
					_reward.visible = true;
					_inputBG.visible = false;
					_inputText.visible = false;
					_inputDescription.visible = false;
					_inputWarning.visible = false;
					
					_gotoMissionButton.visible = true;
					_gotoInstancedMissionButton.visible = false;
					break;
				case CaptainsLogView.DAILIES:
				case CaptainsLogView.EVENTS:
				case CaptainsLogView.RACIAL:
					_comingSoon.visible = true;
					_missionSelection.visible = false;
					_description.visible = false;
					_objectives.visible = false;
					_reward.visible = false;
					_inputBG.visible = false;
					_inputText.visible = false;
					_inputDescription.visible = false;
					_inputWarning.visible = false;
					
					_gotoMissionButton.visible = false;
					_gotoInstancedMissionButton.visible = false;
					break;
				case CaptainsLogView.INSTANCED_MISSION:
					_comingSoon.visible = true;
					_missionSelection.visible = false;
					_description.visible = false;
					_objectives.visible = false;
					_reward.visible = false;
					_inputBG.visible = true;
					_inputText.visible = true;
					_inputDescription.visible = true;
					_inputWarning.visible = false;
					
					_gotoMissionButton.visible = false;
					_gotoInstancedMissionButton.visible = true;
					
					if(_presenter.isInstancedMissionOn())
					{
						_gotoInstancedMissionButton.visible = false;
						_inputWarning.visible = true;
					}
					
					Application.STAGE.focus = _inputText;
					_inputText.setSelection(_inputText.length, _inputText.length);
					
					_presenter.requestAllScores();
					
					break;
				case CaptainsLogView.INSTANCED_MISSION_1:
				case CaptainsLogView.INSTANCED_MISSION_2:
				case CaptainsLogView.INSTANCED_MISSION_3:
				case CaptainsLogView.INSTANCED_MISSION_4:
				case CaptainsLogView.INSTANCED_MISSION_5:
					_comingSoon.visible = true;
					_missionSelection.visible = false;
					_description.visible = false;
					_objectives.visible = false;
					_reward.visible = false;
					_inputBG.visible = false;
					_inputText.visible = false;
					_inputDescription.visible = false;
					
					_gotoMissionButton.visible = false;
					_gotoInstancedMissionButton.visible = true;
					break;
			}
		}

		public function setSubItemID( subItemID:String ):void
		{
			if (subItemID != null)
			{
				_selectedSubItemID = subItemID;
				switch (_selectedGroupID)
				{
					case CaptainsLogView.DAILIES:
						break;
					case CaptainsLogView.EVENTS:
						break;
					case CaptainsLogView.RACIAL:
						break;
					case CaptainsLogView.STORY:
						var maxMission:int = _presenter.currentMission.chapter == int(_selectedSubItemID) ? _presenter.currentMission.mission : 6;
						_missionSelection.setMinMax(1, maxMission);
						_missionSelection.missionID = _presenter.currentMission.chapter == int(_selectedSubItemID) ? _presenter.currentMission.mission : 1;
						break;
					case CaptainsLogView.INSTANCED_MISSION:
						break;
					case CaptainsLogView.INSTANCED_MISSION_1:
					case CaptainsLogView.INSTANCED_MISSION_2:
					case CaptainsLogView.INSTANCED_MISSION_3:
					case CaptainsLogView.INSTANCED_MISSION_4:
					case CaptainsLogView.INSTANCED_MISSION_5:
						currentInstancedMission = _selectedSubItemID;
						break;
				}
				update();
			}
		}

		private function update():void
		{
			var mission:MissionVO;
			switch (_selectedGroupID)
			{
				case CaptainsLogView.DAILIES:
					break;
				case CaptainsLogView.EVENTS:
					break;
				case CaptainsLogView.RACIAL:
					break;
				case CaptainsLogView.STORY:
					var currentMission:MissionVO  = _presenter.currentMission;
					var complete:Boolean;
					mission = _presenter.getStoryMission(int(_selectedSubItemID), _missionSelection.missionID);
					var greeting:MissionInfoVO    = _presenter.getMissionInfo(MissionEvent.MISSION_GREETING, int(_selectedSubItemID), _missionSelection.missionID, true);
					var situational:MissionInfoVO = (mission.accepted || mission.chapter < _presenter.currentMission.chapter) ?
						_presenter.getMissionInfo(MissionEvent.MISSION_SITUATIONAL, int(_selectedSubItemID), _missionSelection.missionID, true) : null;
					var victory:MissionInfoVO     = _presenter.getMissionInfo(MissionEvent.MISSION_VICTORY, int(_selectedSubItemID), _missionSelection.missionID, true);
					_reward.update(greeting);


					if ((mission.chapter < currentMission.chapter) || (mission.chapter == currentMission.chapter && ((mission.mission < currentMission.mission) || (mission.mission == currentMission.mission &&
						currentMission.complete))))
					{
						_objectives.update(victory, _presenter);
						complete = true;
						if(victory.hasSound)
							_presenter.playSound(victory.sound,0.75);
					} else
					{
						_objectives.update(greeting, _presenter);
						if(greeting.hasSound)
							_presenter.playSound(greeting.sound,0.75);
					}

					_description.update(complete, greeting, situational, victory, _presenter.loadIcon);
					//should we show the goto mission button?
					_gotoMissionButton.visible = currentMission.chapter == int(_selectedSubItemID) && currentMission.mission == _missionSelection.missionID && !currentMission.rewardAccepted;
					
					break;
			}
		}

		private function onMissionSelectionChanged( mission:int ):void
		{
			update();
		}
		private function onAllScoresUpdated( scores:Dictionary, missionScore:Dictionary ):void
		{
			//TODO
		}

		public function get gotoMissionButton():BitmapButton  { return _gotoMissionButton; }
		public function get gotoInstancedMissionButton():BitmapButton  { return _gotoInstancedMissionButton; }
		public function get selectedGroupID():String  { return _selectedGroupID; }
		public function get selectedSubItemID():String  { return _selectedSubItemID; }
		
		public function destroy():void
		{
			_presenter.onRemoveAllScoresUpdatedListener(onAllScoresUpdated);
			
			_selectedGroupID = _selectedSubItemID = null;
			_presenter = null;
			while (numChildren > 0)
				removeChildAt(0);

			ObjectPool.give(_description);
			_description = null;
			ObjectPool.give(_missionSelection);
			_missionSelection = null;
			ObjectPool.give(_objectives);
			_objectives = null;
			ObjectPool.give(_reward);
			_reward = null;
			
			_inputBG = null;
			
			_inputText.removeEventListener(Event.CHANGE, onTextChanged);
			_inputText.destroy();
			_inputText = null;
			
			_inputDescription.destroy();
			_inputDescription = null;
			
			_gotoMissionButton = UIFactory.destroyButton(_gotoMissionButton);
			_gotoInstancedMissionButton = UIFactory.destroyButton(_gotoInstancedMissionButton);
			
			
		}
	}
}
