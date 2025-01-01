package com.ui.modal.traderoute.overview
{
	import com.model.starbase.TradeRouteVO;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.ButtonFactory;

	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;

	import org.osflash.signals.Signal;

	public class TradeRouteCorpBtn extends BitmapButton
	{
		private var _corpTradeRoute:TradeRouteVO;
		private var _corpImage:ImageComponent;
		private var _infoBtn:BitmapButton;
		public var showInfoSignal:Signal;

		public function TradeRouteCorpBtn()
		{
			super();

			showInfoSignal = new Signal();

			var corpBtnNeutralClass:Class  = Class(getDefinitionByName(('TradeRouteCorpBtnNeutralBMD')));
			var corpBtnRollOverClass:Class = Class(getDefinitionByName(('TradeRouteCorpBtnRollOverBMD')));
			var corpBtnDownClass:Class     = Class(getDefinitionByName(('TradeRouteCorpBtnSelectedBMD')));
			_corpTradeRoute = tradeRoute;

			super.init(BitmapData(new corpBtnNeutralClass()), BitmapData(new corpBtnRollOverClass()), BitmapData(new corpBtnDownClass()));

			_infoBtn = ButtonFactory.getBitmapButton('TradeRouteInfoBtnNeutralBMD', 266, 4, '', 0xFFFFFF, 'TradeRouteInfoBtnRollOverBMD', 'TradeRouteInfoBtnDownBMD');
			addChild(_infoBtn);

			_corpImage = new ImageComponent();
			_corpImage.init(_bitmap.width, _bitmap.height);
			addChild(_corpImage);
		}

		public function onLoadImage( asset:BitmapData ):void
		{
			if (_corpImage)
			{
				_corpImage.onImageLoaded(asset);
				_corpImage.x = _bitmap.x + (_bitmap.width - _corpImage.width) * 0.5;
				_corpImage.y = _bitmap.y + (_bitmap.height - _corpImage.height) * 0.5;
			}
		}

		override protected function onMouse( e:MouseEvent ):void
		{
			if (mouseEnabled)
			{
				if (e.target != _infoBtn)
					super.onMouse(e);
				else
					showInfoSignal.dispatch(_corpTradeRoute.factionPrototype);
			}
		}

		public function set tradeRoute( value:TradeRouteVO ):void
		{
			_corpTradeRoute = value;
		}

		public function get tradeRoute():TradeRouteVO
		{
			return _corpTradeRoute;
		}

		override public function destroy():void
		{
			super.destroy();
		}
	}
}
