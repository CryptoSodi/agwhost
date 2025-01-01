package com.ui.modal.construction
{
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.prototype.IPrototype;
	import com.presenter.starbase.IConstructionPresenter;
	import com.ui.UIFactory;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.building.RefitBuildingView;
	import com.ui.modal.shipyard.ShipyardView;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.osflash.signals.Signal;
	import org.parade.core.IView;
	import org.parade.core.IViewFactory;
	import org.shared.ObjectPool;

	public class ConstructionList extends Sprite
	{
		private var _bg:Sprite;
		private var _closeSignal:Signal;
		private var _holder:Sprite;
		private var _items:Vector.<ConstructionItem>;
		private var _maxHeight:int;
		private var _presenter:IConstructionPresenter;
		private var _scrollBar:VScrollbar;
		private var _scrollRect:Rectangle;
		private var _state:int;
		private var _tooltips:Tooltips;
		private var _viewFactory:IViewFactory;

		internal function init( presenter:IConstructionPresenter, state:int, tooltips:Tooltips, viewFactory:IViewFactory ):void
		{
			_presenter = presenter;
			_state = state;
			_tooltips = tooltips;
			_bg = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_NOTCHED, PanelEnum.HEADER_NOTCHED_RIGHT, 626, 494, 30, 0, 0, "TEST", LabelEnum.H3);
			_closeSignal = new Signal();
			_viewFactory = viewFactory;

			_holder = new Sprite();
			_holder.x = 4;
			_holder.y = 34;

			_items = new Vector.<ConstructionItem>;
			_maxHeight = 0;

			_scrollRect = new Rectangle(0, 0, 626, 488);

			//scrollbar
			_scrollBar = new VScrollbar();
			_scrollBar.init(7, _scrollRect.height - 15, 606, 32, new Rectangle(0, 4, 5, 3), '', 'ScrollBarBMD', '', false, this);
			_scrollBar.onScrollSignal.add(onChangedScroll);
			_scrollBar.updateDisplayedHeight(_scrollRect.height);
			_scrollBar.updateScrollableHeight(_maxHeight);
			_scrollBar.maxScroll = 29.5;

			addChild(_bg);
			addChild(_holder);
			addChild(_scrollBar);
		}

		internal function update( items:Vector.<IPrototype> ):void
		{
			clearCurrentItems();

			var item:ConstructionItem;
			for (var i:int = 0; i < items.length; i++)
			{
				item = ObjectPool.get(ConstructionItem);
				item.init(items[i], _presenter, _state, _tooltips);
				item.y = _maxHeight;
				item.addEventListener(MouseEvent.CLICK, onItemClicked, false, 0, true);
				_maxHeight += 122;
				_holder.addChild(item);
				_items.push(item);
			}

			_scrollBar.updateScrollableHeight(_maxHeight);
			_scrollBar.updateDisplayedHeight(_scrollRect.height);
			_scrollBar.updateScrollY(0);
		}

		internal function onSpecialButtonClicked( e:MouseEvent ):void
		{
			switch (_state)
			{
				case ConstructionView.COMPONENT:
					var targetView:IView = _presenter.getView(ShipyardView);
					if (targetView)
						ShipyardView(targetView).onComponentSelected(null);
					else
					{
						targetView = _presenter.getView(RefitBuildingView);
						if (targetView)
							RefitBuildingView(targetView).onModuleSelected(null);
					}
					onClose();
					break;
			}
		}

		private function onItemClicked( e:MouseEvent ):void
		{
			var item:ConstructionItem = ConstructionItem(e.currentTarget);
			var view:IView;
			switch (_state)
			{
				case ConstructionView.BUILD:
					view = _viewFactory.createView(ConstructionInfoView);
					ConstructionInfoView(view).setup(_state, item.prototype);
					ConstructionInfoView(view).callback = onClose;
					break;

				case ConstructionView.COMPONENT:
					var targetView:IView = _presenter.getView(ShipyardView);
					if (targetView)
						ShipyardView(targetView).onComponentSelected(item.prototype);
					else
					{
						targetView = _presenter.getView(RefitBuildingView);
						if (targetView)
							RefitBuildingView(targetView).onModuleSelected(item.prototype);
					}
					onClose();
					break;

				case ConstructionView.RESEARCH:
					view = _viewFactory.createView(ConstructionInfoView);
					ConstructionInfoView(view).setup(_state, item.prototype);
					ConstructionInfoView(view).callback = onClose;
					break;
			}

			if (view)
				_viewFactory.notify(view);
		}

		private function clearCurrentItems():void
		{
			if (_items)
			{
				for (var i:int = 0; i < _items.length; i++)
				{
					_holder.removeChild(_items[i]);
					_items[i].removeEventListener(MouseEvent.CLICK, onItemClicked);
					ObjectPool.give(_items[i]);
				}
				_items.length = _maxHeight = 0;
			}
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		private function onClose():void
		{
			_closeSignal.dispatch();
		}

		internal function addCloseListener( listener:Function ):void  { _closeSignal.add(listener); }

		internal function set title( v:String ):void  { Label(_bg.getChildAt(2)).text = v; }

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);

			clearCurrentItems();
			_bg = UIFactory.destroyPanel(_bg);
			_closeSignal.removeAll();
			_closeSignal = null;
			_holder = null;
			_presenter = null;
			_scrollBar.destroy();
			_scrollBar = null;
			_scrollRect = null;
			_tooltips.removeTooltip(null, this);
			_tooltips = null;
			_viewFactory = null;
		}
	}
}
