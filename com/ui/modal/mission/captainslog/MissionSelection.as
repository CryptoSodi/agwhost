package com.ui.modal.mission.captainslog
{
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.component.accordian.AccordianComponent;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.button.ButtonLabelFormat;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class MissionSelection extends Sprite
	{
		private var _centerAccordian:AccordianComponent;
		private var _leftButton:BitmapButton;
		private var _min:int;
		private var _missionID:int;
		private var _max:int;
		private var _onChangeSignal:Signal;
		private var _rightButton:BitmapButton;

		private var _missionText:String = 'CodeString.CaptainsLog.Mission'; //MISSION [[Mission:Number]]

		public function init():void
		{
			_leftButton = UIFactory.getButton("BtnMissionHeader", 0, 0, 0, 0);

			var defaultText:String       = Localization.instance.getStringWithTokens(_missionText, {'[[Mission:Number]]':1});
			_centerAccordian = ObjectPool.get(AccordianComponent);
			_centerAccordian.init(619, 40);
			_centerAccordian.addGroup("Mission", defaultText);
			_centerAccordian.addSubItemToGroup("Mission", "1", defaultText, 0);
			_centerAccordian.addListener(onMissionSelected);
			_centerAccordian.x = _leftButton.width + 1;
			var format:ButtonLabelFormat = new ButtonLabelFormat({upBold:true, upColor:0xd1e5f7,
																	 roBold:true, roColor:0xd1e5f7,
																	 downBold:true, downColor:0x213745,
																	 selectedBold:true, selectedColor:0xd1e5f7});
			_centerAccordian.setGroupTitle("Mission", defaultText, format);

			_rightButton = UIFactory.getButton("BtnMissionHeader", 0, 0, _centerAccordian.x + _centerAccordian.width + _leftButton.width + 1, _leftButton.height);
			_rightButton.scaleX = _rightButton.scaleY = -1;

			_leftButton.addEventListener(MouseEvent.CLICK, onLeftClick, false, 0, true);
			_centerAccordian.addEventListener(MouseEvent.ROLL_OUT, onSelectionRollOut, false, 0, true);
			_rightButton.addEventListener(MouseEvent.CLICK, onRightClick, false, 0, true);
			_onChangeSignal = new Signal(int);

			addChild(_leftButton);
			addChild(_centerAccordian);
			addChild(_rightButton);
		}

		public function update():void
		{
			if (_missionID < _min)
				_missionID = _min;
			if (_missionID > _max)
				_missionID = _max;
			_centerAccordian.setGroupTitle("Mission", Localization.instance.getStringWithTokens(_missionText, {'[[Mission:Number]]':_missionID}));
		}

		public function setMinMax( min:int, max:int ):void
		{
			_min = min;
			_max = max;
			for (var i:int = 1; i <= 10; i++)
			{
				if (i <= _max)
					_centerAccordian.addSubItemToGroup("Mission", i + "", Localization.instance.getStringWithTokens(_missionText, {'[[Mission:Number]]':i}), 0);
				else
					_centerAccordian.removeSubItemFromGroup("Mission", i + "");
			}
		}

		public function addChangeListener( listener:Function ):void  { _onChangeSignal.add(listener); }
		public function removeChangeListener( listener:Function ):void  { _onChangeSignal.remove(listener); }

		private function onLeftClick( e:MouseEvent ):void
		{
			if (_missionID > _min)
			{
				_missionID--;
				update();
				_onChangeSignal.dispatch(_missionID);
			}
		}

		private function onRightClick( e:MouseEvent ):void
		{
			if (_missionID < _max)
			{
				_missionID++;
				update();
				_onChangeSignal.dispatch(_missionID);
			}
		}

		private function onMissionSelected( groupID:String, subItemID:String, data:* ):void
		{
			if (subItemID)
			{
				_missionID = int(subItemID);
				update();
				_centerAccordian.setSelected(null, null);
				_onChangeSignal.dispatch(_missionID);
			}
		}

		private function onSelectionRollOut( e:MouseEvent ):void  { _centerAccordian.setSelected(null, null); }

		public function get missionID():int  { return _missionID; }
		public function set missionID( v:int ):void  { _missionID = v; update(); }

		public function destroy():void
		{
			_leftButton.removeEventListener(MouseEvent.CLICK, onLeftClick);
			_centerAccordian.removeEventListener(MouseEvent.ROLL_OUT, onSelectionRollOut);
			_rightButton.removeEventListener(MouseEvent.CLICK, onRightClick);

			_leftButton = UIFactory.destroyButton(_leftButton);
			ObjectPool.give(_centerAccordian);
			_centerAccordian = null;
			_rightButton = UIFactory.destroyButton(_rightButton);

			_onChangeSignal.removeAll();
			_onChangeSignal = null;
		}
	}
}
