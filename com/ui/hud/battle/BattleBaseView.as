package com.ui.hud.battle
{
	import com.presenter.battle.IBattlePresenter;
	import com.ui.core.View;

	import org.parade.enum.ViewEnum;

	public class BattleBaseView extends View
	{
		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addCleanupListener(destroy);
		}

		[Inject]
		public function set presenter( value:IBattlePresenter ):void  { _presenter = value; }
		public function get presenter():IBattlePresenter  { return IBattlePresenter(_presenter); }

		override public function get type():String  { return ViewEnum.UI; }
		
		override public function get screenshotBlocker():Boolean {return true;}

		override public function destroy():void
		{
			presenter.removeCleanupListener(destroy);
			super.destroy();
		}
	}
}
