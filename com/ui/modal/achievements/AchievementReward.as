package com.ui.modal.achievements
{
	import com.enum.ui.PanelEnum;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	import org.adobe.utils.StringUtil;

	public class AchievementReward extends Sprite
	{

		public static var REWARD_PALLADIUM:uint = 0;
		public static var REWARD_EXP:uint       = 1;
		public static var REWARD_CREDITS:uint   = 2;
		public static var BLUEPRINT:uint        = 3;

		private var _bg:ScaleBitmap;
		private var _rewardSymbol:Bitmap;

		private var _type:uint;

		private var _reward:Label;
		private var _rewardValue:Label;

		private var _value:Number;

		private var _exp:String                 = 'CodeString.Achievement.Exp'; //EXP:
		private var _blueprintPiece:String      = 'CodeString.Achievement.BlueprintPiece'; //BLUEPRINT PIECE:

		public function AchievementReward( value:Number, type:uint )
		{
			_type = type;
			_value = value;

			_bg = UIFactory.getScaleBitmap(PanelEnum.STATBAR_CONTAINER);
			_bg.width = 130;
			_bg.height = 24;

			_rewardValue = new Label(20, 0xf0f0f0);
			_rewardValue.constrictTextToSize = false;
			_rewardValue.autoSize = TextFieldAutoSize.CENTER;
			_rewardValue.align = TextFormatAlign.CENTER;

			if (type == REWARD_PALLADIUM)
			{
				_rewardSymbol = UIFactory.getBitmap('IconPalladiumBMD');
				_bg.width = 38;
				_rewardValue.width = 38;
			}
			else if (type == REWARD_EXP)
			{
				_reward = new Label(22, 0xf0f0f0, 140, 40);
				_reward.autoSize = TextFieldAutoSize.LEFT;
				_reward.align = TextFormatAlign.LEFT;
				_reward.text = _exp;
			} else if (type == REWARD_CREDITS)
				_rewardSymbol = UIFactory.getBitmap('IconCreditBMD');
			else if (type == BLUEPRINT)
			{
				_bg.width = 38;
				_rewardValue.width = 38;
				_reward = new Label(22, 0xf0f0f0, 140, 40);
				_reward.autoSize = TextFieldAutoSize.LEFT;
				_reward.align = TextFormatAlign.LEFT;
				_reward.text = _blueprintPiece;
			}

			addChild(_bg);
			addChild(_rewardValue);

			if (_reward)
				addChild(_reward);

			if (_rewardSymbol)
				addChild(_rewardSymbol);

			layout();
		}

		public function layout():void
		{
			switch (_type)
			{
				case REWARD_CREDITS:
				case REWARD_PALLADIUM:
					_bg.x = _rewardSymbol.x + _rewardSymbol.width + 5;
					_bg.y = 4;
					break;
				case REWARD_EXP:
				case BLUEPRINT:
					_reward.y = 2;
					_bg.x = _reward.x + _reward.textWidth + 4;
					_bg.y = 4;
					break;
			}

			_rewardValue.x = _bg.x + _bg.width * 0.5;
			_rewardValue.y = _bg.y;

			_rewardValue.text = StringUtil.commaFormatNumber(_value);
		}

		public function destroy():void
		{
			_bg = null;

			_rewardSymbol = null;

			if (_rewardValue)
				_rewardValue.destroy();

			_rewardValue = null;

			if (_reward)
				_reward.destroy();

			_reward = null;
		}

	}
}
