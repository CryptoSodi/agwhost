package com.ui.modal.paywall
{
	import com.Application;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.event.PaywallEvent;
	import com.presenter.shared.IUIPresenter;
	import com.service.kongregate.KongregateAPI;
	import com.service.facebook.FacebookAPI;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.service.ExternalInterfaceAPI;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.shared.ObjectPool;

	public class PaywallView extends View
	{
		private var _bg:DefaultWindowBG;

		private var _paywallEntries:Vector.<PaywallEntry>;
		private var _selectedPaywallEntry:PaywallEntry;

		private var _buyNowBtn:BitmapButton;

		private var _entries:Object;

		private var _purchaseInProgress:Boolean;
		private var _externalTrkID:String;

		private var _kongregateAPI:KongregateAPI;
		private var _facebookAPI:FacebookAPI;

		private var _titleText:String        = 'CodeString.PaywallView.Title'; //PAYMENTS
		private var _buyNowText:String       = 'CodeString.PaywallView.BuyBtn'; //BUY NOW

		private static const _logger:ILogger = getLogger('PaywallView');

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_paywallEntries = new Vector.<PaywallEntry>;

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(714, 399);
			_bg.addTitle(_titleText, 220);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_buyNowBtn = UIFactory.getButton(ButtonEnum.GOLD_A, 165, 40, 0, 394, _buyNowText, LabelEnum.H1);
			_buyNowBtn.x = 27 + (692 - _buyNowBtn.width) * 0.5;
			addListener(_buyNowBtn, MouseEvent.CLICK, onBuyClicked);

			addChild(_bg);
			addChild(_buyNowBtn);

			addEffects();
			effectsIN();
		}

		public function setUp( v:String ):void
		{
			_logger.info('setUp - Paywall string = {0}', [v]);
			var payWallData:Object = JSON.parse(v);
			
			if ('success' in payWallData && payWallData.success == true)
			{
				if ('items' in payWallData)
				{
					var currentEntry:PaywallEntry;
					for each (var item:Object in payWallData.items)
					{
						currentEntry = new PaywallEntry(item);
						currentEntry.onClicked.add(onSelectionChanged);
						
						if (_paywallEntries.length == 0)
						{
							onSelectionChanged(currentEntry);
						}

						addChild(currentEntry);
						_paywallEntries.push(currentEntry);
					}
					layout();
				}
			} else
				destroy();
		}

		private function onSelectionChanged( e:PaywallEntry ):void
		{
			if (!_purchaseInProgress)
			{
				if (_selectedPaywallEntry)
					_selectedPaywallEntry.selected = false

				_selectedPaywallEntry = e;

				_selectedPaywallEntry.selected = true;
			}
		}

		private function onPurchaseResult( result:Object ):void
		{
			_logger.info('onPurchaseResult - Purchase success');
			var paywall:PaywallEvent = new PaywallEvent(PaywallEvent.BUY_ITEM);
			presenter.dispatch(paywall);
		}

		private function layout():void
		{
			_paywallEntries.sort(sortByCost);

			var len:uint = _paywallEntries.length;
			var selection:PaywallEntry;
			var yPos:int = 53;
			var xPos:int = 26;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _paywallEntries[i];
				selection.x = xPos;
				selection.y = yPos;
				yPos += selection.height + 5;
			}
		}

		private function onBuyClicked( e:MouseEvent ):void
		{
			_logger.info('onBuyClicked - Attempt to purchase {0}', [_selectedPaywallEntry.id]);
			if (Application.NETWORK == Application.NETWORK_FACEBOOK)
			{
				if(_selectedPaywallEntry)
					_facebookAPI.purchaseCurrency(_selectedPaywallEntry.quantity, onPurchaseResult);
			}
			else if(Application.NETWORK == Application.NETWORK_KONGREGATE)
			{
				_kongregateAPI.purchaseItems([_selectedPaywallEntry.id], onPurchaseResult);
			}
			removeListener(_bg.closeButton, MouseEvent.CLICK, close);
			_purchaseInProgress = true;
			
			destroy();
		}

		private function sortByCost( itemOne:PaywallEntry, itemTwo:PaywallEntry ):Number
		{
			if (!itemOne)
				return -1;
			if (!itemTwo)
				return 1;

			var playerOneCost:int = itemOne.cost;
			var playerTwoCost:int = itemTwo.cost;

			if (playerOneCost < playerTwoCost)
				return -1;
			else if (playerOneCost > playerTwoCost)
				return 1;

			return 0;
		}

		private function close( e:MouseEvent ):void  { destroy(); }

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( v:IUIPresenter ):void  { _presenter = v; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		[Inject]
		public function set kongregateAPI( v:KongregateAPI ):void  { _kongregateAPI = v; }
		
		[Inject]
		public function set facebookAPI( v:FacebookAPI ):void  { _facebookAPI = v; }

		override public function destroy():void
		{
			super.destroy();

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			var len:uint = _paywallEntries.length;
			var selection:PaywallEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _paywallEntries[0];
				selection.destroy();
			}
			_paywallEntries.length = 0;

			if (_buyNowBtn)
				_buyNowBtn.destroy();

			_buyNowBtn = null;
		}
	}
}
