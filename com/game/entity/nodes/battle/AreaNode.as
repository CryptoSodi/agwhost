package com.game.entity.nodes.battle
{
	import com.game.entity.components.battle.Area;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Node;

	public class AreaNode extends Node
	{
		public var animation:Animation;
		public var area:Area;
		public var detail:Detail;
		public var position:Position;

		private var _readyCallback:Function;

		public function init( readyCallback:Function ):void
		{
			_readyCallback = readyCallback;
			animation.addListener(onReady);
		}

		private function onReady( current:int, animation:Animation ):void
		{
			if (current == Animation.ANIMATION_READY && _readyCallback != null)
			{
				animation.removeListener(_readyCallback);
				_readyCallback(this);
				_readyCallback = null;
			}
		}

		public function destroy():void
		{
			_readyCallback = null;
			animation.removeListener(onReady);
		}
	}
}
