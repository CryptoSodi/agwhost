package com.game.entity.nodes.shared
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Node;

	public class RenderNode extends Node
	{
		public var animation:Animation;
		public var detail:Detail;
		public var position:Position;

		private var _render3D:IRender;

		public function get render():IRender  { return animation.render; }
		public function set render( v:IRender ):void  { animation.render = v; }

		public function get render3D():IRender  { return _render3D; }
		public function set render3D( v:IRender ):void  { _render3D = v; }
	}
}
