package org.parade.core
{
	import flash.events.Event;

	public class ViewEvent extends Event
	{
		public static const DESTROY_VIEW:String      = "destroyView";
		public static const DESTROY_ALL_VIEWS:String = "destroyAllView";
		public static const SHOW_VIEW:String         = "showView";
		public static const HIDE_VIEWS:String        = "hideViews";
		public static const UNHIDE_VIEWS:String      = "unhideViews";

		public var targetClass:*;
		public var targetView:IView;

		public function ViewEvent( type:String )
		{
			super(type);
		}

		public function destroy():void
		{
			targetClass = null;
			targetView = null;
		}
	}
}
