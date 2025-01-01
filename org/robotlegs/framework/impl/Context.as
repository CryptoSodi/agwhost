//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.framework.impl
{
	import org.hamcrest.Matcher;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.api.ILifecycle;
	import org.swiftsuspenders.Injector;

	public class Context implements IContext
	{

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		private const _injector:Injector = new Injector();

		/**
		 * @inheritDoc
		 */
		public function get injector():Injector
		{
			return _injector;
		}

		private var _lifecycle:Lifecycle;

		/**
		 * @inheritDoc
		 */
		public function get lifecycle():ILifecycle
		{
			return _lifecycle;
		}

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _uid:String = UID.create(Context);
		
		private var _configManager:ConfigManager;

		private var _extensionInstaller:ExtensionInstaller;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function Context()
		{
			setup();
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * @inheritDoc
		 */
		public function initialize():void
		{
			_lifecycle.initialize();
		}

		/**
		 * @inheritDoc
		 */
		public function destroy():void
		{
			_lifecycle.destroy();
		}

		/**
		 * @inheritDoc
		 */
		public function extend(... extensions):IContext
		{
			for each (var extension:Object in extensions)
			{
				_extensionInstaller.install(extension);
			}
			return this;
		}

		/**
		 * @inheritDoc
		 */
		public function configure(... configs):IContext
		{
			for each (var config:Object in configs)
			{
				_configManager.addConfig(config);
			}
			return this;
		}

		/**
		 * @inheritDoc
		 */
		public function addConfigHandler(matcher:Matcher, handler:Function):IContext
		{
			_configManager.addConfigHandler(matcher, handler);
			return this;
		}

		public function toString():String
		{
			return _uid;
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function setup():void
		{
			_injector.map(Injector).toValue(_injector);
			_injector.map(IContext).toValue(this);
			_lifecycle = new Lifecycle(this);
			_configManager = new ConfigManager(this);
			_extensionInstaller = new ExtensionInstaller(this);
			_lifecycle.beforeInitializing(beforeInitializing);
			_lifecycle.afterInitializing(afterInitializing);
			_lifecycle.beforeDestroying(beforeDestroying);
			_lifecycle.afterDestroying(afterDestroying);
		}

		private function beforeInitializing():void
		{
			
		}

		private function afterInitializing():void
		{
			
		}

		private function beforeDestroying():void
		{
			
		}

		private function afterDestroying():void
		{
			
		}
	}
}
