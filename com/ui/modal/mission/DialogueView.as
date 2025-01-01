package com.ui.modal.mission
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.enum.ui.PanelEnum;
	import com.event.MissionEvent;
	import com.model.mission.MissionInfoVO;
	import com.presenter.starbase.IMissionPresenter;
	import com.ui.UIFactory;
	import com.ui.core.View;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.effects.EffectFactory;
	import com.ui.hud.battle.BattleShipSelectionView;
	import com.ui.hud.battle.BattleUserView;
	import com.ui.hud.shared.ChatView;
	import com.ui.hud.shared.IconDrawerView;
	import com.ui.hud.shared.MiniMapView;
	import com.ui.hud.shared.PlayerView;
	import com.ui.hud.shared.bridge.BridgeView;
	import com.ui.hud.shared.command.CommandView;
	import com.ui.hud.shared.engineering.EngineeringView;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	import org.parade.core.ViewEvent;
	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;
	import com.service.ExternalInterfaceAPI;

	public class DialogueView extends View
	{
		protected static const BAR:Bitmap = new Bitmap(new BitmapData(332, 17, true, 0xffd2bf3d));
		protected const LEFT_MARGIN:int   = 180;

		protected var _missionInfo:MissionInfoVO;
		protected var _nextBtn:BitmapButton;
		protected var _nextBtnLabel:Label;
		protected var _npcDialogue:Label;
		protected var _npcIcon:ImageComponent;
		protected var _npcTitle:Label;
		protected var _progressBar:ProgressBar;
		protected var _progressLabel:Label;
		protected var _state:String;
		protected var _soundToPlay:String;

		private var _percentText:String   = 'CodeString.Shared.Percent'; // [[Number.PercentValue]]%
		private var _completeText:String  = 'CodeString.Dialogue.Complete'; // COMPLETE
		private var _nextText:String      = 'CodeString.Dialogue.Next'; // NEXT

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_nextBtn = ButtonFactory.getBitmapButton('IconClickToContinueBMD', 0, 0, '', 0xffffff, 'IconClickToContinueBMD', 'IconClickToContinueBMD');
			_nextBtn.x = LEFT_MARGIN + 555;
			_nextBtn.y = 102;
			addListener(this, MouseEvent.CLICK, onNextBtnClicked);

			_nextBtnLabel = new Label(14, 0xffffff, 120, 30, false, 1);
			_nextBtnLabel.x = _nextBtn.x + _nextBtn.width;
			_nextBtnLabel.y = 115;
			_nextBtnLabel.constrictTextToSize = false;
			_nextBtnLabel.text = 'Click to Continue';
			_nextBtnLabel.textColor = 0x00CC33;
			_nextBtnLabel.align = TextFormatAlign.LEFT;

			_npcDialogue = new Label(13, 0xffffff, 550, 90, false, 1);
			_npcDialogue.x = LEFT_MARGIN;
			_npcDialogue.y = 72;
			_npcDialogue.align = TextFormatAlign.LEFT;
			_npcDialogue.multiline = true;
			_npcDialogue.useLocalization = false;
			_npcDialogue.constrictTextToSize = false;
			_npcDialogue.leading = -1;
			_npcDialogue.text = _missionInfo.dialog;

			_npcIcon = new ImageComponent();
			_npcIcon.init(iconWidth, iconHeight);
			_npcIcon.x = 13;
			_npcIcon.y = 39;
			if (_missionInfo.hasImage)
				presenter.loadIcon(_missionInfo.largeImage, onIconLoaded);

			_npcTitle = new Label(32, 0xffffff, 370, 35);
			_npcTitle.bold = true;
			_npcTitle.x = LEFT_MARGIN;
			_npcTitle.y = 37;
			_npcTitle.letterSpacing = 1.2;
			_npcTitle.align = TextFormatAlign.LEFT;
			if (_missionInfo.hasTitle)
				_npcTitle.text = _missionInfo.npcTitle;
			_npcTitle.textColor = _missionInfo.titleColor;

			//progress bar
			_progressBar = UIFactory.getProgressBar(UIFactory.getPanel(PanelEnum.STATBAR, 350, 15), UIFactory.getPanel(PanelEnum.STATBAR_CONTAINER, 359, 23), 0, 1, 0, LEFT_MARGIN, 155);

			//progress tab
			_progressLabel = new Label(14, 0xf0f0f0, 46, 36, false, 1);
			_progressLabel.x = _progressBar.x;
			_progressLabel.y = _progressBar.y - 1;
			_progressLabel.bold = true;

			setProgress();

			addChild(_npcDialogue);
			addChild(_nextBtnLabel);
			addChild(_npcIcon);
			addChild(_nextBtn);
			addChild(_npcTitle);
			addChild(_progressBar);
			addChild(_progressLabel);

			onResize();
			addEffects();
			effectsIN();
			
			if(_missionInfo.hasSound)
			{
				_soundToPlay = _missionInfo.sound;
				if (_soundToPlay && _soundToPlay.length > 0)
					presenter.playSound(_soundToPlay);
			}
		}

		override public function onEscapePressed():void  {}

		protected function onNextBtnClicked( e:MouseEvent = null ):void
		{
			if (e)
				e.stopImmediatePropagation();
			if (!_missionInfo)
				return;
			if (_missionInfo.hasDialog)
			{
				_missionInfo.currentProgress++;
				presenter.loadIcon(_missionInfo.largeImage, onIconLoaded);
				_npcDialogue.text = _missionInfo.dialog;
				if (_missionInfo.hasTitle && _npcTitle)
					_npcTitle.text = _missionInfo.npcTitle;

				if (_progressBar)
					setProgress();
				
				if(_missionInfo.hasSound)
				{
					_soundToPlay = _missionInfo.sound;
					if (_soundToPlay != null && _soundToPlay.length > 0)
						presenter.playSound(_soundToPlay);
				}
				
			} else
			{
				removeListener(this, MouseEvent.CLICK, onNextBtnClicked);
				switch (_state)
				{
					case MissionEvent.MISSION_GREETING:
						presenter.acceptMission();
						break;
					case MissionEvent.MISSION_VICTORY:
						presenter.showReward();
						break;
					case MissionEvent.MISSION_SITUATIONAL:
						presenter.unpauseBattle();
						break;
				}
				destroy();
			}
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.alphaEffect(0, 1, 0, .5, .5));
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.CENTER, PositionEnum.BOTTOM, onResize));
			_effects.addEffect(EffectFactory.simpleBackingEffect(0, 0, 0, onNextBtnClicked));
			_effects.addEffect(EffectFactory.stageLetterboxEffect(.5, .5, true, 140, onNextBtnClicked));
			_effects.addEffect(EffectFactory.stageLetterboxEffect(.5, .5, false, 148, onNextBtnClicked));
			hideViews();
		}

		protected function onIconLoaded( asset:BitmapData ):void
		{
			if (_npcIcon)
			{
				_npcIcon.onImageLoaded(asset);
				_npcIcon.smoothing = true;
			}
		}

		protected function onResize():void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			x = (DeviceMetrics.WIDTH_PIXELS - (width * Application.SCALE)) * .5;
			y = DeviceMetrics.HEIGHT_PIXELS - (height * Application.SCALE); // - 5;
		}

		public function get isTextAnimating():Boolean  { return false; } //(_npcDialogue) ? _npcDialogue.running : false; }

		public function set info( v:MissionInfoVO ):void
		{
			_missionInfo = v;
			if (_npcDialogue && _missionInfo.hasDialog)
				_npcDialogue.text = _missionInfo.dialog;

			if (_missionInfo.hasTitle && _npcTitle)
				_npcTitle.text = _missionInfo.npcTitle;

			if (_npcIcon)
				presenter.loadIcon(_missionInfo.largeImage, onIconLoaded);
			if (_progressBar)
				setProgress();
		}

		protected function setProgress():void
		{
			_progressBar.setMinMax(0, _missionInfo.progressRequired);
			_progressBar.overrideAmount = _missionInfo.currentProgress;
			var percent:int = Math.ceil((_missionInfo.currentProgress / _missionInfo.progressRequired) * 100);
			_progressLabel.setTextWithTokens(_percentText, {'[[Number.PercentValue]]':percent});
			if (percent < 65)
			{
				_progressLabel.x = _progressBar.x + _progressBar.barWidth;
					//_progressLabel.textColor = 0xcbbc55;
			} else
			{
				_progressLabel.x = _progressBar.x + (_progressBar.width - _progressLabel.width) / 2;
					//_progressLabel.textColor = 0x17170f;
			}
		}

		public function hideViews():void
		{
			var event:ViewEvent = new ViewEvent(ViewEvent.HIDE_VIEWS);
			event.targetClass = [BridgeView, ChatView, IconDrawerView, PlayerView, EngineeringView, MiniMapView, CommandView, BattleUserView, BattleShipSelectionView];
			presenter.dispatch(event);
		}

		public function unhideViews():void
		{
			var event:ViewEvent = new ViewEvent(ViewEvent.UNHIDE_VIEWS);
			event.targetClass = [BridgeView, ChatView, IconDrawerView, PlayerView, EngineeringView, MiniMapView, CommandView, BattleUserView, BattleShipSelectionView];
			presenter.dispatch(event);
		}

		override public function get height():Number  { return 186; }
		override public function get width():Number  { return super.width - 100; }

		override public function get typeUnique():Boolean  { return false; }
		override public function get type():String  { return ViewEnum.ALERT; }

		protected function get iconWidth():Number  { return 155; }
		protected function get iconHeight():Number  { return 145; }

		public function set state( v:String ):void  { _state = v; }

		[Inject]
		public function set presenter( value:IMissionPresenter ):void  { _presenter = value; }
		public function get presenter():IMissionPresenter  { return IMissionPresenter(_presenter); }

		public function get progressBar():ProgressBar  { return _progressBar; }

		override public function destroy():void
		{
			unhideViews();
			removeListener(this, MouseEvent.CLICK, onNextBtnClicked);
			super.destroy();

			if (_missionInfo)
				ObjectPool.give(_missionInfo);
			_missionInfo = null;
			_nextBtn.destroy();
			_nextBtn = null;
			_nextBtnLabel.destroy();
			_nextBtnLabel = null;
			_npcIcon.destroy();
			_npcIcon = null;
			_npcDialogue.destroy();
			_npcDialogue = null;
			_npcTitle.destroy();
			_npcTitle = null;
			_progressBar.destroy();
			_progressBar = null;
			_progressLabel.destroy();
			_progressLabel = null;
		}
	}
}
