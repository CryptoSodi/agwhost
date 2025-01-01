package org.parade.util
{
	import flash.display.Stage;
	import flash.system.Capabilities;

	import org.parade.enum.PlatformEnum;

	public class DeviceMetrics
	{
		/**
		 * Standard quantized DPI for low-density screens.
		 */
		public static const DENSITY_LOW:int     = 120;

		/**
		 * Standard quantized DPI for medium-density screens.
		 */
		public static const DENSITY_MEDIUM:int  = 160;

		/**
		 * Standard quantized DPI for high-density screens.
		 */
		public static const DENSITY_HIGH:int    = 240;

		/**
		 * Standard quantized DPI for extra-high-density screens.
		 */
		public static const DENSITY_XHIGH:int   = 320;

		/**
		 * Standard quantized DPI for extra-extra-high-density screens.  Applications
		 * should not generally worry about this density; relying on XHIGH graphics
		 * being scaled up to it should be sufficient for almost all cases.
		 */
		public static const DENSITY_XXHIGH:int  = 480;

		/**
		 * The reference density used throughout the system.
		 */
		public static const DENSITY_DEFAULT:int = DENSITY_HIGH;

		public static var PLATFORM:String;

		/**
		 * Maximum height of the display in inches
		 */
		public static var MAX_HEIGHT_INCHES:int;
		/**
		 * Maximum height of the display in pixels
		 */
		public static var MAX_HEIGHT_PIXELS:int;
		/**
		 * Maximum width of the display in inches
		 */
		public static var MAX_WIDTH_INCHES:int;
		/**
		 * Maximum width of the display in pixels
		 */
		public static var MAX_WIDTH_PIXELS:int;

		/**
		 * The logical density of the display.  This is a scaling factor for the
		 * Density Independent Pixel unit, where one DIP is one pixel on an
		 * approximately 160 dpi screen (for example a 240x320, 1.5"x2" screen),
		 * providing the baseline of the system's display. Thus on a 160dpi screen
		 * this density value will be 1; on a 120 dpi screen it would be .75; etc.
		 *
		 * <p>This value does not exactly follow the real screen size (as given by
		 * {@link #xdpi} and {@link #ydpi}, but rather is used to scale the size of
		 * the overall UI in steps based on gross changes in the display dpi.  For
		 * example, a 240x320 screen will have a density of 1 even if its width is
		 * 1.8", 1.3", etc. However, if the screen resolution is increased to
		 * 320x480 but the screen size remained 1.5"x2" then the density would be
		 * increased (probably to 1.5).
		 *
		 * @see #DENSITY_DEFAULT
		 */
		public static var DENSITY:Number;
		/**
		 * The screen density expressed as ldpi, mdpi, hdpi, xhdpi, or xxhdpi.
		 */
		public static var DENSITY_DPI:int;
		/**
		 * The screen density expressed as dots-per-inch.
		 */
		public static var DPI:int;
		/**
		 * A scaling factor for fonts displayed on the display.  This is the same
		 * as {@link #density}, except that it may be adjusted in smaller
		 * increments at runtime based on a user preference for the font size.
		 */
		public static var SCALED_DENSITY:Number;

		private static var _stage:Stage;

		public static function init( stage:Stage, platform:String ):void
		{
			_stage = stage;
			PLATFORM = platform;

			//set screen values
			DPI = (PLATFORM == PlatformEnum.BROWSER) ? DENSITY_DEFAULT : Capabilities.screenDPI;
			if (DPI <= DENSITY_LOW)
				DENSITY_DPI = DENSITY_LOW;
			else if (DPI <= DENSITY_MEDIUM)
				DENSITY_DPI = DENSITY_MEDIUM;
			else if (DPI <= DENSITY_HIGH)
				DENSITY_DPI = DENSITY_HIGH;
			else if (DPI <= DENSITY_XHIGH)
				DENSITY_DPI = DENSITY_XHIGH;
			else
				DENSITY_DPI = DENSITY_XXHIGH;
			DENSITY = DPI / DENSITY_DEFAULT;
			SCALED_DENSITY = DENSITY;

			if (PLATFORM == PlatformEnum.MOBILE)
			{
				MAX_HEIGHT_PIXELS = (_stage.fullScreenWidth > _stage.fullScreenHeight) ? _stage.fullScreenHeight : _stage.fullScreenWidth;
				MAX_HEIGHT_INCHES = MAX_HEIGHT_PIXELS / DPI;
				MAX_WIDTH_PIXELS = (_stage.fullScreenWidth > _stage.fullScreenHeight) ? _stage.fullScreenWidth : _stage.fullScreenHeight;
				MAX_WIDTH_INCHES = MAX_WIDTH_PIXELS / DPI;
			} else
			{
				MAX_HEIGHT_INCHES = _stage.fullScreenHeight / DPI;
				MAX_HEIGHT_PIXELS = _stage.fullScreenHeight;
				MAX_WIDTH_INCHES = _stage.fullScreenWidth / DPI;
				MAX_WIDTH_PIXELS = _stage.fullScreenWidth;
			}
		}

		public static function toString():String
		{
			return "DeviceMetrics{platform=" + PLATFORM + ", densityDPI=" + DENSITY_DPI + ", dpi=" + DPI + ", density=" + DENSITY + "}";
		}

		/**
		 * Current width of the display in pixels
		 */
		public static function get WIDTH_PIXELS():Number
		{
			if (PLATFORM == PlatformEnum.MOBILE)
				return (_stage.fullScreenWidth > _stage.fullScreenHeight) ? _stage.fullScreenWidth : _stage.fullScreenHeight;
			return _stage.stageWidth;
		}

		/**
		 * Current height of the display in pixels
		 */
		public static function get HEIGHT_PIXELS():Number
		{
			if (PLATFORM == PlatformEnum.MOBILE)
				return (_stage.fullScreenWidth > _stage.fullScreenHeight) ? _stage.fullScreenHeight : _stage.fullScreenWidth;
			return _stage.stageHeight;
		}

		/**
		 * Current width of the display in inches
		 */
		public static function get WIDTH_INCHES():Number
		{
			if (PLATFORM == PlatformEnum.MOBILE)
				return (_stage.fullScreenWidth > _stage.fullScreenHeight) ? _stage.fullScreenWidth / DPI : _stage.fullScreenHeight / DPI;
			return _stage.stageWidth / DPI;
		}

		/**
		 * Current height of the display in inches
		 */
		public static function get HEIGHT_INCHES():Number
		{
			if (PLATFORM == PlatformEnum.MOBILE)
				return (_stage.fullScreenWidth > _stage.fullScreenHeight) ? _stage.fullScreenHeight / DPI : _stage.fullScreenWidth / DPI;
			return _stage.stageHeight / DPI;
		}
	}
}
