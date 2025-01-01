package com.ui.modal.alliances.noalliance
{
	import com.enum.server.AllianceResponseEnum;
	import com.service.language.Localization;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;

	public class CreateAllianceDisplay extends Sprite
	{
		public var createAllianceClick:Function;

		private var _title:Label;

		private var _name:Label;
		private var _description:Label;
		private var _checkboxText:Label;

		private var _nameBG:Bitmap;
		private var _descriptionBG:ScaleBitmap;

		private var _descriptionHolder:Sprite;

		private var _publicCheckbox:BitmapButton;
		private var _createAllianceBtn:BitmapButton;

		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _tooltips:Tooltips;

		private const ALLIANCE_MAX_NAME_LENGTH:uint       = 25;

		private var _allianceCreateText:String            = 'CodeString.Alliance.Create'; //CREATE
		private var _allianceDescriptionText:String       = 'CodeString.Alliance.Description'; //Alliance Description
		private var _allianceNameText:String              = 'CodeString.Alliance.AllianceName'; // Alliance Name
		private var _allianceCreatingStateText:String     = 'CodeString.Alliance.Creating'; //CREATING
		private var _allianceCreateTitleText:String       = 'CodeString.Alliance.CreateAlliance'; //Create Alliance
		private var _alliancePublicText:String            = 'CodeString.Alliance.Public'; //Public
		private var _alliancePublicDescriptionText:String = 'CodeString.Alliance.PublicDescription'; //Public alliances can be joined by anyone in your faction!


		public function CreateAllianceDisplay()
		{
			super();

			_nameBG = PanelFactory.getScaleBitmapPanel('AllianceMemberRowBMD', 361, 24, new Rectangle(15, 11, 2, 2));
			_nameBG.x = 27;
			_nameBG.y = 90;

			_descriptionBG = PanelFactory.getScaleBitmapPanel('AllianceMemberRowBMD', 460, 114, new Rectangle(15, 11, 2, 2));
			_descriptionBG.x = 27;
			_descriptionBG.y = _nameBG.y + _nameBG.height + 7;

			_title = new Label(20, 0xf0f0f0, 150, 25);
			_title.align = TextFormatAlign.LEFT;
			_title.allCaps = true;
			_title.x = 27;
			_title.y = 65;
			_title.text = _allianceCreatingStateText;

			_name = new Label(18, 0xa9dcff, 469, 30);
			_name.align = TextFormatAlign.LEFT;
			_name.text = _allianceNameText;
			_name.x = _nameBG.x + 8;
			_name.y = _nameBG.y;
			_name.maxChars = ALLIANCE_MAX_NAME_LENGTH;
			_name.multiline = true;
			_name.allowInput = true;
			_name.clearOnFocusIn = true;
			_name.letterSpacing = .8;
			_name.restrict = "A-Za-z0-9'_ ";
			_name.addLabelColor(0xbdfefd, 0x000000);

			_description = new Label(18, 0xa9dcff, 450, 235);
			_description.align = TextFormatAlign.LEFT;
			_description.text = _allianceDescriptionText;
			_description.maxChars = 512;
			_description.multiline = true;
			_description.allowInput = true;
			_description.clearOnFocusIn = true;
			_description.letterSpacing = .8;
			_description.addLabelColor(0xbdfefd, 0x000000);
			_description.addEventListener(Event.CHANGE, onTextUpdated, false, 0, true);

			_descriptionHolder = new Sprite();
			_descriptionHolder.x = _descriptionBG.x + 5;
			_descriptionHolder.y = _descriptionBG.y + 3;
			_descriptionHolder.addChild(_description);

			_scrollRect = new Rectangle(0, 0, _descriptionHolder.width, _descriptionBG.height - 5);
			_scrollRect.y = 0;
			_descriptionHolder.scrollRect = _scrollRect;

			_publicCheckbox = ButtonFactory.getBitmapButton('CheckboxBtnUncheckedBMD', 0, 0, '', 0, null, 'CheckboxBtnUncheckedBMD', null, 'CheckboxBtnCheckedBMD');
			_publicCheckbox.x = _nameBG.x + _nameBG.width + 5;
			_publicCheckbox.y = _nameBG.y + 1;
			_publicCheckbox.selectable = true;
			_publicCheckbox.selected = true;

			_checkboxText = new Label(18, 0xa9dcff, 469, 30);
			_checkboxText.align = TextFormatAlign.LEFT;
			_checkboxText.text = _alliancePublicText;
			_checkboxText.x = _publicCheckbox.x + _publicCheckbox.width + 5;
			_checkboxText.y = _publicCheckbox.y + (_checkboxText.textHeight - _publicCheckbox.height) * 0.5;

			_createAllianceBtn = ButtonFactory.getBitmapButton('BlueBtnCNeutralBMD', 339, 565, _allianceCreateText, 0xf0f0f0, 'BlueBtnCRollOverBMD', 'BlueBtnCSelectedBMD', null, 'BlueBtnCSelectedBMD');
			_createAllianceBtn.x = _descriptionBG.x + (_descriptionBG.width - _createAllianceBtn.width) * 0.5;
			_createAllianceBtn.y = _descriptionBG.y + _descriptionBG.height + 5;
			_createAllianceBtn.addEventListener(MouseEvent.CLICK, onCreateAllianceClick, false, 0, true);

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = _descriptionBG.x + _descriptionBG.width + 5;
			var scrollbarYPos:Number    = _descriptionBG.y;
			_scrollbar.init(7, _scrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this, _descriptionHolder);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 7;

			addChild(_title);
			addChild(_nameBG);
			addChild(_descriptionBG);
			addChild(_name);
			addChild(_descriptionHolder);
			addChild(_scrollbar);
			addChild(_publicCheckbox);
			addChild(_checkboxText);
			addChild(_createAllianceBtn);
		}

		private function onCreateAllianceClick( e:MouseEvent ):void
		{
			var name:String = _name.text;
			name.split(' ').join('');
			if (name.length > 0 && name != '' && name != _name.inputMessage)
			{
				if (createAllianceClick != null)
				{
					var description:String = (_description.text == _description.inputMessage) ? '' : _description.text;
					createAllianceClick(name, _publicCheckbox.selected, _description.text);
					_createAllianceBtn.enabled = false;
					_createAllianceBtn.text = _allianceCreatingStateText;
				}

			}
		}

		public function handleAllianceMessage( messageEnum:int ):void
		{
			switch (messageEnum)
			{
				case AllianceResponseEnum.ALLIANCE_CREATION_FAILED_NAMEINUSE:
				case AllianceResponseEnum.ALLIANCE_CREATION_FAILED_UNKNOWN:
					_createAllianceBtn.enabled = true;
					_createAllianceBtn.text = _allianceCreateText;
					break;
			}
		}

		private function onTextUpdated( e:Event ):void
		{
			_scrollbar.updateScrollableHeight(_description.textHeight);

			var car:int        = _description.caretIndex;
			var rect:Rectangle = _description.getCharBoundaries(car - 1);

			if (rect != null)
			{
				if (rect.y + rect.height > _scrollRect.height)
				{
					var percent:Number = ((rect.y + rect.height) / _description.textHeight)
					_scrollbar.updateScrollPercent(percent);
				} else if (rect.y + rect.height < _scrollRect.height && _scrollbar.percent != 0)
					_scrollbar.updateScrollPercent(0);
			}
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_description.textHeight - _scrollRect.height) * percent;
			_descriptionHolder.scrollRect = _scrollRect;
		}

		[Inject]
		public function set tooltips( value:Tooltips ):void
		{
			_tooltips = value;

			if (_publicCheckbox)
				_tooltips.addTooltip(_publicCheckbox, this, null, Localization.instance.getString(_alliancePublicDescriptionText));
		}

		public function destroy():void
		{
			if (_tooltips)
				_tooltips.removeTooltip(null, this);

			_tooltips = null;

			_nameBG = null;
			_descriptionBG = null;
			_descriptionHolder = null;
			_scrollRect = null;
			createAllianceClick = null;

			if (_title)
				_title.destroy();

			_title = null;

			if (_name)
				_name.destroy();

			_name = null;

			if (_description)
				_description.destroy();

			_description = null;

			if (_checkboxText)
				_checkboxText.destroy();

			_checkboxText = null;

			if (_publicCheckbox)
				_publicCheckbox.destroy();

			_publicCheckbox = null;

			if (_createAllianceBtn)
				_createAllianceBtn.destroy();

			_createAllianceBtn = null;

			if (_scrollbar)
				_scrollbar.destroy();

			_scrollbar = null;
		}
	}
}
