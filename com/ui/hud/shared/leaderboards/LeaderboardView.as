package com.ui.hud.shared.leaderboards
{
	import com.enum.FactionEnum;
	import com.enum.LeaderboardEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.leaderboards.LeaderboardEntryVO;
	import com.model.leaderboards.LeaderboardVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.ILeaderboardPresenter;
	import com.presenter.shared.IUIPresenter;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.accordian.AccordianComponent;
	import com.ui.core.component.accordian.AccordianGroup;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.ui.modal.playerinfo.PlayerProfileView;
	import com.util.CommonFunctionUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	import org.greensock.TweenLite;
	import org.shared.ObjectPool;

	public class LeaderboardView extends View
	{
		private var _bg:DefaultWindowBG;

		private var _accordian:AccordianComponent;

		private var _gridHolder:Sprite;
		private var _container:Sprite;
		private var _playerHolder:Sprite;

		private var _generalGrid:Bitmap;
		private var _allianceGrid:Bitmap;
		private var _noMemberAllianceGrid:Bitmap;

		private var _gridEnd:ScaleBitmap;

		private var _subTitle:Label;
		private var _noGridText:Label;
		private var _titleOne:Label;
		private var _titleTwo:Label;
		private var _titleThree:Label;
		private var _titleFour:Label;
		private var _titleFive:Label;

		private var _scrollbar:VScrollbar;

		private var _scrollRect:Rectangle;

		private var _maxHeight:int;

		private var _groupID:String;
		private var _subItemID:String;

		private var _players:Vector.<LeaderboardEntry>;

		private var _titleText:String                   = 'CodeString.Leaderboard.Title'; //LEADERBOARDS
		private var _subTitleText:String                = 'CodeString.Leaderboard.SubTitle'; //UPDATES EVERY 24 HOURS
		private var _noEntriesText:String               = 'CodeString.Leaderboard.NoEntries'; //NO ENTRIES TO DISPLAY
		private var _noEntriesAllianceText:String       = 'CodeString.Leaderboard.AllianceNoEntries'; //YOU MUST HAVE ATLEAST 5 MEMBERS TO BE RANKED

		private var _topPlayersText:String              = 'CodeString.Leaderboard.Scope.TopPlayers'; //TOP PLAYERS
		private var _myRankingText:String               = 'CodeString.Leaderboard.Scope.MyRanking'; //MY RANKING
		private var _mySectorText:String                = 'CodeString.Leaderboard.Scope.MySector'; //MY SECTOR
		private var _myAllianceText:String              = 'CodeString.Leaderboard.Scope.MyAlliance'; //MY ALLIANCE
		private var _topAllianceText:String             = 'CodeString.Leaderboard.Scope.TopAlliances'; //TOP ALLIANCES
		private var _myAllianceRankingText:String       = 'CodeString.Leaderboard.Scope.MyAllianceRanking'; //MY ALLIANCE RANKING

		private var _rankText:String                    = 'CodeString.Leaderboard.Type.Rank'; //Rank
		private var _nameText:String                    = 'CodeString.Leaderboard.Type.Name'; //Name
		private var _allianceText:String                = 'CodeString.Leaderboard.Type.Alliance'; //Alliance
		private var _sectorText:String                  = 'CodeString.Leaderboard.Type.Sector'; //Sector
		private var _baseRatingText:String              = 'CodeString.Leaderboard.Type.BaseRating'; //Base Rating
		private var _levelText:String                   = 'CodeString.Leaderboard.Type.Level'; //Level
		private var _commendationRankText:String        = 'CodeString.Leaderboard.Type.CommendationRank'; //Commendation Rank
		private var _totalCommendationRatingText:String = 'CodeString.Leaderboard.Type.TotalCommendationRating'; //Total Commendation Rating
		private var _highestFleetRatingText:String      = 'CodeString.Leaderboard.Type.HighestFleetRating'; //Highest Fleet Rating
		private var _totalHighestFleetRatingText:String = 'CodeString.Leaderboard.Type.TotalHighestFleetRating' //Total Highest Fleet Rating 
		private var _victoriesText:String               = 'CodeString.Leaderboard.Type.Victories'; //Victories
		private var _winLossText:String                 = 'CodeString.Leaderboard.Type.WinLoss'; //Win/Loss Ratio
		private var _totalBlueprintPartsText:String     = 'CodeString.Leaderboard.Type.TotalBlueprintParts'; //Total Blueprint Parts
		private var _numOfMembersText:String            = 'CodeString.Leaderboard.Type.NumOfMembers'; //Number of Members
		private var _totalExperienceText:String         = 'CodeString.Leaderboard.Type.TotalExperience'; //Total Experience
		private var _totalBaseRatingText:String         = 'CodeString.Leaderboard.Type.TotalBaseRating'; //Total Base Rating
		private var _avgHighestFleetText:String         = 'CodeString.Leaderboard.Type.AvgHighestFleet'; //Average Highest Fleet Rating
		
		private var _qualifiedWinsPvP:String       		= 'CodeString.Leaderboard.Type.QualifiedWinsPvP';
		private var _BubbleHoursGranted:String       	= 'CodeString.Leaderboard.Type.BubbleHoursGranted';
		private var _currentPVPEvent:String        		= 'CodeString.Leaderboard.Type.CurrentPVPEvent';
		private var _currentPVPEventQuarter:String      = 'CodeString.Leaderboard.Type.CurrentPVPEventQuarter';
		private var _CreditsTradeRoute:String        	= 'CodeString.Leaderboard.Type.CreditsTradeRoute';
		private var _ResourcesTradeRoute:String        	= 'CodeString.Leaderboard.Type.ResourcesTradeRoute';
		private var _ResourcesSalvaged:String        	= 'CodeString.Leaderboard.Type.ResourcesSalvaged';
		private var _CreditsBounty:String        		= 'CodeString.Leaderboard.Type.CreditsBounty';
		private var _WinsVsBase:String        			= 'CodeString.Leaderboard.Type.WinsVsBase';

		[PostConstruct]
		override public function init():void
		{
			super.init();

			var playerFaction:IPrototype     = presenter.getFactionPrototypesByName(CurrentUser.faction);
			var playerFactionAssetVO:AssetVO = presenter.getAssetVOFromIPrototype(playerFaction);
			var factionColor:uint            = CommonFunctionUtil.getFactionColor(playerFaction.name);

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(1020, 593);
			_bg.addTitle(_titleText, 470);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_subTitle = new Label(26, 0xffd785, 352, 45);
			_subTitle.align = TextFormatAlign.RIGHT;
			_subTitle.x = 140;
			_subTitle.y = 6;
			_subTitle.text = _subTitleText;

			_noGridText = new Label(26, 0xf0f0f0, 352, 45);
			_noGridText.align = TextFormatAlign.CENTER;
			_noGridText.text = _noEntriesText;
			_noGridText.x = 301 + (558 - _subTitle.textWidth) * 0.5;
			_noGridText.y = 78 + (546 - _subTitle.height) * 0.5;
			_noGridText.visible = false;

			_accordian = ObjectPool.get(AccordianComponent);
			_accordian.init(244, 42);
			_accordian.x = _bg.bg.x + 14;
			_accordian.y = _bg.bg.y - 10;
			_accordian.addListener(onAccordianSelected);

			_groupID = String(LeaderboardEnum.PLAYER_GLOBAL);
			_accordian.addGroup(_groupID, _topPlayersText);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BASE_RATING), _baseRatingText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.EXPERIENCE), _levelText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.COMMENDATION_COMBINED), _commendationRankText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.HIGHEST_FLEET_RATING), _highestFleetRatingText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS), _victoriesText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.KILL_DEATH_RATIO), _winLossText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BLUEPRINT_PARTS), _totalBlueprintPartsText, 0);
			
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.QUALIFIED_WINS), _qualifiedWinsPvP, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BUBBLE_HOUR_GRANTED), _BubbleHoursGranted, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT), _currentPVPEvent, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT_QUARTER), _currentPVPEventQuarter, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_TRADE_ROUTE), _CreditsTradeRoute, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_TRADE_ROUTE), _ResourcesTradeRoute, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_SALVAGED), _ResourcesSalvaged, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_BOUNTY), _CreditsBounty, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS_VS_BASES), _WinsVsBase, 0);
			
			
			_groupID = String(LeaderboardEnum.PLAYER_PERSONAL);
			_accordian.addGroup(_groupID, _myRankingText);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BASE_RATING), _baseRatingText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.EXPERIENCE), _levelText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.COMMENDATION_COMBINED), _commendationRankText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.HIGHEST_FLEET_RATING), _highestFleetRatingText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS), _victoriesText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.KILL_DEATH_RATIO), _winLossText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BLUEPRINT_PARTS), _totalBlueprintPartsText, 0);
			
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.QUALIFIED_WINS), _qualifiedWinsPvP, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BUBBLE_HOUR_GRANTED), _BubbleHoursGranted, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT), _currentPVPEvent, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT_QUARTER), _currentPVPEventQuarter, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_TRADE_ROUTE), _CreditsTradeRoute, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_TRADE_ROUTE), _ResourcesTradeRoute, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_SALVAGED), _ResourcesSalvaged, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_BOUNTY), _CreditsBounty, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS_VS_BASES), _WinsVsBase, 0);
			

			_groupID = String(LeaderboardEnum.PLAYER_SECTOR);
			_accordian.addGroup(_groupID, _mySectorText);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BASE_RATING), _baseRatingText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.EXPERIENCE), _levelText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.COMMENDATION_COMBINED), _commendationRankText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.HIGHEST_FLEET_RATING), _highestFleetRatingText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS), _victoriesText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.KILL_DEATH_RATIO), _winLossText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BLUEPRINT_PARTS), _totalBlueprintPartsText, 0);
			
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.QUALIFIED_WINS), _qualifiedWinsPvP, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BUBBLE_HOUR_GRANTED), _BubbleHoursGranted, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT), _currentPVPEvent, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT_QUARTER), _currentPVPEventQuarter, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_TRADE_ROUTE), _CreditsTradeRoute, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_TRADE_ROUTE), _ResourcesTradeRoute, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_SALVAGED), _ResourcesSalvaged, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_BOUNTY), _CreditsBounty, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS_VS_BASES), _WinsVsBase, 0);

			if (CurrentUser.alliance != '')
			{
				_groupID = String(LeaderboardEnum.PLAYER_ALLIANCE);
				_accordian.addGroup(_groupID, _myAllianceText);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BASE_RATING), _baseRatingText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.EXPERIENCE), _levelText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.COMMENDATION_COMBINED), _commendationRankText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.HIGHEST_FLEET_RATING), _highestFleetRatingText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS), _victoriesText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.KILL_DEATH_RATIO), _winLossText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BLUEPRINT_PARTS), _totalBlueprintPartsText, 0);
				
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.QUALIFIED_WINS), _qualifiedWinsPvP, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BUBBLE_HOUR_GRANTED), _BubbleHoursGranted, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT), _currentPVPEvent, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT_QUARTER), _currentPVPEventQuarter, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_TRADE_ROUTE), _CreditsTradeRoute, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_TRADE_ROUTE), _ResourcesTradeRoute, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_SALVAGED), _ResourcesSalvaged, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_BOUNTY), _CreditsBounty, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS_VS_BASES), _WinsVsBase, 0);
				
			}

			_groupID = String(LeaderboardEnum.ALLIANCE_GLOBAL);
			_accordian.addGroup(_groupID, _topAllianceText);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BASE_RATING), _baseRatingText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.EXPERIENCE), _totalExperienceText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.COMMENDATION_COMBINED), _totalCommendationRatingText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.HIGHEST_FLEET_RATING), _totalHighestFleetRatingText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS), _victoriesText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.KILL_DEATH_RATIO), _winLossText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BLUEPRINT_PARTS), _totalBlueprintPartsText, 0);

			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.ALLIANCE_NUM_MEMBERS), _numOfMembersText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.ALLIANCE_TOTAL_RATING), _totalBaseRatingText, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.ALLIANCE_AVERAGE_HIGHEST_FLEET_RATING), _avgHighestFleetText, 0);
			
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.QUALIFIED_WINS), _qualifiedWinsPvP, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BUBBLE_HOUR_GRANTED), _BubbleHoursGranted, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT), _currentPVPEvent, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT_QUARTER), _currentPVPEventQuarter, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_TRADE_ROUTE), _CreditsTradeRoute, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_TRADE_ROUTE), _ResourcesTradeRoute, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_SALVAGED), _ResourcesSalvaged, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_BOUNTY), _CreditsBounty, 0);
			_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS_VS_BASES), _WinsVsBase, 0);
			

			if (CurrentUser.alliance != '')
			{
				_groupID = String(LeaderboardEnum.ALLIANCE_PERSONAL);
				_accordian.addGroup(_groupID, _myAllianceRankingText);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BASE_RATING), _baseRatingText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.EXPERIENCE), _totalExperienceText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.COMMENDATION_COMBINED), _totalCommendationRatingText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.HIGHEST_FLEET_RATING), _totalHighestFleetRatingText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS), _victoriesText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.KILL_DEATH_RATIO), _winLossText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BLUEPRINT_PARTS), _totalBlueprintPartsText, 0);

				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.ALLIANCE_NUM_MEMBERS), _numOfMembersText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.ALLIANCE_TOTAL_RATING), _totalBaseRatingText, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.ALLIANCE_AVERAGE_HIGHEST_FLEET_RATING), _avgHighestFleetText, 0);
				
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.QUALIFIED_WINS), _qualifiedWinsPvP, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.BUBBLE_HOUR_GRANTED), _BubbleHoursGranted, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT), _currentPVPEvent, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.PVP_EVENT_QUARTER), _currentPVPEventQuarter, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_TRADE_ROUTE), _CreditsTradeRoute, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_TRADE_ROUTE), _ResourcesTradeRoute, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.RESOURCE_SALVAGED), _ResourcesSalvaged, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.CREDITS_BOUNTY), _CreditsBounty, 0);
				_accordian.addSubItemToGroup(_groupID, String(LeaderboardEnum.WINS_VS_BASES), _WinsVsBase, 0);
				
			}

			_accordian.setSelected(String(LeaderboardEnum.PLAYER_GLOBAL), String(LeaderboardEnum.BASE_RATING));

			_container = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED, PanelEnum.HEADER_NOTCHED_RIGHT, 750, 548, 30, _accordian.x + _accordian.width + 5, _accordian.y, "BASE RATING", LabelEnum.
												  H3);
			Label(_container.getChildAt(2)).allCaps = true;

			_generalGrid = UIFactory.getBitmap("LeaderboardGeneralGridBMD");
			_allianceGrid = UIFactory.getBitmap("LeaderboardAllianceGridBMD");
			_noMemberAllianceGrid = UIFactory.getBitmap("LeaderboardAllianceMemberGridBMD");

			_titleOne = new Label(16, 0xf0f0f0, 51, 30);
			_titleOne.align = TextFormatAlign.CENTER;
			_titleOne.allCaps = true;
			_titleOne.text = _rankText;
			_titleOne.y = -_titleOne.height;

			_titleTwo = new Label(16, 0xf0f0f0, 215, 30);
			_titleTwo.align = TextFormatAlign.CENTER;
			_titleTwo.allCaps = true;
			_titleTwo.text = _nameText;
			_titleTwo.y = -_titleOne.height;

			_titleThree = new Label(16, 0xf0f0f0, 215, 30);
			_titleThree.align = TextFormatAlign.CENTER;
			_titleThree.allCaps = true;

			_titleFour = new Label(16, 0xf0f0f0, 215, 30);
			_titleFour.align = TextFormatAlign.CENTER;
			_titleFour.allCaps = true;

			_titleFive = new Label(16, 0xf0f0f0, 215, 30);
			_titleFive.align = TextFormatAlign.CENTER;
			_titleFour.allCaps = true;

			_gridEnd = UIFactory.getScaleBitmap(PanelEnum.GRID_END);
			_players = new Vector.<LeaderboardEntry>;

			_playerHolder = new Sprite();
			_gridHolder = new Sprite();

			_maxHeight = 0;

			_scrollRect = new Rectangle(0, 0, 632, 519);

			var dragBarBGRect:Rectangle      = new Rectangle(0, 3, 5, 7);
			_scrollbar = new VScrollbar();
			_scrollbar.init(7, 480, 0, 0, dragBarBGRect, '', 'ScrollBarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 40;

			addChild(_bg);
			addChild(_subTitle);
			addChild(_accordian);
			addChild(_container);
			addChild(_gridHolder);
			addChild(_playerHolder);
			addChild(_scrollbar);
			addChild(_titleOne);
			addChild(_titleTwo);
			addChild(_titleThree);
			addChild(_titleFour);
			addChild(_titleFive);
			addChild(_noGridText);

			presenter.addOnLeaderboardDataUpdatedListener(leaderboardUpdate);

			addEffects();
			effectsIN();

			onAccordianSelected(String(LeaderboardEnum.PLAYER_GLOBAL), String(LeaderboardEnum.BASE_RATING), null);
		}

		private function onAccordianSelected( groupID:String, subItemID:String, data:* ):void
		{
			_playerHolder.alpha = 0;
			_gridHolder.alpha = 0;
			_scrollbar.alpha = 0;

			_titleOne.alpha = 0;
			_titleTwo.alpha = 0;
			_titleThree.alpha = 0;
			_titleFour.alpha = 0;
			_titleFive.alpha = 0;

			var group:AccordianGroup          = _accordian.getGroup(groupID);
			if (!subItemID && group.hasSubItems)
			{
				subItemID = group.subItems[0].id;
				_accordian.setSelected(groupID, subItemID)
			}

			_groupID = groupID;
			_subItemID = subItemID;

			presenter.currentLeaderboardScope = int(_groupID);
			presenter.currentLeaderboardType = int(_subItemID);

			setUpGrid();

			var leaderboardData:LeaderboardVO = presenter.getLeaderboardData();

			if (leaderboardData)
				leaderboardUpdate(leaderboardData);
		}

		private function setUpGrid():void
		{
			var bitmap:Bitmap;
			var endBitmap:Bitmap;
			var finalTitle:Label;

			_playerHolder.visible = true;
			_gridHolder.visible = true;
			_scrollbar.visible = true;

			_titleOne.visible = true;
			_titleTwo.visible = true;
			_titleThree.visible = true;
			_titleFour.visible = true;
			_titleFive.visible = true;

			_noGridText.visible = false;

			_gridHolder.removeChildren();

			switch (int(_groupID))
			{
				case LeaderboardEnum.PLAYER_GLOBAL:
				case LeaderboardEnum.PLAYER_PERSONAL:
				case LeaderboardEnum.PLAYER_SECTOR:
				case LeaderboardEnum.PLAYER_ALLIANCE:
					bitmap = _generalGrid;

					_titleTwo.width = 120;

					_titleThree.text = _allianceText;
					_titleThree.x = 170;
					_titleThree.width = 225;

					_titleFour.text = _sectorText;
					_titleFour.x = 394;
					_titleFour.width = 126;

					_titleFive.visible = true;
					_titleFour.visible = true;

					finalTitle = _titleFive;
					break;
				case LeaderboardEnum.ALLIANCE_GLOBAL:
				case LeaderboardEnum.ALLIANCE_PERSONAL:
					_titleFive.visible = false;
					_titleTwo.width = 225;
					if (int(_subItemID) == LeaderboardEnum.ALLIANCE_NUM_MEMBERS)
					{
						bitmap = _noMemberAllianceGrid;
						_titleFour.visible = false;
						finalTitle = _titleThree;
					} else
					{
						bitmap = _allianceGrid;

						_titleThree.text = _numOfMembersText;
						_titleThree.x = 275;
						_titleThree.width = 150;

						_titleFour.visible = true;

						finalTitle = _titleFour;

					}
					break;
			}

			_gridHolder.addChildAt(bitmap, 0);
			var stringToUse:String = '';
			switch (int(_subItemID))
			{
				case LeaderboardEnum.BASE_RATING:
					setContainerTitle(_baseRatingText);
					finalTitle.text = _baseRatingText;
					break;
				case LeaderboardEnum.EXPERIENCE:
					if (int(_groupID) == LeaderboardEnum.ALLIANCE_GLOBAL || int(_groupID) == LeaderboardEnum.ALLIANCE_PERSONAL)
						stringToUse = _totalExperienceText;
					else
						stringToUse = _levelText;

					setContainerTitle(stringToUse);
					finalTitle.text = stringToUse;
					break;
				case LeaderboardEnum.COMMENDATION_COMBINED:
					if (int(_groupID) == LeaderboardEnum.ALLIANCE_GLOBAL || int(_groupID) == LeaderboardEnum.ALLIANCE_PERSONAL)
						stringToUse = _totalCommendationRatingText;
					else
						stringToUse = _commendationRankText;

					setContainerTitle(stringToUse);
					finalTitle.text = stringToUse;
					break;
				case LeaderboardEnum.HIGHEST_FLEET_RATING:
					if (int(_groupID) == LeaderboardEnum.ALLIANCE_GLOBAL || int(_groupID) == LeaderboardEnum.ALLIANCE_PERSONAL)
						stringToUse = _totalHighestFleetRatingText;
					else
						stringToUse = _highestFleetRatingText;

					setContainerTitle(stringToUse);
					finalTitle.text = stringToUse;
					break;
				case LeaderboardEnum.WINS:
					setContainerTitle(_victoriesText);
					finalTitle.text = _victoriesText;
					break;
				case LeaderboardEnum.KILL_DEATH_RATIO:
					setContainerTitle(_winLossText);
					finalTitle.text = _winLossText;
					break;
				case LeaderboardEnum.BLUEPRINT_PARTS:
					setContainerTitle(_totalBlueprintPartsText);
					finalTitle.text = _totalBlueprintPartsText;
					break;
				case LeaderboardEnum.ALLIANCE_NUM_MEMBERS:
					setContainerTitle(_numOfMembersText);
					finalTitle.text = _numOfMembersText;
					break;
				case LeaderboardEnum.ALLIANCE_TOTAL_RATING:
					setContainerTitle(_totalBaseRatingText);
					finalTitle.text = _totalBaseRatingText;
					break;
				case LeaderboardEnum.ALLIANCE_AVERAGE_HIGHEST_FLEET_RATING:
					setContainerTitle(_avgHighestFleetText);
					finalTitle.text = _avgHighestFleetText;
					break;
				case LeaderboardEnum.QUALIFIED_WINS:
					setContainerTitle(_qualifiedWinsPvP);
					finalTitle.text = _qualifiedWinsPvP;
					break;
				case LeaderboardEnum.BUBBLE_HOUR_GRANTED:
					setContainerTitle(_BubbleHoursGranted);
					finalTitle.text = _BubbleHoursGranted;
					break;
				case LeaderboardEnum.PVP_EVENT:
					setContainerTitle(_currentPVPEvent);
					finalTitle.text = _currentPVPEvent;
					break;
				case LeaderboardEnum.PVP_EVENT_QUARTER:
					setContainerTitle(_currentPVPEventQuarter);
					finalTitle.text = _currentPVPEventQuarter;
					break;
				case LeaderboardEnum.CREDITS_TRADE_ROUTE:
					setContainerTitle(_CreditsTradeRoute);
					finalTitle.text = _CreditsTradeRoute;
					break;
				case LeaderboardEnum.RESOURCE_TRADE_ROUTE:
					setContainerTitle(_ResourcesTradeRoute);
					finalTitle.text = _ResourcesTradeRoute;
					break;
				case LeaderboardEnum.RESOURCE_SALVAGED:
					setContainerTitle(_ResourcesSalvaged);
					finalTitle.text = _ResourcesSalvaged;
					break;
				case LeaderboardEnum.CREDITS_BOUNTY:
					setContainerTitle(_CreditsBounty);
					finalTitle.text = _CreditsBounty;
					break;
				case LeaderboardEnum.WINS_VS_BASES:
					setContainerTitle(_WinsVsBase);
					finalTitle.text = _WinsVsBase;
					break;
			}

			_titleOne.x = 0;
			_titleTwo.x = 51;

			var gridEndWidth:int   = 717 - _gridHolder.width;

			_gridEnd.width = gridEndWidth;
			_gridEnd.x = bitmap.x + bitmap.width;
			_gridHolder.addChild(_gridEnd);

			finalTitle.x = _gridEnd.x;
			finalTitle.y = -finalTitle.textHeight;
			finalTitle.width = _gridEnd.width;

			_playerHolder.x = _gridHolder.x = 360 + (558 - _gridHolder.width) * 0.5;
			_playerHolder.y = _gridHolder.y = 78 + (546 - _gridHolder.height) * 0.5;

			_titleOne.x += _gridHolder.x;
			_titleTwo.x += _gridHolder.x;
			_titleThree.x += _gridHolder.x;
			_titleFour.x += _gridHolder.x;
			_titleFive.x += _gridHolder.x;

			_titleOne.y = _titleTwo.y = _titleThree.y = _titleFour.y = _titleFive.y = _gridHolder.y - 20;

			_scrollbar.x = _gridHolder.x + _gridHolder.width + 4;
			_scrollbar.y = _gridHolder.y;
			_scrollbar.resetScroll();

			_scrollRect = new Rectangle(0, 0, _gridHolder.width, _gridHolder.height - 1);
			_scrollRect.y = 0;
			_playerHolder.scrollRect = _scrollRect;


			if (_gridHolder.alpha == 0)
			{
				TweenLite.to(_playerHolder, 0.5, {alpha:1});
				TweenLite.to(_gridHolder, 0.5, {alpha:1});
				TweenLite.to(_scrollbar, 0.5, {alpha:1});

				TweenLite.to(_titleOne, 0.5, {alpha:1});
				TweenLite.to(_titleTwo, 0.5, {alpha:1});
				TweenLite.to(_titleThree, 0.5, {alpha:1});
				TweenLite.to(_titleFour, 0.5, {alpha:1});
				TweenLite.to(_titleFive, 0.5, {alpha:1});
			}
		}

		public function leaderboardUpdate( leaderboardData:LeaderboardVO ):void
		{
			var entries:Vector.<LeaderboardEntryVO>;
			if (int(_groupID) == LeaderboardEnum.ALLIANCE_GLOBAL || int(_groupID) == LeaderboardEnum.ALLIANCE_PERSONAL)
				entries = leaderboardData.alliances;
			else
				entries = leaderboardData.players;

			var len:uint = entries.length;
			if (len > 0)
			{
				var currentUserKey:String  = CurrentUser.id;
				var currentPlayerEntry:LeaderboardEntry;
				var currentPlayer:LeaderboardEntryVO;
				var currentRace:IPrototype;
				var faction:String;
				var assetName:String;
				var factionColor:uint;
				var rank:int;
				var rankProto:IPrototype;
				var rankAssetVO:AssetVO;
				var i:uint;

				while (_players.length > len)
				{
					currentPlayerEntry = _players.shift();
					if (_playerHolder.contains(currentPlayerEntry))
						_playerHolder.removeChild(currentPlayerEntry);

					currentPlayerEntry.destroy();
					currentPlayerEntry = null;
				}

				var currentPlayersLen:uint = _players.length;
				var currentUser:LeaderboardEntry;
				var width:int              = _gridHolder.width;
				var lastTypeXPos:int       = _gridHolder.getChildAt(0).width;
				for (; i < len; ++i)
				{
					currentPlayer = entries[i];
					var isCurrentUser:Boolean = (currentPlayer.key == currentUserKey);
					if (currentPlayer.isAlliance)
						faction = currentPlayer.racePrototype;
					else
						currentRace = presenter.getRacePrototypeByName(currentPlayer.racePrototype);

					if (currentRace)
						faction = currentRace.getUnsafeValue('faction');

					factionColor = CommonFunctionUtil.getFactionColor(faction);

					switch (faction)
					{
						case FactionEnum.IGA:
							assetName = 'igaUIAsset';
							break;
						case FactionEnum.SOVEREIGNTY:
							assetName = 'sovUIAsset';
							break;
						case FactionEnum.TYRANNAR:
							assetName = 'tryUIAsset';
							break;
					}

					rank = CommonFunctionUtil.getCommendationRank(currentPlayer.commendationPointsPvE + currentPlayer.commendationPointsPvP);
					rankProto = presenter.getCommendationRankPrototypesByName(CommonFunctionUtil.getCommendationProtoName(rank));
					rankAssetVO = presenter.getAssetVO(rankProto.getValue(assetName));


					if (i < currentPlayersLen)
					{
						currentPlayerEntry = _players[i];
						if (currentPlayerEntry != null)
							currentPlayerEntry.update(width, lastTypeXPos, int(_groupID), int(_subItemID), currentPlayer, factionColor, rankAssetVO, isCurrentUser);
						else
						{
							currentPlayerEntry = new LeaderboardEntry(presenter);
							currentPlayerEntry.onClick.add(onShowProfile);
							presenter.injectObject(currentPlayerEntry);
							currentPlayerEntry.update(width, lastTypeXPos, int(_groupID), int(_subItemID), currentPlayer, factionColor, rankAssetVO, isCurrentUser);
							_players.push(currentPlayerEntry);
						}
					} else
					{
						currentPlayerEntry = new LeaderboardEntry(presenter);
						currentPlayerEntry.onClick.add(onShowProfile);
						presenter.injectObject(currentPlayerEntry);
						currentPlayerEntry.update(width, lastTypeXPos, int(_groupID), int(_subItemID), currentPlayer, factionColor, rankAssetVO, isCurrentUser);
						_players.push(currentPlayerEntry);
					}


					if (!isCurrentUser)
						_playerHolder.addChild(currentPlayerEntry);
					else
						currentUser = currentPlayerEntry;
				}
				if (currentUser)
					_playerHolder.addChildAt(currentUser, _playerHolder.numChildren);

				layout();
			} else
			{
				switch (int(_groupID))
				{
					case LeaderboardEnum.ALLIANCE_PERSONAL:
						_noGridText.text = _noEntriesAllianceText;
						break;
					default:
						_noGridText.text = _noEntriesText;
						break;
				}
				_noGridText.x = 301 + (558 - _subTitle.textWidth) * 0.5;

				_playerHolder.visible = false;
				_gridHolder.visible = false;
				_scrollbar.visible = false;
				_titleOne.visible = false;
				_titleTwo.visible = false;
				_titleThree.visible = false;
				_titleFour.visible = false;
				_titleFive.visible = false;
				_noGridText.visible = true;
			}
		}

		private function layout():void
		{
			_players.sort(orderEntriesByRank);
			var len:uint = _players.length;
			var selection:LeaderboardEntry;
			var yPos:int = 0;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _players[i];
				selection.index = i + 1;
				selection.y = yPos;
				_maxHeight += selection.height - 1;
				yPos += selection.height - 1;
			}
			_scrollbar.updateScrollableHeight(_maxHeight);
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_playerHolder.scrollRect = _scrollRect;
		}

		private function setContainerTitle( v:String ):void  { Label(_container.getChildAt(2)).text = v; }

		private function orderEntriesByRank( entryOne:LeaderboardEntry, entryTwo:LeaderboardEntry ):Number
		{
			if (!entryOne)
				return -1;
			if (!entryTwo)
				return 1;

			var playerOneRank:int = entryOne.rank;
			var playerTwoRank:int = entryTwo.rank;

			if (playerOneRank > playerTwoRank)
				return 1;
			else if (playerOneRank < playerTwoRank)
				return -1;

			return 0;
		}

		override public function get height():Number
		{
			return _bg.height;
		}

		override public function get width():Number
		{
			return _bg.width;
		}

		private function onShowProfile( v:String ):void
		{
			var playerProfileView:PlayerProfileView = PlayerProfileView(_viewFactory.createView(PlayerProfileView));
			playerProfileView.playerKey = v;
			_viewFactory.notify(playerProfileView);
		}

		[Inject]
		public function set presenter( v:ILeaderboardPresenter ):void  { _presenter = v; }
		public function get presenter():ILeaderboardPresenter  { return ILeaderboardPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.removeOnLeaderboardDataUpdatedListener(leaderboardUpdate);
			super.destroy();

			var len:uint = _players.length;
			var selection:LeaderboardEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _players[i];
				selection.destroy();
			}

			_players.length = 0;

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			if (_accordian)
				ObjectPool.give(_accordian);

			_accordian = null;

			if (_playerHolder)
				TweenLite.killTweensOf(_playerHolder);

			_playerHolder = null;

			if (_gridHolder)
				TweenLite.killTweensOf(_gridHolder);

			_gridHolder = null;

			if (_scrollbar)
			{
				TweenLite.killTweensOf(_scrollbar);
				_scrollbar.destroy();
			}

			_scrollbar = null;

			if (_subTitle)
				_subTitle.destroy();

			_subTitle = null;

			if (_noGridText)
				_noGridText.destroy();

			_noGridText = null;

			if (_titleOne)
			{
				TweenLite.killTweensOf(_titleOne);
				_titleOne.destroy();
			}

			_titleOne = null;

			if (_titleTwo)
			{
				TweenLite.killTweensOf(_titleTwo);
				_titleTwo.destroy();
			}

			_titleTwo = null;

			if (_titleThree)
			{
				TweenLite.killTweensOf(_titleThree);
				_titleThree.destroy();
			}

			_titleThree = null;

			if (_titleFour)
			{
				TweenLite.killTweensOf(_titleFour);
				_titleFour.destroy();
			}

			_titleFour = null;

			if (_titleFive)
			{
				TweenLite.killTweensOf(_titleFive);
				_titleFive.destroy();
			}

			_titleFive = null;
		}
	}
}
