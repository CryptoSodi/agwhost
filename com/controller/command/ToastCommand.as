package com.controller.command
{
	import com.controller.fte.FTEController;
	import com.controller.toast.ToastController;
	import com.enum.CurrencyEnum;
	import com.enum.ToastEnum;
	import com.event.ToastEvent;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.mission.MissionInfoVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.service.loading.LoadPriority;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.toast.ToastView;

	import flash.text.TextFormatAlign;

	import org.adobe.utils.StringUtil;
	import org.robotlegs.extensions.presenter.impl.Command;
	import org.shared.ObjectPool;

	public class ToastCommand extends Command
	{
		//backgrounds
		public static const BG_SMALL:String     = "ToastSmallBMD";
		public static const BG_LARGE:String     = "ToastLargeBMD";
		public static const BG_RESOURCES:String = "ToastResourcesBMD";

		private var _palladiumAdded:String      = 'CodeString.Shared.PalladiumAdded'; //Level [[Number.Level]]
		private var _level:String               = 'CodeString.Shared.Level'; //Level [[Number.Level]]
		private var _missionComplete:String     = 'CodeString.Toast.MissionComplete'; //Mission Complete!
		private var _congratulations:String     = 'CodeString.Toast.Congratulations'; //Congratulations!
		private var _reward:String              = 'CodeString.Toast.Reward' //Reward:
		private var _alert:String               = 'CodeString.Toast.Alert'; //ALERT
		private var _alliance:String            = 'CodeString.Toast.AllianceTitle'; //Alliance Event
		private var _blueprintTitle:String      = 'CodeString.Toast.Blueprint'; //Blueprint Part Acquired
		private var _achievementUnlocked:String = 'CodeString.Achievement.ToastTitle'; //Achievement Unlocked!
		private var _incomingMessage:String     = 'CodeString.Toast.IncomingMessage'; //Incoming Message
		private var _newMission:String          = 'CodeString.Toast.NewMission'; // New mission for you.

		[Inject]
		public var assetModel:AssetModel;
		[Inject]
		public var event:ToastEvent;
		[Inject]
		public var fteController:FTEController;
		public var toast:ToastView;
		[Inject]
		public var toastController:ToastController;

		override public function execute():void
		{
			if (fteController.running && !(event.toastType == ToastEnum.MISSION_REWARD || event.toastType == ToastEnum.FTE_REWARD))
				return;

			var assetVO:AssetVO;
			var label:Label;
			var title:Label;
			toast = ObjectPool.get(ToastView);

			switch (event.toastType)
			{
				case ToastEnum.FLEET_DOCKED:
				{
					toast.addBackground(BG_RESOURCES);
					toast.addLabel("title", LabelFactory.createLabel(-1, 340, 32, 0xfac973), 0, 10, event.nextString);
					toast.addLabel("message", LabelFactory.createLabel(-1, 340, 23, 0xf0f0f0), 0, 50, event.nextString);
					toast.addLabel("alloy", LabelFactory.createLabel(LabelFactory.DYNAMIC_TEXT_COLOR, 105, 22, 0xf0f0f0), 225, 104,
								   StringUtil.commaFormatNumber(event.nextString), TextFormatAlign.LEFT);
					toast.addLabel("credit", LabelFactory.createLabel(LabelFactory.DYNAMIC_TEXT_COLOR, 105, 22, 0xf0f0f0), 75, 104,
								   event.nextString, TextFormatAlign.LEFT);
					toast.addLabel("energy", LabelFactory.createLabel(LabelFactory.DYNAMIC_TEXT_COLOR, 105, 22, 0xf0f0f0), 75, 139,
								   StringUtil.commaFormatNumber(event.nextString), TextFormatAlign.LEFT);
					toast.addLabel("synthetic", LabelFactory.createLabel(LabelFactory.DYNAMIC_TEXT_COLOR, 105, 22, 0xf0f0f0), 225, 139,
								   StringUtil.commaFormatNumber(event.nextString), TextFormatAlign.LEFT);
					break;
				}

				case ToastEnum.FTE_REWARD:
				{
					toast.addBackground(BG_LARGE);
					toast.addLabel("title", LabelFactory.createLabel(-1, 340, 32, 0xfac973), 0, 10, event.data.text);
					addImage("image", event.data.url, 0, 25, 340);
					break;
				}

				case ToastEnum.LEVEL_UP:
				{
					toast.addBackground(BG_SMALL);
					toast.addLabel("message", LabelFactory.createLabel(-1, 340, 22, 0xf0f0f0), 0, 20, _congratulations);
					label = LabelFactory.createLabel(-1, 340, 32, 0xfac973);
					label.setTextWithTokens(_level, {'[[Number.Level]]':CurrentUser.level});
					toast.addLabel("level", label, 0, 50);
					break;
				}

				case ToastEnum.PALLADIUM_ADDED:
				{
					toast.addBackground(BG_LARGE);
					var ty:Number = (toast.height - 121) / 2;
					addImage("icon", "assets/Palladium_LG.png", 0, ty, 108, 121);
					title = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DIALOG_TITLE, toast.width - 118, -1, 0xf0f0f0)
					toast.addLabel("message", title, 100, 20, _congratulations);
					label = LabelFactory.createLabel(-1, toast.width - 118, 32, 0xfac973, true);
					label.setTextWithTokens(_palladiumAdded, {'[[Number.Amount]]':CurrentUser.vo.wallet.getPrevAddedAmount(CurrencyEnum.PREMIUM)});
					toast.addLabel("level", label, 100, 50);
					var th:Number = title.textHeight + 10 + label.textHeight;
					title.y = (toast.height - th) / 2;
					label.y = title.y + title.textHeight + 10;

					break;
				}

				case ToastEnum.MISSION_NEW:
				{
					toast.addBackground(BG_SMALL);
					toast.addLabel("title", LabelFactory.createLabel(-1, 340, 32, 0xfac973), 0, 10, _incomingMessage);
					toast.addLabel("message", LabelFactory.createLabel(-1, 340, 23, 0xf0f0f0), 0, 50, _newMission);
					break;
				}

				case ToastEnum.MISSION_REWARD:
				{
					var missionInfo:MissionInfoVO = MissionInfoVO(event.data);
					toast.addBackground(BG_RESOURCES);
					toast.addLabel("title", LabelFactory.createLabel(-1, 340, 32, 0xfac973), 0, 10, _missionComplete);
					toast.addLabel("message", LabelFactory.createLabel(-1, 340, 23, 0xf0f0f0), 0, 50, _reward);
					toast.addLabel("alloy", LabelFactory.createLabel(LabelFactory.DYNAMIC_TEXT_COLOR, 105, 22, 0xf0f0f0), 225, 104,
								   StringUtil.commaFormatNumber(missionInfo.alloyReward), TextFormatAlign.LEFT);
					toast.addLabel("credit", LabelFactory.createLabel(LabelFactory.DYNAMIC_TEXT_COLOR, 105, 22, 0xf0f0f0), 75, 104,
								   StringUtil.commaFormatNumber(missionInfo.creditReward), TextFormatAlign.LEFT);
					toast.addLabel("energy", LabelFactory.createLabel(LabelFactory.DYNAMIC_TEXT_COLOR, 105, 22, 0xf0f0f0), 75, 139,
								   StringUtil.commaFormatNumber(missionInfo.energyReward), TextFormatAlign.LEFT);
					toast.addLabel("synthetic", LabelFactory.createLabel(LabelFactory.DYNAMIC_TEXT_COLOR, 105, 22, 0xf0f0f0), 225, 139,
								   StringUtil.commaFormatNumber(missionInfo.syntheticReward), TextFormatAlign.LEFT);
					break;
				}

				case ToastEnum.FLEET_REPAIRED:
				case ToastEnum.TRANSACTION_COMPLETE:
				{
					if (!event.prototype)
						return;
					toast.autoLayout = true;
					toast.addBackground(BG_LARGE);
					assetVO = getAssetVO(event.prototype);
					addImageFromAsset("proto", assetVO, 0, 0);
					toast.addTransactionLabels(event.transaction, assetVO, event.prototype);
					break;
				}

				case ToastEnum.WRONG:
				{
					toast.addBackground(BG_SMALL);
					toast.addLabel("title", LabelFactory.createLabel(-1, 340, 32, 0xaa3333), 0, 10, _alert);
					label = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DYNAMIC, 200, 24, 0xf0f0f0, true);
					label.setSize(250, 55);
					label.leading = -6;
					toast.addLabel("message", label, -1, 45, event.nextString);
					break;
				}

				case ToastEnum.ALLIANCE:
				{
					toast.addBackground(BG_SMALL);
					toast.addLabel("title", LabelFactory.createLabel(-1, 340, 32, 0x79da62), 0, 10, _alliance);
					label = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DYNAMIC, 200, 24, 0xf0f0f0, true);
					label.setSize(250, 55);
					label.leading = -6;
					toast.addLabel("message", label, -1, 45, event.nextString);
					break;
				}

				case ToastEnum.BLUEPRINT:
				{
					var blueprint:BlueprintVO = BlueprintVO(event.prototype);
					if (blueprint == null)
						return;

					toast.autoLayout = true;
					toast.addBackground(BG_LARGE);
					assetVO = getAssetVO(blueprint);
					addImageFromAsset("proto", assetVO, 0, 0);
					toast.addLabel("title", LabelFactory.createLabel(-1, 225, 32, 0xfac973), 130, 10, _blueprintTitle, TextFormatAlign.LEFT);
					toast.addLabel("message", LabelFactory.createLabel(-1, 250, 42, 0xf0f0f0, true), 130, 48, event.nextString, TextFormatAlign.LEFT);
					break;
				}

				case ToastEnum.BUBBLE_ALERT:
				{
					toast.addBackground(BG_LARGE);
					assetVO = getAssetVO(event.prototype);
					toast.addLabel("title", LabelFactory.createLabel(-1, 225, 32, 0xfac973), 130, 10, event.nextString, TextFormatAlign.LEFT);
					toast.addLabel("message", LabelFactory.createLabel(-1, 250, 42, 0xf0f0f0, true), 130, 48, event.nextString, TextFormatAlign.LEFT);
					addImageFromAsset("proto", assetVO, 0, 0);
					break;
				}

				case ToastEnum.BASE_RELOCATED:
				{
					toast.addBackground(BG_SMALL);
					toast.addLabel("title", LabelFactory.createLabel(-1, 340, 32, 0x79da62), 0, 10, event.nextString);
					label = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DYNAMIC, 200, 24, 0xf0f0f0, true);
					label.setSize(250, 55);
					label.leading = -6;
					toast.addLabel("message", label, -1, 45, event.nextString);
					break;
				}

				case ToastEnum.ACHIEVEMENT:
				{
					assetVO = getAssetVO(event.prototype);
					toast.autoLayout = true;
					toast.addBackground(BG_LARGE);
					toast.addLabel("title", LabelFactory.createLabel(-1, 340, 32, 0x79da62), 25, 10, _achievementUnlocked);
					label = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DYNAMIC, 200, 24, 0xf0f0f0, true);
					label.setSize(250, 55);
					label.leading = -6;
					toast.addLabel("message", label, 25 + (340 - 250) * 0.5, 45, assetVO.visibleName);
					addImageFromAsset("proto", assetVO, -50, 0);
					break;
				}

				default:
				{
					throw new Error("Tried to create a Toast with an invalid type");
					break;
				}
			}

			toastController.addToast(event.toastType, toast);
		}

		private function getAssetVO( prototype:IPrototype ):AssetVO
		{
			var assetName:String = prototype.uiAsset;
			if (!assetName || assetName == '')
				assetName = prototype.asset;
			return assetModel.getEntityData(assetName);
		}

		private function addImage( id:String, url:String, x:Number, y:Number, width:Number = 126, height:Number = 126 ):ImageComponent
		{
			var image:ImageComponent = new ImageComponent();
			image.init(width, height);
			image.center = true;
			image.x = x;
			image.y = y;
			toast.addImage(id, image);
			assetModel.getFromCache(url, image.onImageLoaded, LoadPriority.LOW);
			return image;
		}

		private function addImageFromAsset( id:String, assetVO:AssetVO, x:Number, y:Number, width:Number = 126, height:Number = 126 ):ImageComponent
		{
			var url:String           = "assets/" + ((assetVO.mediumImage && assetVO.mediumImage != "" && assetVO.mediumImage != "Default.png") ? assetVO.mediumImage : assetVO.smallImage)
			var image:ImageComponent = addImage(id, url, x, y, width, height);
			return image;
		}
	}
}
