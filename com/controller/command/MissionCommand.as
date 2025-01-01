package com.controller.command
{
	import com.enum.ToastEnum;
	import com.event.MissionEvent;
	import com.event.ToastEvent;
	import com.model.mission.MissionModel;
	import com.presenter.starbase.IMissionPresenter;
	import com.ui.modal.mission.DialogueView;

	import org.parade.core.IViewFactory;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class MissionCommand extends Command
	{
		[Inject]
		public var event:MissionEvent;
		[Inject]
		public var missionModel:MissionModel;
		[Inject]
		public var presenter:IMissionPresenter;
		[Inject]
		public var viewFactory:IViewFactory;

		override public function execute():void
		{
			switch (event.type)
			{
				case MissionEvent.SHOW_REWARDS:
					var toastEvent:ToastEvent     = new ToastEvent();
					toastEvent.data = presenter.getMissionInfo(MissionEvent.MISSION_VICTORY);
					toastEvent.toastType = ToastEnum.MISSION_REWARD;
					dispatch(toastEvent);
					presenter.acceptMissionReward();
					break;
				default:
					var dialogueView:DialogueView = DialogueView(viewFactory.createView(DialogueView));
					dialogueView.info = presenter.getMissionInfo(event.type);
					dialogueView.state = event.type;
					viewFactory.notify(dialogueView);
					break;
			}
		}
	}
}
