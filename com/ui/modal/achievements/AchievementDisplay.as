package com.ui.modal.achievements
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.achievements.AchievementVO;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	import org.adobe.utils.StringUtil;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class AchievementDisplay extends Sprite
	{
		public var onLoadImage:Signal;
		public var onClaimReward:Signal;
		public var maxCredits:Function;
		public var getScore:Function;

		private var _bg:Sprite;

		private var _starUnlit:BitmapData
		private var _starLit:BitmapData;

		private var _scoreProgressBar:ProgressBar;

		private var _description:Label;
		private var _rewardsLabel:Label;
		private var _scoreLabel:Label;

		public var _claimBtn:BitmapButton;

		private var _rewards:Vector.<AchievementReward>;

		private var _achievements:Dictionary;
		private var _achievementsAsset:Dictionary;
		private var _achievementProgress:Dictionary;

		private var _achievementImage:ImageComponent;

		private var _category:String;
		private var _currentRank:uint;
		private var _nextRankKey:String;
		private var _sort:Number;
		private var _maxScore:Number;
		private var _scoreKey:String;
		
		private var _stars:Vector.<Bitmap>;

		private var _rewardText:String   = 'CodeString.Achievements.Rewards'; //REWARDS:
		private var _claimBtnText:String = 'CodeString.Achievement.ClaimBtn'; //CLAIM
		private var _outOfString:String  = 'CodeString.Shared.OutOf'; //[[Number.MinValue]]/[[Number.MaxValue]]

		public function AchievementDisplay( category:String )
		{
			super();

			onLoadImage = new Signal(String, Function);
			onClaimReward = new Signal(String);

			_rewards = new Vector.<AchievementReward>;
			_achievements = new Dictionary;
			_achievementsAsset = new Dictionary;
			_achievementProgress = new Dictionary;

			_starUnlit = UIFactory.getBitmapData('IconStarInactiveBMD');
			_starLit = UIFactory.getBitmapData('IconStarActiveBMD');

			_bg = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_INNER, PanelEnum.HEADER_NOTCHED, 582, 137, 30, 0, 0, 'Achievement');

			_stars = new Vector.<Bitmap>;
			
			_description = new Label(18, 0xf0f0f0, 440, 35);
			_description.multiline = true;
			_description.constrictTextToSize = false;
			_description.align = TextFormatAlign.LEFT;
			_description.x = 134;
			_description.y = 63;

			_rewardsLabel = new Label(22, 0xf0f0f0, 125, 25);
			_rewardsLabel.constrictTextToSize = false;
			_rewardsLabel.align = TextFormatAlign.LEFT;
			_rewardsLabel.x = 132;
			_rewardsLabel.y = 130;
			_rewardsLabel.text = _rewardText;

			_achievementImage = ObjectPool.get(ImageComponent);
			_achievementImage.init(120, 120);
			_achievementImage.x = 9;
			_achievementImage.y = 39;

			_claimBtn = UIFactory.getButton(ButtonEnum.GREEN_A, 100, 30, 0, 0, _claimBtnText, LabelEnum.H1);
			_claimBtn.x = _bg.width - _claimBtn.width - 19;
			_claimBtn.y = 34;
			_claimBtn.visible = false;
			_claimBtn.addEventListener(MouseEvent.CLICK, onClickClaimReward, false, 0, true);

			_category = category;

			_currentRank = 1;
			_nextRankKey = _category + '_' + _currentRank;

			addChild(_bg);
			addChild(_description);
			addChild(_rewardsLabel);
			addChild(_claimBtn);
			addChild(_achievementImage);
		}

		public function setUpStars( maximumRank:int ):void
		{
			for(var i:int=0; i<maximumRank; i++){
				var star:Bitmap = new Bitmap(_starUnlit);
				star.x = 132 + 34 * i;
				star.y = 33;
				addChild(star);
				_stars.push(star);
			}			
		}

		public function addAchievement( achievement:IPrototype, assetVO:AssetVO ):void
		{
			_achievements[achievement.name] = achievement;
			_achievementsAsset[achievement.name] = assetVO;

			if (achievement.getValue('rank') == 1)
				updateAchievementDisplay(_nextRankKey);
		}

		public function addAchievementProgress( achievementProgress:AchievementVO ):void
		{
			_achievementProgress[achievementProgress.achievementPrototype] = achievementProgress;

			if (achievementProgress.achievementPrototype in _achievements)
			{
				if (!achievementProgress.claimedFlag && !_claimBtn.visible)
					_claimBtn.visible = true;

				var achievement:IPrototype = _achievements[achievementProgress.achievementPrototype];
				if (achievementProgress.claimedFlag)
					updateRank(achievement.getValue('rank'));
				else
					cleanUpScoreBar();
			}
		}

		private function updateRank( rank:uint ):void
		{
			for (var i:int = 0; i < rank; i++)
			{
				if(i < _stars.length)
				{		
					_stars[i].bitmapData = _starLit;
				}
			}

			if (rank >= _currentRank)
			{
				_currentRank = rank;
				_nextRankKey = _category + '_' + (rank + 1);

				if (_nextRankKey in _achievementsAsset)
					updateAchievementDisplay(_nextRankKey);
				else
				{
					_nextRankKey = _category + '_' + rank;
					_rewardsLabel.visible = false;
					_description.visible = false;
					removeRewards();
				}
			}
		}

		private function onClickClaimReward( e:MouseEvent ):void
		{
			var rankKey:String;
			var achievementProgress:AchievementVO;
			var alreadyClaimed:Boolean;
			for (var i:uint = 1; i <= _stars.length; ++i)
			{
				rankKey = _category + '_' + i;
				if (rankKey in _achievementProgress)
				{
					achievementProgress = _achievementProgress[rankKey];
					if (!achievementProgress.claimedFlag)
					{
						if (!alreadyClaimed)
						{
							var achievement:IPrototype = _achievements[achievementProgress.achievementPrototype];
							achievementProgress.claimedFlag = alreadyClaimed = true;
							_claimBtn.visible = false;
							_achievementProgress[rankKey] = achievementProgress;

							updateRank(achievement.getValue('rank'));

							if (onClaimReward != null)
								onClaimReward.dispatch(achievementProgress.key);

						} else
						{
							_claimBtn.visible = true;
							break;
						}
					}
				}
			}
		}

		private function updateAchievementDisplay( key:String ):void
		{
			var achievement:IPrototype;
			var assetVO:AssetVO;
			var achievementProgress:AchievementVO;

			if (key in _achievements)
				achievement = _achievements[key];

			if (key in _achievementsAsset)
				assetVO = _achievementsAsset[key];

			if (key in _achievementProgress)
				achievementProgress = _achievementProgress[key];

			_scoreKey = '';
			removeRewards();

			if (onLoadImage && assetVO)
				onLoadImage.dispatch(assetVO.smallImage, _achievementImage.onImageLoaded);

			if (_bg && assetVO)
				Label(_bg.getChildAt(2)).text = assetVO.visibleName;

			if (_description && assetVO)
				_description.text = assetVO.descriptionText;

			if (achievement)
			{
				_sort = achievement.getValue('sort');
				if (achievementProgress == null)
				{
					_scoreKey = achievement.getValue('scoreKey');
					_maxScore = achievement.getValue('scoreRequired');
				}

				if (scoreKey == '' || scoreKey == null)
					cleanUpScoreBar();
			}

			if (_rewards && achievement)
			{
				var rewardAmount:Number = achievement.getValue('hardCurrencyReward');
				if (rewardAmount > 0)
					addReward(rewardAmount, AchievementReward.REWARD_PALLADIUM);

				rewardAmount = achievement.getValue('experienceReward');
				if (rewardAmount > 0)
					addReward(rewardAmount, AchievementReward.REWARD_EXP);

				rewardAmount = achievement.getValue('creditsReward');
				if (rewardAmount > 0)
				{
					if (maxCredits != null)
						rewardAmount *= maxCredits();
					addReward(rewardAmount, AchievementReward.REWARD_CREDITS);
				}

				if (achievement.getValue('blueprintReward') == true)
				{
					var bpParts:int = achievement.getValue('blueprintRewardParts');
					if(bpParts == 0) bpParts = 1;
					addReward(bpParts, AchievementReward.BLUEPRINT);
				}

				layoutRewards();
			}
		}

		private function addReward( amount:int, type:int ):void
		{
			var reward:AchievementReward = new AchievementReward(amount, type);
			addChild(reward);
			_rewards.push(reward)
		}

		private function layoutRewards():void
		{
			var xPos:Number = _rewardsLabel.x + _rewardsLabel.textWidth + 4;
			var yPos:Number = 130;

			var len:uint    = _rewards.length;
			var currentReward:AchievementReward;
			for (var i:uint = 0; i < len; ++i)
			{
				currentReward = _rewards[i];
				currentReward.x = xPos;
				currentReward.y = yPos;

				xPos += currentReward.width + 10;
			}
		}

		private function removeRewards():void
		{
			if (_rewards)
			{
				var len:uint = _rewards.length;
				var currentReward:AchievementReward;
				for (var i:uint = 0; i < len; ++i)
				{
					currentReward = _rewards[i];
					removeChild(currentReward);
					currentReward.destroy();
					currentReward = null;
				}
				_rewards.length = 0;
			}
		}

		public function setScore( v:Number ):void
		{
			var achievementProgress:AchievementVO;
			if (_nextRankKey in _achievementProgress)
				achievementProgress = _achievementProgress[_nextRankKey];

			if (achievementProgress == null || achievementProgress.claimedFlag)
				setUpScoreBar(v);
		}

		private function setUpScoreBar( current:Number ):void
		{
			if (current > _maxScore)
				current = _maxScore;

			if (_scoreProgressBar == null)
			{
				_scoreProgressBar = UIFactory.getProgressBar(UIFactory.getPanel(PanelEnum.STATBAR, 428, 16), UIFactory.getPanel(PanelEnum.STATBAR_CONTAINER, 436, 24), 0, _maxScore, current, 135, 102);
				addChild(_scoreProgressBar);
			}
			_scoreProgressBar.setMinMax(0, _maxScore);
			_scoreProgressBar.amount = current;

			if (_scoreLabel == null)
			{
				_scoreLabel = new Label(14, 0xf0f0f0, 436, 25, true, 1);
				_scoreLabel.letterSpacing = 1.5;
				_scoreLabel.align = TextFormatAlign.CENTER;
				_scoreLabel.y = _scoreProgressBar.y;
				_scoreLabel.x = _scoreProgressBar.x;
				_scoreLabel.constrictTextToSize = false;
				addChild(_scoreLabel);
			}
			_scoreLabel.setTextWithTokens(_outOfString, {'[[Number.MinValue]]':StringUtil.commaFormatNumber(current), '[[Number.MaxValue]]':StringUtil.commaFormatNumber(_maxScore)});
		}

		private function cleanUpScoreBar():void
		{
			if (_scoreProgressBar)
			{
				removeChild(_scoreProgressBar);
				_scoreProgressBar.destroy();
			}

			_scoreProgressBar = null;

			if (_scoreLabel)
			{
				removeChild(_scoreLabel);
				_scoreLabel.destroy();
			}

			_scoreLabel = null;
		}

		public function get sort():Number  { return _sort; }
		public function get scoreKey():String  { return _scoreKey; }
		
		public function achievementsCount():int 
		{ 
			var n:int = 0;
			for (var key:* in _achievements) {
				n++;
			}
			return n; 
		}

		public function destroy():void
		{
			removeRewards();

			if (onLoadImage)
				onLoadImage.removeAll();

			onLoadImage = null;

			if (onClaimReward)
				onClaimReward.removeAll();

			onClaimReward = null;

			_bg = null;
			
			_stars = null;

			_starUnlit = null;
			_starLit = null;

			cleanUpScoreBar();

			if (_achievementImage)
				ObjectPool.give(_achievementImage)

			_achievementImage = null

			if (_description)
				_description.destroy();

			_description = null;

			if (_rewardsLabel)
				_rewardsLabel.destroy();

			_rewardsLabel = null;

			if (_claimBtn)
			{
				_claimBtn.removeEventListener(MouseEvent.CLICK, onClickClaimReward);
				_claimBtn.destroy();
			}

			_claimBtn = null;

			_achievements = null;
			_achievementsAsset = null;
			_achievementProgress = null;
		}
	}
}
