package com.ui.modal.battlelog
{
	import com.enum.ui.ButtonEnum;
	import com.model.asset.AssetVO;
	import com.model.battlelog.BattleLogEntityInfoVO;
	import com.model.battlelog.BattleLogPlayerInfoVO;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.BattleLogEntityDetailInfo;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.ui.modal.dock.ShipIcon;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class BattleLogPlayerPanel extends Sprite
	{
		public var onViewBaseClick:Signal;

		private var _playerPortrait:ImageComponent;

		private var _playerPortraitFrame:Bitmap;
		private var _shipsInFleetBg:Bitmap;
		private var _fleetFrame:Bitmap;

		private var _playerName:Label;
		private var _playerRating:Label;

		private var _entityText:Vector.<Label>;
		private var _gotoBaseBtn:BitmapButton;

		private var _isWinner:Boolean;

		private var _ships:Vector.<ShipIcon>;

		private var _battleLogPlayer:BattleLogPlayerInfoVO;
		private var _player:PlayerVO;

		private var _getShipPrototype:Function;
		private var _getUIAsset:Function;
		private var _loadPortraitMedium:Function;
		private var _loadPortraitIcon:Function;

		private var WINNER_PORTRAIT_X:Number    = 5;
		private var LOSER_PORTRAIT_X:Number     = 391;

		private var WINNER_GOTO_BASE_X:Number   = 244;
		private var LOSER_GOTO_BASE_X:Number    = 167;

		private var WINNER_BATTLE_TEXT_X:Number = 139;
		private var LOSER_BATTLE_TEXT_X:Number  = 174;

		private var BATTLE_ENTITY_Y:Number      = 58;

		private var WINNER_BATTLE_SHIP_X:Number = 361;
		private var LOSER_BATTLE_SHIP_X:Number  = 25;
		private var BATTLE_SHIP_Y:Number        = 8;

		private var PANEL_HEIGHT:Number         = 143;

		private var _leftEntityText:String      = 'CodeString.BattleLogs.EntityHealthLeft';
		private var _RightEntityText:String     = 'CodeString.BattleLogs.EntityHealthRight';
		private var _fleetRatingText:String     = 'CodeString.BattleLogs.FleetRating';
		private var _baseRatingText:String      = 'CodeString.BattleLogs.BaseRating';
		private var _baseHealthText:String      = 'CodeString.BattleLog.BaseHealth';
		private var _viewBaseText:String        = 'CodeString.Shared.ViewBase' //VIEW BASE

		public function BattleLogPlayerPanel( battleLogPlayer:BattleLogPlayerInfoVO, won:Boolean )
		{
			onViewBaseClick = new Signal(Number, Number, String);

			_ships = new Vector.<ShipIcon>;
			_entityText = new Vector.<Label>;
			_battleLogPlayer = battleLogPlayer;
			_isWinner = won;
			var factionColor:uint        = CommonFunctionUtil.getFactionColor(_battleLogPlayer.faction);
			var ratingText:String        = (_battleLogPlayer.hasFleet) ? _fleetRatingText : _baseRatingText;
			var ratingVariables:Object   = (_battleLogPlayer.hasFleet) ? {'[[Number.Rating]]':_battleLogPlayer.fleet.fleetRating()} : {'[[Number.Rating]]':_battleLogPlayer.base.baseRatings};

			var portraitFrameClass:Class = Class(getDefinitionByName('BattleLogLargePortraitFrameBMD'));
			_playerPortrait = ObjectPool.get(ImageComponent);
			_playerPortrait.init(2000, 2000);

			var bmd:BitmapData           = BitmapData(new portraitFrameClass());
			bmd.applyFilter(bmd, bmd.rect, new Point(0, 0), CommonFunctionUtil.getColorMatrixFilter(factionColor));
			_playerPortraitFrame = new Bitmap(bmd);

			_playerName = new Label(24, 0xf0f0f0, 210, 25);
			_playerName.constrictTextToSize = false;
			_playerName.align = (_isWinner) ? TextFormatAlign.LEFT : TextFormatAlign.RIGHT;
			_playerName.text = _battleLogPlayer.name;
			_playerName.textColor = factionColor;

			_playerRating = new Label(20, 0xfbefaf, 210, 25);
			_playerRating.constrictTextToSize = false;
			_playerRating.align = (_isWinner) ? TextFormatAlign.LEFT : TextFormatAlign.RIGHT;
			_playerRating.constrictTextToSize = false;
			_playerRating.setTextWithTokens(ratingText, ratingVariables);

			_gotoBaseBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 130, 29, 0, 0, _viewBaseText);
			_gotoBaseBtn.visible = false;
			_gotoBaseBtn.addEventListener(MouseEvent.MOUSE_UP, onButtonClick, false, 0, true);

			_fleetFrame = UIFactory.getBitmap('SectorFleetSelectionBGBMD');


			addChild(_playerPortrait);
			addChild(_playerName);
			addChild(_playerRating);
			addChild(_playerPortraitFrame);
			addChild(_fleetFrame);
			addChild(_gotoBaseBtn);
		}

		public function setUp( getShipPrototype:Function, getUIAsset:Function, loadPortraitMedium:Function, loadPortraitIcon:Function ):void
		{
			_getShipPrototype = getShipPrototype;
			_getUIAsset = getUIAsset;
			_loadPortraitMedium = loadPortraitMedium;
			_loadPortraitIcon = loadPortraitIcon;

			if (_battleLogPlayer.hasFleet)
				setUpPlayerFleet();
			else
				setUpBase();

			_loadPortraitMedium(_battleLogPlayer.race, _playerPortrait.onImageLoaded);
			layout();
		}

		private function layout():void
		{

			_playerName.x = (_isWinner) ? WINNER_BATTLE_TEXT_X : LOSER_BATTLE_TEXT_X;
			_playerName.y = 8;

			_playerRating.x = (_isWinner) ? WINNER_BATTLE_TEXT_X : LOSER_BATTLE_TEXT_X;
			_playerRating.y = 35;

			_playerPortrait.x = ((_isWinner) ? WINNER_PORTRAIT_X : LOSER_PORTRAIT_X) + 5;
			_playerPortrait.y = 8;

			_playerPortraitFrame.x = ((_isWinner) ? WINNER_PORTRAIT_X : LOSER_PORTRAIT_X);
			_playerPortraitFrame.y = 3;

			_gotoBaseBtn.x = _playerPortraitFrame.x + (_playerPortraitFrame.width - _gotoBaseBtn.width) * 0.5;
			_gotoBaseBtn.y = _playerPortraitFrame.y + _playerPortraitFrame.height + 2;

			_fleetFrame.x = (_isWinner) ? WINNER_BATTLE_SHIP_X - 1 : LOSER_BATTLE_SHIP_X - 1;
			_fleetFrame.y = BATTLE_SHIP_Y - 1;

			var xPos:Number = (_isWinner) ? WINNER_BATTLE_TEXT_X : LOSER_BATTLE_TEXT_X;
			var yPos:Number = BATTLE_ENTITY_Y;
			var len:uint    = _entityText.length;
			var currentLabel:Label;
			for (var i:uint = 0; i < len; ++i)
			{
				currentLabel = _entityText[i];
				currentLabel.x = xPos;
				currentLabel.y = yPos;

				yPos += currentLabel.textHeight;
			}
		}

		private function setUpBase():void
		{
			_fleetFrame.visible = false;

			var healthValue:Number = Math.round(_battleLogPlayer.base.health * 100);
			var healthColor:uint   = getHealthColor(healthValue);
			var textToUse:String   = (_isWinner) ? _leftEntityText : _RightEntityText;
			var base:Label         = new Label(12, 0xf0f0f0, 210, 25);
			base.align = (_isWinner) ? TextFormatAlign.LEFT : TextFormatAlign.RIGHT;
			base.constrictTextToSize = false;
			base.x = (_isWinner) ? WINNER_BATTLE_TEXT_X : LOSER_BATTLE_TEXT_X;
			base.y = BATTLE_ENTITY_Y;
			base.setHtmlTextWithTokens(textToUse, {'[[HexNumber.Color]]':healthColor.toString(16), '[[Number.EntityHealth]]':healthValue, '[[String.EntityName]]':_baseHealthText});
			_entityText.push(base);
			addChild(base);
		}

		private function setUpPlayerFleet():void
		{
			_fleetFrame.visible = true;

			var image:ShipIcon;
			var xPos:Number;
			var yPos:Number;

			var ships:Vector.<BattleLogEntityInfoVO> = _battleLogPlayer.fleet.ships
			var currentShip:BattleLogEntityDetailInfo;
			var shipProto:IPrototype;
			for (var i:uint = 0; i < 6; ++i)
			{
				if( ships.length > i )
				{
					shipProto = _getShipPrototype(ships[i].protoName);
				}
				else
				{
					shipProto = null;				
				}
				image = new ShipIcon();
				image.scale(0.37, 0.37);

				xPos = (_isWinner) ? WINNER_BATTLE_SHIP_X : LOSER_BATTLE_SHIP_X;
				yPos = BATTLE_SHIP_Y;

				switch (i)
				{
					case 0:
						xPos += 46;
						yPos -= 1;
						break;
					case 1:
						xPos += 0;
						yPos += 24;
						break;
					case 2:
						xPos += 90;
						yPos += 24;
						break;
					case 3:
						xPos += 0;
						yPos += 76;
						break;
					case 4:
						xPos += 90;
						yPos += 76;
						break;
					case 5:
						xPos += 45;
						yPos += 103;
						break;
				}

				if (shipProto)
				{
					image.onLoadShipImage.add(_loadPortraitIcon);
					image.setShip(null, shipProto);
					image.setBarValue(1 - ships[i].health);
					addShipLabel(shipProto, ships[i].health);
				}

				image.x = xPos;
				image.y = yPos;
				image.mouseEnabled = false;
				addChild(image);
				_ships.push(image);
			}

		}

		private function addShipLabel( shipProto:IPrototype, health:Number ):void
		{
			var healthValue:Number  = Math.round(health * 100);
			var shipUIAsset:AssetVO = _getUIAsset(shipProto);
			var healthColor:uint    = getHealthColor(healthValue);
			var textToUse:String    = (_isWinner) ? _leftEntityText : _RightEntityText;
			var ship:Label          = new Label(14, 0xf0f0f0, 210, 25);
			ship.constrictTextToSize = false;
			ship.align = (_isWinner) ? TextFormatAlign.LEFT : TextFormatAlign.RIGHT;
			ship.setHtmlTextWithTokens(textToUse, {'[[HexNumber.Color]]':healthColor.toString(16), '[[Number.EntityHealth]]':healthValue, '[[String.EntityName]]':shipUIAsset.visibleName});
			_entityText.push(ship);
			addChild(ship);

		}

		private function getHealthColor( healthValue:Number ):uint
		{

			if (healthValue >= 75)
				return 0x3cf219;
			else if (healthValue >= 50)
				return 0xfbe81a;
			else if (healthValue >= 25)
				return 0xfa7d0e;
			else
				return 0xf81919;
		}

		private function onButtonClick( e:MouseEvent ):void
		{
			if (_player)
			{
				onViewBaseClick.dispatch(_player.baseXPos, _player.baseYPos, _player.baseSector);
			}
		}

		public function get playerID():String
		{
			return _battleLogPlayer.playerKey;
		}

		public function set player( player:PlayerVO ):void
		{
			_player = player;
			_gotoBaseBtn.visible = true;
		}

		override public function get height():Number
		{
			return PANEL_HEIGHT;
		}

		public function destroy():void
		{
			if (onViewBaseClick)
				onViewBaseClick.removeAll();
			onViewBaseClick = null;

			ObjectPool.give(_playerPortrait);
			_playerPortrait = null;

			_playerName.destroy();
			_playerName = null;

			_playerRating.destroy();
			_playerRating = null;

			_playerPortraitFrame = null;

			if (_gotoBaseBtn)
			{
				_gotoBaseBtn.removeEventListener(MouseEvent.MOUSE_UP, onButtonClick);
				_gotoBaseBtn.destroy();
			}
			_gotoBaseBtn = null;

			var len:uint = _ships.length;
			var i:uint;
			var currentShipIcon:ShipIcon;
			for (; i < len; ++i)
			{
				currentShipIcon = _ships[i];
				currentShipIcon.destroy();
				currentShipIcon = null;
			}
			_ships.length = 0;
			len = _entityText.length;
			var currentLabel:Label;
			for (i = 0; i < len; ++i)
			{
				currentLabel = _entityText[i];
				currentLabel.destroy();
				currentLabel = null;
			}

			_isWinner = false;

			_battleLogPlayer = null;

			_getShipPrototype = null;
			_getUIAsset = null;
			_loadPortraitMedium = null;
			_loadPortraitIcon = null;
		}
	}
}
