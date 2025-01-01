package com.ui.hud.shared.mail
{
	import com.model.mail.MailVO;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextFormatAlign;
	import flash.ui.Mouse;
	import flash.utils.getDefinitionByName;
	
	import org.osflash.signals.Signal;
	
	public class MailEntry extends Sprite
	{
		private var _bg:Bitmap;
		private var _clickBG:Sprite;
		private var _hoverImage:Bitmap;
		
		private var _sender:Label;
		private var _subject:Label;
		private var _dateSent:Label;
		
		private var _isRead:Boolean;
		
		private var _checkbox:BitmapButton;
		
		private var _mail:MailVO;
		
		public var onClicked:Signal;
		public var onSelectionChanged:Signal;

		public function MailEntry()
		{
			super();
			
			onClicked = new Signal(MailEntry);
			onSelectionChanged = new Signal(Boolean);
			
			var windowBGClass:Class = Class(getDefinitionByName('MailMessageBlueRowBMD'));
			var hoverImageClass:Class = Class(getDefinitionByName('MailTabRollOverBMD'));
			_bg = new Bitmap(BitmapData(new windowBGClass()));
			
			_clickBG = new Sprite();
			_clickBG.addChild(_bg);
			_clickBG.buttonMode = true;
			_clickBG.useHandCursor = true;
			_clickBG.x = 36;
			
			_hoverImage = new Bitmap(BitmapData(new hoverImageClass()));
			_hoverImage.visible = false;
			_hoverImage.y = 15;
			
			_checkbox = ButtonFactory.getBitmapButton('CheckboxBtnUncheckedBMD', 9, 12, '', 0, null, 'CheckboxBtnUncheckedBMD', null, 'CheckboxBtnCheckedBMD');
			_checkbox.selectable = true;
			
			_sender = new Label(14, 0xf0f0f0, 300, 25, false, 1);
			_sender.x = 49;
			_sender.y = 1;
			_sender.align = TextFormatAlign.LEFT;
			
			_subject = new Label(12, 0xf0f0f0, 600, 25, false, 1);
			_subject.x = 49;
			_subject.y = 22;
			_subject.align = TextFormatAlign.LEFT;
			
			_dateSent = new Label(13, 0xf0f0f0, 300, 25, false, 1);
			_dateSent.x = 349;
			_dateSent.y = 1;
			_dateSent.align = TextFormatAlign.RIGHT;
			
			_clickBG.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			_clickBG.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut, false, 0, true);
			_clickBG.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver, false, 0, true);
			
			_checkbox.addEventListener(MouseEvent.CLICK, onCheckboxClick, false, 0, true);
			_checkbox.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut, false, 0, true);
			_checkbox.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver, false, 0, true);
	
			addChild(_clickBG);
			addChild(_checkbox);
			addChild(_subject);
			addChild(_sender);
			addChild(_subject);
			addChild(_dateSent);
			addChild(_hoverImage);
		}
		
		public function init( mail:MailVO ):void
		{
			_mail = mail;
			_sender.text = _mail.sender;
			_subject.text = _mail.subject;
			_dateSent.text = new Date(_mail.timeSent).toLocaleString();
			_isRead = mail.isRead;
			if(_isRead)
			{
				_bg.transform.colorTransform = new ColorTransform(0.5, 0.5, 0.5);
				_sender.textColor = _subject.textColor = _dateSent.textColor = 0xbfbfbf;
			}
			
		}
		
		private function onMouseRollOut( e:MouseEvent ):void
		{
			_hoverImage.visible = false;
		}
		
		private function onMouseRollOver( e:MouseEvent ):void
		{
			_hoverImage.visible = true;
		}
		
		private function onClick( e:MouseEvent ):void
		{
			if(e.target != _checkbox)
			{
				if(!_isRead)
					isRead = true;
				onClicked.dispatch(this);
			}
		}
		
		private function onCheckboxClick( e:MouseEvent ):void
		{
			onSelectionChanged.dispatch(_checkbox.selected);
		}
		
		public function get timeSent():Number
		{
			return _mail.timeSent;	
		}
		
		public function get mailKey():String
		{
			return _mail.key;
		}
		
		public function get mail():MailVO
		{
			return _mail;
		}
		
		public function get selected():Boolean
		{
			return _checkbox.selected;
		}
		
		public function set selected( v:Boolean ):void
		{
			_checkbox.selected = v;
		}
		
		public function set isRead( v:Boolean):void
		{
			_isRead = v;
			
			if(v)
			{
				_bg.transform.colorTransform = new ColorTransform(0.5, 0.5, 0.5);
				_sender.textColor = _subject.textColor = _dateSent.textColor = 0xbfbfbf;
			}
		}
		
		public function get isRead():Boolean
		{
			return _isRead;
		}
		
		override public function get height():Number
		{
			return _bg.height;
		}
		
		public function destroy():void
		{
			
			_clickBG.removeEventListener(MouseEvent.CLICK, onClick);
			_clickBG.removeEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
			_clickBG.removeEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
			_clickBG.removeChild(_bg);
			_clickBG = null;
			
			_bg = null;
			_hoverImage = null;
			
			_checkbox.removeEventListener(MouseEvent.CLICK, onCheckboxClick);
			_checkbox.removeEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
			_checkbox.removeEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
			_checkbox.destroy();
			_checkbox = null;
			
			_subject.destroy();
			_subject = null;
			
			_sender.destroy();
			_sender = null;
			
			_dateSent.destroy();
			_dateSent = null;
			
			_mail = null;

			onClicked.removeAll();
			onClicked = null;
		}
	}
}