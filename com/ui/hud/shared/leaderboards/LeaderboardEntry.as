package com.ui.hud.shared.leaderboards
{
	import com.enum.LeaderboardEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.leaderboards.LeaderboardEntryVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.ILeaderboardPresenter;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;
	import org.adobe.utils.StringUtil;

	public class LeaderboardEntry extends Sprite
	{
		public var onClick:Signal;

		private var _presenter:ILeaderboardPresenter;

		private var _bg:ScaleBitmap;

		private var _entryOne:Label;
		private var _entryTwo:Label;
		private var _entryThree:Label;
		private var _entryFour:Label;
		private var _entryFive:Label;

		private var _tooltipHitArea:Sprite;

		private var _image:ImageComponent;

		private var _getSector:Function;

		private var _data:LeaderboardEntryVO;

		private var _scope:int;
		private var _type:int;
		private var _rank:int;

		private var _width:int;

		private var _isCurrentUser:Boolean;

		private var HEIGHT:Number                   = 41;

		private var _tooltip:Tooltips;

		private var _noneText:String                = 'CodeString.Shared.None'; //None
		private var _winLossTooltipText:String      = 'CodeString.Leaderboard.Tooltip.WinLoss'; //Kills: [[Number.Kills]] \nLosses:  [[Number.Losses]]
		private var _commendationTooltipText:String = 'CodeString.Leaderboard.Tooltip.CommendationRank'; //Commendation Points PvE: [[Number.PvEPoints]] \nCommendation Points PvP: [[Number.PvPPoints]]


		public function LeaderboardEntry( presenter:ILeaderboardPresenter )
		{
			_presenter = presenter;

			onClick = new Signal(String);

			var center:Number = HEIGHT * 0.5 - 9;

			_entryOne = new Label(16, 0xf0f0f0, 100, 39, false);
			_entryOne.constrictTextToSize = false;
			_entryOne.align = TextFormatAlign.CENTER;
			_entryOne.y = center;

			_entryTwo = new Label(16, 0xf0f0f0, 100, 39, false);
			_entryTwo.constrictTextToSize = false;
			_entryTwo.align = TextFormatAlign.CENTER;
			_entryTwo.y = center;

			_entryThree = new Label(16, 0xf0f0f0, 100, 39, false);
			_entryThree.constrictTextToSize = false;
			_entryThree.align = TextFormatAlign.CENTER;
			_entryThree.y = center;

			_entryFour = new Label(16, 0xf0f0f0, 100, 39, false);
			_entryFour.constrictTextToSize = false;
			_entryFour.align = TextFormatAlign.CENTER;
			_entryFour.y = center;

			_entryFive = new Label(16, 0xf0f0f0, 100, 39);
			_entryFive.constrictTextToSize = false;
			_entryFive.align = TextFormatAlign.CENTER;
			_entryFive.y = center;

			_image = ObjectPool.get(ImageComponent);
			_image.init(34, 34);
			_image.x = 375;
			_image.y = 3;

			_tooltipHitArea = new Sprite();

			addChild(_entryOne);
			addChild(_entryTwo);
			addChild(_entryThree);
			addChild(_entryFour);
			addChild(_entryFive);
			addChild(_image);
			addChild(_tooltipHitArea);
		}

		public function update( width:int, lastTypeXPos:int, scope:int, type:int, data:LeaderboardEntryVO, factionColor:uint, rankAssetVO:AssetVO, isCurrentUser:Boolean ):void
		{
			_tooltip.removeTooltip(_tooltipHitArea);
			_tooltipHitArea.x = lastTypeXPos;
			_tooltipHitArea.graphics.clear();
			_tooltipHitArea.graphics.beginFill(0xf0f0f0, 0.0);
			_tooltipHitArea.graphics.drawRect(0, 0, (width - lastTypeXPos), 40);
			_tooltipHitArea.graphics.endFill();

			var filteredLabel:Label;
			var offset:int;
			var localization:Localization;
			var tooltip:String = '';
			_data = data;
			_scope = scope;
			_type = type;
			_width = width;
			_isCurrentUser = isCurrentUser;

			_entryTwo.text = _data.name;
			_entryTwo.textColor = factionColor;

			_entryTwo.width = _entryTwo.textWidth + 5;

			_image.visible = false;
			if (data.isAlliance)
			{
				buttonMode = false;
				removeEventListener(MouseEvent.CLICK, onShowProfileClick);
				_entryFour.useLocalization = false;
				_entryFive.visible = false;
				if (_type == LeaderboardEnum.ALLIANCE_NUM_MEMBERS)
				{
					filteredLabel = _entryThree;
					_entryThree.textColor = factionColor;
					_entryFour.visible = false;
				} else
				{
					_entryFour.visible = true;
					_entryFour.textColor = factionColor;
					filteredLabel = _entryFour;

					_entryThree.useLocalization = false;
					_entryThree.text = String(_data.numOfMembers);
					_entryThree.textColor = factionColor;
					_entryThree.width = _entryThree.textWidth + 5;
					_entryThree.x = 275 + (150 - _entryThree.width) * 0.5;
				}
				_entryTwo.x = 51 + (223 - _entryTwo.width) * 0.5;

			} else
			{
				buttonMode = true;
				addEventListener(MouseEvent.CLICK, onShowProfileClick, false, 0, true);
				filteredLabel = _entryFive;
				_entryFive.textColor = factionColor;
				_entryFive.visible = true;
				_entryFour.visible = true;

				if (_data.allianceName != '')
				{
					_entryThree.useLocalization = false;
					_entryThree.text = _data.allianceName;
				} else
				{
					_entryThree.useLocalization = true;
					_entryThree.text = _noneText;
				}

				_entryTwo.x = 51 + (118 - _entryTwo.width) * 0.5;

				_entryThree.textColor = factionColor;
				_entryThree.width = _entryThree.textWidth + 5;
				_entryThree.x = 170 + (223 - _entryThree.width) * 0.5;

				_entryFour.useLocalization = true;
				_entryFour.text = _presenter.getSectorName(_data.sectorOwner);
				_entryFour.textColor = factionColor;
				_entryFour.width = _entryFour.textWidth + 5;
				_entryFour.x = 394 + (126 - _entryFour.width) * 0.5;
			}

			switch (_type)
			{
				case LeaderboardEnum.ALLIANCE_NUM_MEMBERS:
					_rank = _data.numOfMembersRank;
					filteredLabel.text = StringUtil.commaFormatNumber(Math.round(_data.numOfMembers));
					break;
				case LeaderboardEnum.BASE_RATING:
					_rank = _data.baseRatingRank;
					filteredLabel.text = StringUtil.commaFormatNumber(Math.round(_data.baseRating));
					break;
				case LeaderboardEnum.ALLIANCE_TOTAL_RATING:
					_rank = _data.highestBaseRanking;
					filteredLabel.text = StringUtil.commaFormatNumber(Math.round(_data.highestBaseRating));
					break;
				case LeaderboardEnum.EXPERIENCE:
					_rank = _data.experienceRank;
					if (data.isAlliance)
						filteredLabel.text = StringUtil.commaFormatNumber(_data.experience);
					else
						filteredLabel.text = StringUtil.commaFormatNumber(CommonFunctionUtil.findPlayerLevel(_data.experience));
					break;
				case LeaderboardEnum.COMMENDATION_COMBINED:
					_rank = _data.commendiationCombinedRank;
					localization = Localization.instance;
					if (data.isAlliance)
					{
						filteredLabel.text = StringUtil.commaFormatNumber(_data.totalCommendationScore);
					} else
					{
						_rank = _data.commendiationCombinedRank;
						filteredLabel.useLocalization = true;
						filteredLabel.text = rankAssetVO.visibleName;
						_presenter.loadIcon(rankAssetVO.iconImage, _image.onImageLoaded);
						_image.filters = [CommonFunctionUtil.getColorMatrixFilter(CommonFunctionUtil.getRankColorBasedOnScore(_data.commendationPointsPvE, _data.commendationPointsPvP))];
						_image.x = lastTypeXPos + 5;
						_image.visible = true;

						if (width - lastTypeXPos != 292)
							offset = 10;
					}
					tooltip = localization.getStringWithTokens(_commendationTooltipText, {"[[Number.PvEPoints]]":data.commendationPointsPvE, "[[Number.PvPPoints]]":data.commendationPointsPvP});
					break;
				case LeaderboardEnum.HIGHEST_FLEET_RATING:
					_rank = _data.highestFleetRank;
					filteredLabel.text = StringUtil.commaFormatNumber(data.highestFleetRating);
					break;
				case LeaderboardEnum.ALLIANCE_AVERAGE_HIGHEST_FLEET_RATING:
					_rank = _data.avgHighestFleetRank;
					filteredLabel.text = StringUtil.commaFormatNumber(data.avgHighestFleetRating);
					break;
				case LeaderboardEnum.WINS:
					_rank = _data.winsRank;
					filteredLabel.text = StringUtil.commaFormatNumber(data.wins);
					break;
				case LeaderboardEnum.KILL_DEATH_RATIO:
					localization = Localization.instance;
					_rank = _data.kdrRank;
					filteredLabel.text = String(data.ktdRatio);
					tooltip = localization.getStringWithTokens(_winLossTooltipText, {"[[Number.Kills]]":data.wins, "[[Number.Losses]]":data.losses});
					break;
				case LeaderboardEnum.BLUEPRINT_PARTS:
					_rank = _data.blueprintPartsRank;
					filteredLabel.text = StringUtil.commaFormatNumber(data.blueprintPartsCollected);
					break;
				case LeaderboardEnum.QUALIFIED_WINS:
					_rank = _data.qualifiedWinsPvPRank;
					filteredLabel.text = StringUtil.commaFormatNumber(_data.qualifiedWinsPvP);
					break;
				case LeaderboardEnum.BUBBLE_HOUR_GRANTED:
					_rank = _data.BubbleHoursGrantedRank;
					filteredLabel.text = StringUtil.commaFormatNumber(_data.BubbleHoursGranted);
					break;
				case LeaderboardEnum.PVP_EVENT:
					_rank = _data.currentPVPEventRank;
					filteredLabel.text = StringUtil.commaFormatNumber(_data.currentPVPEvent);
					break;
				case LeaderboardEnum.PVP_EVENT_QUARTER:
					_rank = _data.currentPVPEventQuarterRank;
					filteredLabel.text = StringUtil.commaFormatNumber(_data.currentPVPEventQuarter);
					break;
				case LeaderboardEnum.CREDITS_TRADE_ROUTE:
					_rank = _data.CreditsTradeRouteRank;
					filteredLabel.text = StringUtil.commaFormatNumber(_data.CreditsTradeRoute);
					break;
				case LeaderboardEnum.RESOURCE_TRADE_ROUTE:
					_rank = _data.ResourcesTradeRouteRank;
					filteredLabel.text = StringUtil.commaFormatNumber(_data.ResourcesTradeRoute);
					break;
				case LeaderboardEnum.RESOURCE_SALVAGED:
					_rank = _data.ResourcesSalvagedRank;
					filteredLabel.text = StringUtil.commaFormatNumber(_data.ResourcesSalvaged);
					break;
				case LeaderboardEnum.CREDITS_BOUNTY:
					_rank = _data.CreditsBountyRank;
					filteredLabel.text = StringUtil.commaFormatNumber(_data.CreditsBounty);
					break;
				case LeaderboardEnum.WINS_VS_BASES:
					_rank = _data.WinsVsBaseRank;
					filteredLabel.text = StringUtil.commaFormatNumber(_data.WinsVsBase);
					break;
			}

			filteredLabel.width = filteredLabel.textWidth + 5;
			filteredLabel.x = lastTypeXPos + ((width - lastTypeXPos) - filteredLabel.width) * 0.5 + offset;

			if (tooltip != '')
				_tooltip.addTooltip(_tooltipHitArea, this, null, tooltip);

			_entryOne.text = String(rank);
			_entryOne.textColor = (_isCurrentUser) ? 0xf7c78b : 0xf0f0f0
			_entryOne.width = _entryOne.textWidth + 5;
			_entryOne.x = (50 - _entryOne.width) * 0.5;
		}

		public function set index( v:uint ):void
		{
			if (_bg != null)
			{
				removeChild(_bg)
				_bg = null;
			}

			if (v % 2 != 0 || _isCurrentUser)
			{
				_bg = UIFactory.getScaleBitmap((_isCurrentUser) ? PanelEnum.LEADERBOARD_ROW_GLOW : PanelEnum.LEADERBOARD_ROW);
				_bg.width = _width;
				addChildAt(_bg, 0);
			}
		}

		private function onShowProfileClick( e:MouseEvent ):void
		{
			if (_data)
				onClick.dispatch(_data.key);
		}

		public function get rank():int  { return _rank; }

		override public function get height():Number  { return HEIGHT; }
		override public function get width():Number  { return _width; }

		[Inject]
		public function set tooltips( v:Tooltips ):void  { _tooltip = v; }

		public function destroy():void
		{

			_bg = null;

			if (_entryOne)
				_entryOne.destroy();
			_entryOne = null;

			if (_entryTwo)
				_entryTwo.destroy();
			_entryTwo = null;

			if (_entryThree)
				_entryThree.destroy();
			_entryThree = null;

			if (_entryFour)
				_entryFour.destroy();
			_entryFour = null;


			if (_entryFive)
				_entryFive.destroy();
			_entryFive = null;

			if (_image)
				ObjectPool.give(_image);

			_image = null;

			if (_tooltip && _tooltipHitArea)
				_tooltip.removeTooltip(_tooltipHitArea);

			_tooltipHitArea = null;

			_tooltip = null;
		}
	}
}
