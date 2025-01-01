/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.extensions.presenter.api
{
	import flash.events.Event;

	public interface IPresenter
	{
		/**
		 * Lets the presenter know that there is a view using it.
		 */
		function highfive():void;

		/**
		 * Informs the presenter that a view is no longer using it.
		 * This function will also prepare the current instance of the presenter for
		 * garbage collection if there are no more views using it.
		 */
		function shun():void;

		function dispatch( event:Event ):Boolean;

		function injectObject( object:* ):void;
	}
}
