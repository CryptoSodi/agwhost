package com.ui.hud.shared.command
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.model.prototype.IPrototype;
	import com.model.starbase.TradeRouteVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.starbase.ITradePresenter;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.ScaleBitmap;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.osflash.signals.Signal;
	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class TradeRouteComponent extends Sprite
	{
		static public const STATE_LOCKED:String = "locked";
		static public const STATE_ACTIVE:String = "active";
		static public const STATE_RENEW:String  = "renew";

		public var tradePresenter:ITradePresenter;

		public var onClick:Signal;

		private var _agentImg:ImageComponent;
		private var _renewImg:ScaleBitmap;
		private var _lockImg:Bitmap;
		private var _frameBtn:BitmapButton;
		private var _nextLbl:Label;
		private var _timeLbl:Label;
		private var _isPendingUpdate:Boolean;
		private var _tradeData:TradeRouteVO;
		private var _isInitialized:Boolean;
		private var _timer:Timer;
		private var _unscaledHeight:Number      = 0;
		private var _unscaledWidth:Number       = 0;

		private var _nextDeliveryText:String    = 'CodeString.TradeRouteComponent.NextDelivery'; //NEXT DELIVERY
		private var _expiredText:String         = 'CodeString.TradeRouteComponent.Expired'; //EXPIRED
		private var _lockedText:String          = 'CodeString.TradeRouteComponent.Locked'; //LOCKED

		public function init():void
		{
			_unscaledWidth = 60;
			_unscaledHeight = 60;

			onClick = new Signal(String);

			_renewImg = UIFactory.getScaleBitmap("TradeRouteRiverExclamationBMD");
			_renewImg.visible = false;
			addChild(_renewImg);

			_lockImg = UIFactory.getBitmap("IconBlueLockedBMD");
			_lockImg.visible = false;
			addChild(_lockImg);

			_frameBtn = UIFactory.getButton(ButtonEnum.CHARACTER_FRAME);
			_frameBtn.addEventListener(MouseEvent.CLICK, onMouseClick);
			addChild(_frameBtn);

			_agentImg = ObjectPool.get(ImageComponent);
			_agentImg.visible = false;
			_agentImg.init(54, 54);
			addChildAt(_agentImg, 0);

			_nextLbl = UIFactory.getLabel(LabelEnum.H5, 100, 25);
			_nextLbl.align = TextFormatAlign.CENTER;
			_nextLbl.constrictTextToSize = true;
			_nextLbl.bold = false;
			_nextLbl.textColor = 0xd1e5f7;
			_nextLbl.text = "";
			addChild(_nextLbl);

			_timeLbl = UIFactory.getLabel(LabelEnum.H4, 125, 25);
			_timeLbl.align = TextFormatAlign.CENTER;
			_timeLbl.constrictTextToSize = false;
			_timeLbl.textColor = 0xecffff;
			_timeLbl.text = "";
			addChild(_timeLbl);

			_isInitialized = true;

			if (_isPendingUpdate)
				update(_tradeData);

			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, onTimerTick);
		}

		protected function updateDisplayList():void
		{
			if (!_isInitialized)
				return;

			_frameBtn.setSize(_unscaledWidth, _unscaledHeight);

			_agentImg.x = _frameBtn.x + (_unscaledWidth - _agentImg.width) / 2;
			_agentImg.y = _frameBtn.y + (_unscaledHeight - _agentImg.height) / 2;

			_renewImg.x = (_unscaledWidth - _renewImg.width) / 2;
			_renewImg.y = (_unscaledHeight - _renewImg.height) / 2;

			_lockImg.width = _lockImg.height = 54;
			_lockImg.x = (_unscaledWidth - _lockImg.width) / 2;
			_lockImg.y = (_unscaledHeight - _lockImg.height) / 2;

			switch (_crntState)
			{
				case STATE_ACTIVE:
				{
					_agentImg.visible = true;
					_renewImg.visible = false;
					_lockImg.visible = false;

					_nextLbl.text = _nextDeliveryText;
					_timeLbl.text = "9m 59s";

					TweenLite.killTweensOf(_renewImg);

					break;
				}

				case STATE_RENEW:
				{
					_agentImg.visible = false;
					_renewImg.visible = true;
					_lockImg.visible = false;
					_nextLbl.text = _expiredText;
					_timeLbl.text = "";

					onFadeOut();

					break;
				}

				case STATE_LOCKED:
				default:
				{
					_agentImg.visible = false;
					_renewImg.visible = false;
					_lockImg.visible = true;

					_nextLbl.text = _lockedText;
					_timeLbl.text = "";

					TweenLite.killTweensOf(_renewImg);

					break;
				}
			}

			_nextLbl.x = _frameBtn.x + (_unscaledWidth - _nextLbl.width) / 2;
			_nextLbl.y = _frameBtn.y + _frameBtn.height + 2;

			_timeLbl.y = _nextLbl.y + _nextLbl.height - 7;

			_timer.reset();
			_timer.start();
		}

		private function onMouseClick( event:MouseEvent ):void
		{
			if (onClick)
				onClick.dispatch(_crntState);
		}

		public function update( tradeData:Object ):void
		{
			_tradeData = tradeData is TradeRouteVO ? TradeRouteVO(tradeData) : null;

			if (!_isInitialized)
			{
				_isPendingUpdate = true;
				return;
			}

			if (_tradeData)
			{
				var proto:IPrototype = tradePresenter.getAgent(_tradeData.contractGroup, 1441);
				tradePresenter.loadIconFromPrototype("iconImage", proto, onImageLoaded);

				_crntState = STATE_ACTIVE;
			}

			else if (tradeData)
				_crntState = STATE_RENEW;

			else
				_crntState = STATE_LOCKED;

			updateDisplayList();
		}

		private function onTimerTick( e:TimerEvent ):void
		{
			if (!_tradeData)
				return;

			var freq:int                            = _tradeData.frequency * 60 * 1000;
			var tradeRouteTransaction:TransactionVO = tradePresenter.getTradeRouteTransaction(_tradeData.id);
			if (tradeRouteTransaction)
			{
				var nextDropMS:int = tradeRouteTransaction.timeRemainingMS % freq;

				if (_timeLbl)
				{
					_timeLbl.setBuildTime(nextDropMS / 1000, 2);
					_timeLbl.x = _frameBtn.x + (_unscaledWidth - _timeLbl.width) / 2;
				}
			}
		}

		private var _crntState:String           = STATE_LOCKED;

		private function onImageLoaded( asset:BitmapData ):void
		{
			if (_agentImg)
				_agentImg.onImageLoaded(asset);

			updateDisplayList();
		}

		private function onFadeOut():void
		{
			TweenLite.to(_renewImg, .5, {alpha:1.0, ease:Quad.easeOut, onComplete:onFadeIn});
		}

		private function onFadeIn():void
		{
			TweenLite.to(_renewImg, .5, {alpha:0.0, ease:Quad.easeIn, onComplete:onFadeOut});
		}

		public function destroy():void
		{
			_isInitialized = false;
			
			onClick.removeAll();
			onClick = null;

			tradePresenter = null;

			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
			_timer = null;

			_frameBtn.removeEventListener(MouseEvent.CLICK, onMouseClick);
			_frameBtn.destroy();
			_frameBtn = null;

			_agentImg.destroy();
			_agentImg = null;

			TweenLite.killTweensOf(_renewImg);
			_renewImg.destroy();
			_renewImg = null;

			_lockImg = null;

			_nextLbl.destroy();
			_nextLbl = null;

			_timeLbl.destroy();
			_timeLbl = null;
		}
	}
}
