package com.ui.core.component.page
{
	import flash.events.Event;

	public class PageEvent extends Event
	{
		public static const ITEM_SELECTED:String = 'ItemSelected';

		public var selection:*;

		public function PageEvent( selection:* )
		{
			super(ITEM_SELECTED, true, true);
			this.selection = selection;
		}
	}
}
