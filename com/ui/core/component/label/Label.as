package com.ui.core.component.label
{
	import com.service.language.Localization;

	import flash.events.FocusEvent;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import org.adobe.utils.StringUtil;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	
	import com.service.ExternalInterfaceAPI;
	
	import com.StartupConfig;

	public class Label extends TextField
	{
		public static var showUnlocalizedString:Boolean;

		protected var _constrict:Boolean;
		protected var _desiredFontSize:Number;
		protected var _desiredWidth:Number;
		protected var _desiredHeight:Number;
		protected var _inputMessage:String;
		protected var _textFormat:TextFormat;
		protected var _clearOnFocusIn:Boolean;
		protected var _useLocalization:Boolean;
		protected var _allCaps:Boolean;

		private var _unlocalizedString:String;
		private var _tokens:Object;
		private var _labelColor:LabelColor;

		private const logger:ILogger = getLogger('ui.core.component.Label');

		public function Label( fontSize:Number = 12, color:uint = 0, maxWidth:Number = 100, maxHeight:Number = 20, useLocalization:Boolean = true, fontNr:int = 0 )
		{
			//ExternalInterfaceAPI.logConsole("Use font: " + font);
			init(fontSize, color, maxWidth, maxHeight, useLocalization, fontNr);
		}

		public function init( fontSize:Number = 12, color:uint = 0, maxWidth:Number = 100, maxHeight:Number = 20, useLocalization:Boolean = true, fontNr:int = 0 ):void
		{
			embedFonts = true;
			selectable = false;
			mouseEnabled = multiline = false;
			_constrict = true;
			textColor = color;
			antiAliasType = AntiAliasType.ADVANCED;
			gridFitType = GridFitType.SUBPIXEL;
			_desiredFontSize = fontSize;
			_desiredWidth = maxWidth;
			_desiredHeight = maxHeight;
			width = maxWidth;
			height = maxHeight;
			_textFormat = new TextFormat(StartupConfig.FontArray[fontNr]);
			defaultTextFormat = _textFormat;
			this.fontSizeFormat = fontSize;
			align = TextFormatAlign.CENTER;
			_useLocalization = useLocalization;
			text = '';
		}

		private function localizeText( value:String ):String
		{
			var localizedString:String = _unlocalizedString = value;
			if (!showUnlocalizedString && value != '' && _useLocalization)
			{
				localizedString = Localization.instance.getString(_unlocalizedString);
				if (localizedString == '' && _unlocalizedString != '')
				{
					localizedString = _unlocalizedString;
					if (isNaN(Number(value)))
						logger.debug('Unlocalized String = {}', _unlocalizedString);
				}
			}

			if (_allCaps)
				localizedString = localizedString.toUpperCase();

			return localizedString;
		}

		private function localizeTextWithTokens( value:String, tokens:Object ):String
		{
			var localizedString:String = _unlocalizedString = value;
			_tokens = tokens;
			if (!showUnlocalizedString)
			{
				localizedString = Localization.instance.getStringWithTokens(_unlocalizedString, tokens);

				if (localizedString == '' && _unlocalizedString != '')
				{
					localizedString = value;
					logger.debug('Unlocalized String = {}', _unlocalizedString);
				}
			}
			return localizedString;
		}

		public function setTextWithTokens( value:String, tokens:Object ):void
		{
			super.text = localizeTextWithTokens(value, tokens);
			if (_constrict)
				resize();
		}

		public function setHtmlTextWithTokens( value:String, tokens:Object ):void
		{
			super.htmlText = localizeTextWithTokens(value, tokens);
			if (_constrict)
				resize();
		}

		public function setBuildTime( seconds:Number, maxElems:int = 4 ):void
		{
			super.text = StringUtil.getBuildTime(seconds, maxElems);
			if (_constrict)
				resize();
		}

		public function setSize( w:Number, h:Number ):void
		{
			_desiredWidth = w;
			_desiredHeight = h;
			resize();
		}

		protected function resize():void
		{
			fontSizeFormat = _desiredFontSize;
			autoSize = TextFieldAutoSize.LEFT;
			var value:String     = text;
			var firstRun:Boolean = true;
			do
			{
				if (!firstRun)
					fontSizeFormat--;
				if (fontSizeFormat == 0)
					break;
				super.text = value;
				if (multiline)
					width = _desiredWidth;
				firstRun = false;
			} while (width > _desiredWidth || height > _desiredHeight)
			autoSize = TextFieldAutoSize.NONE;
			width = _desiredWidth;
			height = _desiredHeight;
		}

		public function addLabelColor( selectionColor:uint = 0x000000, selectedColor:uint = 0x000000 ):void
		{
			_labelColor = new LabelColor(this, textColor, selectionColor, selectedColor);
		}

		private function updateFocusListeners():void
		{
			if (type == TextFieldType.INPUT)
			{
				if (_clearOnFocusIn)
				{
					removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
					removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
					addEventListener(FocusEvent.FOCUS_IN, onFocusIn, false, 0, true);
					addEventListener(FocusEvent.FOCUS_OUT, onFocusOut, false, 0, true)
				} else
				{
					removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
					removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				}
			}
		}

		public function updateLabelColor( value:uint ):void
		{
			if (_labelColor)
				_labelColor.textColor = value;
		}

		public function updateLabelSelectedColor( value:uint ):void
		{
			if (_labelColor)
				_labelColor.selectedColor = value;
		}

		public function updateLabelSelectionColor( value:uint ):void
		{
			if (_labelColor)
				_labelColor.selectionColor = value;
		}

		private function onFocusIn( e:FocusEvent ):void
		{
			if (text == _inputMessage)
				text = '';
		}

		private function onFocusOut( e:FocusEvent ):void
		{
			if (text == "")
			{
				super.text = _inputMessage;
				if (_constrict)
					resize();
			}
		}

		public function get align():String  { return defaultTextFormat.align; }
		public function set align( type:String ):void
		{
			_textFormat.align = type;
			defaultTextFormat = _textFormat;
		}

		public function get allCaps():Boolean  { return _allCaps; }
		public function set allCaps( value:Boolean ):void  { _allCaps = value; }

		public function set allowInput( v:Boolean ):void
		{
			type = (v) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			selectable = v;
			mouseEnabled = v;
			constrictTextToSize = !v;
			align = TextFormatAlign.LEFT;
			width = _desiredWidth;
			height = _desiredHeight;
			_inputMessage = text;
			text = _inputMessage;
			updateFocusListeners();
		}

		public function updateInputText( v:String ):void
		{
			if (text == _inputMessage)
				text = "";

			if (useLocalization)
				_inputMessage = localizeText(v);
			else
				_inputMessage = v;

			if (text == "")
			{
				super.text = _inputMessage;
				if (_constrict)
					resize();
			}
		}

		public function get inputMessage():String  { return _inputMessage; }

		public function set bold( value:Boolean ):void  { _textFormat.bold = value; defaultTextFormat = _textFormat; }

		public function set clearOnFocusIn( v:Boolean ):void  { _clearOnFocusIn = v; updateFocusListeners(); }

		public function set constrictTextToSize( v:Boolean ):void  { _constrict = v; }

		public function set fontSize( v:int ):void  { _desiredFontSize = v; resize(); }

		protected function get fontSizeFormat():*  { return _textFormat.size; }
		protected function set fontSizeFormat( value:int ):void
		{
			_textFormat.size = value;
			defaultTextFormat = _textFormat;
		}

		override public function set htmlText( value:String ):void
		{
			super.htmlText = localizeText(value);
			if (_constrict)
				resize();
		}

		public function set letterSpacing( value:Number ):void
		{
			_textFormat.letterSpacing = value;
			defaultTextFormat = _textFormat;
			text = text;
		}
		public function set leading( value:int ):void  { _textFormat.leading = value; defaultTextFormat = _textFormat; }
		public function set leftMargin( margin:int ):void  { _textFormat.leftMargin = margin; defaultTextFormat = _textFormat; }

		override public function set multiline( value:Boolean ):void  { wordWrap = value; super.multiline = value; }

		public function set rightMargin( margin:int ):void  { _textFormat.rightMargin = margin; defaultTextFormat = _textFormat; }

		override public function set text( value:String ):void
		{
			if(!value)
				value = "";
			super.text = localizeText(value);
			if (_constrict)
				resize();
		}

		public function set underline( value:Boolean ):void  { _textFormat.underline = value; defaultTextFormat = _textFormat; }

		public function get useLocalization():Boolean  { return _useLocalization; }
		public function set useLocalization( useLoc:Boolean ):void  { _useLocalization = useLoc; }

		public function get unLocalizedText():String  { return _unlocalizedString; }

		public function destroy():void
		{
			type = TextFieldType.DYNAMIC;
			autoSize = TextFieldAutoSize.NONE;
			filters = [];
			_clearOnFocusIn = false;
			_labelColor = null;
			_textFormat = null;
			_tokens = null;
			styleSheet = null;
			updateFocusListeners();
			super.htmlText = super.text = '';
		}
	}
}
