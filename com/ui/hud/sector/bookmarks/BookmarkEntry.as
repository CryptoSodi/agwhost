package com.ui.hud.sector.bookmarks
{
	import com.Application;
	import com.controller.keyboard.KeyboardController;
	import com.controller.keyboard.KeyboardKey;
	import com.enum.ui.ButtonEnum;
	import com.model.player.BookmarkVO;
	import com.model.prototype.IPrototype;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;

	public class BookmarkEntry extends Sprite
	{
		public var gotoCoordsClicked:Signal;
		public var changedBookmarkName:Signal;
		public var fleetGotoCoords:Signal;
		public var deleteBookmark:Signal;

		private var _bg:Bitmap;

		private var _name:Label;
		private var _sectorName:Label;
		private var _coords:Label;

		private var _gotoCoordsBtn:BitmapButton;
		private var _changeBookmarkName:BitmapButton;
		private var _fleetGotoCoordsBtn:BitmapButton;
		private var _deleteBookmark:BitmapButton;

		private var _bookmark:BookmarkVO;

		private var _stage:Stage;
		private var _keyboard:KeyboardController;
		private var _tooltip:Tooltips;

		private var _sectorNameText:String     = 'CodeString.Bookmarks.SectorName'; //[[SectorName:String]]  [[SectorEnum:String]]
		private var _sectorCoordsText:String   = 'CodeString.Bookmarks.SectorCoords'; //[[SectorX:int]] ,[[SectorY:int]]

		private var _gotoBookmarkText:String   = 'CodeString.Bookmarks.GotoBookmarkTooltip'; //Goto Bookmark
		private var _selectAllText:String      = 'CodeString.Bookmarks.SelectAllTooltip'; //Select All Bookmark Text
		private var _selectFleetText:String    = 'CodeString.Bookmarks.SelectFleetTooltip'; //Selected Fleet Goto Bookmark
		private var _deleteBookmarkText:String = 'CodeString.Bookmarks.DeleteBookmarkTooltip'; //Delete Bookmark

		public function BookmarkEntry( bookmark:BookmarkVO )
		{
			_bookmark = bookmark;

			gotoCoordsClicked = new Signal(BookmarkVO);
			changedBookmarkName = new Signal(BookmarkVO);
			fleetGotoCoords = new Signal(BookmarkVO);
			deleteBookmark = new Signal(uint);

			_bg = PanelFactory.getPanel('BookmarkRowBGBMD');

			var sectorProto:IPrototype = _bookmark.sectorPrototype;
			var faction:String         = (sectorProto) ? sectorProto.getUnsafeValue('factionPrototype') : '';
			var textColor:uint         = (faction == '') ? 0xf0f0f0 : CommonFunctionUtil.getFactionColor(faction);

			_name = new Label(18, textColor, 205, 26, true);
			_name.align = TextFormatAlign.CENTER;
			_name.x = 1;
			_name.y = 1;
			_name.maxChars = 20;
			_name.restrict = "A-Za-z0-9'_\\- ";
			_name.allowInput = true;
			_name.clearOnFocusIn = false;
			_name.addLabelColor(0xbdfefd, 0x000000);
			_name.text = _bookmark.name;
			_name.addEventListener(FocusEvent.FOCUS_OUT, onClearFocus, false, 0, true);

			_sectorName = new Label(18, textColor, 108, 26, false);
			_sectorName.align = TextFormatAlign.LEFT;
			_sectorName.x = 209;
			_sectorName.y = 1;
			_sectorName.text = _bookmark.sectorName;
			_sectorName.setTextWithTokens(_sectorNameText, {'[[SectorName:String]]':_bookmark.sectorName, '[[SectorEnum:String]]':_bookmark.sectorEnum});

			_coords = new Label(18, textColor, 52, 26, true);
			_coords.align = TextFormatAlign.LEFT;
			_coords.x = 317;
			_coords.y = 1;
			_coords.setTextWithTokens(_sectorCoordsText, {'[[SectorX:int]]':_bookmark.displayX, '[[SectorY:int]]':_bookmark.displayY});

			_gotoCoordsBtn = ButtonFactory.getBitmapButton('GotoBtnUpBMD', 375, 4, '', 0, 'GotoBtnRollOverBMD', 'GotoBtnDownBMD', null, 'GotoBtnDownBMD');
			_gotoCoordsBtn.addEventListener(MouseEvent.CLICK, onGotoCoordsClicked, false, 0, true);

			_changeBookmarkName = ButtonFactory.getBitmapButton('EditBtnUpBMD', 417, 4, '', 0, 'EditBtnRollOverBMD', 'EditBtnUpBMD', null, 'EditBtnUpBMD');
			_changeBookmarkName.addEventListener(MouseEvent.CLICK, onChangedBookmarkName, false, 0, true);

			_fleetGotoCoordsBtn = UIFactory.getButton(ButtonEnum.FLEET_GOTO, 0, 0, 451, 4);
			_fleetGotoCoordsBtn.addEventListener(MouseEvent.CLICK, onFleetGotoCoordsClicked, false, 0, true);

			_deleteBookmark = ButtonFactory.getBitmapButton('DeleteBtnUpBMD', 498, 7, '', 0, 'DeleteBtnRollOverBMD', 'DeleteBtnDownBMD', null, 'DeleteBtnDownBMD');
			_deleteBookmark.addEventListener(MouseEvent.CLICK, onDeleteClicked, false, 0, true);

			addChild(_bg);
			addChild(_name);
			addChild(_sectorName);
			addChild(_coords);
			addChild(_gotoCoordsBtn);
			addChild(_fleetGotoCoordsBtn)
			addChild(_changeBookmarkName);
			addChild(_deleteBookmark);
		}

		public function selectedFleet( v:Boolean ):void
		{
			_fleetGotoCoordsBtn.enabled = v;
		}

		private function onGotoCoordsClicked( e:MouseEvent ):void
		{
			gotoCoordsClicked.dispatch(_bookmark);
		}

		private function onFleetGotoCoordsClicked( e:MouseEvent ):void
		{
			fleetGotoCoords.dispatch(_bookmark);
		}

		private function onChangedBookmarkName( e:MouseEvent ):void
		{
			_stage.focus = _name;
			_name.setSelection(0, _name.length);
		}

		private function onDeleteClicked( e:MouseEvent ):void
		{
			deleteBookmark.dispatch(_bookmark.index);
		}

		private function onClearFocus( e:FocusEvent = null ):void
		{
			setName();
		}

		public function set stage( value:Stage ):void  { _stage = value; }
		public function get index():uint  { return _bookmark.index; }

		[Inject]
		public function set tooltip( value:Tooltips ):void
		{
			_tooltip = value;

			var loc:Localization = Localization.instance;
			if (_gotoCoordsBtn)
				_tooltip.addTooltip(_gotoCoordsBtn, this, null, loc.getString(_gotoBookmarkText));

			if (_changeBookmarkName)
				_tooltip.addTooltip(_changeBookmarkName, this, null, loc.getString(_selectAllText));

			if (_fleetGotoCoordsBtn)
				_tooltip.addTooltip(_fleetGotoCoordsBtn, this, null, loc.getString(_selectFleetText));

			if (_deleteBookmark)
				_tooltip.addTooltip(_deleteBookmark, this, null, loc.getString(_deleteBookmarkText));
		}

		[Inject]
		public function set keyboard( value:KeyboardController ):void
		{
			_keyboard = value;
			_keyboard.addKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);
		}

		private function onEnterPress( keyCode:uint ):void
		{
			if (_stage.focus == _name)
			{
				setName();
				addEventListener(Event.ENTER_FRAME, removeFocus, false, 0, true);
			}
		}

		private function setName():void
		{
			if (_bookmark.name != _name.text)
			{
				if (_name.text != '')
				{
					_bookmark.name = _name.text;
					changedBookmarkName.dispatch(_bookmark);
				} else
					_name.text = _bookmark.name;
			}
		}

		private function removeFocus( e:Event ):void
		{
			removeEventListener(Event.ENTER_FRAME, removeFocus);
			if (_stage)
				_stage.focus = Application.STAGE;
		}

		public function destroy():void
		{
			if (gotoCoordsClicked)
				gotoCoordsClicked.removeAll();

			gotoCoordsClicked = null;

			if (changedBookmarkName)
				changedBookmarkName.removeAll();

			changedBookmarkName = null;

			if (deleteBookmark)
				deleteBookmark.removeAll();

			deleteBookmark = null;

			if (_keyboard)
				_keyboard.removeKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);

			_keyboard = null;

			if (_name)
			{
				_name.removeEventListener(FocusEvent.FOCUS_OUT, onClearFocus);
				_name.destroy();
			}

			_name = null;

			if (_sectorName)
				_sectorName.destroy();

			_sectorName = null;

			if (_coords)
				_coords.destroy();

			_coords = null;

			if (_gotoCoordsBtn)
				_gotoCoordsBtn.destroy();

			_gotoCoordsBtn = null;

			if (_changeBookmarkName)
				_changeBookmarkName.destroy();

			_changeBookmarkName = null;

			if (_deleteBookmark)
				_deleteBookmark.destroy();

			_deleteBookmark = null;

			_tooltip.removeTooltip(null, this);
			_tooltip = null;
		}
	}
}
