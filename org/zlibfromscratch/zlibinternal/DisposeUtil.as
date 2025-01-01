/*
 * This file is a part of ZlibFromScratch,
 * an open-source ActionScript decompression library.
 * Copyright (C) 2011 - Joey Parrish
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 * If not, see <http://www.gnu.org/licenses/>.
 */
package org.zlibfromscratch.zlibinternal
{
	/** @private For internal use only. */
	public class DisposeUtil
	{
		private static var _iterator:int;
		private static var _k:String;

		public static function genericDispose( x:* ):void
		{
			if (x is Array)
			{
				for (_iterator = x.length - 1; _iterator >= 0; _iterator--)
				{
					genericDispose(x[_iterator]);
				}
				(x as Array).length = 0;
			} else if (x is String)
			{
				// do nothing, just don't treat it as an Object.
			} else if (x is Object)
			{
				for (_k in x)
				{
					genericDispose(x[_k]);
					delete x[_k];
				}
			}
		}
	}
}
