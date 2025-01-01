package com.ui.modal.battle
{
	import com.enum.CategoryEnum;
	import com.enum.TypeEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleEntityVO;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.dock.ShipIcon;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;

	import org.shared.ObjectPool;

	public class BattleEndParticipantDisplay extends Sprite
	{
		private var _player:PlayerVO;
		private var _isVictor:Boolean;
		private var _rating:int;

		private var _playerPortrait:ImageComponent;

		private var _playerPortraitFrame:Bitmap;
		private var _shipsInFleetBg:Bitmap;
		private var _fleetFrame:Bitmap;

		private var _participantBG:ScaleBitmap;

		private var _playerName:Label;
		private var _playerRating:Label;

		private var _entityText:Vector.<Label>;

		private var _ships:Vector.<ShipIcon>;

		private var _getUIAsset:Function;
		private var _loadPortraitMedium:Function;
		private var _loadPortraitIcon:Function;

		private var WINNER_FRAME_X:Number       = 1;
		private var LOSER_FRAME_X:Number        = 16;

		private var WINNER_PORTRAIT_X:Number    = 5;
		private var LOSER_PORTRAIT_X:Number     = 330;

		private var WINNER_BATTLE_TEXT_X:Number = 135;
		private var LOSER_BATTLE_TEXT_X:Number  = 118;

		private var BATTLE_ENTITY_Y:Number      = 58;

		private var WINNER_BATTLE_SHIP_X:Number = 300;
		private var LOSER_BATTLE_SHIP_X:Number  = 25;
		private var BATTLE_SHIP_Y:Number        = 8;

		private var _leftEntityText:String      = 'CodeString.BattleLogs.EntityHealthLeft';
		private var _RightEntityText:String     = 'CodeString.BattleLogs.EntityHealthRight';
		private var _fleetRatingText:String     = 'CodeString.BattleLogs.FleetRating';
		private var _baseRatingText:String      = 'CodeString.BattleLogs.BaseRating';
		private var _baseHealthText:String      = 'CodeString.BattleLog.BaseHealth';

		public function BattleEndParticipantDisplay( player:PlayerVO, rating:int, isVictor:Boolean )
		{
			super();
			var factionColor:uint = CommonFunctionUtil.getFactionColor(player.faction);

			_player = player;
			_isVictor = isVictor;
			_rating = rating;

			_participantBG = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER);
			_participantBG.width = 449;
			_participantBG.height = 164;

			_fleetFrame = UIFactory.getBitmap('SectorFleetSelectionBGBMD');

			_playerPortrait = ObjectPool.get(ImageComponent);
			_playerPortrait.init(2000, 2000);

			_playerPortraitFrame = UIFactory.getScaleBitmap(PanelEnum.CHARACTER_FRAME);
			_playerPortraitFrame.width = 130;
			_playerPortraitFrame.height = 130;

			_playerName = new Label(24, 0xf0f0f0, 210, 25);
			_playerName.constrictTextToSize = false;
			_playerName.align = (_isVictor) ? TextFormatAlign.LEFT : TextFormatAlign.RIGHT;
			_playerName.text = player.name;
			_playerName.textColor = factionColor;

			_playerRating = new Label(20, 0xfbefaf, 210, 25);
			_playerRating.constrictTextToSize = false;
			_playerRating.align = (_isVictor) ? TextFormatAlign.LEFT : TextFormatAlign.RIGHT;
			_playerRating.constrictTextToSize = false;

			_ships = new Vector.<ShipIcon>;
			_entityText = new Vector.<Label>;

			addChild(_participantBG);
			addChild(_fleetFrame);
			addChild(_playerPortrait);
			addChild(_playerName);
			addChild(_playerRating);
			addChild(_playerPortraitFrame);
		}

		public function setUp( getUIAsset:Function, loadPortraitMedium:Function, loadPortraitIcon:Function, getBattleEntities:Function ):void
		{
			_getUIAsset = getUIAsset;
			_loadPortraitMedium = loadPortraitMedium;
			_loadPortraitIcon = loadPortraitIcon;

			var battleEntities:Vector.<BattleEntityVO> = getBattleEntities(_player.id);

			var ratingText:String                      = (battleEntities.length > 0) ? _fleetRatingText : _baseRatingText;

			_playerRating.setTextWithTokens(ratingText, {'[[Number.Rating]]':_rating});

			if (battleEntities.length > 0)
				setUpPlayerFleet(battleEntities);
			else
				setUpBase(getBattleEntities(_player.id, CategoryEnum.BUILDING));

			_loadPortraitMedium(_player.avatarName, _playerPortrait.onImageLoaded);
			layout();
		}

		private function layout():void
		{
			_participantBG.x = (_isVictor) ? WINNER_FRAME_X : LOSER_FRAME_X;

			_playerName.x = (_isVictor) ? WINNER_BATTLE_TEXT_X : LOSER_BATTLE_TEXT_X;
			_playerName.y = 8;

			_playerRating.x = (_isVictor) ? WINNER_BATTLE_TEXT_X : LOSER_BATTLE_TEXT_X;
			_playerRating.y = 35;

			_playerPortrait.x = ((_isVictor) ? WINNER_PORTRAIT_X : LOSER_PORTRAIT_X) + 5;
			_playerPortrait.y = 22;

			_playerPortraitFrame.x = ((_isVictor) ? WINNER_PORTRAIT_X : LOSER_PORTRAIT_X);
			_playerPortraitFrame.y = 17;

			_fleetFrame.x = (_isVictor) ? WINNER_BATTLE_SHIP_X - 1 : LOSER_BATTLE_SHIP_X - 1;
			_fleetFrame.y = BATTLE_SHIP_Y - 1;

			var xPos:Number = (_isVictor) ? WINNER_BATTLE_TEXT_X : LOSER_BATTLE_TEXT_X;
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

		private function setUpBase( buildings:Vector.<BattleEntityVO> ):void
		{
			_fleetFrame.visible = false;
			var len:uint           = buildings.length;
			var baseHealth:Number  = 0;
			var allBldgsCurrentHealth:Number = 0;
			var allBldgsMaxHealth:Number = 0;
			var currentBuilding:BattleEntityVO;
			var currentBuildingProto:IPrototype;
			var currentBuildingMaxHealth:Number;
			for (var i:uint = 0; i < len; ++i)
			{
				currentBuilding = buildings[i];
				currentBuildingProto = currentBuilding.prototype;
				if (currentBuildingProto)
				{
					if(currentBuildingProto.itemClass != TypeEnum.PYLON)
					{
						currentBuildingMaxHealth = Number(currentBuildingProto.getValue('health'));
						allBldgsCurrentHealth += currentBuilding.healthPercent * currentBuildingMaxHealth;
						allBldgsMaxHealth += currentBuildingMaxHealth;
					}
				}
			}

			baseHealth = allBldgsMaxHealth > 0 ? allBldgsCurrentHealth / allBldgsMaxHealth : 1.0;

			var healthValue:Number = Math.round(baseHealth * 100);
			var healthColor:uint   = getHealthColor(healthValue);
			var textToUse:String   = (_isVictor) ? _leftEntityText : _RightEntityText;
			var base:Label         = new Label(12, 0xf0f0f0, 210, 25);
			base.align = (_isVictor) ? TextFormatAlign.LEFT : TextFormatAlign.RIGHT;
			base.constrictTextToSize = false;
			base.x = (_isVictor) ? WINNER_BATTLE_TEXT_X : LOSER_BATTLE_TEXT_X;
			base.y = BATTLE_ENTITY_Y;
			base.setHtmlTextWithTokens(textToUse, {'[[HexNumber.Color]]':healthColor.toString(16), '[[Number.EntityHealth]]':healthValue, '[[String.EntityName]]':_baseHealthText});
			_entityText.push(base);
			addChild(base);
		}

		private function setUpPlayerFleet( ships:Vector.<BattleEntityVO> ):void
		{
			_fleetFrame.visible = true;

			var image:ShipIcon;
			var xPos:Number;
			var yPos:Number;

			var shipProto:IPrototype;
			var currentBattleEntity:BattleEntityVO;
			var len:uint = ships.length;
			for (var i:uint = 0; i < 6; ++i)
			{
				if (i < len)
					currentBattleEntity = ships[i];

				image = new ShipIcon();
				image.scale(0.37, 0.37);

				xPos = (_isVictor) ? WINNER_BATTLE_SHIP_X : LOSER_BATTLE_SHIP_X;
				yPos = BATTLE_SHIP_Y;

				switch (i)
				{
					case 0:
						xPos += 46;
						yPos += 0;
						break;
					case 1:
						xPos += 0;
						yPos += 25;
						break;
					case 2:
						xPos += 90;
						yPos += 25;
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
						yPos += 104;
						break;
				}

				if (currentBattleEntity)
				{
					shipProto = currentBattleEntity.prototype;
					if (shipProto)
					{
						image.onLoadShipImage.add(_loadPortraitIcon);
						image.setShip(null, shipProto);
						image.setBarValue(1 - currentBattleEntity.healthPercent);
						addShipLabel(shipProto, currentBattleEntity.healthPercent);
					}
					currentBattleEntity = null;
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
			var textToUse:String    = (_isVictor) ? _leftEntityText : _RightEntityText;
			var ship:Label          = new Label(14, 0xf0f0f0, 210, 25);
			ship.constrictTextToSize = false;
			ship.align = (_isVictor) ? TextFormatAlign.LEFT : TextFormatAlign.RIGHT;
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

		override public function get height():Number
		{
			return _participantBG.height;
		}

		public function destroy():void
		{
			_participantBG = null;

			ObjectPool.give(_playerPortrait);
			_playerPortrait = null;

			_playerName.destroy();
			_playerName = null;

			_playerRating.destroy();
			_playerRating = null;

			_playerPortraitFrame = null;

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

			_isVictor = false;

			_getUIAsset = null;
			_loadPortraitMedium = null;
			_loadPortraitIcon = null;
		}
	}
}
