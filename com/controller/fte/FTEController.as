package com.controller.fte
{
	import com.Application;
	import com.controller.ServerController;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.FTEEvent;
	import com.event.SectorEvent;
	import com.model.mission.MissionModel;
	import com.model.mission.MissionVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.outgoing.proxy.ProxyTutorialStepCompletedMessage;
	import com.service.server.outgoing.starbase.StarbaseSkipTrainingRequest;
	import com.ui.core.View;
	import com.ui.core.component.contextmenu.ContextMenu;
	
	import flash.events.Event;

	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	import org.parade.core.ViewController;
	import org.parade.enum.PlatformEnum;
	import org.parade.enum.ViewEnum;
	
	import com.service.ExternalInterfaceAPI;

	public class FTEController
	{
		private var _complete:Boolean                  = false;
		private var _stepVO:FTEStepVO                  = new FTEStepVO();
		private var _eventDispatcher:IEventDispatcher;
		private var _missionModel:MissionModel;
		private var _progressStepOnStateChange:Boolean = false;
		private var _prototypeModel:PrototypeModel;
		private var _ready:Boolean                     = false;
		private var _step:int                          = 0;
		private var _timeDelay:Timer;
		private var _viewController:ViewController;

		public var closeContext:ContextMenu;

		public var serverController:ServerController;

		[PostConstruct]
		public function init():void
		{
			_timeDelay = new Timer(0, 1);
			_timeDelay.addEventListener(TimerEvent.TIMER_COMPLETE, dispatch, false, 0, true);
		}

		public function skipFTE():void
		{
			if (serverController)
			{
				ExternalInterfaceAPI.logConsole("Skip Tutorial");
				var msg:ProxyTutorialStepCompletedMessage = ProxyTutorialStepCompletedMessage(
					serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_TUTORIAL_STEP_COMPLETED));
				msg.stepId = 411060;
				msg.kabamNaid = CurrentUser.naid;
				serverController.send(msg);

				var skipTrainingRequest:StarbaseSkipTrainingRequest = StarbaseSkipTrainingRequest(serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_SKIP_TRAINING_MESSAGE));
				serverController.send(skipTrainingRequest);
				
				var event:Event;
				event = new SectorEvent(SectorEvent.CHANGE_SECTOR, null);
				_eventDispatcher.dispatchEvent(event);
			}
		}

		public function nextStep():void
		{
			if (!_complete)
			{
				if (serverController && _stepVO.stepId != 0)
				{
					var msg:ProxyTutorialStepCompletedMessage = ProxyTutorialStepCompletedMessage(
						serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_TUTORIAL_STEP_COMPLETED));
					msg.stepId = _stepVO.stepId;
					msg.kabamNaid = CurrentUser.naid;
					serverController.send(msg);
				}

				_progressStepOnStateChange = false;
				_step++;

				if (_timeDelay)
					_timeDelay.reset();

				if (closeContext)
				{
					closeContext.destroy();
					closeContext = null;
				}

				if (!_complete && _step >= _stepVO.totalSteps)
				{
					_complete = true;
					showNextStep();
					cleanup();
				} else
				{
					_stepVO.updateStep(_step);
					showNextStep();
				}
			}
		}

		public function checkMissionRequired( mission:MissionVO ):void
		{
			var completedCurrentStep:Boolean = false;
			if (!_stepVO || !_stepVO.step)
				return;
			if (_stepVO.missionName.length > 0)
			{
				var names:Array = _stepVO.missionName.split(',');
				var index:int   = names.indexOf(mission.name);
				if (index > -1)
					completedCurrentStep = true;
			}
			if (completedCurrentStep)
				nextStep();
			else if (_stepVO && !_stepVO.anchor)
			{
				//determine which step the player is on based on the mission
				var missionName:String;
				var steps:Vector.<IPrototype> = _prototypeModel.getFTEStepsByPlatform(PlatformEnum.BROWSER); //hardcoding this to browser for now
				for (var i:int = 0; i < steps.length; i++)
				{
					missionName = steps[i].getValue("missionName");
					if (missionName.length > 0)
					{
						names = missionName.split(',');
						if (names.indexOf(mission.name) > -1)
						{
							if (_stepVO.currentStep < i + 1)
							{
								//remove any old view we may be looking at
								var c:Class;
								var newViewClass:Class = (steps[i + 1].getValue('uiID') != "") ? Class(getDefinitionByName(steps[i + 1].getValue('uiID'))) : null;
								var view:View;
								if (_stepVO.currentStep != 0)
								{
									//go back through the steps to find the last view
									for (var j:int = i - 1; j >= 0; j--)
									{
										if (steps[j].getValue('uiID') != "")
										{
											c = Class(getDefinitionByName(steps[j].getValue('uiID')));
											if (c != newViewClass)
											{
												view = View(_viewController.getView(c));
												if (view && view.type != ViewEnum.UI)
												{
													if (view.parent)
														view.destroy();
													else
														_viewController.removeFromQueue(_stepVO.viewClass);
												}
											}
											break;
										}
									}
								}

								//start on the step right after
								_step = i + 1;
								_stepVO.updateStep(_step);
								showNextStep();
							}
							break;
						}
					}
				}
			}
		}

		private function showNextStep():void
		{
			if (_complete || _stepVO.timeDelay <= 0)
				dispatch();
			else
			{
				_timeDelay.delay = _stepVO.timeDelay;
				_timeDelay.start();
			}
		}

		public function inFTE():Boolean  { return _missionModel.currentMission.isFTE; }

		private function checkStart():void
		{
			if (_ready)
			{
				//look at which mission the player is on to determine if they are in the fte
				var mission:MissionVO = _missionModel.currentMission;
				if (false)
				{
					//setup the steps
					var steps:Vector.<IPrototype> = _prototypeModel.getFTEStepsByPlatform(PlatformEnum.BROWSER); //hardcoding this to browser for now
					_stepVO = new FTEStepVO();
					_stepVO.init(steps);
					_stepVO.updateStep(_step);

					// Block Flash's core accessibility (tab to select) feature
					Application.STAGE.tabChildren = false;

					checkMissionRequired(mission);
					if (_stepVO.currentStep == 0)
						showNextStep();
				} else
				{
					//if we can't find a match to the player's current mission, then the player must be done with the fte
					_complete = true;
					cleanup();
				}
			}
		}

		private function dispatch( e:TimerEvent = null ):void
		{
			var event:FTEEvent;
			if (_complete)
				event = new FTEEvent(FTEEvent.FTE_COMPLETE, _stepVO);
			else
				event = new FTEEvent(FTEEvent.FTE_STEP, _stepVO);
			_eventDispatcher.dispatchEvent(event);
		}

		public function get complete():Boolean  { return _complete; }
		public function get progressStepOnStateChange():Boolean  { return _progressStepOnStateChange; }
		public function set progressStepOnStateChange( v:Boolean ):void  { _progressStepOnStateChange = v; }
		public function get step():int  { return _step; }

		[Inject]
		public function set eventDispatcher( v:IEventDispatcher ):void  { _eventDispatcher = v; }
		[Inject]
		public function set missionModel( v:MissionModel ):void  { _missionModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set viewController( v:ViewController ):void  { _viewController = v; }

		public function set ready( v:Boolean ):void
		{
			if (!_ready && v)
			{
				_ready = true;
				checkStart();
			}
		}
		public function get running():Boolean  { return (_ready && !_complete) || (_missionModel && _missionModel.currentMission && _missionModel.currentMission.isFTE); }
		public function get startInSector():Boolean
		{
			if (_complete)
				return false;

			var mission:MissionVO = _missionModel.currentMission;
			switch ("FTE_IGA_Starting_Mission")
			{
				case "FTE_IGA_Intro":
				case "FTE_SOV_Intro":
				case "FTE_TYR_Intro":

				case "FTE_IGA_Starting_Mission":
				case "FTE_SOV_Starting_Mission":
				case "FTE_TYR_Starting_Mission":

				case "FTE_IGA_Dock":
				case "FTE_SOV_Dock":
				case "FTE_TYR_Dock":

				case "FTE_TYR_Upgrade_Shipyard_Begin":
				case "FTE_IGA_Upgrade_Shipyard_Begin":
				case "FTE_SOV_Upgrade_Shipyard_Begin":

				case "FTE_TYR_Reward":
				case "FTE_IGA_Reward":
				case "FTE_SOV_Reward":

					return true;
					break;
			}
			return false;
		}

		public function terminate():void
		{
			_complete = true;
			dispatch();
		}

		private function cleanup():void
		{
			_eventDispatcher = null;
			_missionModel = null;
			_prototypeModel = null;
			_stepVO = null;
			if (_timeDelay.running)
				_timeDelay.stop();
			_timeDelay = null;
			_viewController = null;

			// Turn accessibility back on
			Application.STAGE.tabChildren = true;
		}
	}
}


