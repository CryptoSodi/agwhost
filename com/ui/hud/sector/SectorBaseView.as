package com.ui.hud.sector
{
	import com.presenter.sector.ISectorPresenter;
	import com.ui.core.View;

	import org.parade.enum.ViewEnum;

	public class SectorBaseView extends View
	{
		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addCleanupListener(destroy);
		}

		[Inject]
		public function set presenter( value:ISectorPresenter ):void  { _presenter = value; }
		public function get presenter():ISectorPresenter  { return ISectorPresenter(_presenter); }

		override public function get type():String  { return ViewEnum.UI; }
		
		override public function get screenshotBlocker():Boolean {return true;}

		override public function destroy():void
		{
			presenter.removeCleanupListener(destroy);
			super.destroy();
		}
	}
}
