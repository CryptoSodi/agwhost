//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.framework.impl
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.hamcrest.Matcher;
	import org.hamcrest.core.allOf;
	import org.hamcrest.core.not;
	import org.hamcrest.object.instanceOf;
	import org.robotlegs.framework.api.IConfig;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.api.LifecycleEvent;
	import org.swiftsuspenders.Injector;

	/**
	 * The config manager handles configuration files and
	 * allows the installation of custom configuration handlers.
	 *
	 * <p>It is pre-configured to handle plain objects and classes</p>
	 */
	public class ConfigManager
	{

		/*============================================================================*/
		/* Private Static Properties                                                  */
		/*============================================================================*/

		private static const plainObjectMatcher:Matcher = allOf(
			instanceOf(Object),
			not(instanceOf(Class)),
			not(instanceOf(DisplayObject)));

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _uid:String = UID.create(ConfigManager);

		private const _objectProcessor:ObjectProcessor = new ObjectProcessor();

		private const _configs:Dictionary = new Dictionary();

		private const _queue:Array = [];

		private var _injector:Injector;
		
		private var _initialized:Boolean;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function ConfigManager(context:IContext)
		{
			_injector = context.injector;
			addConfigHandler(instanceOf(Class), handleClass);
			addConfigHandler(plainObjectMatcher, handleObject);
			// The ConfigManager should process the config queue
			// at the end of the INITIALIZE phase,
			// but *before* POST_INITIALIZE, so use low event priority
			context.lifecycle.addEventListener(LifecycleEvent.INITIALIZE, initialize, false, -100);
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * Process a given configuration object by running it through registered handlers.
		 * <p>If the manager is not initialized the configuration will be queued.</p>
		 * @param config The configuration object or class
		 */
		public function addConfig(config:Object):void
		{
			if (!_configs[config])
			{
				_configs[config] = true;
				_objectProcessor.processObject(config);
			}
		}

		/**
		 * Adds a custom configuration handlers
		 * @param matcher Pattern to match configuration objects
		 * @param handler Handler to process matching configurations
		 */
		public function addConfigHandler(matcher:Matcher, handler:Function):void
		{
			_objectProcessor.addObjectHandler(matcher, handler);
		}

		public function toString():String
		{
			return _uid;
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function initialize(event:LifecycleEvent):void
		{
			if (!_initialized)
			{
				_initialized = true;
				processQueue();
			}
		}

		private function handleClass(type:Class):void
		{
			if (_initialized)
			{
				processClass(type);
			}
			else
			{
				_queue.push(type);
			}
		}

		private function handleObject(object:Object):void
		{
			if (_initialized)
			{
				processObject(object);
			}
			else
			{
				_queue.push(object);
			}
		}

		private function processQueue():void
		{
			for each (var config:Object in _queue)
			{
				if (config is Class)
				{
					processClass(config as Class);
				}
				else
				{
					processObject(config);
				}
			}
			_queue.length = 0;
		}

		private function processClass(type:Class):void
		{
			const config:IConfig = _injector.getInstance(type) as IConfig;
			config && config.configure();
		}

		private function processObject(object:Object):void
		{
			_injector.injectInto(object);
			const config:IConfig = object as IConfig;
			config && config.configure();
		}
	}
}
