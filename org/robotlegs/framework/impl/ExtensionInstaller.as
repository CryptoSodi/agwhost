//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.framework.impl
{
	import flash.utils.Dictionary;
	
	import org.robotlegs.framework.api.IContext;
	import org.swiftsuspenders.DescribeTypeReflector;
	import org.swiftsuspenders.Reflector;

	/**
	 * Installs custom extensions into a given context
	 */
	public class ExtensionInstaller
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _uid:String = UID.create(ExtensionInstaller);

		private const _classes:Dictionary = new Dictionary(true);

		private const _reflector:Reflector = new DescribeTypeReflector();

		private var _context:IContext;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function ExtensionInstaller(context:IContext)
		{
			_context = context;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * Installs the supplied extension
		 * @param extension An object or class implementing IExtension
		 */
		public function install(extension:Object):void
		{
			if (extension is Class)
			{
				_classes[extension] || install(new extension());
			}
			else
			{
				const extensionClass:Class = _reflector.getClass(extension);
				if (_classes[extensionClass])
					return;
				_classes[extensionClass] = true;
				extension.extend(_context);
			}
		}

		public function toString():String
		{
			return _uid;
		}
	}
}
