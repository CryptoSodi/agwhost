package com.ui.modal.event
{
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.event.EventVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.IEventPresenter;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	import org.greensock.TweenLite;
	import org.shared.ObjectPool;

	public class EventView extends View
	{
		private var _bg:DefaultWindowBG;

		private var _eventTitle:Label;
		private var _eventDescription:Label;
		private var _eventObjective:Label;
		private var _eventReward:Label;
		private var _eventBuffs:Label;
		private var _score:Label;

		private var _eventImage:ImageComponent;

		private var _eventProgressBar:ProgressBar;

		private var _eventObjectiveContainer:ScaleBitmap;
		private var _eventImageContainer:ScaleBitmap;
		private var _eventRewardsContainer:ScaleBitmap;

		private var _nextArrow:Bitmap;
		private var _activeArrow:Sprite;

		private var _nextReward:EventReward;

		private var _eventDescriptionContainer:Sprite;
		private var _eventRewards:Sprite;

		private var _currentActiveEvent:EventVO;

		private var _tooltips:Tooltips;

		private var _titleText:String = 'EVENT';

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(1020, 604);
			_bg.addTitle(_titleText, 200);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_eventTitle = new Label(40, 0xf0f0f0, 482, 50);
			_eventTitle.align = TextFormatAlign.CENTER;
			_eventTitle.x = 46;
			_eventTitle.y = 62;

			_eventDescription = new Label(12, 0xf0f0f0, 464, 100, true, 1);
			_eventDescription.autoSize = TextFieldAutoSize.LEFT
			_eventDescription.align = TextFormatAlign.LEFT;
			_eventDescription.constrictTextToSize = false;
			_eventDescription.multiline = true;
			_eventDescription.x = 55;
			_eventDescription.y = 108;

			_eventObjective = new Label(12, 0xf0f0f0, 956, 100, true, 1);
			_eventObjective.align = TextFormatAlign.LEFT;
			_eventObjective.constrictTextToSize = false;
			_eventObjective.multiline = true;
			_eventObjective.x = 55;
			_eventObjective.y = 348;

			_eventReward = new Label(12, 0xf0f0f0, 956, 100, true, 1);
			_eventReward.align = TextFormatAlign.LEFT;
			_eventReward.constrictTextToSize = false;
			_eventReward.multiline = true;
			_eventReward.x = 55;
			_eventReward.y = 368;

			_eventBuffs = new Label(12, 0xf0f0f0, 956, 100, true, 1);
			_eventBuffs.align = TextFormatAlign.LEFT;
			_eventBuffs.constrictTextToSize = false;
			_eventBuffs.multiline = true;
			_eventBuffs.x = 55;
			_eventBuffs.y = 388;

			_eventDescriptionContainer = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_INNER, PanelEnum.HEADER_NOTCHED, 480, 216, 38, 46, 67);

			_eventImageContainer = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER);
			_eventImageContainer.width = 452;
			_eventImageContainer.height = 252;
			_eventImageContainer.x = 551;
			_eventImageContainer.y = 67;

			_eventObjectiveContainer = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER);
			_eventObjectiveContainer.width = 958;
			_eventObjectiveContainer.height = 70;
			_eventObjectiveContainer.x = 46;
			_eventObjectiveContainer.y = 343;

			_eventRewardsContainer = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER);


			_eventImage = ObjectPool.get(ImageComponent);
			_eventImage.init(450, 250);
			_eventImage.x = _eventImageContainer.x + 1;
			_eventImage.y = _eventImageContainer.y + 1;


			_eventProgressBar = UIFactory.getProgressBar(UIFactory.getPanel(PanelEnum.STATBAR, 893, 16), UIFactory.getPanel(PanelEnum.STATBAR_CONTAINER, 901, 24), 0, 1, 0, _eventObjectiveContainer.
														 x,
														 _eventObjectiveContainer.
														 y + _eventObjectiveContainer.height + 24);

			_score = new Label(14, 0xf0f0f0, _eventProgressBar.width, _eventProgressBar.height, true, 1);
			_score.align = TextFormatAlign.CENTER;
			_score.constrictTextToSize = false;
			_score.multiline = true;
			_score.x = _eventProgressBar.x;
			_score.y = _eventProgressBar.y;



			_eventRewards = new Sprite();
			_eventRewards.y = _eventProgressBar.y + _eventProgressBar.height + 24;

			_nextReward = new EventReward(50, 50, true, true, _tooltips, presenter);
			_nextReward.x = _eventProgressBar.x + _eventProgressBar.width + 1;
			_nextReward.y = _eventProgressBar.y - 21;
			_nextReward.active = true;

			_nextArrow = UIFactory.getBitmap('NextArrowUnlitBMD');
			_nextArrow.x = _nextReward.x - 5;
			_nextArrow.y = _eventProgressBar.y + 4;

			addChild(_bg);
			addChild(_eventDescriptionContainer);
			addChild(_eventObjectiveContainer);
			addChild(_eventImageContainer);
			addChild(_eventRewardsContainer);
			addChild(_eventTitle);
			addChild(_eventDescription);
			addChild(_eventObjective);
			addChild(_eventReward);
			addChild(_eventBuffs);
			addChild(_eventProgressBar);
			addChild(_score);
			addChild(_eventImage);
			addChild(_eventRewards);
			addChild(_nextReward);
			addChild(_nextArrow);

			_currentActiveEvent = presenter.currentActiveEvent;

			presenter.onAddAchievementsUpdatedListener(onAchievementsUpdated);
			presenter.requestAchievements();

			setUp();

			addEffects();
			effectsIN();
		}

		private function setUp():void
		{
			if (_currentActiveEvent)
			{
				var asset:AssetVO = presenter.getAssetVO(_currentActiveEvent.prototype);
				_eventTitle.text = asset.visibleName;
				_eventDescription.text = asset.descriptionText;
				_eventObjective.text = _currentActiveEvent.objectiveText;
				_eventReward.text = _currentActiveEvent.rewardsText;
				_eventBuffs.text = _currentActiveEvent.activeEventBuffsText;

				presenter.loadIcon(asset.largeImage, _eventImage.onImageLoaded);

				updateEvent(0);
			}
		}

		private function onAchievementsUpdated( achievements:Dictionary, scores:Dictionary ):void
		{
			if (_currentActiveEvent && scores.hasOwnProperty(_currentActiveEvent.scoreKey))
				updateEvent(scores[_currentActiveEvent.scoreKey].value);
		}

		private function updateEvent( currentScore:uint ):void
		{
			if (_activeArrow)
				TweenLite.killTweensOf(_activeArrow);

			_activeArrow = null;

			_nextReward.reward = null;
			_nextReward.index = 0;
			_eventRewards.removeChildren(0);

			var currentReward:Object;
			var currentEventReward:EventReward;
			var previousEventReward:EventReward;
			var nextArrow:Sprite;
			var previousArrow:Sprite;
			var rewardPrototype:IPrototype;
			var unlocked:Boolean;
			var index:uint;
			var nextRewardSet:Boolean;
			var xPos:Number;
			var padding:Number = 26;
			var rewards:Array  = new Array();
			var len:uint       = _currentActiveEvent.rewards.length;
			var i:uint;
			for (; i < len; ++i)
			{
				currentReward = _currentActiveEvent.rewards[i];
				if (!currentReward.hasOwnProperty("factionRequirement") || (currentReward.hasOwnProperty("factionRequirement") && currentReward.factionRequirement == CurrentUser.faction))
					rewards.push(currentReward);
			}

			len = rewards.length;

			for (i = 0; i < len; ++i)
			{
				currentReward = rewards[i];

				previousEventReward = currentEventReward;
				previousArrow = nextArrow;

				rewardPrototype = presenter.getResearchItemPrototypeByName(currentReward.blueprint);
				unlocked = currentScore >= currentReward.scoreRequirement;

				currentEventReward = new EventReward(100, 100, false, unlocked, _tooltips, presenter);
				currentEventReward.reward = rewardPrototype;
				currentEventReward.index = index;
				currentEventReward.scoreRequirement = currentReward.scoreRequirement;
				currentEventReward.x = xPos;
				_eventRewards.addChildAt(currentEventReward, index);
				++index;

				if (previousArrow)
				{
					var scoreToUse:int = (currentScore > currentReward.scoreRequirement) ? currentReward.scoreRequirement : currentScore;
					_tooltips.addTooltip(previousArrow, this, null, "Current Score: " + scoreToUse + "\nRequired Score: " +
										 currentReward.scoreRequirement);
				}

				if (!unlocked && !nextRewardSet)
				{
					nextRewardSet = true;
					_activeArrow = previousArrow;
					currentEventReward.active = true;

					_nextReward.reward = rewardPrototype;
					_nextReward.index = index;

					if (previousEventReward)
						var previousScoreRequirement:uint = previousEventReward.scoreRequirement;

					_score.text = (currentScore - previousScoreRequirement) + '/' + (currentEventReward.scoreRequirement - previousScoreRequirement);
					var percent:Number                    = (currentScore - previousScoreRequirement) / (currentEventReward.scoreRequirement - previousScoreRequirement);
					_eventProgressBar.amount = percent;

					onFadeIn();
				} else if (i == (len - 1) && unlocked)
				{
					_nextArrow.visible = false;
					_score.visible = false;
					_eventProgressBar.visible = false;
				}

				if (i != (len - 1))
				{
					nextArrow = new Sprite();
					nextArrow.addChild(UIFactory.getBitmap((unlocked) ? "NextArrowLargeBMD" : 'NextArrowLargeUnlitBMD'));
					nextArrow.x = currentEventReward.x + currentEventReward.width;
					nextArrow.y = currentEventReward.y + (currentEventReward.height - nextArrow.height) * 0.5 + 9;
					_eventRewards.addChild(nextArrow);
				}

				xPos = currentEventReward.x + currentEventReward.width + padding;
			}

			_eventRewardsContainer.width = len * 100 + (len - 1) * padding + 20;
			_eventRewardsContainer.height = 135;


			_eventRewardsContainer.x = _bg.x + (_bg.width - _eventRewardsContainer.width) * 0.5 + 8;
			_eventRewardsContainer.y = _eventRewards.y;

			_eventRewards.x = _eventRewardsContainer.x + 1;
		}

		private function onFadeOut():void
		{
			if (_activeArrow)
				TweenLite.to(_activeArrow, 0.75, {alpha:1, onComplete:onFadeIn});
		}

		private function onFadeIn():void
		{
			if (_activeArrow)
				TweenLite.to(_activeArrow, 0.75, {alpha:0.7, onComplete:onFadeOut});
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set tooltips( v:Tooltips ):void  { _tooltips = v; }

		[Inject]
		public function set presenter( value:IEventPresenter ):void  { _presenter = value; }
		public function get presenter():IEventPresenter  { return IEventPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.onRemoveAchievementsUpdatedListener(onAchievementsUpdated);
			super.destroy();

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			if (_activeArrow)
				TweenLite.killTweensOf(_activeArrow);

			_activeArrow = null;

			if (_nextReward)
			{
				TweenLite.killTweensOf(_nextReward);
				_nextReward.destroy();
			}

			_nextReward = null;

			if (_eventProgressBar)
				ObjectPool.give(_eventProgressBar);

			_eventProgressBar = null;

			if (_eventTitle)
				_eventTitle.destroy()

			_eventTitle = null;

			if (_eventDescription)
				_eventDescription.destroy()

			_eventDescription = null;

			if (_eventObjective)
				_eventObjective.destroy()

			_eventObjective = null;

			if (_eventReward)
				_eventReward.destroy()

			_eventReward = null;

			if (_eventBuffs)
				_eventBuffs.destroy()

			_eventBuffs = null;

			if (_score)
				_score.destroy()

			_score = null;

			if (_eventImage)
				ObjectPool.give(_eventImage);

			_eventImage = null;

			_eventObjectiveContainer = null;
			_eventImageContainer = null;
			_eventRewardsContainer = null;
			_nextArrow = null;
			_eventDescriptionContainer = null;
			_eventRewards = null;
			_currentActiveEvent = null;
		}
	}
}
