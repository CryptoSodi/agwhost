package org.ash.integration.swiftsuspenders
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;

	/**
	 * A custom dependency provider for SwiftSuspenders to allow injection
	 * of NodeList objects based on the node class they contain.
	 *
	 * <p>This enables injections rules like</p>
	 *
	 * <p>[Inject(nodeType="com.myDomain.project.nodes.MyNode")]
	 * public var nodes : NodeList;</p>
	 */
	public class NodeListProvider implements DependencyProvider
	{
		private var game:Game;

		public function NodeListProvider( game:Game )
		{
			this.game = game;
		}

		public function apply( targetType:Class, activeInjector:Injector, injectParameters:Dictionary ):Object
		{
			if (injectParameters["nodeType"])
			{
				var nodeClass:Class = getDefinitionByName(NodeLookup.lookupNode(injectParameters["nodeType"])) as Class
				if (nodeClass)
				{
					return game.getNodeList(nodeClass);
				}
			}
			return null;
		}
	}
}
