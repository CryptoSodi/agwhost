package com.ui.modal.construction
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.prototype.IPrototype;
	import com.presenter.starbase.IConstructionPresenter;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.misc.TooltipComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFormatAlign;

	import org.adobe.utils.StringUtil;
	import org.shared.ObjectPool;

	public class ConstructionItem extends Sprite
	{
		private var _actionButton:BitmapButton;
		private var _bg:ScaleBitmap;
		private var _description:Label;
		private var _image:ImageComponent;
		private var _imageFrame:ScaleBitmap;
		private var _lock:Bitmap;
		private var _presenter:IConstructionPresenter;
		private var _prototype:IPrototype;
		private var _state:int;
		private var _statsBG:ScaleBitmap;
		private var _title:Label;
		private var _tooltipComponent:TooltipComponent;
		private var _tooltips:Tooltips;

		private var _buildText:String    = 'CodeString.ConstructionItem.Build'; //BUILD
		private var _upgradeText:String  = 'CodeString.ConstructionItem.Upgrade'; //UPGRADE
		private var _addText:String      = 'CodeString.ConstructionItem.Add'; //ADD
		private var _detailsText:String  = 'CodeString.ConstructionItem.Details'; //DETAILS
		private var _researchText:String = 'CodeString.ConstructionItem.Research'; //RESEARCH
		private var _completeText:String = 'CodeString.ConstructionItem.Complete'; //COMPLETE
		private var _lockedText:String   = 'CodeString.ConstructionItem.Locked'; //LOCKED

		public function init( prototype:IPrototype, presenter:IConstructionPresenter, state:int, tooltips:Tooltips ):void
		{
			_presenter = presenter;
			_prototype = prototype;
			_state = state;
			_tooltips = tooltips;
			_bg = UIFactory.getPanel(PanelEnum.CONTAINER_INNER, 600, 118);

			_image = ObjectPool.get(ImageComponent);
			_image.init(100, 100);
			_image.center = true;
			_image.x = _image.y = 9;
			_image.mouseEnabled = _image.mouseChildren = false;

			_imageFrame = UIFactory.getPanel(PanelEnum.CHARACTER_FRAME, 100, 100, 9, 9);

			_lock = UIFactory.getBitmap("IconBlueLockedBMD");
			_lock.x = _imageFrame.x + (100 - _lock.width) * .5;
			_lock.y = _imageFrame.y + (100 - _lock.height) * .5;
			_lock.visible = false;

			_title = UIFactory.getLabel(LabelEnum.TITLE, 300, 45, _image.x + 108, 8);
			_title.textColor = 0xfbefaf;
			_title.align = TextFormatAlign.LEFT;
			_title.useLocalization = false;
			_title.bold = false;
			_title.constrictTextToSize = true;
			_title.mouseEnabled = false;

			_statsBG = UIFactory.getPanel(PanelEnum.CONTAINER_NOTCHED_RIGHT_SMALL, 474, 61, _title.x, 49);

			_tooltipComponent = ObjectPool.get(TooltipComponent);
			_tooltipComponent.init(2, 474);
			_tooltipComponent.x = _statsBG.x;
			_tooltipComponent.y = _statsBG.y;
			_tooltipComponent.mouseEnabled = _tooltipComponent.mouseChildren = false;

			finalize();

			addChild(_bg);
			addChild(_actionButton);
			if (_description)
				addChild(_description);
			addChild(_image);
			addChild(_imageFrame);
			addChild(_lock);
			addChild(_statsBG);
			addChild(_title);
			addChild(_tooltipComponent);
		}

		private function finalize():void
		{
			var glow:GlowFilter;
			var rarity:String;

			//load the image and display the title
			var assetVO:AssetVO = _presenter.getAssetVO(_prototype);
			
			if(assetVO)
			{
				_presenter.loadImage(assetVO.mediumImage, _image.onImageLoaded);
				_title.text = Localization.instance.getString(assetVO.visibleName).toUpperCase();
			}

			var proto:IPrototype;
			switch (_state)
			{
				case ConstructionView.BUILD:
					var count:int              = _presenter.getBuildingCount(_prototype.itemClass);
					var maxCount:int           = _presenter.getBuildingMaxCount(_prototype.itemClass);
					if (count < maxCount)
						_actionButton = UIFactory.getButton(ButtonEnum.GREEN_A, 138, 31, 452, 8, _buildText);
					else if (maxCount == 1 && count == 1 && _presenter.getBuildingVOByClass(_prototype.itemClass, true).level != 10)
						_actionButton = UIFactory.getButton(ButtonEnum.GREEN_A, 138, 31, 452, 8, _upgradeText);
					else
						_actionButton = UIFactory.getButton(ButtonEnum.BLUE_A, 138, 31, 452, 8, _detailsText);
					_title.text += " " + count + "/" + maxCount;
					_description = UIFactory.getLabel(LabelEnum.DESCRIPTION, _statsBG.width - 4, _statsBG.height - 4, _statsBG.x + 2, _statsBG.y + 2);
					
					if(assetVO)
						_description.text = assetVO.descriptionText;
					
					_tooltips.addTooltip(this, null, null, StringUtil.getTooltip(_prototype.getValue("type"), _prototype, false, null));
					break;

				case ConstructionView.COMPONENT:
					_actionButton = UIFactory.getButton(ButtonEnum.BLUE_A, 138, 31, 452, 8, _addText);
					_tooltipComponent.layoutTooltip(StringUtil.getTooltip(_prototype.getValue("type"), _prototype, false, null, true));
					_tooltips.addTooltip(this, null, null, StringUtil.getTooltip(_prototype.getValue("type"), _prototype, false, null));

					rarity = _prototype.getUnsafeValue('rarity');
					if (rarity != 'Common')
					{
						glow = CommonFunctionUtil.getRarityGlow(rarity);
						_title.textColor = glow.color;
						_imageFrame.filters = [glow];
					}
					break;

				case ConstructionView.RESEARCH:
					var blueprint:BlueprintVO  = _presenter.getBlueprint(_prototype.name);
					var requirementMet:Boolean = _presenter.requirementsMet(_prototype);
					if (_presenter.isResearched(_prototype.name))
						_actionButton = UIFactory.getButton(ButtonEnum.BLUE_A, 138, 31, 452, 8, _detailsText);
					else if (requirementMet)
						_actionButton = UIFactory.getButton(ButtonEnum.GREEN_A, 138, 31, 452, 8, _researchText);
					else if (!requirementMet)
					{
						if (blueprint && blueprint.partsCompleted < blueprint.totalParts)
							_actionButton = UIFactory.getButton(ButtonEnum.GOLD_A, 138, 31, 452, 8, _completeText);
						else
							_actionButton = UIFactory.getButton(ButtonEnum.RED_A, 138, 31, 452, 8, _lockedText);
						_lock.visible = true;
						_image.filters = [CommonFunctionUtil.getGreyScaleFilter()];
					}

					rarity = _prototype.getUnsafeValue('rarity');
					if (rarity != 'Common')
					{
						glow = CommonFunctionUtil.getRarityGlow(rarity);
						_title.textColor = glow.color;
						_imageFrame.filters = [glow];
					} else
						_imageFrame.filters = [];

					//see if this is a blueprint
					if (blueprint && (CONFIG::IS_CRYPTO || blueprint.partsCollected < blueprint.totalParts))
						_title.text += " " + blueprint.partsCollected + "/" + blueprint.totalParts;
					

					proto = _presenter.getResearchItemPrototypeByName(_prototype.getValue("referenceName"));
					_tooltipComponent.layoutTooltip(StringUtil.getTooltip(proto.getValue("type"), proto, false, null, true));
					_tooltips.addTooltip(this, null, null, StringUtil.getTooltip(proto.getValue("type"), proto, false, null));
					break;
			}

			_actionButton.hitArea = this;
		}

		public function get prototype():IPrototype  { return _prototype; }

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);

			_actionButton = UIFactory.destroyButton(_actionButton);
			_bg = UIFactory.destroyPanel(_bg);
			if (_description)
				_description = UIFactory.destroyLabel(_description);
			ObjectPool.give(_image);
			_image = null;
			_imageFrame = UIFactory.destroyPanel(_imageFrame);
			_lock = UIFactory.destroyPanel(_lock);
			_presenter = null;
			_prototype = null;
			_statsBG = UIFactory.destroyPanel(_statsBG);
			_title = UIFactory.destroyLabel(_title);
			ObjectPool.give(_tooltipComponent);
			_tooltipComponent = null;
			_tooltips.removeTooltip(this);
			_tooltips = null;
		}
	}
}
