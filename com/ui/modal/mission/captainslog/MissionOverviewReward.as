package com.ui.modal.mission.captainslog
{
	import com.enum.CurrencyEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.mission.MissionInfoVO;
	import com.ui.UIFactory;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.hud.shared.command.ResourceComponent;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	import org.shared.ObjectPool;

	public class MissionOverviewReward extends Sprite
	{
		private var _bg:Sprite;

		private var _blueprintText:Label;
		private var _blueprintBG:Bitmap;
		private var _blueprintLabel:Label;

		private var _palladiumBG:Bitmap;
		private var _palladiumIcon:Bitmap;
		private var _palladiumLabel:Label;

		private var _resourceComponent:ResourceComponent;

		private var _rewardsTitleText:String = 'CodeString.MissionOverview.Rewards'; //REWARDS:
		private var _blueprintPiece:String   = 'CodeString.Achievement.BlueprintPiece'; //BLUEPRINT PIECE:

		public function init():void
		{
			_bg = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED, PanelEnum.HEADER_NOTCHED, 700, 120, 30, 0, 0, _rewardsTitleText, LabelEnum.H2);

			_resourceComponent = ObjectPool.get(ResourceComponent);
			_resourceComponent.init(false, false);

			_palladiumBG = UIFactory.getBitmap("ResourceBoxBMD");
			_palladiumIcon = UIFactory.getBitmap('IconPalladiumBMD');

			_palladiumLabel = new Label(20, 0xf0f0f0);
			_palladiumLabel.constrictTextToSize = false;
			_palladiumLabel.autoSize = TextFieldAutoSize.CENTER;
			_palladiumLabel.align = TextFormatAlign.CENTER;

			_blueprintBG = UIFactory.getBitmap("ResourceBoxBMD");

			_blueprintText = new Label(22, 0xf0f0f0, 140, 40);
			_blueprintText.align = TextFormatAlign.RIGHT;
			_blueprintText.text = _blueprintPiece;

			_blueprintLabel = new Label(20, 0xf0f0f0);
			_blueprintLabel.constrictTextToSize = false;
			_blueprintLabel.autoSize = TextFieldAutoSize.CENTER;
			_blueprintLabel.align = TextFormatAlign.CENTER;

			addChild(_bg);

			addChild(_resourceComponent);

			addChild(_palladiumBG);
			addChild(_palladiumIcon);
			addChild(_palladiumLabel);

			addChild(_blueprintBG);
			addChild(_blueprintText);
			addChild(_blueprintLabel);
		}

		public function update( info:MissionInfoVO ):void
		{
			if (info.alloyReward + info.creditReward + info.energyReward + info.syntheticReward > 0)
			{
				_resourceComponent.updateResource(info.alloyReward, 1, CurrencyEnum.ALLOY);
				_resourceComponent.updateResource(info.creditReward, 1, CurrencyEnum.CREDIT);
				_resourceComponent.updateResource(info.energyReward, 1, CurrencyEnum.ENERGY);
				_resourceComponent.updateResource(info.syntheticReward, 1, CurrencyEnum.SYNTHETIC);
			}

			_resourceComponent.x = (info.blueprintReward || info.palladiumCurrencyReward > 0) ? 95 : 212;
			_resourceComponent.y = 50;

			_blueprintBG.x = _palladiumBG.x = width - _palladiumBG.width - 106;
			_palladiumBG.y = 53;

			if (info.palladiumCurrencyReward > 0)
				_blueprintBG.y = 101;
			else
				_blueprintBG.y = 53;

			_palladiumLabel.x = _palladiumBG.x + _palladiumBG.width * 0.5;
			_palladiumLabel.text = String(info.palladiumCurrencyReward);
			_palladiumLabel.y = _palladiumBG.y + (_palladiumBG.height - _palladiumLabel.height) * 0.5;

			_blueprintLabel.x = _palladiumBG.x + _palladiumBG.width * 0.5;
			_blueprintLabel.text = '1';
			_blueprintLabel.y = _blueprintBG.y + (_blueprintBG.height - _blueprintLabel.height) * 0.5;

			_palladiumIcon.x = _palladiumBG.x - _palladiumIcon.width - 2;
			_palladiumIcon.y = _palladiumBG.y + (_palladiumBG.height - _palladiumIcon.height) * 0.5;

			_blueprintText.x = _blueprintBG.x - _blueprintText.width - 1;
			_blueprintText.y = _blueprintBG.y + (_blueprintBG.height - _blueprintText.textHeight) * 0.5;

			_palladiumBG.visible = _palladiumIcon.visible = _palladiumLabel.visible = (info.palladiumCurrencyReward > 0)
			_blueprintBG.visible = _blueprintText.visible = _blueprintLabel.visible = (info.blueprintReward)
		}

		public function destroy():void
		{
			_bg = UIFactory.destroyPanel(_bg);
			while (numChildren > 0)
				removeChildAt(0);
			ObjectPool.give(_resourceComponent);
			_resourceComponent = null;

			_palladiumBG = null;
			_palladiumIcon = null;

			if (_palladiumLabel)
				_palladiumLabel.destroy();

			_palladiumLabel = null;

			_blueprintBG = null;

			if (_blueprintText)
				_blueprintText.destroy();

			_blueprintText = null;

			if (_blueprintLabel)
				_blueprintLabel.destroy();

			_blueprintLabel = null;
		}
	}
}
