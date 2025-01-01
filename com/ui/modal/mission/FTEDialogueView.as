package com.ui.modal.mission
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.effects.EffectFactory;
	import com.ui.hud.battle.BattleShipSelectionView;
	import com.ui.hud.battle.BattleUserView;
	import com.ui.hud.shared.ChatView;
	import com.ui.hud.shared.IconDrawerView;
	import com.ui.hud.shared.MiniMapView;
	import com.ui.hud.shared.PlayerView;
	import com.ui.hud.shared.bridge.BridgeView;
	import com.ui.hud.shared.command.CommandView;
	import com.ui.hud.shared.command.FleetCommandView;
	import com.ui.hud.shared.engineering.EngineeringView;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;

	import org.parade.core.ViewEvent;
	import org.parade.util.DeviceMetrics;
	
	
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.ui.UIFactory;
	
	import com.service.ExternalInterfaceAPI;
	import com.event.SectorEvent;
	import flash.events.Event;

	public class FTEDialogueView extends DialogueView
	{
		protected var _arrow:MovieClip;
		// This exists in case we try to hide the next button before init gets called
		protected var _nextBtnVisible:Boolean = false;
		protected var _startY:Number;
		
		private var _skipBtn:BitmapButton;
		private var _skipText:String       = 'CodeString.FTE.SkipTutorialBtn'; //SkipTutorial

		[PostConstruct]
		override public function init():void
		{
			super.init();

			var arrowClass:Class = Class(getDefinitionByName('ArrowMC'));
			_arrow = MovieClip(new arrowClass());
			_arrow.visible = _nextBtnVisible && _effects.isDoneIn;
			_arrow.rotation = 90;
			_arrow.x = _nextBtn.x + _nextBtn.width * .5;
			_arrow.y = _nextBtn.y - 1;

			nextButtonEnabled = _nextBtnVisible;
			_startY = DeviceMetrics.HEIGHT_PIXELS - height - 5;

			_npcDialogue.y = 87;
			_npcTitle.x = LEFT_MARGIN;
			_npcTitle.y = 56;

			_progressBar.y = 160;
			_progressLabel.y = _progressBar.y - 1;

			addChild(_arrow);
			
			
			_skipBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 140, 40, 1100, 110, _skipText, LabelEnum.H1);
			addListener(_skipBtn, MouseEvent.CLICK, onSkipTutorial);
			addChild(_skipBtn);
			
			if(presenter && presenter.fteStep >= 64 || presenter.fteStep<=14)
				skipTutorialEnabled(false);
		}
		
		protected function onSkipTutorial( e:MouseEvent = null ):void
		{
			//presenter.showSector();
			presenter.fteSkip();
		}

		override protected function onIconLoaded( asset:BitmapData ):void
		{
			super.onIconLoaded(asset);
			if (_npcIcon)
			{
				_npcIcon.x = -33 + (264 - asset.width) / 2;
				_npcIcon.y = -50 + (241 - asset.height) / 2;
			}
		}

		override protected function onNextBtnClicked( e:MouseEvent = null ):void
		{
			if (e)
				e.stopImmediatePropagation();
			if (!_nextBtn.visible)
				return;
			_nextBtn.enabled = false;
			_arrow.visible = false;
			presenter.fteNextStep();
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.CENTER, PositionEnum.BOTTOM, onResize));
			_effects.addEffect(EffectFactory.alphaEffect(0, 1, 0, .5, .5));
			_effects.addEffect(EffectFactory.stageLetterboxEffect(.5, .5, false, 130, onNextBtnClicked));
			hideViews();
			unhideViews();
		}

		override public function hideViews():void
		{
			if (presenter)
			{
				var event:ViewEvent = new ViewEvent(ViewEvent.HIDE_VIEWS);
				if (presenter.fteStep < 8)
					event.targetClass = [BattleUserView, BridgeView, ChatView, IconDrawerView, PlayerView, EngineeringView, MiniMapView, CommandView, FleetCommandView, BattleShipSelectionView];
				if (presenter.fteStep < 22)
					event.targetClass = [BridgeView, ChatView, IconDrawerView, PlayerView, EngineeringView, MiniMapView, CommandView, FleetCommandView, BattleShipSelectionView];
				else if (presenter.fteStep <= 31)
					event.targetClass = [BridgeView, ChatView, IconDrawerView, EngineeringView, MiniMapView, CommandView, FleetCommandView, BattleShipSelectionView];
				else if (presenter.fteStep <= 61)
					event.targetClass = [BridgeView, ChatView, IconDrawerView, MiniMapView, CommandView, BattleShipSelectionView];
				else
					event.targetClass = [BridgeView, ChatView, IconDrawerView, MiniMapView, BattleShipSelectionView];
				presenter.dispatch(event);
			}
		}

		override public function unhideViews():void
		{
			if (presenter && presenter.fteStep > 8)
			{
				var event:ViewEvent = new ViewEvent(ViewEvent.UNHIDE_VIEWS);
				if (presenter.fteStep <= 9)
					event.targetClass = [MiniMapView, BattleUserView, BattleShipSelectionView, PlayerView, ChatView];
				else if ((presenter.fteStep > 9 && presenter.fteStep <= 21) || presenter.fteStep == 67)
					event.targetClass = [];
				else if (presenter.fteStep <= 22)
					event.targetClass = [PlayerView];
				else if (presenter.fteStep > 31 && presenter.fteStep <= 60)
					event.targetClass = [PlayerView, EngineeringView];
				else if (presenter.fteStep > 60 && presenter.fteStep < 62)
					event.targetClass = [PlayerView, EngineeringView, CommandView];
				else if (presenter.fteStep > 61 && presenter.fteStep < 65)
					event.targetClass = [PlayerView, EngineeringView, CommandView, BridgeView];
				
				if(presenter.fteStep >= 64 || presenter.fteStep<=14)
					skipTutorialEnabled(false);
				else
					skipTutorialEnabled(true);
				
				ExternalInterfaceAPI.logConsole("Tutorial Step " + presenter.fteStep.toString());
				
				presenter.dispatch(event);
			}
		}
		
		public function skipTutorialEnabled( v:Boolean ):void
		{
			if (_skipBtn)
			{
				removeListener(_skipBtn, MouseEvent.CLICK, onSkipTutorial);
				_skipBtn.visible = v;
				_skipBtn.enabled = v;
				
				if (v)
					addListener(_skipBtn, MouseEvent.CLICK, onSkipTutorial);
			}
		}
		public function set nextButtonEnabled( v:Boolean ):void
		{
			if (_nextBtn)
			{
				removeListener(this, MouseEvent.CLICK, onNextBtnClicked);
				_nextBtn.visible = v;
				_nextBtnLabel.visible = v;

				if (v)
				{
					addListener(this, MouseEvent.CLICK, onNextBtnClicked);
					_nextBtn.enabled = true;
					_arrow.visible = true;
				} else
					_arrow.visible = false;
			}
			_nextBtnVisible = v;
		}

		override protected function effectsDoneIn():void
		{
			super.effectsDoneIn();
			if (_arrow)
				_arrow.visible = _nextBtnVisible;
		}

		override protected function effectsDoneOut():void
		{
			super.effectsDoneOut();
			if (_arrow)
				_arrow.visible = _nextBtnVisible;
		}

		override protected function effectsIN():void
		{
			super.effectsIN();
			if (_arrow)
				_arrow.visible = false;
		}

		override protected function effectsOUT():void
		{
			super.effectsOUT();
			if (_arrow)
				_arrow.visible = false;
		}

		override protected function get iconWidth():Number  { return 1000; }
		override protected function get iconHeight():Number  { return 1000; }
		public function get nextBtn():BitmapButton  { return _nextBtn; }

		override public function destroy():void
		{
			super.destroy();
			_arrow = null;
			
			_skipBtn.destroy();
			_skipBtn = null;
			
		}
	}
}

