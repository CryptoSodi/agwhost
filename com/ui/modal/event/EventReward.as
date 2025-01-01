package com.ui.modal.event
{
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.IEventPresenter;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	import org.adobe.utils.StringUtil;
	import org.greensock.TweenLite;
	import org.greensock.easing.Linear;
	import org.shared.ObjectPool;

	public class EventReward extends Sprite
	{
		private var _reward:IPrototype;
		private var _index:uint;
		private var _scoreRequirement:uint;
		private var _unlocked:Boolean;
		private var _isNextRewardDisplay:Boolean;

		private var _image:ImageComponent;
		private var _imageFrame:ScaleBitmap;
		private var _maskFrame:ScaleBitmap;

		private var _checkmark:Bitmap;
		private var _lock:Bitmap;

		private var _delayTimer:Timer;

		private var _gradient:Sprite;

		private var _scoreRequirementText:Label;

		private var _tooltips:Tooltips;
		private var _presenter:IEventPresenter;

		public function EventReward( width:Number, height:Number, isNextRewardDisplay:Boolean, unlocked:Boolean, tooltips:Tooltips, presenter:IEventPresenter )
		{
			super();
			_presenter = presenter;
			_tooltips = tooltips;
			_unlocked = unlocked;
			_isNextRewardDisplay = isNextRewardDisplay;

			_image = ObjectPool.get(ImageComponent);
			_image.init(width, height);
			_image.center = true;
			_image.x = _image.y = 9;
			_image.mouseEnabled = _image.mouseChildren = false;

			_imageFrame = UIFactory.getPanel(PanelEnum.CHARACTER_FRAME, width, height, 9, 9);

			addChild(_imageFrame);
			addChild(_image);

			if (!isNextRewardDisplay)
			{
				if (!unlocked)
					_image.filters = [CommonFunctionUtil.getGreyScaleFilter()]

				_lock = UIFactory.getBitmap("IconBlueLockedBMD");
				_lock.x = _imageFrame.x + (width - _lock.width) * .5;
				_lock.y = _imageFrame.y + (height - _lock.height) * .5;
				_lock.visible = !unlocked;

				_checkmark = UIFactory.getBitmap("EventCheckmarkBMD");
				_checkmark.scaleX = _checkmark.scaleY = 0.65;
				_checkmark.smoothing = true;
				_checkmark.x = _imageFrame.x + _imageFrame.width - _checkmark.width * 0.85;
				_checkmark.y = _imageFrame.y + _imageFrame.height - _checkmark.height;
				_checkmark.visible = unlocked;

				addChild(_lock);
				addChild(_checkmark);
			}

		}

		public function set reward( v:IPrototype ):void
		{
			_reward = v;

			if (_reward)
			{
				visible = true;
				var assetVO:AssetVO = _presenter.getAssetVO(_reward);
				_presenter.loadIcon(assetVO.mediumImage, _image.onImageLoaded);


				var rarity:String = _reward.getUnsafeValue('rarity');
				if (rarity != 'Common')
				{
					var glow:GlowFilter = CommonFunctionUtil.getRarityGlow(rarity);
					_imageFrame.filters = [glow];
				} else
					_imageFrame.filters = [];

				_tooltips.addTooltip(this, null, null, StringUtil.getTooltip(_reward.getValue("type"), _reward, false, null));
			} else
				visible = false;
		}

		public function set scoreRequirement( v:uint ):void
		{
			_scoreRequirement = v;

			_scoreRequirementText = new Label(12, 0xf0f0f0, _imageFrame.width, 100, true, 1);
			_scoreRequirementText.align = TextFormatAlign.CENTER;
			_scoreRequirementText.constrictTextToSize = false;
			_scoreRequirementText.multiline = true;
			_scoreRequirementText.x = _imageFrame.x;
			_scoreRequirementText.y = _imageFrame.y + _imageFrame.height;
			_scoreRequirementText.text = StringUtil.commaFormatNumber(v);
			addChild(_scoreRequirementText);
		}

		public function get scoreRequirement():uint  { return _scoreRequirement; }

		public function set active( v:Boolean ):void
		{
			if (!_isNextRewardDisplay)
			{
				addGradientEffect();
			} else
			{
				_delayTimer = new Timer(1000, 1);
				_delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onDelayFinished, false, 0, true);
				_delayTimer.start();
			}
		}

		private function addGradientEffect():void
		{
			_maskFrame = UIFactory.getPanel(PanelEnum.CHARACTER_FRAME, _imageFrame.width, _imageFrame.height, 9, 9);
			_maskFrame.cacheAsBitmap = true;

			_gradient = new Sprite();
			_gradient.graphics.beginBitmapFill(UIFactory.getBitmapData("ShineBMD"));
			_gradient.graphics.drawRect(0, 0, _imageFrame.width * 4, _imageFrame.height * 4);
			_gradient.graphics.endFill();
			_gradient.blendMode = BlendMode.ADD;
			_gradient.x = _imageFrame.x + (_imageFrame.width - _gradient.width) * 0.5;
			_gradient.cacheAsBitmap = true;
			_gradient.alpha = 0;
			_gradient.mask = _maskFrame;

			addChild(_gradient);
			addChild(_maskFrame);

			onMoveComplete();
		}

		private function onMoveComplete():void
		{
			_gradient.y = _imageFrame.y + (_imageFrame.height - _gradient.height) * 0.75;
			TweenLite.to(_gradient, 0.5, {alpha:1, onComplete:onFadeInComplete, delay:2, overwrite:0});
			TweenLite.to(_gradient, 1.5, {y:(_gradient.y + _gradient.height * 0.25), onComplete:onMoveComplete, delay:2, overwrite:0, ease:Linear.easeNone});
		}

		private function onFadeInComplete():void
		{
			TweenLite.to(_gradient, 0.5, {alpha:0, delay:0.25, overwrite:0});
		}

		private function onDelayFinished( e:TimerEvent ):void
		{
			_delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onDelayFinished);
			addGradientEffect();
		}

		public function set index( v:uint ):void
		{
			_index = v;
		}

		public function get index():uint
		{
			return _index;
		}


		override public function get height():Number  { return _imageFrame.height; }
		override public function get width():Number  { return _imageFrame.width; }

		public function destroy():void
		{
			if (_gradient)
				TweenLite.killTweensOf(_gradient);

			if (_delayTimer && _delayTimer.running)
			{
				_delayTimer.stop();
				_delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onDelayFinished);
			}

			_delayTimer = null;
			_gradient = null;
			_lock = null;
			_imageFrame = null;
			_maskFrame = null;

			if (_tooltips)
				_tooltips.removeTooltip(this, null);

			if (_image)
				ObjectPool.give(_image);

			_image = null;

			if (_scoreRequirementText)
				_scoreRequirementText.destroy();

			_scoreRequirementText = null;
		}
	}
}
