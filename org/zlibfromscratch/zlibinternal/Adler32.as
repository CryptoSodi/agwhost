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
	import flash.utils.ByteArray;

	/** @private For internal use only. */
	public class Adler32 implements IChecksum
	{
		private static const BLOCK_SIZE:uint = 5552;
		private static const MODULO:uint     = 65521;

		private var _bytesLeftInBlock:uint   = BLOCK_SIZE;
		private var _iterator:uint;
		private var _s1:uint                 = 1;
		private var _s2:uint                 = 0;

		public function reset():void
		{
			_bytesLeftInBlock = BLOCK_SIZE;
			_s1 = 1;
			_s2 = 2;
		}

		public function feed( input:ByteArray, position:uint, length:uint ):void
		{
			for (_iterator = position; _iterator < position + length; _iterator++)
			{
				_s1 += input[_iterator];
				_s2 += _s1;
				_bytesLeftInBlock--;
				if (_bytesLeftInBlock == 0)
				{
					_s1 %= MODULO;
					_s2 %= MODULO;
					_bytesLeftInBlock = BLOCK_SIZE;
				}
			}
		}

		public function feedByte( byte:uint ):void
		{
			_s1 += byte;
			_s2 += _s1;
			_bytesLeftInBlock--;
			if (_bytesLeftInBlock == 0)
			{
				_s1 %= MODULO;
				_s2 %= MODULO;
				_bytesLeftInBlock = BLOCK_SIZE;
			}
		}

		public function get bytesAccumulated():uint  { return 0; }
		public function get checksum():uint  { return ((_s2 % MODULO) << 16) | (_s1 % MODULO); }
	}
}
