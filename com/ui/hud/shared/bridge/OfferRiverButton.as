package com.ui.hud.shared.bridge
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.model.player.OfferVO;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.osflash.signals.Signal;

	public class OfferRiverButton extends Sprite
	{
		public var onClick:Signal;

		private var _offerGlow:Bitmap;
		private var _offerStarsA:Bitmap;
		private var _offerStarsB:Bitmap;

		private var _offerTimeRemaining:Label;
		private var _btnText:Label;

		private var _offerBtn:BitmapButton;

		private var _currentOffer:OfferVO;
		private var _offers:Vector.<OfferVO>;
		private var _timer:Timer;

		private var _offerText:String = 'CodeString.OfferWindow.Offer' //OFFER

		public function OfferRiverButton()
		{
			onClick = new Signal(OfferVO);
			super();

			_offerBtn = UIFactory.getButton(ButtonEnum.OFFER_CHEST);
			_offerBtn.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
			_offerBtn.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			_offerBtn.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true)
			_offerBtn.enabled = false;

			_offerGlow = UIFactory.getBitmap('BeginnersChestGlowBMD');
			_offerGlow.alpha = 0.0;
			_offerGlow.visible = false;

			_offerStarsA = UIFactory.getBitmap('BeginnersChestStarsABMD');
			_offerStarsA.alpha = 0.0;
			_offerStarsA.visible = false;

			_offerStarsB = UIFactory.getBitmap('BeginnersChestStarsBBMD');
			_offerStarsB.alpha = 1.0;
			_offerStarsB.visible = false;

			_offerTimeRemaining = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DYNAMIC, 150, 10);
			_offerTimeRemaining.constrictTextToSize = false;
			_offerTimeRemaining.align = TextFormatAlign.CENTER;

			_btnText = UIFactory.getLabel(LabelEnum.H3, 100, 25);
			_btnText.constrictTextToSize = false;
			_btnText.text = _offerText;

			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);

			addChild(_offerBtn);
			addChild(_offerTimeRemaining);
			addChild(_offerGlow);
			addChild(_offerStarsA);
			addChild(_offerStarsB);
			addChild(_btnText);

			layout();
		}

		private function layout():void
		{
			var btnTextOffset:Number = 16;
			if (_offerBtn)
			{
				_offerBtn.x = 18;
				_offerBtn.y = -7;
			}

			if (_offerGlow)
			{
				_offerGlow.x = _offerBtn.x;
				_offerGlow.y = _offerBtn.y;
			}

			if (_offerStarsA)
			{
				_offerStarsA.x = _offerBtn.x;
				_offerStarsA.y = _offerBtn.y;
			}

			if (_offerStarsB)
			{
				_offerStarsB.x = _offerBtn.x;
				_offerStarsB.y = _offerBtn.y;
			}

			if (_offerTimeRemaining)
			{
				_offerTimeRemaining.x = _offerBtn.x + (_offerBtn.width - _offerTimeRemaining.width) * 0.5;
				_offerTimeRemaining.y = _offerBtn.height - 17;

				btnTextOffset = 3;
			}

			if (_btnText)
			{
				_btnText.x = _offerBtn.x + (_offerBtn.width - _btnText.width) * 0.5;
				_btnText.y = _offerBtn.height - btnTextOffset;
			}
		}


		private function onMouseClick( e:MouseEvent ):void
		{
			if (onClick)
				onClick.dispatch(_currentOffer);
			e.stopPropagation();
		}

		private function onRollOver( e:MouseEvent = null ):void
		{
			if (_offerGlow)
			{
				TweenLite.killTweensOf(_offerGlow);
				_offerGlow.alpha = 1;
			}
		}

		private function onRollOut( e:MouseEvent = null ):void
		{
			if (_offerGlow)
			{
				_offerGlow.alpha = 0;
				onFadeOut(_offerGlow, 1.0, 0.8, 0.1);
			}
		}

		private function onFadeOut( fadeBitmap:Bitmap, fadeTime:Number, alphaIn:Number = 1.0, alphaOut:Number = 0.0 ):void
		{
			TweenLite.to(fadeBitmap, fadeTime, {alpha:alphaIn, ease:Quad.easeOut, onComplete:onFadeIn, onCompleteParams:[fadeBitmap, fadeTime, alphaIn, alphaOut], overwrite:0});
		}

		private function onFadeIn( fadeBitmap:Bitmap, fadeTime:Number, alphaIn:Number = 1.0, alphaOut:Number = 0.0 ):void
		{
			TweenLite.to(fadeBitmap, fadeTime, {alpha:alphaOut, ease:Quad.easeIn, onComplete:onFadeOut, onCompleteParams:[fadeBitmap, fadeTime, alphaIn, alphaOut], overwrite:0});
		}

		private function onTimerTick( e:TimerEvent ):void
		{
			if (_currentOffer == null)
			{
				if (_timer)
					_timer.stop();

				return;
			}
			var timeRemaining:Number = _currentOffer.timeRemainingMS;

			if (timeRemaining <= 0)
			{
				_timer.stop();
				onOfferEnded();
			} else
			{
				if (_offerTimeRemaining)
					_offerTimeRemaining.setBuildTime(timeRemaining / 1000, 3);
			}
		}

		private function onOfferEnded():void
		{
			if (_offers)
			{
				var len:uint = _offers.length;
				var currentOffer:OfferVO;
				for (var i:uint = 0; i < len; ++i)
				{
					currentOffer = _offers[i];
					if (currentOffer.offerPrototype == _currentOffer.offerPrototype)
					{
						_offers.splice(i, 1);
						_currentOffer = null;
						break;
					}
				}

				if (_offerTimeRemaining)
					_offerTimeRemaining.text = '';

				if (_offers.length > 0)
				{
					_currentOffer = _offers[0];
					if (_timer)
					{
						_timer.reset();
						_timer.start();
					}

					if (_offerTimeRemaining)
						_offerTimeRemaining.visible = true;
				} else
				{
					if (_offerBtn)
						_offerBtn.enabled = false;

					if (_offerGlow)
					{
						TweenLite.killTweensOf(_offerGlow);
						_offerGlow.visible = false;
					}

					if (_offerStarsA)
					{
						TweenLite.killTweensOf(_offerStarsA);
						_offerStarsA.visible = false;
					}

					if (_offerStarsB)
					{
						TweenLite.killTweensOf(_offerStarsB);
						_offerStarsB.visible = false;
					}

					if (_offerTimeRemaining)
						_offerTimeRemaining.visible = false;

				}
			}
		}

		public function set offers( v:Vector.<OfferVO> ):void
		{
			_offers = v;
			if (_offers && _offers.length > 0)
			{
				_currentOffer = _offers[0];

				if (_offerBtn)
					_offerBtn.enabled = true;

				if (_offerGlow)
				{
					TweenLite.killTweensOf(_offerGlow);
					_offerGlow.visible = true;
					onFadeOut(_offerGlow, 1.0, 0.8, 0.1);
				}

				if (_offerStarsA)
				{
					TweenLite.killTweensOf(_offerStarsA);
					_offerStarsA.visible = true;
					onFadeOut(_offerStarsA, 1.0);
				}

				if (_offerStarsB)
				{
					TweenLite.killTweensOf(_offerStarsB);
					_offerStarsB.visible = true;
					onFadeIn(_offerStarsB, 1.0);
				}

				if (_btnText)
				{
					_btnText.bold = true;
					_btnText.textColor = 0xd1e5f7;
					_btnText.text = _offerText;
					_btnText.x = _offerBtn.x + (_offerBtn.width - _btnText.width) * 0.5;
					_btnText.y = _offerBtn.height - 3;
				}

				if (_timer)
				{
					_timer.reset();
					_timer.start();
				}

				if (_offerTimeRemaining)
					_offerTimeRemaining.visible = true;

			} else
			{
				if (_offerBtn)
					_offerBtn.enabled = false;

				if (_offerGlow)
				{
					TweenLite.killTweensOf(_offerGlow);
					_offerGlow.visible = false;
				}

				if (_offerStarsA)
				{
					TweenLite.killTweensOf(_offerStarsA);
					_offerStarsA.visible = false;
				}

				if (_btnText)
				{
					_btnText.bold = false;
					_btnText.textColor = 0x213745;
					_btnText.text = _offerText;
					_btnText.x = _offerBtn.x + (_offerBtn.width - _btnText.width) * 0.5;
					_btnText.y = _offerBtn.height - 16;
				}

				if (_offerStarsB)
				{
					TweenLite.killTweensOf(_offerStarsB);
					_offerStarsB.visible = false;
				}

				if (_offerTimeRemaining)
					_offerTimeRemaining.visible = false;
			}
		}

		public function get currentOffer():OfferVO
		{
			return _currentOffer;
		}

		public function destroy():void
		{
			if (onClick)
				onClick.removeAll();

			onClick = null;

			if (_offerBtn)
			{
				_offerBtn.removeEventListener(MouseEvent.CLICK, onMouseClick);
				_offerBtn.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				_offerBtn.removeEventListener(MouseEvent.ROLL_OUT, onRollOut)
				_offerBtn.destroy();
			}

			_offerBtn = null;

			if (_offerGlow)
				TweenLite.killTweensOf(_offerGlow);

			_offerGlow = null;

			if (_offerStarsA)
				TweenLite.killTweensOf(_offerStarsA);

			_offerStarsA = null;

			if (_offerStarsB)
				TweenLite.killTweensOf(_offerStarsB);

			_offerStarsB = null;

			if (_timer)
			{
				_timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
				if (_timer.running)
					_timer.stop();
			}
			_timer = null;

			if (_offerTimeRemaining)
				_offerTimeRemaining.destroy();

			_offerTimeRemaining = null;

			if (_btnText)
				_btnText.destroy();

			_btnText = null;

		}
	}
}
