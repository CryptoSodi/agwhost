/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.extensions.presenter.impl
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	import org.robotlegs.extensions.localEventMap.api.IEventMap;
	import org.robotlegs.extensions.localEventMap.impl.EventMap;
	import org.robotlegs.extensions.presenter.api.IPresenter;
	import org.swiftsuspenders.Injector;

	/**
	 * Abstract MVCS <code>IPresenter</code> implementation
	 */
	public class Presenter implements IPresenter
	{
		protected var _eventDispatcher:IEventDispatcher;
		protected var _eventMap:IEventMap;
		protected var _immortal:Boolean = false; //Set to true if this presenter should remain active when there are no views no longer using it   
		protected var _injector:Injector;
		protected var _usageCount:int;

		[PostConstruct]
		public function init():void
		{
			_eventMap = new EventMap(_eventDispatcher);
			_usageCount = 0;
		}

		public function highfive():void
		{
			_usageCount++;
		}

		public function shun():void
		{
			_usageCount--;
			if (_usageCount <= 0 && !_immortal)
			{
				var presenterClass:Class = Object(this).constructor;
				var ec:XMLList           = describeType(this).implementsInterface;
				if (ec.length() < 2)
					throw new Error('Presenters must implement a unique interface that extends IPresenter');
				else
				{
					var presenterInterface:Class = Class(getDefinitionByName(ec[ec.length() - 1].@type));
					if (_injector.getMapping(presenterInterface))
					{
						//remove the mapping so the instance of this presenter can be garbage collected
						//then add the mapping back so new instance will be created when needed
						_injector.unmap(presenterInterface);
						_injector.map(presenterInterface).toSingleton(presenterClass);
					}
					destroy();
				}
			}
		}

		/**
		 * Dispatch helper method
		 *
		 * @param event The Event to dispatch on the <code>IContext</code>'s <code>IEventDispatcher</code>
		 */
		public function dispatch( event:Event ):Boolean
		{
			if (_eventDispatcher && event)
				return _eventDispatcher.dispatchEvent(event);
			return false;
		}

		/**
		 * Syntactical sugar for mapping a listener to an <code>IEventDispatcher</code>
		 *
		 * @param dispatcher
		 * @param type
		 * @param listener
		 * @param eventClass
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 *
		 */
		protected function addContextListener( type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true ):void
		{
			_eventMap.mapListener(_eventDispatcher, type, listener,
								  eventClass, useCapture, priority, useWeakReference);
		}

		/**
		 * Syntactical sugar for unmapping a listener from an <code>IEventDispatcher</code>
		 *
		 * @param dispatcher
		 * @param type
		 * @param listener
		 * @param eventClass
		 * @param useCapture
		 *
		 */
		protected function removeContextListener( type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false ):void
		{
			_eventMap.unmapListener(_eventDispatcher, type, listener,
									eventClass, useCapture);
		}

		public function injectObject( object:* ):void  { _injector.injectInto(object); }

		[Inject]
		public function set eventDispatcher( value:IEventDispatcher ):void  { _eventDispatcher = value; }

		[Inject]
		public function set injector( value:Injector ):void  { _injector = value; }

		public function destroy():void
		{
			_eventDispatcher = null;
			_eventMap.unmapListeners();
			_eventMap = null;
			_injector = null;
		}
	}
}
