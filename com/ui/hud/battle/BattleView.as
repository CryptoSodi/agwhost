package com.ui.hud.battle
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.ui.core.effects.EffectFactory;

	import org.parade.util.DeviceMetrics;

	public class BattleView extends BattleBaseView
	{
		private const MIN_X_POS:Number      = 650;
		private const EXIT_MIN_X_POS:Number = 67;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			x = DeviceMetrics.WIDTH_PIXELS * 0.5;

			if (x < MIN_X_POS)
				x = MIN_X_POS;

			addHitArea();
			addEffects();
			effectsIN();
			onResize();
		}

		private function onResize():void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			x = DeviceMetrics.WIDTH_PIXELS * 0.5;

			if (x < MIN_X_POS)
				x = MIN_X_POS;
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.CENTER, PositionEnum.TOP, onResize));
		}

		override public function destroy():void
		{
			super.destroy();
			//abilityView will handle destroying itself
		}
	}
}
