package com.game.entity.nodes.shared.visualComponent
{
	import com.game.entity.components.shared.render.RenderStarling;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.VCList;

	import org.ash.core.Entity;
	import org.ash.core.Node;

	public class VCStarlingNode extends Node implements IVCNode
	{
		public var internal_render:RenderStarling;
		public var internal_vcList:VCList;

		public function get ientity():Entity  { return entity; }
		public function get render():IRender  { return internal_render; }
		public function get vcList():VCList  { return internal_vcList; }
	}
}
