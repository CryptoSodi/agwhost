package com.ui.modal.mission.captainslog
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.mission.MissionInfoVO;
	import com.presenter.starbase.IMissionPresenter;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.display.Sprite;
	import flash.text.TextFormatAlign;

	public class MissionOverviewObjectives extends Sprite
	{
		private var _bg:Sprite;
		private var _checkBoxes:Vector.<BitmapButton>;
		private var _labels:Vector.<Label>;

		private var _rewardsTitleText:String      = 'CodeString.MissionOverview.Rewards'; //REWARDS:
		private var _missionObjectivesText:String = 'CodeString.CaptainsLog.MissionObjectives'; //MISSION OBJECTIVES

		public function init():void
		{
			_bg = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED, PanelEnum.HEADER_NOTCHED, 700, 120, 30, 0, 0, _missionObjectivesText, LabelEnum.H2);
			_checkBoxes = new Vector.<BitmapButton>;
			_labels = new Vector.<Label>;

			addChild(_bg);
		}

		public function update( info:MissionInfoVO, presenter:IMissionPresenter ):void
		{
			clear();
			var checkbox:BitmapButton;
			var label:Label;
			var ypos:int = 38;
			while (info.hasObjectives)
			{
				checkbox = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 10, ypos);
				if (info.currentProgress == info.progressRequired)
					checkbox.selected = true;

				label = UIFactory.getLabel(LabelEnum.DEFAULT_OPEN_SANS, 640, 70, checkbox.x + checkbox.width + 8, ypos);
				label.textColor = 0xd1e5f7;
				label.multiline = true;
				label.align = TextFormatAlign.LEFT;
				label.text = info.objective;
				ypos += label.textHeight + 4;

				_checkBoxes.push(checkbox);
				_labels.push(label);
				addChild(checkbox);
				addChild(label);
			}
		}

		private function clear():void
		{
			for (var i:int = 0; i < _checkBoxes.length; i++)
			{
				removeChild(_checkBoxes[i]);
				UIFactory.destroyButton(_checkBoxes[i]);
			}
			_checkBoxes.length = 0;

			for (i = 0; i < _labels.length; i++)
			{
				removeChild(_labels[i]);
				UIFactory.destroyLabel(_labels[i]);
			}
			_labels.length = 0;
		}

		public function destroy():void
		{
			clear();
			while (numChildren > 0)
				removeChildAt(0);

			_bg = UIFactory.destroyPanel(_bg);
			_checkBoxes = null;
			_labels = null;
		}
	}
}
