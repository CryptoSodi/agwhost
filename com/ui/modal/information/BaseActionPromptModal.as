package com.ui.modal.information
{
	import com.enum.TypeEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.event.StarbaseEvent;
	import com.model.asset.AssetModel;
	import com.presenter.shared.IUIPresenter;
	import com.service.loading.LoadPriority;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.construction.ConstructionView;
	import com.ui.modal.traderoute.overview.TradeRouteOverviewView;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import org.parade.core.IView;
	import org.shared.ObjectPool;

	public class BaseActionPromptModal extends View
	{
		static public const BUILD_ACTION:uint            = 1 << 0;
		static public const TRADE_ACTION:uint            = 1 << 1;
		static public const RESEARCH_WEAPONS_ACTION:uint = 1 << 2;
		static public const RESEARCH_DEFENSE_ACTION:uint = 1 << 3;
		static public const RESEARCH_TECH_ACTION:uint    = 1 << 4;
		static public const RESEARCH_SHIPS_ACTION:uint   = 1 << 5;

		private var _titleString:String                  = "CodeString.ActionPrompt.Title";
		private var _messageString:String                = "CodeString.ActionPrompt.Message";

		private var _buildBtnString:String               = "CodeString.ActionPrompt.BuildButton";
		private var _researchBtnString:String            = "CodeString.ActionPrompt.ResearchButton";
		private var _tradeBtnString:String               = "CodeString.ActionPrompt.TradeButton";

		public var actionTypes:uint                      = 0;

		[Inject]
		public var assetModel:AssetModel;

		[PostConstruct]
		override public function init():void
		{
			super.init();

			createChildren();
			updateDisplayList();

			addEffects();
			effectsIN();
		}

		private var _childrenCreated:Boolean;

		private var _bg:DefaultWindowBG;
		private var _msgLbl:Label;
		private var _msgBkgd:ScaleBitmap;

		private var _buildImg:ImageComponent;
		private var _buildBtn:BitmapButton;

		private var _researchImg:ImageComponent;
		private var _researchBtn:BitmapButton;

		private var _tradeImg:ImageComponent;
		private var _tradeBtn:BitmapButton;

		static private const IMG_ENABLED_SUFFIX:String   = "_Image_Active.png";
		static private const IMG_DISABLED_SUFFIX:String  = "_Image_NonActive.png";

		private var _btns:Vector.<DisplayObject>         = Vector.<DisplayObject>([]);
		private var _imgs:Vector.<DisplayObject>         = Vector.<DisplayObject>([]);

		protected function createChildren():void
		{
			if (_childrenCreated)
				return;

			var imgURL:String;

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.addTitle(_titleString, 180);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);
			addChild(_bg);

			_msgBkgd = UIFactory.getPanel(PanelEnum.CONTAINER_NOTCHED_RIGHT_SMALL, 550, 32);
			addChild(_msgBkgd);

			_msgLbl = UIFactory.getLabel(LabelEnum.SUBTITLE, 550, 32);
			_msgLbl.align = TextFormatAlign.LEFT;
			_msgLbl.text = _messageString;
			var tf:TextFormat = _msgLbl.defaultTextFormat;
			tf.font = "Agency";
			_msgLbl.defaultTextFormat = tf;
			addChild(_msgLbl);

			//BUILD
			_buildImg = ObjectPool.get(ImageComponent);
			_buildImg.init(188, 214);
			_buildImg.center = true;
			_buildImg.name = "img_" + BUILD_ACTION.toString();
			imgURL = "assets/PromptForAction/Build";
			imgURL += BUILD_ACTION == (actionTypes & BUILD_ACTION) ? IMG_ENABLED_SUFFIX : IMG_DISABLED_SUFFIX;
			assetModel.getFromCache(imgURL, _buildImg.onImageLoaded, LoadPriority.MEDIUM);
			addChild(_buildImg);
			_imgs.push(_buildImg);

			_buildBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 188, 40, 0, 0, _buildBtnString);
			_buildBtn.name = "btn_" + BUILD_ACTION.toString();
			_buildBtn.enabled = BUILD_ACTION == (actionTypes & BUILD_ACTION);
			_buildBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
			addChild(_buildBtn);
			_btns.push(_buildBtn);

			//RESEARCH
			var researchType:uint;

			if (RESEARCH_WEAPONS_ACTION == (actionTypes & RESEARCH_WEAPONS_ACTION))
				researchType = RESEARCH_WEAPONS_ACTION;

			else if (RESEARCH_DEFENSE_ACTION == (actionTypes & RESEARCH_DEFENSE_ACTION))
				researchType = RESEARCH_DEFENSE_ACTION;

			else if (RESEARCH_TECH_ACTION == (actionTypes & RESEARCH_TECH_ACTION))
				researchType = RESEARCH_TECH_ACTION;

			else if (RESEARCH_SHIPS_ACTION == (actionTypes & RESEARCH_SHIPS_ACTION))
				researchType = RESEARCH_SHIPS_ACTION;

			_researchImg = ObjectPool.get(ImageComponent);
			_researchImg.init(188, 214);
			_researchImg.center = true;
			_researchImg.name = "img_" + researchType.toString();
			imgURL = "assets/PromptForAction/Research";
			imgURL += researchType > 0 ? IMG_ENABLED_SUFFIX : IMG_DISABLED_SUFFIX;
			assetModel.getFromCache(imgURL, _researchImg.onImageLoaded, LoadPriority.MEDIUM);
			addChild(_researchImg);
			_imgs.push(_researchImg);

			_researchBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 188, 40, 0, 0, _researchBtnString);
			_researchBtn.name = "btn_" + researchType.toString();
			_researchBtn.enabled = researchType > 0;
			_researchBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
			addChild(_researchBtn);
			_btns.push(_researchBtn);

			//TRADE
			_tradeImg = ObjectPool.get(ImageComponent);
			_tradeImg.init(188, 214);
			_tradeImg.center = true;
			_tradeImg.name = "img_" + TRADE_ACTION.toString();
			imgURL = "assets/PromptForAction/TradeRoute";
			imgURL += TRADE_ACTION == (actionTypes & TRADE_ACTION) ? IMG_ENABLED_SUFFIX : IMG_DISABLED_SUFFIX;
			assetModel.getFromCache(imgURL, _tradeImg.onImageLoaded, LoadPriority.MEDIUM);
			addChild(_tradeImg);
			_imgs.push(_tradeImg);

			_tradeBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 188, 40, 0, 0, _tradeBtnString);
			_tradeBtn.name = "btn_" + TRADE_ACTION.toString();
			_tradeBtn.enabled = TRADE_ACTION == (actionTypes & TRADE_ACTION);
			_tradeBtn.addEventListener(MouseEvent.CLICK, onButtonClick);
			addChild(_tradeBtn);
			_btns.push(_tradeBtn);

			_childrenCreated = true;
		}

		public function updateDisplayList():void
		{
			const PADDING_TOP:Number    = 60;
			const PADDING_BOTTOM:Number = 10;
			const PADDING_LEFT:Number   = 35;
			const PADDING_RIGHT:Number  = 10;
			const GAP:Number            = 15;

			var iw:Number               = 188 * 3 + GAP * 2;
			var tx:Number               = PADDING_LEFT;
			var tw:Number               = PADDING_LEFT + iw + PADDING_RIGHT;

			_msgBkgd.x = PADDING_LEFT;
			_msgBkgd.y = PADDING_TOP;
			_msgBkgd.setSize(iw, 32);

			_msgLbl.x = PADDING_LEFT + 3;
			_msgLbl.y = PADDING_TOP + 3;
			_msgLbl.setSize(iw, 32);

			var uic:DisplayObject;
			var i:int;

			for (i; i < _btns.length; i++)
			{
				uic = _imgs[i];
				uic.x = tx;
				uic.y = _msgBkgd.y + _msgBkgd.height + GAP;

				uic = _btns[i];
				uic.x = tx;
				uic.y = _msgBkgd.y + _msgBkgd.height + GAP + 214 + GAP;

				tx += uic.width + GAP;
			}

			var th:Number               = _msgBkgd.y + _msgBkgd.height + GAP + 214 + GAP + 40;

			//			_bg.setBGSize(tw, th);
			_bg.setBGSize(635, 360);
		}

		private function onButtonClick( event:MouseEvent ):void
		{
			var name:String = event.target.name;
			var id:uint;

			if (name && name.indexOf("_") > -1)
			{
				var ns:Array = name.split("_");
				id = uint(ns[1]);
			}

			if (id == 0)
				return;

			var view:IView;

			switch (id)
			{
				case BUILD_ACTION:
				{
					view = presenter.getView(ConstructionView);
					if (!view)
					{
						view = _viewFactory.createView(ConstructionView);
						ConstructionView(view).openOn(ConstructionView.BUILD, null, null);
					} else
						view = null;
					break;
				}

				case RESEARCH_WEAPONS_ACTION:
				{
					view = _viewFactory.createView(ConstructionView);
					ConstructionView(view).openOn(ConstructionView.RESEARCH, TypeEnum.WEAPONS_FACILITY, null);
					break;
				}

				case RESEARCH_DEFENSE_ACTION:
				{
					view = _viewFactory.createView(ConstructionView);
					ConstructionView(view).openOn(ConstructionView.RESEARCH, TypeEnum.DEFENSE_DESIGN, null);
					break;
				}

				case RESEARCH_TECH_ACTION:
				{
					view = _viewFactory.createView(ConstructionView);
					ConstructionView(view).openOn(ConstructionView.RESEARCH, TypeEnum.ADVANCED_TECH, null);
					break;
				}

				case RESEARCH_SHIPS_ACTION:
				{
					view = _viewFactory.createView(ConstructionView);
					ConstructionView(view).openOn(ConstructionView.RESEARCH, TypeEnum.SHIPYARD, null);
					break;
				}

				case TRADE_ACTION:
				{
					view = _viewFactory.createView(TradeRouteOverviewView);
					break;
				}
			}

			if (view)
				_viewFactory.notify(view);

			destroy();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( v:IUIPresenter ):void  { _presenter = v; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.dispatch(new StarbaseEvent(StarbaseEvent.WELCOME_BACK));
			super.destroy();

			if (_bg)
				ObjectPool.give(_bg);
			_bg = null;

			_msgBkgd = null;

			if (_msgLbl)
				_msgLbl.destroy();

			_msgLbl = null;

			if (_buildImg)
				ObjectPool.give(_buildImg);

			_buildImg = null;

			if (_researchImg)
				ObjectPool.give(_researchImg);

			_researchImg = null;

			if (_tradeImg)
				ObjectPool.give(_tradeImg);

			_tradeImg = null;

			if (_buildBtn)
			{
				_buildBtn.removeEventListener(MouseEvent.CLICK, onButtonClick);
				_buildBtn.destroy();
			}

			_buildBtn = null;

			if (_researchBtn)
			{
				_researchBtn.removeEventListener(MouseEvent.CLICK, onButtonClick);
				_researchBtn.destroy();
			}

			_researchBtn = null;

			if (_tradeBtn)
			{
				_tradeBtn.removeEventListener(MouseEvent.CLICK, onButtonClick);
				_tradeBtn.destroy();
			}

			_tradeBtn = null;
		}
	}
}
