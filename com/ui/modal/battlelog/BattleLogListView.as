package com.ui.modal.battlelog
{
	import com.Application;
	import com.enum.BattleLogFilterEnum;
	import com.model.battlelog.BattleLogVO;
	import com.presenter.shared.IUIPresenter;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.accordian.AccordianComponent;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import org.shared.ObjectPool;

	public class BattleLogListView extends View
	{
		private var _bg:DefaultWindowBG;
		private var _battleLogEntries:Dictionary;
		private var _noBattleLogs:Label;
		private var _accordian:AccordianComponent;

		private var _battleLogs:Vector.<BattleLogEntry>;

		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _holder:Sprite;

		private var _titleText:String        = 'CodeString.BattleLogs.Title';
		private var _noBattleLogsText:String = 'CodeString.BattleLog.NoBattleLogs'; //Your faction needs your strength - don't be shy, enter the fray!
		
		// accordian entries for results filtering
		private var _filterSelfAllText:String = 'CodeString.BattleLog.ShowSelfAll';
		private var _filterSelfPvPText:String = 'CodeString.BattleLog.ShowSelfPvP';
		private var _filterSelfPvEText:String = 'CodeString.BattleLog.ShowSelfPvE';
		private var _filterFleetPvPText:String = 'CodeString.BattleLog.ShowFleetPvP';
		private var _filterBasePvPText:String = 'CodeString.BattleLog.ShowBasePvP';
		private var _filterBestPvEText:String = 'CodeString.BattleLog.ShowBestPvE';

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_battleLogEntries = new Dictionary;
			_battleLogs = new Vector.<BattleLogEntry>;
			
			var filterWidth:int = ( Application.BATTLE_WEB_PATH )?150:0; 

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(722+filterWidth, 475);
			_bg.addTitle(_titleText, 239);
			_bg.x -= 21;
			
			if( Application.BATTLE_WEB_PATH )
			{
				_accordian = ObjectPool.get(AccordianComponent);
				_accordian.init(140, 52);
				_accordian.x = _bg.bg.x;
				_accordian.y = _bg.bg.y + 5;
				_accordian.addListener(onAccordianSelected);
				_accordian.addGroup(BattleLogFilterEnum.SELFALL, _filterSelfAllText);			
				_accordian.addGroup(BattleLogFilterEnum.SELFPVP, _filterSelfPvPText);			
				_accordian.addGroup(BattleLogFilterEnum.SELFPVE, _filterSelfPvEText);			
				_accordian.addGroup(BattleLogFilterEnum.BASEPVP, _filterBasePvPText);			
				_accordian.addGroup(BattleLogFilterEnum.FLEETPVP, _filterFleetPvPText);
				_accordian.addGroup(BattleLogFilterEnum.BESTPVE, _filterBestPvEText);			
			}
			
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);
			addChild(_bg);

			_noBattleLogs = new Label(24, 0xf0f0f0);
			_noBattleLogs.constrictTextToSize = false;
			_noBattleLogs.autoSize = TextFieldAutoSize.CENTER;
			_noBattleLogs.x = _bg.x + (_bg.width - _noBattleLogs.textWidth) * 0.5;
			_noBattleLogs.y = _bg.y + (_bg.height - _noBattleLogs.textHeight) * 0.5;
			_noBattleLogs.text = _noBattleLogsText;

			_holder = new Sprite();
			_holder.x = 6+filterWidth;
			_holder.y = 50;
			_maxHeight = 0;

			_scrollRect = new Rectangle(0, 0, 682+filterWidth, 448);
			_scrollRect.y = 0;
			_holder.scrollRect = _scrollRect;

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = 690+filterWidth;
			var scrollbarYPos:Number    = 78;
			_scrollbar.init(7, _scrollRect.height - 10, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollBarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 28.25;

			addChild(_bg);
			if( _accordian )
			{
				addChild(_accordian);
			}
			addChild(_noBattleLogs);
			addChild(_scrollbar);
			addChild(_holder);

			presenter.addBattleLogListUpdatedListener(onBattleLogListUpdated);
			presenter.getBattleLogList( BattleLogFilterEnum.SELFALL);
			if( _accordian )
			{
				_accordian.setSelected(BattleLogFilterEnum.SELFALL, "");
			}
			addEffects();
			effectsIN();
		}

		private function onBattleLogListUpdated( v:Vector.<BattleLogVO> ):void
		{
			destroyEntries();
			_battleLogEntries = new Dictionary;

			var len:int = v.length;
			var currentBattleLogVO:BattleLogVO;
			var currentBattleLogEntry:BattleLogEntry;
			for (var i:int = 0; i < len; ++i)
			{
				currentBattleLogVO = v[i];
				if (currentBattleLogVO.battleKey in _battleLogEntries)
					currentBattleLogEntry = _battleLogEntries[currentBattleLogVO.battleKey];
				else
				{
					currentBattleLogEntry = new BattleLogEntry(currentBattleLogVO);
					currentBattleLogEntry.onClicked.add(onEntryClicked);
					currentBattleLogEntry.onLoadImage.add(onLoadImage);
					currentBattleLogEntry.onReplayClicked.add(onReplay);
					currentBattleLogEntry.setUp();
					_battleLogs.push(currentBattleLogEntry);
				}
				_battleLogEntries[currentBattleLogVO.battleKey] = currentBattleLogEntry;
				_holder.addChild(currentBattleLogEntry);
			}

			_battleLogs.sort(orderItems);
			layout();
		}

		private function onEntryClicked( log:BattleLogVO ):void
		{
			var battleLogDetailView:BattleLogDetailView = BattleLogDetailView(_viewFactory.createView(BattleLogDetailView));
			battleLogDetailView.battleLog(log);
			_viewFactory.notify(battleLogDetailView);
		}
		
		private function onReplay( log:BattleLogVO ):void
		{
			var battleId:String = log.battleKey.replace(".battleLog", "");
			presenter.viewBattleReplay( battleId );
		}
		
		private function onAccordianSelected( groupID:String, subItemID:String, data:* ):void
		{
			presenter.getBattleLogList( groupID );
		}

		private function onLoadImage( race:String, callback:Function ):void
		{
			if (presenter)
				presenter.loadPortraitSmall(race, callback);
		}

		protected function layout():void
		{
			var len:uint = _battleLogs.length;
			var selection:BattleLogEntry;
			var yPos:int = 20;
			_noBattleLogs.visible = (len > 0) ? false : true;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _battleLogs[i];
				selection.y = yPos;
				_maxHeight += selection.height;
				yPos += selection.height;
			}
			_scrollbar.updateScrollableHeight(_maxHeight);
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		private function orderItems( itemOne:BattleLogEntry, itemTwo:BattleLogEntry ):Number
		{

			if (!itemOne)
				return -1;
			if (!itemTwo)
				return 1;

			var timeOccurredOne:Number = itemOne.timeOccurred;
			var timeOccurredTwo:Number = itemTwo.timeOccurred;

			if (timeOccurredOne < timeOccurredTwo)
				return -1;
			else if (timeOccurredOne > timeOccurredTwo)
				return 1;

			return 0;
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }
		
		private function destroyEntries():void
		{
			var len:uint = _battleLogs.length;
			var battleLogEntry:BattleLogEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				battleLogEntry = _battleLogs[i];
				_holder.removeChild(battleLogEntry);
				battleLogEntry.destroy();
				battleLogEntry = null;
			}
			_battleLogs.length = 0;
			
			for (var key:String in _battleLogEntries)
			{
				delete _battleLogEntries[key];
			}
			_battleLogEntries = null;
		}

		override public function destroy():void
		{
			presenter.removeBattleLogListUpdatedListener(onBattleLogListUpdated)
			super.destroy();

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			if( _accordian )
			{
				ObjectPool.give(_accordian);
				_accordian = null;
			}
			
			destroyEntries();


			_holder = null;

			_scrollbar.destroy();
			_scrollbar = null;

			_noBattleLogs.destroy();
			_noBattleLogs = null;

			_maxHeight = 0;
		}
	}
}
