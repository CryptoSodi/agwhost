package com.ui
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.google.analytics.debug.Panel;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.button.ButtonLabelFormatFactory;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	import org.shared.ObjectPool;

	public class UIFactory
	{
		private static const _bmdStore:Dictionary     = new Dictionary();
		private static const _scaleBitmap:ScaleBitmap = new ScaleBitmap();
		private static const _scaleRect:Rectangle     = new Rectangle();

		//============================================================================================================
		//************************************************************************************************************
		//													PANELS
		//************************************************************************************************************
		//============================================================================================================

		/**
		 * Essentially the same as <code>getScaleBitmap</code> but also resizes and positions the ScaleBitmap
		 *
		 * @param type The type of panel to create. All panels are defined in PanelEnum
		 * @param width Width to resize the panel to
		 * @param height Height to resize the panel to
		 * @param x X position of the panel
		 * @param y Y position of the panel
		 * @return Returns a newly created Panel (ScaleBitmap)
		 */
		public static function getPanel( type:String,
										 width:Number = 0, height:Number = 0,
										 x:int = 0, y:int = 0 ):ScaleBitmap
		{
			var bitmap:ScaleBitmap = getScaleBitmap(type);
			bitmap.setSize(width, height);
			bitmap.x = x;
			bitmap.y = y;

			return bitmap;
		}

		/**
		 * Creates a panel with a header and optional title label.
		 *
		 * @param panelType The type of panel to create. All panels are defined in PanelEnum
		 * @param headerType The type of header to create. All panels are defined in PanelEnum
		 * @param width Width to resize the panel and header to
		 * @param height Height to resize the panel to
		 * @param headerHeight Height to resize the header to
		 * @param x X position of the header panel
		 * @param y Y position of the header panel
		 * @param text The text to display in the title of the header
		 * @param labelType The format to apply to the label
		 * @return Returns a newly creaded Header Panel (Sprite)
		 */
		public static function getHeaderPanel( panelType:String, headerType:String,
											   width:Number = 0, height:Number = 0, headerHeight:Number = 0,
											   x:int = 0, y:int = 0,
											   text:String = null, labelType:String = null ):Sprite
		{
			var sprite:Sprite      = new Sprite();

			//create the back panel
			var panel:ScaleBitmap  = getPanel(panelType, width, height, 0, headerHeight);
			sprite.addChild(panel);

			//adjust based on panel
			switch (panelType)
			{
				case PanelEnum.CONTAINER_DOUBLE_NOTCHED_ARROWS:
				case PanelEnum.CONTAINER_RIGHT_NOTCHED_ARROW:
					width -= 2;
					x += 1;
					break;
				case PanelEnum.CONTAINER_INNER:
					panel.y -= 2;
					break;
			}

			//create the header
			var header:ScaleBitmap = getPanel(headerType, width, headerHeight, 0, 0);
			if (headerType == PanelEnum.HEADER_NOTCHED_RIGHT)
			{
				header.width += 1;
				header.scaleX = -1;
				header.x = header.width;
			}
			sprite.addChild(header);

			//add the text
			if (text)
			{
				if (labelType == null)
					labelType = LabelEnum.H2;
				var label:Label = getLabel(labelType, width, headerHeight, 4, 4);
				label.align = TextFormatAlign.LEFT;
				label.text = text;
				label.x = 10;
				label.y = (headerHeight - label.textHeight) * .5;
				sprite.addChild(label);
			}
			sprite.x = x;
			sprite.y = y;

			return sprite;
		}

		public static function destroyPanel( panel:* ):*
		{
			if (!panel)
				return null;
			if (panel is Sprite)
			{
				var sprite:Sprite = Sprite(panel);
				while (sprite.numChildren > 0)
					sprite.removeChildAt(0);
			} else
			{
				var bitmap:Bitmap = Bitmap(panel);
				bitmap.bitmapData = null;
			}
			ObjectPool.give(panel);
			return null;
		}

		//============================================================================================================
		//************************************************************************************************************
		//													LABELS
		//************************************************************************************************************
		//============================================================================================================

		/**
		 * Creates a new Label
		 *
		 * @param type The type of label to create. All labels are defined in LabelEnum
		 * @param width Width to resize the label to
		 * @param height Height to resize the label to
		 * @param x X position of the label
		 * @param y Y position of the label
		 * @return Returns a newly created Label
		 */
		public static function getLabel( type:String, width:Number, height:Number, x:int = 0, y:int = 0 ):Label
		{
			var label:Label = ObjectPool.get(Label);

			switch (type)
			{
				case LabelEnum.H1:
					label.init(30, 0xd1e5f7, width, height);
					label.bold = true;
					break;

				case LabelEnum.H2:
					label.init(26, 0xd1e5f7, width, height);
					label.bold = true;
					break;

				case LabelEnum.H3:
					label.init(22, 0xd1e5f7, width, height);
					label.bold = true;
					break;
				case LabelEnum.H4:
					label.init(18, 0xacd1ff, width, height);
					label.bold = true;
					break;
				case LabelEnum.H5:
					label.init(16, 0xacd1ff, width, height);
					label.bold = true;
					break;

				case LabelEnum.SUBTITLE:
					label.init(20, 0xd1e5f7, width, height);
					break;

				case LabelEnum.TITLE:
					label.init(28, 0xd1e5f7, width, height);
					break;

				case LabelEnum.DESCRIPTION:
					label.init(12, 0xecffff, width, height, true, 1);
					label.bold = false;
					label.multiline = true;
					label.align = TextFormatAlign.LEFT;
					label.constrictTextToSize = true;
					break;

				case LabelEnum.DEFAULT_OPEN_SANS:
					label.init(14, 0xf0f0f0, width, height, true, 1);
					break;

				case LabelEnum.DEFAULT:
				default:
					label.init(14, 0xefefef, width, height);
					break;
			}

			label.x = x;
			label.y = y;
			label.constrictTextToSize = false;
			return label;
		}

		public static function destroyLabel( label:Label ):*
		{
			if (!label)
				return null;
			ObjectPool.give(label);
			return null;
		}

		//============================================================================================================
		//************************************************************************************************************
		//													BUTTON
		//************************************************************************************************************
		//============================================================================================================

		/**
		 * Creates a new button
		 * @param type
		 * @param width
		 * @param height
		 * @param x
		 * @param y
		 * @param text
		 * @param labelType
		 * @return
		 *
		 */
		public static function getButton( type:String,
										  width:Number = 0, height:Number = 0,
										  x:int = 0, y:int = 0,
										  text:String = null, labelType:String = null ):BitmapButton
		{
			var button:BitmapButton = ObjectPool.get(BitmapButton);
			initButton(button, type);
			button.labelType = labelType;
			if (setScaleRect(type))
				button.scale9Grid = _scaleRect;

			switch (type)
			{
				case ButtonEnum.BLUE_A:
				case ButtonEnum.GOLD_A:
				case ButtonEnum.RED_A:
				case ButtonEnum.GREEN_A:
					if (!labelType)
						button.labelType = LabelEnum.H2;
					button.labelFormat = ButtonLabelFormatFactory.getFormat(type);
					break;
				case ButtonEnum.ACCORDIAN_SUBITEM:
				case ButtonEnum.HEADER:
				case ButtonEnum.HEADER_NOTCHED:
					if (!labelType)
						button.labelType = LabelEnum.H2;
					button.labelFormat = ButtonLabelFormatFactory.getFormat(type);
					break;
				case ButtonEnum.CHECKBOX:
					button.selectable = true;
					break;
			}

			button.setSize(width, height);
			button.x = x;
			button.y = y;
			if (text)
				button.text = text;

			return button;
		}

		private static function initButton( button:BitmapButton, type:String ):void
		{
			var up:BitmapData       = getBitmapData(type + "UpBMD");
			var down:BitmapData     = getBitmapData(type + "DownBMD");
			if (!down)
				down = up;
			var ro:BitmapData       = getBitmapData(type + "ROBMD");
			if (!ro)
				ro = (down) ? down : up;
			var disabled:BitmapData = getBitmapData(type + "DisabledBMD");
			if (!disabled)
				disabled = (down) ? down : up;
			var selected:BitmapData = getBitmapData(type + "SelectedBMD");
			if (!selected)
				selected = (down) ? down : (disabled) ? disabled : (ro) ? ro : up;
			button.init(up, ro, down, disabled, selected);
		}

		public static function destroyButton( button:BitmapButton ):*
		{
			if (button)
				ObjectPool.give(button);
			return null;
		}

		//============================================================================================================
		//************************************************************************************************************
		//													PROGRESS BAR
		//************************************************************************************************************
		//============================================================================================================

		/**
		 * Creates a new progress bar
		 *
		 * @param barBmpd the BitmapdData that will fill as the bar progresses
		 * @param bkgdBmpd the BitmapData that is used as the background for the progress bar
		 * @param min the minimum value for the progress bar
		 * @param max the maximum value for the progress bar
		 * @param amount the current value of the progress bar
		 * @return ProgressBar
		 */
		public static function getProgressBar( bar:DisplayObject, background:DisplayObject, min:Number = 0, max:Number = 1, amount:Number = 0, x:Number = 0, y:Number = 0 ):ProgressBar
		{
			var pbar:ProgressBar = ObjectPool.get(ProgressBar);
			pbar.init(ProgressBar.HORIZONTAL, bar, background);
			pbar.setMinMax(min, max);
			pbar.amount = amount;
			pbar.x = x;
			pbar.y = y;

			return pbar;
		}

		public static function destroyProgressBar( bar:ProgressBar ):*
		{
			ObjectPool.give(bar);
			return null;
		}

		//============================================================================================================
		//************************************************************************************************************
		//													GENERAL
		//************************************************************************************************************
		//============================================================================================================

		public static function getBitmap( name:String ):Bitmap
		{
			var bitmap:Bitmap = new Bitmap();
			if (!_bmdStore.hasOwnProperty(name))
				getBitmapData(name);
			bitmap.bitmapData = _bmdStore[name];
			return bitmap;
		}

		public static function getScaleBitmap( name:String ):ScaleBitmap
		{
			var bitmap:ScaleBitmap = new ScaleBitmap();
			if (!_bmdStore.hasOwnProperty(name))
				getBitmapData(name);
			bitmap.bitmapData = _bmdStore[name];
			//see if there is a scale rect for this type and if so, apply it
			if (setScaleRect(name))
				bitmap.scale9Grid = _scaleRect;
			return bitmap;
		}

		public static function getBitmapData( name:String ):BitmapData
		{
			if (_bmdStore.hasOwnProperty(name))
				return _bmdStore[name];
			try
			{
				var bmdClass:Class = Class(getDefinitionByName(name));
			} catch ( e:Error )
			{
				return null;
			}
			var bmd:BitmapData = BitmapData(new bmdClass());
			_bmdStore[name] = bmd;
			return bmd;
		}

		public static function getDefaultWindow():void
		{

		}

		private static function setScaleRect( type:String ):Boolean
		{
			switch (type)
			{
				case ButtonEnum.FRAME_BLUE:
				case ButtonEnum.FRAME_GREEN:
				case ButtonEnum.FRAME_GREY:
				case ButtonEnum.FRAME_RED:
				case ButtonEnum.FRAME_GOLD:
				case ButtonEnum.BLUE_A:
				case ButtonEnum.GOLD_A:
				case ButtonEnum.RED_A:
				case ButtonEnum.GREEN_A:
				case ButtonEnum.GREY:
					_scaleRect.setTo(10, 10, 2, 2);
					return true;
				case ButtonEnum.CHARACTER_FRAME:
				case PanelEnum.CHARACTER_FRAME:
				case PanelEnum.BLUE_FRAME:
				case ButtonEnum.ICON_FRAME:
					_scaleRect.setTo(12, 12, 8, 8);
					return true;
				case ButtonEnum.DROP_TAB:
					_scaleRect.setTo(13, 1, 4, 4);
					return true;
				case PanelEnum.HEADER:
				case PanelEnum.HEADER_NOTCHED:
				case PanelEnum.NUMBER_BOX:
				case ButtonEnum.HEADER:
				case ButtonEnum.HEADER_NOTCHED:
					_scaleRect.setTo(9, 9, 4, 4);
					return true;
				case PanelEnum.STATBAR_CONTAINER:
				case PanelEnum.STATBAR:
				case PanelEnum.STATBAR_GREY:
				case PanelEnum.SCROLL_BAR:
				case PanelEnum.CONTAINER_INNER:
				case PanelEnum.CONTAINER_INNER_DARK:
					_scaleRect.setTo(1, 1, 1, 1);
					return true;
				case PanelEnum.CONTAINER_DOUBLE_NOTCHED:
				case PanelEnum.CONTAINER_RIGHT_NOTCHED_ARROW:
				case PanelEnum.CONTAINER_DOUBLE_NOTCHED_ARROWS:
				case PanelEnum.CONTAINER_NOTCHED:
				case PanelEnum.CONTAINER_NOTCHED_RIGHT_SMALL:
				case PanelEnum.CONTAINER_NOTCHED_LEFT_SMALL:
					_scaleRect.setTo(30, 2, 2, 2);
					return true;
				case PanelEnum.PLAYER_CONTAINER_NOTCHED:
					_scaleRect.setTo(20, 7, 2, 2);
					return true;
				case PanelEnum.ENEMY_CONTAINER_NOTCHED:
					_scaleRect.setTo(11, 2, 2, 2);
					return true;
				case PanelEnum.WINDOW:
					_scaleRect.setTo(50, 125, 4, 4);
					return true;
				case PanelEnum.WINDOW_HEADER:
					_scaleRect.setTo(30, 30, 4, 4);
					return true;
				case PanelEnum.WINDOW_SIDE_HEADER:
					_scaleRect.setTo(18, 130, 2, 2);
					return true;
				case PanelEnum.INPUT_BOX_BLUE:
				case PanelEnum.INPUT_BOX_GOLD:
				case PanelEnum.BOX_GOLD_GLOW:
				case PanelEnum.LEADERBOARD_ROW_GLOW:
					_scaleRect.setTo(5, 5, 5, 5);
					return true;
				case PanelEnum.FAQ_SUBJECT_BG:
					_scaleRect.setTo(0, 7, 522, 29);
					return true;
				default:
					_scaleRect.setTo(0, 0, 1, 1);
					return true;
			}
			return false;
		}
	}
}
