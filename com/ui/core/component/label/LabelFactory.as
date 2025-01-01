package com.ui.core.component.label
{
	import flash.text.StyleSheet;
	import com.StartupConfig;

	public class LabelFactory
	{

		public static const TITLE_COLOR:int             = 0xffffff //0xb4e0ff;
		public static const DYNAMIC_TEXT_COLOR:int      = 0xf0f0f0;
		public static const LINK_TEXT_COLOR:int         = 0xf04c4c;
		public static const TOAST_GOLD:int              = 0xfac973;
		public static const TRAY_TITLE_COLOR:int        = 0xc6e2f2;
		public static const SPEED_UP_COLOR:int          = 0xf7c78b;

		//public static const TITLE_FONT:String           = "Agency FB";
		//public static const BODY_FONT:String            = "Open Sans";

		public static const LABEL_TYPE_TITLE:int        = 0;
		public static const LABEL_TYPE_HEADER:int       = 1;
		public static const LABEL_TYPE_DYNAMIC:int      = 2;
		public static const LABEL_TYPE_DIALOG_TITLE:int = 3;
		public static const LABEL_TYPE_TRAY_TITLE:int   = 4;
		public static const LABEL_TYPE_SPEED_UP:int     = 5;

		private static var _linkStyleSheet:StyleSheet;

		public static function createLabel( labelType:int, width:Number, size:int = -1, col:int = -1, multiline:Boolean = false ):Label
		{
			var allCaps:Boolean;
			var color:int    = col == -1 ? TITLE_COLOR : col;
			var font:int  = StartupConfig.FontArray[0];

			switch (labelType)
			{
				case LABEL_TYPE_TITLE:
					size = size == -1 ? 18 : size;
					break;

				case LABEL_TYPE_HEADER:
					size = size == -1 ? 14 : size;
					allCaps = true;
					break;

				case LABEL_TYPE_DYNAMIC:
					size = size == -1 ? 12 : size;
					color = col == -1 ? DYNAMIC_TEXT_COLOR : col;
					font = StartupConfig.FontArray[1];
					break;

				case LABEL_TYPE_DIALOG_TITLE:
					size = size == -1 ? 24 : size;
					color = DYNAMIC_TEXT_COLOR;
					allCaps = true;
					break;

				case LABEL_TYPE_TRAY_TITLE:
					size = size == -1 ? 18 : size;
					color = TRAY_TITLE_COLOR;
					allCaps = true;
					break;

				case LABEL_TYPE_SPEED_UP:
					size = size == -1 ? 11 : size;
					color = SPEED_UP_COLOR;
					font = StartupConfig.FontArray[1];
					allCaps = true;
					break;

				default:

					break;
			}

			var result:Label = new Label(size, color, width, size * 1.6, true, font);
			result.allCaps = allCaps;
			result.multiline = multiline;
			return result;
		}

		public static function get linkStyleSheet():StyleSheet
		{
			if (!_linkStyleSheet)
			{
				var link:Object = {color:"#" + LINK_TEXT_COLOR.toString(16), textDecoration:"underline"};
				_linkStyleSheet = new StyleSheet();
				_linkStyleSheet.setStyle("a:link", link);
				_linkStyleSheet.setStyle("a:hover", {color:"#" + LINK_TEXT_COLOR.toString(16), textDecoration:'underline'});
			}

			return _linkStyleSheet;
		}
	}
}
