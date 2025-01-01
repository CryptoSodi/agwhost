package com.game.entity.systems.shared
{
	import com.enum.CategoryEnum;
	import com.enum.TypeEnum;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.nodes.shared.FSMNode;

	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class FSMSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.shared.FSMNode")]
		public var nodes:NodeList;

		private var _starbaseFactory:IStarbaseFactory;

		override public function addToGame( game:Game ):void
		{
			super.addToGame(game);
		}

		override public function update( time:Number ):void
		{
			for (var node:FSMNode = nodes.head; node; node = node.next)
			{
				if (!node.fsm.advanceState(node))
					destroyNode(node);
			}
		}

		private function destroyNode( node:FSMNode ):void
		{
			switch (node.detail.category)
			{
				case CategoryEnum.BUILDING:
					_starbaseFactory.destroyStarbaseItem(node.entity);
					break;
			}
		}

		[Inject]
		public function set starbaseFactory( v:IStarbaseFactory ):void  { _starbaseFactory = v; }

		override public function removeFromGame( game:Game ):void
		{
			super.removeFromGame(game);
			nodes = null;
		}
	}
}
