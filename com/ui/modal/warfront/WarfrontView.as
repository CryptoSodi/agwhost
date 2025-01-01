package com.ui.modal.warfront
{
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.warfrontModel.WarfrontVO;
	import com.presenter.battle.IWarfrontPresenter;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	import org.parade.core.IView;
	import org.shared.ObjectPool;

	public class WarfrontView extends View implements IView
	{
		private var _bg:DefaultWindowBG;

		private var _entries:Vector.<WarfrontEntry>;

		private var _holder:Sprite;

		private var _lookup:Dictionary;

		private var _maxHeight:int;

		private var _nobattles:Label;

		private var _scrollbar:VScrollbar;

		private var _scrollRect:Rectangle;

		private var _titleText:String     = 'CodeString.Warfront.Title';
		private var _noBattlesText:String = 'CodeString.Warfront.Empty'; //Your faction needs your strength - don't be shy, enter the fray! 

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(722, 420);
			_bg.addTitle(_titleText, 139);
			_bg.x -= 21;
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);
			addChild(_bg);

			_entries = new Vector.<WarfrontEntry>;
			_lookup = new Dictionary(true);
			_maxHeight = 0;

			_holder = new Sprite();
			_holder.x = 6;
			_holder.y = 61;

			_nobattles = new Label(24, 0xf0f0f0);
			_nobattles.constrictTextToSize = false;
			_nobattles.autoSize = TextFieldAutoSize.CENTER;
			_nobattles.x = _bg.x + (_bg.width - _nobattles.textWidth) * 0.5;
			_nobattles.y = _bg.y + (_bg.height - _nobattles.textHeight) * 0.5;
			_nobattles.text = _noBattlesText;

			_scrollRect = new Rectangle(0, 0, 682, 386);
			_scrollRect.y = 0;
			_holder.scrollRect = _scrollRect;

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 3, 5, 7);
			var scrollbarXPos:Number    = 690;
			var scrollbarYPos:Number    = 57;
			_scrollbar.init(7, _scrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollBarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 24.25;

			addChild(_bg);
			addChild(_holder);
			addChild(_nobattles);
			addChild(_scrollbar);

			presenter.addUpdateListener(onWarfrontUpdated);
			onWarfrontUpdated(presenter.battles, null);

			addEffects();
			effectsIN();
		}

		private function onWarfrontUpdated( battles:Vector.<WarfrontVO>, removed:Vector.<String> ):void
		{
			var entry:WarfrontEntry;
			var index:int;

			//add the new warfronts
			for (var i:int = battles.length - 1; i >= 0; i--)
			{
				if (!_lookup.hasOwnProperty(battles[i].id))
				{
					entry = ObjectPool.get(WarfrontEntry);
					entry.setup(battles[i]);
					entry.onClicked.add(onEntryClicked);
					entry.onLoadImage.add(onLoadImage);
					entry.layout();
					_holder.addChild(entry);
					_entries.unshift(entry);
					_lookup[battles[i].id] = entry;
				}
			}

			//remove the existing warfronts
			if (removed)
			{
				for (i = 0; i < removed.length; i++)
				{
					entry = _lookup[removed[i]];
					if (entry)
					{
						index = _entries.indexOf(entry);
						if (index > -1)
						{
							_entries.splice(index, 1);
							_holder.removeChild(entry);
							ObjectPool.give(entry);
						}
						delete _lookup[removed[i]];
					}
				}
			}

			//layout the entries
			layout();
		}

		private function onEntryClicked( battle:WarfrontVO ):void
		{
			presenter.watchBattle(battle);
		}

		private function onLoadImage( race:String, callback:Function ):void
		{
			if (_presenter)
				presenter.loadPortraitSmall(race, callback);
		}

		protected function layout():void
		{
			var len:uint = _entries.length;
			var selection:WarfrontEntry;
			var yPos:int = 0;
			_nobattles.visible = (len > 0) ? false : true;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _entries[i];
				selection.y = yPos;
				_maxHeight += selection.height + 5;
				yPos += selection.height + 5;
			}
			_maxHeight -= 3;
			_scrollbar.updateScrollableHeight(_maxHeight);
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( v:IWarfrontPresenter ):void  { _presenter = v; }
		public function get presenter():IWarfrontPresenter  { return IWarfrontPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.removeStateListener(destroy);
			presenter.removeUpdateListener(onWarfrontUpdated);
			super.destroy();

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			if (_nobattles)
				_nobattles.destroy();

			_nobattles = null;

			if (_scrollbar)
				_scrollbar.destroy();

			_scrollbar = null;

			_scrollRect = null;

			var len:uint = _entries.length;
			var entry:WarfrontEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				entry = _entries[i];
				entry.destroy();
				entry = null;
			}
			_entries.length = 0;

			_holder = null;
			_lookup = null;
		}
	}
}
