package com.ui.hud.shared.bridge
{
	import com.enum.ToastEnum;
	import com.event.MissionEvent;
	import com.event.ToastEvent;
	import com.model.mission.MissionInfoVO;
	import com.model.mission.MissionVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.starbase.IMissionPresenter;
	import com.ui.modal.mission.captainslog.CaptainsLogView;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.parade.core.IViewFactory;
	import org.shared.ObjectPool;

	public class MissionRiver extends Sprite
	{
		private var _initialized:Boolean;
		private var _missionButton:MissionRiverButton;
		private var _missionName:String;
		private var _presenter:IMissionPresenter;
		private var _viewFactory:IViewFactory;

		private var _completeImage:String = "complete.jpg";

		[PostConstruct]
		public function init():void
		{
			_initialized = false;
			_presenter && _presenter.highfive();
			presenter.addTransactionListener(onMissionUpdated);

			//create the mission button
			_missionButton = new MissionRiverButton();
			_missionButton.addEventListener(MouseEvent.CLICK, onMissionClicked, false, 0, true);
			addChild(_missionButton);

			onMissionUpdated(null);
		}

		private function onMissionClicked( e:MouseEvent ):void
		{
			if (!presenter.hudEnabled)
				return;
			var mission:MissionVO = presenter.currentMission;
			if (!mission.accepted)
			{
				presenter.dispatchMissionEvent(MissionEvent.MISSION_GREETING);
			} else if (mission.complete && !mission.rewardAccepted)
			{
				presenter.dispatchMissionEvent(MissionEvent.MISSION_VICTORY);
			} else
			{
				var log:CaptainsLogView = CaptainsLogView(_viewFactory.createView(CaptainsLogView));
				_viewFactory.notify(log);
			}
			e.stopPropagation();
		}

		/**
		 * Called when the server updates a mission.
		 * Updates the missionButton and if this is a new mission the button image is changed.
		 */
		private function onMissionUpdated( transaction:TransactionVO ):void
		{
			try{
			var mission:MissionVO = presenter.currentMission;
			if (_missionName != mission.name)
			{
				_missionButton.mission = mission;
				if (!mission.isFTE)
				{
					var info:MissionInfoVO = presenter.getMissionInfo(MissionEvent.MISSION_GREETING);
					var icon:String;
					if (mission.accepted && mission.complete && mission.rewardAccepted)
						icon = _completeImage;
					else
						icon = info.smallImage;

					presenter.loadIcon(icon, _missionButton.onImageLoaded);
					_missionName = mission.name;
					ObjectPool.give(info);
					if (!mission.accepted && _initialized)
					{
						//send out a toast to inform the player they have a new mission
						var toastEvent:ToastEvent = new ToastEvent();
						toastEvent.toastType = ToastEnum.MISSION_NEW;
						presenter.dispatch(toastEvent);
					}
					_initialized = visible = true;
				}
			} else
				_missionButton.mission = mission;
			}catch(ex){}
		}

		[Inject]
		public function set presenter( v:IMissionPresenter ):void  { _presenter = v; }
		public function get presenter():IMissionPresenter  { return IMissionPresenter(_presenter); }

		[Inject]
		public function set viewFactory( v:IViewFactory ):void  { _viewFactory = v; }

		public function destroy():void
		{
			presenter.removeTransactionListener(onMissionUpdated);

			_missionButton.removeEventListener(MouseEvent.CLICK, onMissionClicked);
			_missionButton.destroy();
			_missionButton = null;
			_presenter && _presenter.shun();
			_presenter = null;
			_viewFactory = null;
		}
	}
}


