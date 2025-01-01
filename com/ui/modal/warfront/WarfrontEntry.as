package com.ui.modal.warfront
{
	import com.model.warfrontModel.WarfrontVO;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class WarfrontEntry extends BitmapButton
	{
		public var onClicked:Signal;
		public var onLoadImage:Signal;

		private var _attackerUserImage:ImageComponent;
		private var _attackerUserPortraitFrame:Bitmap;
		private var _attackerUserName:Label;
		private var _attackerUserRating:Label;
		private var _battle:WarfrontVO;
		private var _defenderPlayerImage:ImageComponent;
		private var _defenderPlayerPortraitFrame:Bitmap;
		private var _defenderPlayerName:Label;
		private var _defenderRating:Label;
		private var _vs:Label;

		private var _fleetRatingText:String = 'CodeString.BattleLogs.FleetRating';
		private var _baseRatingText:String  = 'CodeString.BattleLogs.BaseRating';
		private var _vsText:String          = 'CodeString.Warfront.Vs';

		public function setup( battle:WarfrontVO ):void
		{
			super.init(PanelFactory.getBitmapData('BattleLogContainerBMD'));

			onClicked = new Signal(WarfrontVO);
			onLoadImage = new Signal(String, Function);

			_battle = battle;

			_attackerUserImage = ObjectPool.get(ImageComponent);
			_attackerUserImage.init(2000, 2000);
			_attackerUserImage.x = 6;
			_attackerUserImage.y = 9;

			_attackerUserPortraitFrame = new Bitmap();
			_attackerUserPortraitFrame.x = 2;
			_attackerUserPortraitFrame.y = 6;

			_attackerUserName = new Label(24, 0xf0f0f0, 300, 25, true);
			_attackerUserName.x = 95;
			_attackerUserName.y = 15;
			_attackerUserName.align = TextFormatAlign.LEFT;

			_attackerUserRating = new Label(20, 0xfbefaf, 300, 25);
			_attackerUserRating.x = 95;
			_attackerUserRating.y = 38;
			_attackerUserRating.align = TextFormatAlign.LEFT;

			_defenderPlayerImage = ObjectPool.get(ImageComponent);
			_defenderPlayerImage.init(2000, 2000);
			_defenderPlayerImage.x = 601;
			_defenderPlayerImage.y = 9;

			_defenderPlayerPortraitFrame = new Bitmap();
			_defenderPlayerPortraitFrame.x = 597;
			_defenderPlayerPortraitFrame.y = 6;

			_defenderPlayerName = new Label(24, 0xf0f0f0, 300, 25, true);
			_defenderPlayerName.x = 289;
			_defenderPlayerName.y = 15;
			_defenderPlayerName.align = TextFormatAlign.RIGHT;

			_defenderRating = new Label(20, 0xfbefaf, 300, 25);
			_defenderRating.x = 289;
			_defenderRating.y = 38;
			_defenderRating.align = TextFormatAlign.RIGHT;

			_vs = new Label(60, 0xf0f0f0);
			_vs.constrictTextToSize = false;
			_vs.autoSize = TextFieldAutoSize.CENTER;
			_vs.x = _bitmap.x + _bitmap.width * 0.5;

			addChild(_attackerUserImage);
			addChild(_attackerUserPortraitFrame);
			addChild(_attackerUserName);
			addChild(_attackerUserRating);

			addChild(_defenderPlayerImage);
			addChild(_defenderPlayerPortraitFrame);
			addChild(_defenderPlayerName);
			addChild(_defenderRating);

			addChild(_vs);
		}

		public function layout():void
		{
			_vs.text = _vsText;
			_vs.textColor = 0xffdd3d;

			var attackerUserFactionColor:uint = CommonFunctionUtil.getFactionColor(_battle.attackerRace.getValue('faction'));
			var defenderUserFactionColor:uint = CommonFunctionUtil.getFactionColor(_battle.defenderRace.getValue('faction'));
			var portraitFrameClass:Class      = Class(getDefinitionByName('BattleLogSmallPortraitFrameBMD'));

			var attackerBMD:BitmapData        = BitmapData(new portraitFrameClass());
			attackerBMD.applyFilter(attackerBMD, attackerBMD.rect, new Point(0, 0), CommonFunctionUtil.getColorMatrixFilter(attackerUserFactionColor));

			var defenderBMD:BitmapData        = BitmapData(new portraitFrameClass());
			defenderBMD.applyFilter(defenderBMD, defenderBMD.rect, new Point(0, 0), CommonFunctionUtil.getColorMatrixFilter(defenderUserFactionColor));

			onLoadImage.dispatch(_battle.attackerRace.uiAsset, _attackerUserImage.onImageLoaded);
			_attackerUserName.text = _battle.attackerName;
			_attackerUserName.textColor = attackerUserFactionColor;
			_attackerUserPortraitFrame.bitmapData = attackerBMD;
			_attackerUserRating.setTextWithTokens(_fleetRatingText, {'[[Number.Rating]]':_battle.attackerFleetRating});

			onLoadImage.dispatch(_battle.defenderRace.uiAsset, _defenderPlayerImage.onImageLoaded);
			_defenderPlayerName.text = _battle.defenderName;
			_defenderPlayerName.textColor = defenderUserFactionColor;
			_defenderPlayerPortraitFrame.bitmapData = defenderBMD;
			var ratingTxt:String              = (_battle.defenderFleetRating > 0) ? _fleetRatingText : _baseRatingText;
			var rating:int                    = (_battle.defenderFleetRating > 0) ? _battle.defenderFleetRating : _battle.defenderBaseRating;
			_defenderRating.setTextWithTokens(ratingTxt, {'[[Number.Rating]]':rating});

			_vs.y = _bitmap.y + (_bitmap.height - _vs.textHeight) * 0.5;
		}

		override protected function onMouse( e:MouseEvent ):void
		{
			super.onMouse(e);
			if (mouseEnabled)
			{
				switch (e.type)
				{
					case MouseEvent.CLICK:
						onClicked.dispatch(_battle);
						break;
				}
			}
		}

		override public function destroy():void
		{
			super.destroy();

			_battle = null;
			onClicked.removeAll();
			onClicked = null;

			onLoadImage.removeAll();
			onLoadImage = null;

			ObjectPool.give(_attackerUserImage);

			_attackerUserPortraitFrame = null;

			_attackerUserName.destroy();
			_attackerUserName = null;

			_attackerUserRating.destroy();
			_attackerUserRating = null;


			ObjectPool.give(_defenderPlayerImage);

			_defenderPlayerPortraitFrame = null;

			_defenderPlayerName.destroy();
			_defenderPlayerName = null;

			_defenderRating.destroy();
			_defenderRating = null;

			_vs.destroy();
			_vs = null;
		}
	}
}
