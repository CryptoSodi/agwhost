package com.ui.modal.battlelog
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.battlelog.BattleLogPlayerInfoVO;
	import com.model.battlelog.BattleLogVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.IUIPresenter;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.util.CommonFunctionUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	
	import org.adobe.utils.StringUtil;
	import org.shared.ObjectPool;

	public class BattleLogDetailView extends View
	{
		private var _bg:DefaultWindowBG;

		private var _winners:Vector.<BattleLogPlayerPanel>;
		private var _losers:Vector.<BattleLogPlayerPanel>;

		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _holder:Sprite;

		private var _battleLog:BattleLogVO;

		private var _alloyCount:Label;
		private var _creditsCount:Label;
		private var _energyCount:Label;
		private var _syntheticsCount:Label;

		private var _blueprintTitle:Label;
		private var _blueprintName:Label;
		private var _quoteText:Label;

		private var _victorsHeading:Label;
		private var _losersHeading:Label;

		private var _blueprintFrame:Bitmap;
		private var _blueprintWeb:Bitmap;
		private var _blueprintBg:Bitmap;
		private var _alloyFrame:Bitmap;
		private var _creditsFrame:Bitmap;
		private var _energyFrame:Bitmap;
		private var _syntheticsFrame:Bitmap;

		private var _blueprintImage:ImageComponent;

		private var _victorBG:ScaleBitmap;
		private var _defeatedBG:ScaleBitmap;
		private var _quoteFrame:ScaleBitmap;

		private var _currentUserHasWon:Boolean;

		private var _currentUsersOutcome:int;

		private var _blueprint:IPrototype;
		
		private static var WINNER:int          = 0;
		private static var LOSER:int           = 1;
		private static var DRAW:int            = 2;

		private var _titleText:String          = 'CodeString.BattleLogs.LogTitle'; //Battlelog
		private var _victorText:String         = 'CodeString.BattleLog.Victor'; //Victor
		private var _defeatedText:String       = 'CodeString.BattleLog.Defeated'; //Defeated
		private var _drawText:String           = 'CodeString.BattleLog.DrawTitle'; //Draw
		private var _blueprintTitleText:String = 'CodeString.BattleLog.BlueprintTitle'; //BLUEPRINT

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_winners = new Vector.<BattleLogPlayerPanel>;
			_losers = new Vector.<BattleLogPlayerPanel>;

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(582, 450);
			_bg.addTitle(_titleText, 139);
			_bg.x -= 21;
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);
			addChild(_bg);

			_holder = new Sprite();
			_holder.x = 10;
			_holder.y = 60;
			_maxHeight = 0;

			_scrollRect = new Rectangle(0, 0, 550, 413);
			_scrollRect.y = 0;
			_holder.scrollRect = _scrollRect;

			_blueprintImage = ObjectPool.get(ImageComponent);
			_blueprintImage.init(2000, 2000);

			_victorBG = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER);
			_victorBG.width = 539;
			_victorBG.height = 33;

			_defeatedBG = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER);
			_defeatedBG.width = 539;
			_defeatedBG.height = 33;

			_quoteFrame = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER);
			_quoteFrame.width = 532;
			_quoteFrame.height = 33;

			_blueprintBg = UIFactory.getBitmap('BattleLogBlueprintBGBMD');

			_blueprintFrame = UIFactory.getBitmap('BattleLogBlueprintFrameBMD');

			_blueprintWeb = UIFactory.getBitmap('BattleLogBlueprintWebBMD');

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = 550;
			var scrollbarYPos:Number    = 78;
			_scrollbar.init(7, _scrollRect.height - 32, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollBarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);

			_alloyFrame = UIFactory.getBitmap('LootedResourceAlloyBMD');
			_creditsFrame = UIFactory.getBitmap('LootedResourceCreditsBMD');
			_energyFrame = UIFactory.getBitmap('LootedResourceEnergyBMD');
			_syntheticsFrame = UIFactory.getBitmap('LootedResourceSyntheticsBMD');

			_creditsCount = new Label(16, 0xf04c4c, 108, 30, true, 1);
			_creditsCount.constrictTextToSize = false;
			_creditsCount.align = TextFormatAlign.CENTER;
			_creditsCount.letterSpacing = 1.5;

			_alloyCount = new Label(16, 0xf04c4c, 108, 108, true, 1);
			_alloyCount.constrictTextToSize = false;
			_alloyCount.align = TextFormatAlign.CENTER;
			_alloyCount.letterSpacing = 1.5;

			_energyCount = new Label(16, 0xf04c4c, 108, 108, true, 1);
			_energyCount.constrictTextToSize = false;
			_energyCount.align = TextFormatAlign.CENTER;

			_syntheticsCount = new Label(16, 0xf04c4c, 108, 108, true, 1);
			_syntheticsCount.constrictTextToSize = false;
			_syntheticsCount.align = TextFormatAlign.CENTER;
			_syntheticsCount.letterSpacing = 1.5;

			_quoteText = new Label(21, 0x7ca5fd, 512, 33, true);
			_quoteText.align = TextFormatAlign.CENTER;

			_victorsHeading = new Label(22, 0xffdd3d, 515, 33);
			_victorsHeading.align = TextFormatAlign.LEFT;
			_victorsHeading.text = _victorText;

			_losersHeading = new Label(22, 0xfe4f4f, 515, 33);
			_losersHeading.align = TextFormatAlign.RIGHT;

			_blueprintName = new Label(14, 0xf0f0f0, 189, 25, true, 1);
			_blueprintName.align = TextFormatAlign.CENTER;

			_blueprintTitle = new Label(20, 0xf0f0f0, 139, 25);
			_blueprintTitle.align = TextFormatAlign.CENTER;
			_blueprintTitle.text = _blueprintTitleText;

			_blueprintBg.visible = false;
			_blueprintFrame.visible = false;
			_blueprintWeb.visible = false;
			_blueprintName.visible = false;
			_blueprintImage.visible = false;
			_blueprintTitle.visible = false;

			addChild(_bg);
			addChild(_scrollbar);
			addChild(_holder);

			_holder.addChild(_victorBG);
			_holder.addChild(_defeatedBG);
			_holder.addChild(_victorsHeading);
			_holder.addChild(_losersHeading);
			_holder.addChild(_creditsFrame);
			_holder.addChild(_alloyFrame);
			_holder.addChild(_energyFrame);
			_holder.addChild(_syntheticsFrame);
			_holder.addChild(_quoteFrame);
			_holder.addChild(_creditsCount);
			_holder.addChild(_alloyCount);
			_holder.addChild(_energyCount);
			_holder.addChild(_syntheticsCount);
			_holder.addChild(_quoteText);
			_holder.addChild(_blueprintBg);
			_holder.addChild(_blueprintFrame);
			_holder.addChild(_blueprintWeb);
			_holder.addChild(_blueprintImage);
			_holder.addChild(_blueprintName);
			_holder.addChild(_blueprintTitle);

			presenter.addBattleLogDetailUpdatedListener(onBattleLogListUpdated);
			presenter.addOnPlayerVOAddedListener(onPlayerVOUpdated);
			
			if (_battleLog.hasDetails)
				setUp(_battleLog);
			else
				presenter.getBattleLogDetails(_battleLog.battleKey);

			addEffects();
			effectsIN();
		}

		public function battleLog( v:BattleLogVO ):void
		{
			_battleLog = v;
			//setUp(_battleLog);
		}

		private function onBattleLogListUpdated( v:BattleLogVO ):void
		{
			_battleLog = v;
			setUp(_battleLog);
		}

		private function setUp( v:BattleLogVO ):void
		{
			var winners:Vector.<BattleLogPlayerInfoVO> = _battleLog.winners;
			var losers:Vector.<BattleLogPlayerInfoVO>  = _battleLog.losers;
			var len:uint                               = winners.length;
			var i:uint;
			var creditsAmount:int;
			var alloyAmount:int;
			var energyAmount:int;
			var syntheticsAmount:int;
			var blueprint:String;
			var bpAsset:AssetVO;
			var currentPanel:BattleLogPlayerPanel;
			var currentPlayer:BattleLogPlayerInfoVO;
			var currentUserKey:String                  = CurrentUser.id;

			if (len < 1)
				_currentUsersOutcome = DRAW;

			for (; i < len; ++i)
			{
				currentPlayer = winners[i];
				
				if(currentPlayer == null)
					continue;
				
				currentPanel = new BattleLogPlayerPanel(currentPlayer, true);
				currentPanel.setUp(presenter.getShipPrototypeByName, presenter.getAssetVOFromIPrototype, presenter.loadPortraitMedium, presenter.loadPortraitIcon);
				_holder.addChild(currentPanel);

				if (_currentUsersOutcome != WINNER)
				{
					alloyAmount -= currentPlayer.alloyGained;
					energyAmount -= currentPlayer.energyGained;
					syntheticsAmount -= currentPlayer.syntheticGained;
				}
				if (currentPlayer.playerKey == currentUserKey)
				{
					_winners.unshift(currentPanel);
					creditsAmount = currentPlayer.creditsGained;
					alloyAmount = currentPlayer.alloyGained;
					energyAmount = currentPlayer.energyGained;
					syntheticsAmount = currentPlayer.syntheticGained;
					blueprint = currentPlayer.blueprintGained;
					_currentUsersOutcome = WINNER;
				} else
				{
					_winners.push(currentPanel);
					currentPanel.onViewBaseClick.add(gotoBase);
					presenter.requestPlayer(currentPlayer.playerKey);
				}
			}

			len = losers.length;
			for (i = 0; i < len; ++i)
			{
				currentPlayer = losers[i];
				currentPanel = new BattleLogPlayerPanel(currentPlayer, false);
				currentPanel.setUp(presenter.getShipPrototypeByName, presenter.getAssetVOFromIPrototype, presenter.loadPortraitMedium, presenter.loadPortraitIcon);
				_holder.addChild(currentPanel);

				if (currentPlayer.playerKey == currentUserKey)
				{
					if (_currentUsersOutcome != DRAW)
						_currentUsersOutcome = LOSER;
					_losers.unshift(currentPanel);
					blueprint = currentPlayer.blueprintGained;
				} else
				{
					_losers.push(currentPanel);
					currentPanel.onViewBaseClick.add(gotoBase);
					presenter.requestPlayer(currentPlayer.playerKey);
				}
			}

			if (blueprint != '')
				_blueprint = presenter.getBlueprintPrototypeByName(blueprint);

			if (_blueprint)
			{
				var rarity:String = _blueprint.getUnsafeValue('rarity');
				if (rarity != 'Common')
				{
					var glow:GlowFilter = CommonFunctionUtil.getRarityGlow(rarity);
					_blueprintName.textColor = glow.color;
					_blueprintFrame.filters = [glow];
				}

				bpAsset = presenter.getAssetVOFromIPrototype(_blueprint);
				_blueprintName.text = bpAsset.visibleName;

				_blueprintBg.visible = true
				_blueprintFrame.visible = true;
				_blueprintWeb.visible = true;
				_blueprintName.visible = true;
				_blueprintImage.visible = true;
				_blueprintTitle.visible = true;
			}


			var resourceColor:uint;
			var faction:String;
			var victory:Boolean;
			switch (_currentUsersOutcome)
			{
				case WINNER:
					resourceColor = 0x7afe60;
					faction = CurrentUser.faction;
					victory = true;
					break;
				case LOSER:
					resourceColor = 0xfe4f4f;
					faction = BattleLogPlayerInfoVO(winners[Math.floor(CommonFunctionUtil.randomMinMax(0, (winners.length - 1)))]).faction;
					victory = false;
					break;
				case DRAW:
					resourceColor = 0xfe4f4f;
					faction = CurrentUser.faction;
					victory = false;
					break;
			}

			_syntheticsCount.textColor = _energyCount.textColor = _alloyCount.textColor = _creditsCount.textColor = resourceColor;
			_creditsCount.text = StringUtil.commaFormatNumber(creditsAmount);
			_alloyCount.text = StringUtil.commaFormatNumber(alloyAmount);
			_energyCount.text = StringUtil.commaFormatNumber(energyAmount);
			_syntheticsCount.text = StringUtil.commaFormatNumber(syntheticsAmount);

			var dialogueOptions:Vector.<IPrototype>    = presenter.getBattleEndDialogByFaction(faction, (victory) ? 'Victory' : 'Taunt');
			_quoteText.text = dialogueOptions[Math.floor(CommonFunctionUtil.randomMinMax(0, (dialogueOptions.length - 1)))].getValue('dialogString');
			
			//todo uncomment when ready
			//var audioDir:String = dialogueOptions[Math.floor(CommonFunctionUtil.randomMinMax(0, (dialogueOptions.length - 1)))].getValue('dialogAudioString');
			//if(audioDir.length>0)
			//	presenter.playSound(audioDir, 0.75);

			layout();

			if (bpAsset)
				presenter.loadIcon(bpAsset.mediumImage, layoutBlueprint);
		}

		private function onEntryClicked( entry:BattleLogEntry ):void
		{
			presenter.getBattleLogDetails(entry.battleKey);
		}

		private function onLoadImage( race:String, callback:Function ):void
		{
			if (presenter)
				presenter.loadPortraitSmall(race, callback);
		}

		private function layoutBlueprint( asset:BitmapData ):void
		{
			_blueprintImage.onImageLoaded(asset);
			_blueprintImage.x = _blueprintWeb.x + (_blueprintWeb.width - _blueprintImage.width) * 0.5;
			_blueprintImage.y = _blueprintWeb.y + (_blueprintWeb.height - _blueprintImage.height) * 0.5;
		}

		private function layout():void
		{
			var hasBlueprint:Boolean = (_blueprint != null);


			if (_currentUsersOutcome != DRAW)
				layoutNormalConditions();
			else
				layoutDrawConditions();

			var offset:int           = (hasBlueprint) ? 41 : 10;
			var yPos:Number          = _defeatedBG.y + _defeatedBG.height + offset;

			_creditsFrame.x = (hasBlueprint) ? 0 : 100;
			_creditsFrame.y = yPos;

			_alloyFrame.x = _creditsFrame.x + 175;
			_alloyFrame.y = _creditsFrame.y;

			_energyFrame.x = _creditsFrame.x;
			_energyFrame.y = _creditsFrame.y + 50;

			_syntheticsFrame.x = _alloyFrame.x;
			_syntheticsFrame.y = _creditsFrame.y + 50;

			_creditsCount.x = _creditsFrame.x + 42;
			_creditsCount.y = _creditsFrame.y + 16;

			_alloyCount.x = _alloyFrame.x + 42;
			_alloyCount.y = _alloyFrame.y + 16;

			_energyCount.x = _energyFrame.x + 42;
			_energyCount.y = _energyFrame.y + 16;

			_syntheticsCount.x = _syntheticsFrame.x + 42;
			_syntheticsCount.y = _syntheticsFrame.y + 16;

			_blueprintBg.x = _alloyFrame.x + 173;
			_blueprintBg.y = _defeatedBG.y + _defeatedBG.height + 3;

			_blueprintFrame.x = _blueprintBg.x + (_blueprintBg.width - _blueprintFrame.width) * 0.5;
			_blueprintFrame.y = _blueprintBg.y + (_blueprintBg.height - _blueprintFrame.height) * 0.5 - 8;

			_blueprintWeb.x = _blueprintFrame.x + (_blueprintFrame.width - _blueprintWeb.width) * 0.5;
			_blueprintWeb.y = _blueprintFrame.y + (_blueprintFrame.height - _blueprintWeb.height) * 0.5;

			_blueprintName.x = _blueprintBg.x + 1;
			_blueprintName.y = _blueprintBg.y + _blueprintBg.height - _blueprintName.textHeight - 6;

			_blueprintTitle.x = _blueprintBg.x - 1;
			_blueprintTitle.y = _blueprintBg.y + _blueprintBg.height - _blueprintTitle.textHeight + 20;
			_blueprintTitle.rotation = -90;

			_quoteFrame.y = (hasBlueprint) ? (_blueprintBg.y + _blueprintBg.height + 10) : (_syntheticsFrame.y + _syntheticsFrame.height + 38);
			
			_quoteText.x = _quoteFrame.x + 11;
			_quoteText.y = _quoteFrame.y + 5;

			_maxHeight = _quoteFrame.y + _quoteFrame.height + 8;

			_scrollbar.updateScrollableHeight(_maxHeight);
		}

		private function layoutNormalConditions():void
		{
			_losersHeading.text = _defeatedText;

			_victorsHeading.x = 12;
			_victorsHeading.y = -4;
			_victorBG.y = 22;

			var i:uint;
			var len:uint = _winners.length;
			var selection:BattleLogPlayerPanel;
			var xPos:int = 11;
			var yPos:int = _victorBG.y + 5;
			_maxHeight = 0;
			for (i = 0; i < len; ++i)
			{
				selection = _winners[i];
				selection.y = yPos;
				yPos += selection.height + 10;
			}

			if (yPos > _victorBG.y + _victorBG.height)
				_victorBG.height = yPos - 2;

			_defeatedBG.y = _victorBG.y + _victorBG.height + 26;

			_losersHeading.x = 5;
			_losersHeading.y = _defeatedBG.y - _losersHeading.textHeight - 2;

			yPos = _defeatedBG.y + 5;
			len = _losers.length;
			for (i = 0; i < len; ++i)
			{
				selection = _losers[i];
				selection.y = yPos;
				yPos += selection.height + 10;
			}

			if (yPos > _defeatedBG.y + _defeatedBG.height)
				_defeatedBG.height = (yPos - _defeatedBG.y) + 20;
		}

		private function layoutDrawConditions():void
		{

			var i:uint;
			var len:uint = _winners.length;
			var selection:BattleLogPlayerPanel;
			var xPos:int = 11;
			var yPos:int = _victorBG.y;

			_losersHeading.text = _drawText;

			_victorsHeading.visible = false;
			_victorBG.visible = false;

			_losersHeading.x = 12;
			_losersHeading.y = -4;
			_defeatedBG.y = 22;

			yPos = _defeatedBG.y + 5;
			len = _losers.length;
			for (i = 0; i < len; ++i)
			{
				selection = _losers[i];
				selection.y = yPos;
				yPos += selection.height + 10;
			}

			if (yPos > _defeatedBG.y + _defeatedBG.height)
				_defeatedBG.height = (yPos - _defeatedBG.y) + 20;
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		private function onPlayerVOUpdated( player:PlayerVO ):void
		{
			var i:uint;
			var len:uint = _winners.length;
			var selection:BattleLogPlayerPanel;
			var playerUpdated:Boolean;
			for (i = 0; i < len; ++i)
			{
				selection = _winners[i];
				if (selection.playerID == player.id)
				{
					playerUpdated = true;
					selection.player = player;
					break;
				}

			}

			if (!playerUpdated)
			{
				len = _losers.length;
				for (i = 0; i < len; ++i)
				{
					selection = _losers[i];
					if (selection.playerID == player.id)
					{
						playerUpdated = true;
						selection.player = player;
						break;
					}
				}
			}
		}
		
		private function gotoBase( baseXPos:Number, baseYPos:Number, baseSector:String ):void
		{
			presenter.gotoCoords(baseXPos, baseYPos, baseSector);
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }
		
		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.removeBattleLogDetailUpdatedListener(onBattleLogListUpdated);
			presenter.removeOnPlayerVOAddedListener(onPlayerVOUpdated);
			super.destroy();

			_bg = null;
			_quoteFrame = null;

			_holder = null;

			_scrollbar.destroy();
			_scrollbar = null;

			var len:uint = _winners.length;
			var i:uint;
			var currentPlayer:BattleLogPlayerPanel;
			for (; i < len; ++i)
			{
				currentPlayer = _winners[i];
				currentPlayer.destroy();
				currentPlayer = null;
			}
			_winners.length = 0;

			len = _losers.length;
			for (i = 0; i < len; ++i)
			{
				currentPlayer = _losers[i];
				currentPlayer.destroy();
				currentPlayer = null;
			}
			_losers.length = 0;

			_scrollRect = null;

			_holder = null;

			_battleLog = null;

			_alloyCount.destroy();
			_alloyCount = null;

			_creditsCount.destroy();
			_creditsCount = null;

			_energyCount.destroy();
			_energyCount = null;

			_syntheticsCount.destroy();
			_syntheticsCount = null;

			_blueprintTitle.destroy();
			_blueprintTitle = null;

			_blueprintName.destroy();
			_blueprintName = null;

			_quoteText.destroy();
			_quoteText = null;

			_victorsHeading.destroy();
			_victorsHeading = null;

			_losersHeading.destroy();
			_losersHeading = null;

			_blueprintFrame = null;
			_blueprintWeb = null;
			_blueprintBg = null;
			_alloyFrame = null;
			_creditsFrame = null;
			_energyFrame = null;
			_syntheticsFrame = null;
			
			ObjectPool.give(_blueprintImage);
			_blueprintImage = null;

			_victorBG = null;
			_defeatedBG = null;

			_currentUserHasWon = false;
			_blueprint = null;

			_maxHeight = 0;
		}

	}
}
