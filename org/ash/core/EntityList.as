package org.ash.core
{
	import flash.utils.Dictionary;

	/**
	 * An internal class for a linked list of entities. Used inside the framework for
	 * managing the entities.
	 */
	internal class EntityList
	{
		internal var head:Entity;
		internal var tail:Entity;
		internal var lookup:Dictionary = new Dictionary();

		internal function add( entity:Entity ):void
		{
			if (!head)
			{
				head = tail = entity;
			} else
			{
				tail.next = entity;
				entity.previous = tail;
				tail = entity;
			}
			if (entity.id)
				lookup[entity.id] = entity;
		}

		internal function updateEntityID( entity:Entity, newID:String ):void
		{
			lookup[entity.id] = null;
			delete lookup[entity.id];
			entity.id = newID;
			lookup[entity.id] = entity;
		}

		internal function remove( entity:Entity ):void
		{
			if (head == entity)
			{
				head = head.next;
			}
			if (tail == entity)
			{
				tail = tail.previous;
			}

			if (entity.previous)
			{
				entity.previous.next = entity.next;
			}

			if (entity.next)
			{
				entity.next.previous = entity.previous;
			}
			if (entity.id)
			{
				lookup[entity.id] = null;
				delete lookup[entity.id];
				entity.id = null;
			}
		}

		internal function getEntity( key:* ):Entity
		{
			if (lookup[key])
				return lookup[key];
			return null;
		}

		internal function getLookup():Dictionary  { return lookup; }
	}
}
