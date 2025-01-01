package com.game.entity.nodes.shared.visualComponent
{
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.VCList;

	import org.ash.core.Entity;

	public interface IVCNode
	{
		function get ientity():Entity;
		function get render():IRender;
		function get vcList():VCList;
	}
}
