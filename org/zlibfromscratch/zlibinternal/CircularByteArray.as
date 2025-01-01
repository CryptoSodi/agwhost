// KABAM CHANGE BEGIN - Allow output stream to be emptied between feeds. -bmazza 6/10/13
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
	public class CircularByteArray
	{
		private var _ar:ByteArray            = new ByteArray();
		private var _beginIdx:uint           = 0;
		private var _idx:uint;
		private var _lengthCurrent:uint      = 0;
		private var _lengthMax:uint;
		private var _pos0:int;
		private var _tempByteArray:ByteArray = new ByteArray();
		private var _toEnd:uint;
		private var _toWrite:uint;

		public function reset( lengthMax:uint ):void
		{
			_ar.clear();
			_ar.length = lengthMax;
			_beginIdx = 0;
			_lengthMax = lengthMax;
			_lengthCurrent = 0;
		}

		public function appendByte( val:uint ):void
		{
			if (_lengthMax == 0)
				throw new Error("maximum length is 0");

			val &= 0xFF;

			if (_lengthCurrent == _lengthMax)
			{
				if (_beginIdx < _lengthCurrent - 1)
				{
					_idx = _beginIdx++;
				} else
				{
					_idx = _beginIdx;
					_beginIdx = 0;
				}
			} else
			{
				_idx = _lengthCurrent++;
			}

			_ar.position = _idx;
			_ar.writeByte(val);
		}

		public function appendBytes( byteArray:ByteArray, pos:uint = 0, count:uint = 4294967295 ):void
		{
			if (pos >= byteArray.length)
				return;
			if (byteArray.length - pos < count)
				count = byteArray.length - pos;
			if (count == 0)
				return;

			if (_lengthMax == 0)
				throw new Error("maximum length is 0");

			for (; ; )
			{
				_idx = (_lengthCurrent == _lengthMax) ? _beginIdx : _lengthCurrent;
				_ar.position = _idx;

				_toEnd = _lengthMax - _idx;
				if (_toEnd >= count)
				{
					_ar.writeBytes(byteArray, pos, count);
					if (_lengthMax - _lengthCurrent >= count)
					{
						_lengthCurrent += count;
					} else
					{
						_beginIdx = (_toEnd > count) ? _beginIdx + count : 0;
						_lengthCurrent = _lengthMax;
					}
					break;
				} else
				{
					_ar.writeBytes(byteArray, pos, _toEnd);
					pos += _toEnd;
					count -= _toEnd;
					_beginIdx = 0;
					_lengthCurrent = (_lengthMax - _lengthCurrent >= _toEnd) ? _lengthCurrent + _toEnd : _lengthMax;
				}
			}
		}

		public function at( idx:uint ):uint
		{
			if (idx >= _lengthCurrent)
				throw new Error("buffer overflow");

			_toEnd = _lengthCurrent - _beginIdx;
			_idx = (_toEnd > idx) ? _beginIdx + idx : idx - _toEnd;
			return _ar[_idx];
		}

		public function getBytes( pos:uint = 0, count:uint = 4294967295 ):ByteArray
		{
			if (pos >= _lengthCurrent)
				throw new Error("buffer overflow");
			if (count > _lengthCurrent - pos)
				count = _lengthCurrent - pos;

			_tempByteArray.clear();
			_tempByteArray.length = count;

			_toEnd = _lengthCurrent - _beginIdx;
			if (pos < _toEnd)
			{
				_toWrite = (_toEnd - pos > count) ? count : _toEnd - pos;
				_tempByteArray.writeBytes(_ar, _beginIdx + pos, _toWrite);
				count -= _toWrite;
				_pos0 = 0;
			} else
			{
				_pos0 = pos - _toEnd;
			}

			if (count > 0)
			{
				_tempByteArray.writeBytes(_ar, _pos0, count);
			}

			return _tempByteArray;
		}

		public function get length():uint  { return _lengthCurrent; }
	}
}
// KABAM CHANGE END
