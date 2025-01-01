package com.game.entity.nodes.shared.visualComponent
{
	import com.game.entity.components.shared.render.RenderSprite;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.VCList;

	import org.ash.core.Entity;
	import org.ash.core.Node;

	public class VCSpriteNode extends Node implements IVCSpriteNode
	{
		public var internal_render:RenderSprite;
		public var internal_vcList:VCList;

		public function get ientity():Entity  { return entity; }
		public function get render():IRender  { return internal_render; }
		public function get vcList():VCList  { return internal_vcList; }
	}
}
