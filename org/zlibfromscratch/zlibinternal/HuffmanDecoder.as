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
	public class HuffmanDecoder
	{
		private static var _reversed:uint;

		private var _length_count:Array   = [];
		private var _max_length:uint;
		private var _sorted_symbols:Array = [];
		private var _table:Array          = [];

		public function HuffmanDecoder( code_lengths:*, offset:uint = 0, length:uint = 0 )
		{
			_length_count.length = 0;
			_sorted_symbols.length = 0;

			var symbol:uint;
			var code:uint;
			var n:uint;
			var len:uint;
			var i:uint;
			var j:uint;
			var max_code:uint;
			var k:uint;

			if (offset > code_lengths.length)
			{
				throw new Error("Invalid offset in Huffman decoder construction.");
			}

			if (length == 0)
				length = code_lengths.length - offset;

			for (symbol = 0; symbol < length; symbol++)
			{
				len = code_lengths[symbol + offset];
				if (!_length_count[len])
					_length_count[len] = 1;
				else
					_length_count[len] += 1;
				if (len != 0)
				{
					_sorted_symbols.push({symbol:symbol, length:len});
				}
			}
			_sorted_symbols.sortOn(["length", "symbol"], [Array.NUMERIC, Array.NUMERIC]);
			_max_length = _length_count.length - 1;
			max_code = (1 << _max_length) - 1;

			// build the array out in order so that it's properly packed.
			// this is an AS3-specific optimization.
			_table.length = 0;
			n = 0;
			code = 0;
			for (len = 1; len < _length_count.length; len++)
			{
				k = (1 << len);
				if (!_length_count[len])
					_length_count[len] = 0; // turns undefined into 0.
				for (i = 0; i < _length_count[len]; i++)
				{
					for (j = reverseBits(code, len); j <= max_code; j += k)
					{
						_table[j] = [_sorted_symbols[n].symbol, len];
					}
					n++;
					code++;
				}
				code <<= 1;
			}

			DisposeUtil.genericDispose(_sorted_symbols);
			DisposeUtil.genericDispose(_length_count);
		}

		public function dispose():void
		{
			DisposeUtil.genericDispose(_table);
		}

		private static function reverseBits( data:uint, numBits:uint ):uint
		{
			_reversed = 0;
			while (numBits)
			{
				_reversed <<= 1;
				_reversed |= data & 1;
				data >>= 1;
				numBits--;
			}
			return _reversed;
		}

		public function bitsUsed( code:uint ):uint  { return _table[code][1]; }
		public function decode( code:uint ):uint  { return _table[code][0]; }

		public function get maxLength():uint  { return _max_length; }
	}
}
