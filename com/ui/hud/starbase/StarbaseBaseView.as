package com.ui.hud.starbase
{
	import com.presenter.starbase.IStarbasePresenter;
	import com.ui.core.View;

	import org.parade.enum.ViewEnum;

	public class StarbaseBaseView extends View
	{
		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addCleanupListener(destroy);
		}

		[Inject]
		public function set presenter( value:IStarbasePresenter ):void  { _presenter = value; }
		public function get presenter():IStarbasePresenter  { return IStarbasePresenter(_presenter); }

		override public function get type():String  { return ViewEnum.UI; }
		
		override public function get screenshotBlocker():Boolean {return true;}

		override public function destroy():void
		{
			presenter.removeCleanupListener(destroy);
			super.destroy();
		}
	}
}
