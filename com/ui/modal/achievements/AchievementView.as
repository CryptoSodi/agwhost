package com.ui.modal.achievements
{
	import com.enum.ui.LabelEnum;
	import com.model.achievements.AchievementVO;
	import com.model.asset.AssetVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.IAchievementPresenter;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.accordian.AccordianComponent;
	import com.ui.core.component.accordian.AccordianGroup;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.label.Label;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	import org.shared.ObjectPool;

	public class AchievementView extends View
	{
		private var _currentAchievements:Dictionary;
		private var _currentScores:Dictionary;
	
		private var _accordian:AccordianComponent;
		
		private var _bg:DefaultWindowBG;

		private var _totalAchievementsText:Label;

		private var _achievementEntries:Dictionary;

		private var _scrollbar:VScrollbar;

		private var _maxHeight:int;
		private var _completedAchievements:int;
		private var _totalAchievements:int;

		private var _scrollRect:Rectangle;

		private var _holder:Sprite;
		
		private var _achievementEntriesDictionary:Dictionary;

		private var _titleText:String   = 'CodeString.Achievements.Title'; //BADGES OF HONOR
		private var _outOfString:String = 'CodeString.Shared.OutOf'; //[[Number.MinValue]]/[[Number.MaxValue]]

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_achievementEntries = new Dictionary;

			_bg = ObjectPool.get(DefaultWindowBG);
			var accordianOffset:int = 261;
			//_bg.setBGSize(633, 530);
			_bg.setBGSize(894-29, 535);
			_bg.addTitle(_titleText, 240);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);
			
			_accordian = ObjectPool.get(AccordianComponent);
			_accordian.init(244, 52);
			_accordian.x = _bg.bg.x + 14;
			_accordian.y = _bg.bg.y + 5;
			_accordian.addListener(onAccordianSelected);

			_totalAchievementsText = UIFactory.getLabel(LabelEnum.H1, 100, 50);
			_totalAchievementsText.align = TextFormatAlign.LEFT;
			_totalAchievementsText.x = 242;
			_totalAchievementsText.y = 4;

			_holder = new Sprite();
			_holder.x = accordianOffset + 12;//41;
			_holder.y = _bg.bg.y + 5;

			_maxHeight = 0;
			_completedAchievements = 0;
			_totalAchievements = 0;

			_scrollRect = new Rectangle(_holder.x, _holder.y, 582+36, 514);
			_scrollRect.y = 0;
			_holder.scrollRect = _scrollRect

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = _bg.x + _bg.width - 25;
			var scrollbarYPos:Number    = _bg.y + 52;
			_scrollbar.init(7, _scrollRect.height - 15, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollBarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 174;

			addChild(_bg);
			addChild(_holder);
			addChild(_scrollbar);
			addChild(_totalAchievementsText);
			addChild(_accordian);
	
			_achievementEntriesDictionary = new Dictionary;
			var accordianGroups:Vector.<IPrototype> = setUpAccordian(presenter.getFilterAchievementPrototypes());
			setUpStars(presenter.getAchievementPrototypes());			
			
			if(accordianGroups.length > 0)
			{
				var firstGroup:String = accordianGroups[0].getValue('key');
				setUp(presenter.getAchievementPrototypes(), firstGroup);
				_accordian.setSelected(firstGroup, null);
			}
			
			presenter.onAddAchievementsUpdatedListener(onAchievementsUpdated);

			presenter.requestAchievements();

			addEffects();
			effectsIN();
		}

		private function onAccordianSelected( groupID:String, subItemID:String, data:* ):void
		{
			setUp(presenter.getAchievementPrototypes(), groupID);
			if(_currentAchievements && _currentScores)
			{
				_completedAchievements = 0;
				onAchievementsUpdated(_currentAchievements, _currentScores);
			}
		}
		
		private function setUpAccordian( v:Vector.<IPrototype> ):Vector.<IPrototype>
		{
			var len:uint = v.length;
			var currentFilterAchievement:IPrototype;
			
			v.sort(orderAccordianItems);				
			
			for (var i:uint = 0; i < len; ++i)
			{
				currentFilterAchievement = v[i];
				_accordian.addGroup(currentFilterAchievement.getValue('key'), currentFilterAchievement.getValue('uiName'));
			}
			
			return v;
		}
		
		private function orderAccordianItems( itemOne:IPrototype, itemTwo:IPrototype ):int
		{
			var sortOrderOne:Number = itemOne.getValue('sort');
			var sortOrderTwo:Number = itemTwo.getValue('sort');
			
			if (sortOrderOne < sortOrderTwo)
			{
				return -1;
			} else if (sortOrderOne > sortOrderTwo)
			{
				return 1;
			} else
			{
				return 0;
			}
		}
		
		private function setUpStars( v:Vector.<IPrototype> ):void
		{
			var len:uint = v.length;
			var currentEntry:AchievementDisplay;
			var currentCategory:String;
			var currentAchievement:IPrototype;
			var currentAchievementAsset:AssetVO;
			for (var i:uint = 0; i < len; ++i)
			{
				currentAchievement = v[i];
				currentCategory = currentAchievement.getValue('category');
				_achievementEntriesDictionary[currentCategory] = 0;	
			}	
			for (var i:uint = 0; i < len; ++i)
			{
				currentAchievement = v[i];
				currentCategory = currentAchievement.getValue('category');
				_achievementEntriesDictionary[currentCategory]++;	
			}			
		}
		
		private function setUp( v:Vector.<IPrototype>, filterAchievement:String = ''):void
		{
			_achievementEntries = new Dictionary;
			_holder.removeChildren();
			
			var len:uint = v.length;
			var currentEntry:AchievementDisplay;
			var currentCategory:String;
			var currentAchievement:IPrototype;
			var currentAchievementAsset:AssetVO;
			var currentFaction:String;
			var currentFilterAchievement:String;
			for (var i:uint = 0; i < len; ++i)
			{
				currentAchievement = v[i];
				currentAchievementAsset = presenter.getAssetVOFromIPrototype(currentAchievement);
				currentCategory = currentAchievement.getValue('category');
				currentFaction = currentAchievement.getValue('factionType');
				
				if(currentFaction && CurrentUser.faction != currentFaction)
				{
					continue;
				}
								
				currentFilterAchievement = currentAchievement.getValue('filterAchievement');//check na null

				if(currentFilterAchievement == filterAchievement)
				{				
					if (!(currentCategory in _achievementEntries))
					{
						currentEntry = new AchievementDisplay(currentCategory);
						currentEntry.setUpStars(_achievementEntriesDictionary[currentCategory]);
						currentEntry.onLoadImage.add(presenter.loadIcon);
						currentEntry.onClaimReward.add(presenter.claimAchievementReward);
						currentEntry.maxCredits = presenter.maxCredits;
						currentEntry.getScore = presenter.getScoreValueByName;
						_holder.addChild(currentEntry);
					} else
						currentEntry = _achievementEntries[currentCategory];
	
					currentEntry.addAchievement(currentAchievement, currentAchievementAsset);				
	
					_achievementEntries[currentCategory] = currentEntry;
				}
			}	
			
			layout();
			_scrollbar.resetScroll();
		}

		private function onAchievementsUpdated( achievements:Dictionary, scores:Dictionary ):void
		{
			_currentAchievements = achievements;
			_currentScores = scores;
			
			var currentEntry:AchievementDisplay;
			var currentAchievementProgress:AchievementVO;
			var achievementProtoName:String;
			var achievementCategory:String;				
			
			for (var key:String in achievements)
			{
				currentAchievementProgress = achievements[key];
				achievementCategory = currentAchievementProgress.category;
				if (achievementCategory in _achievementEntries)
				{
					++_completedAchievements;
					currentEntry = _achievementEntries[achievementCategory];
					currentEntry.addAchievementProgress(currentAchievementProgress);
					_achievementEntries[achievementCategory] = currentEntry;
				}
			}

			for each (var entry:AchievementDisplay in _achievementEntries)
			{
				if (entry.scoreKey != null && entry.scoreKey != '')
				{
					if (entry.scoreKey in scores)
						entry.setScore(scores[entry.scoreKey].value);
					else
						entry.setScore(0);
				}
			}
			_totalAchievementsText.setTextWithTokens(_outOfString, {'[[Number.MinValue]]':_completedAchievements, '[[Number.MaxValue]]':_totalAchievements});
			
			layout();
			_scrollbar.resetScroll();
		}

		protected function layout():void
		{
			_totalAchievements = 0;
			var entry:AchievementDisplay;
			var holder:Vector.<AchievementDisplay> = new Vector.<AchievementDisplay>;
			var yPos:int                           = 0;
			var xPos:int                           = _holder.x;
			var offset:Number                      = 174;
			_maxHeight = 0;
			for each (entry in _achievementEntries)
			{
				holder.push(entry);
				++_totalAchievements;
			}

			holder.sort(orderByID);

			for (var i:uint = 0; i < _totalAchievements; ++i)
			{
				entry = holder[i];
				entry.x = xPos;
				entry.y = yPos;
				_maxHeight += offset;
				yPos += offset;
			}
			
			_totalAchievements = 0;
			holder.length = 0;
			for each (entry in _achievementEntries)
			{
				holder.push(entry);
				_totalAchievements += entry.achievementsCount();
			}
			
			_maxHeight -= 5;
			_scrollbar.updateScrollableHeight(_maxHeight);
			_totalAchievementsText.setTextWithTokens(_outOfString, {'[[Number.MinValue]]':_completedAchievements, '[[Number.MaxValue]]':_totalAchievements});
		}

		private function orderByID( achievementOne:AchievementDisplay, achievementTwo:AchievementDisplay ):Number
		{
			if (!achievementOne)
				return -1;
			if (!achievementTwo)
				return 1;

			var achievementOneSort:Number = achievementOne.sort;
			var achievementTwoSort:Number = achievementTwo.sort;

			if(achievementOne._claimBtn.visible && !achievementTwo._claimBtn.visible)
				return -1;
			else if(!achievementOne._claimBtn.visible && achievementTwo._claimBtn.visible)
				return 1;
				
			if (achievementOneSort < achievementTwoSort)
				return -1;
			else if (achievementOneSort > achievementTwoSort)
				return 1;

			return 0;
		}


		private function onChangedScroll( percent:Number ):void
		{
			if (_scrollRect)
				_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;

			if (_holder)
				_holder.scrollRect = _scrollRect;
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( v:IAchievementPresenter ):void  { _presenter = v; }
		public function get presenter():IAchievementPresenter  { return IAchievementPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.onRemoveAchievementsUpdatedListener(onAchievementsUpdated);
			super.destroy();

			ObjectPool.give(_accordian);
			_accordian = null;
			
			_currentAchievements = null;
			_currentScores = null;
			
			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			if (_totalAchievementsText)
				_totalAchievementsText.destroy();

			_totalAchievementsText = null;

			for each (var entry:AchievementDisplay in _achievementEntries)
			{
				entry.destroy();
				entry = null;
			}
			_achievementEntries = null;

			_scrollbar = null;
			_maxHeight = 0;

			_scrollRect = null;

			_holder = null;
		}
	}
}
