//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.extensions.matching
{
	import flash.utils.getQualifiedClassName;

	public class TypeFilter implements ITypeFilter
	{

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		// TODO: Discuss whether we should return a slice here instead
		// of references to actual vectors. Overhead vs encapsulation.

		protected var _allOfTypes:Vector.<Class>;

		public function get allOfTypes():Vector.<Class>
		{
			return _allOfTypes;
		}

		protected var _anyOfTypes:Vector.<Class>;

		public function get anyOfTypes():Vector.<Class>
		{
			return _anyOfTypes;
		}

		protected var _descriptor:String;

		public function get descriptor():String
		{
			return _descriptor ||= createDescriptor();
		}

		protected var _noneOfTypes:Vector.<Class>;

		public function get noneOfTypes():Vector.<Class>
		{
			return _noneOfTypes;
		}

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function TypeFilter(allOf:Vector.<Class>, anyOf:Vector.<Class>, noneOf:Vector.<Class>)
		{
			if (!allOf || !anyOf || !noneOf)
				throw ArgumentError('TypeFilter parameters can not be null');
			_allOfTypes = allOf;
			_anyOfTypes = anyOf;
			_noneOfTypes = noneOf;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function matches(item:*):Boolean
		{
			var i:uint = _allOfTypes.length;
			while (i--)
			{
				if (!(item is _allOfTypes[i]))
				{
					return false;
				}
			}

			i = _noneOfTypes.length;
			while (i--)
			{
				if (item is _noneOfTypes[i])
				{
					return false;
				}
			}

			if (_anyOfTypes.length == 0 && (_allOfTypes.length > 0 || _noneOfTypes.length > 0))
			{
				return true;
			}

			i = _anyOfTypes.length;
			while (i--)
			{
				if (item is _anyOfTypes[i])
				{
					return true;
				}
			}

			return false;
		}

		/*============================================================================*/
		/* Protected Functions                                                        */
		/*============================================================================*/

		protected function alphabetiseCaseInsensitiveFCQNs(classVector:Vector.<Class>):Vector.<String>
		{
			var fqcn:String;
			const allFCQNs:Vector.<String> = new <String>[];

			const iLength:uint = classVector.length;
			for (var i:uint = 0; i < iLength; i++)
			{
				fqcn = getQualifiedClassName(classVector[i]);
				allFCQNs[allFCQNs.length] = fqcn;
			}

			allFCQNs.sort(stringSort);
			return allFCQNs;
		}

		protected function createDescriptor():String
		{
			const allOf_FCQNs:Vector.<String> = alphabetiseCaseInsensitiveFCQNs(allOfTypes);
			const anyOf_FCQNs:Vector.<String> = alphabetiseCaseInsensitiveFCQNs(anyOfTypes);
			const noneOf_FQCNs:Vector.<String> = alphabetiseCaseInsensitiveFCQNs(noneOfTypes);
			return "all of: " + allOf_FCQNs.toString()
				+ ", any of: " + anyOf_FCQNs.toString()
				+ ", none of: " + noneOf_FQCNs.toString();
		}

		protected function stringSort(item1:String, item2:String):int
		{
			if (item1 < item2)
			{
				return 1;
			}
			return -1;
		}
	}
}
