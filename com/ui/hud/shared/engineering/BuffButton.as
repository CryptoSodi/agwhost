package com.ui.hud.shared.engineering
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.model.asset.AssetVO;
	import com.model.starbase.BuffVO;
	import com.presenter.shared.IUIPresenter;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;

	import flash.display.Sprite;

	public class BuffButton extends Sprite
	{
		private var _buff:BuffVO;
		private var _button:BitmapButton;
		private var _presenter:IUIPresenter;
		private var _tempTime:Number;

		private var _protectionBuffText:String = 'CodeString.EngineeringView.ProtectionBuff'; //Starbase Protection

		public function init( buff:BuffVO, presenter:IUIPresenter ):void
		{
			_buff = buff;
			_presenter = presenter;

			//if there is no buff then assume base bubble buff
			var buffType:String = (_buff) ? _buff.buffType : "Protection";
			var buttonType:String;
			switch (buffType)
			{
				case "Protection":
					buttonType = ButtonEnum.BUFF_SHIELD;
					break;
				case "IncomeAll":
				case "IncomeAlloy":
				case "IncomeCredits":
				case "IncomeEnergy":
				case "IncomeSynth":
					buttonType = ButtonEnum.BUFF_RESOURCE;
					break;
				case "BuildSpeed":
					buttonType = ButtonEnum.BUFF_REPAIR_SPEED;
					break;
				case "BuildTime":
					buttonType = ButtonEnum.BUFF_REPAIR_SPEED;
					break;
				case "MapSpeed":
					buttonType = ButtonEnum.BUFF_MAP_SPEED;
					break;
				case "CargoCapacity":
					buttonType = ButtonEnum.BUFF_REPAIR_SPEED;
					break;
				case "DEV_DamageNegation":
				case "DEV_IncomeBoost":
				case "DEV_BuildAccelerator":
				case "DEV_EverythingIsFree":
				case "DEV_DisableRequirements":
					buttonType = ButtonEnum.BUFF_REPAIR_SPEED;
					break;
				case "DailyBuff":
					switch (buff.id)
					{
						case "Daily_Bounty":
							buttonType = ButtonEnum.BUFF_COMMISSION;
							break;
						case "Daily_RepairSpeed":
							buttonType = ButtonEnum.BUFF_REPAIR_SPEED;
							break;
						case "Daily_Salvage":
							buttonType = ButtonEnum.BUFF_RESOURCE;
							break;
						case "Daily_TreasureFinding":
							buttonType = ButtonEnum.BUFF_RECLAMATION;
							break;
						default:
							buttonType = ButtonEnum.BUFF_REPAIR_SPEED;
							break;
					}
					break;
				case "SalvageBonus":
					buttonType = ButtonEnum.BUFF_RESOURCE;
					break;
				case "BountyBonus":
					buttonType = ButtonEnum.BUFF_COMMISSION;
					break;
				case "RepairSpeed":
					buttonType = ButtonEnum.BUFF_REPAIR_SPEED;
					break;
				case "TreasureFinding":
					buttonType = ButtonEnum.BUFF_RECLAMATION;
					break;
				default:
					buttonType = ButtonEnum.BUFF_REPAIR_SPEED;
					break;
			}
			_button = UIFactory.getButton(buttonType, 0, 0, 0, 0, "hello", LabelEnum.H4);
			_button.label.setSize(35, 35);
			_button.label.bold = true;
			_button.label.constrictTextToSize = false;
			_button.textColor = 0xfef9bd;
			_button.label.y = 28;
			updateTime();
			addChild(_button);
		}

		public function updateTime():Boolean
		{
			_tempTime = (_buff) ? _buff.timeRemainingMS : _presenter.bubbleTimeRemaining;
			_button.label.setBuildTime(_tempTime * .001, 1);
			return _tempTime > 0;
		}

		public function getTooltip():String
		{
			if (_buff)
			{
				var asset:AssetVO = _presenter.getAssetVO(_buff.uiAsset);
				if (asset)
					return Localization.instance.getString(asset.visibleName);
			} else
				return Localization.instance.getString(_protectionBuffText);
			return "Unknown Buff";
		}

		public function get buff():BuffVO  { return _buff; }
		public function get buffType():String  { return (_buff) ? _buff.buffType : "Protection"; }

		public function destroy():void
		{
			_buff = null;
			_button = UIFactory.destroyButton(_button);
			_presenter = null;
		}
	}
}
