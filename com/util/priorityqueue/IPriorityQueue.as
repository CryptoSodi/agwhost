package com.util.priorityqueue
{

	public interface IPriorityQueue
	{
		function add(object:IPrioritizable):IPrioritizable;
		function contains(object:IPrioritizable):Boolean;
		function toVector():Vector.<IPrioritizable>;

		/**
		 * Gets the next item in the queue AND REMOVES IT from the queue
		 * @return
		 *
		 */
		function getNext():IPrioritizable;

		/**
		 * Gets the next item in the queue WITHOUT REMOVING IT from the queue
		 * @return
		 *
		 */
		function peekNext():IPrioritizable;
		function remove(object:IPrioritizable):IPrioritizable;

		function get isEmpty():Boolean;
	}
}