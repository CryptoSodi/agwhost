package com.service.server
{
	import com.Application;
	import com.controller.ServerController;
	import com.enum.server.EncodingEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.model.player.CurrentUser;
	import com.service.server.outgoing.proxy.ProxyReportCrashRequest;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;
	import org.zlibfromscratch.ZlibDecoder;
	import org.zlibfromscratch.ZlibDecoderError;

	public class EightTrack
	{
		private const _logger:ILogger             = getLogger("EightTrack");

		private var _io:BinaryInputStream;
		private var _protocolListener:int         = -1;
		private var _responseSignal:Signal;
		private var _serverController:ServerController;
		private var _zlibDecoderBuffer:ByteArray;
		private var _zlibDecoder:ZlibDecoder;
		private var _waitingResponseSize:uint     = 0;
		private var _recordedStream:ByteArray;

		public function init( stream:ByteArray ):void
		{
			_io = new BinaryInputStream();
			_responseSignal = new Signal(IResponse);

			_zlibDecoderBuffer = new ByteArray();
			_zlibDecoderBuffer.endian = Endian.BIG_ENDIAN;
			_zlibDecoder = new ZlibDecoder();

			_recordedStream = stream;
			_recordedStream.endian = Endian.BIG_ENDIAN;

			reset();
		}

		public function reset():void
		{
			_recordedStream.position = 0;
			_zlibDecoder.reset(false, false);
		}

		public function onReceive( e:ProgressEvent ):void
		{
			do
			{
				var size:uint;
				if (_waitingResponseSize > 0)
				{
					size = _waitingResponseSize;
				} else
				{
					if (_recordedStream.bytesAvailable >= 4)
						size = _recordedStream.readUnsignedInt() - 4;
					else
						break;
				}

				if (_recordedStream.bytesAvailable >= size)
				{
					_io.clear();
					_recordedStream.readBytes(_io, 0, size);
					var protocolID:int = _io.readByte();
					var speakerID:int  = _io.readByte();
					var header:int     = _io.readByte();
					var encoding:int   = _io.readByte();
					if (encoding == EncodingEnum.BINARYZLIBCOMPRESSED)
					{
						// Read compressed input into _zlibDecoderBuffer.
						_zlibDecoderBuffer.length = _io.bytesAvailable + 4;
						_zlibDecoderBuffer.position = 0;
						_io.readBytes(_zlibDecoderBuffer);

						// Append the zlib sync-flush byte sequence.
						_zlibDecoderBuffer.position = _zlibDecoderBuffer.length - 4;
						_zlibDecoderBuffer.writeByte(0x00);
						_zlibDecoderBuffer.writeByte(0x00);
						_zlibDecoderBuffer.writeByte(0xff);
						_zlibDecoderBuffer.writeByte(0xff);

						// Uncompress the input to _io.
						_zlibDecoderBuffer.position = 0;
						_io.clear();
						var bytesRead:uint = _zlibDecoder.feed(_zlibDecoderBuffer, _io);
						if (bytesRead != _zlibDecoderBuffer.length || (_zlibDecoder.lastError != ZlibDecoderError.NEED_MORE_DATA && _zlibDecoder.lastError != ZlibDecoderError.NO_ERROR))
							throw new Error("Failed to uncompress network message");

						_io.position = 0;
						encoding = EncodingEnum.BINARY;
					}
					if (_protocolListener == -1 || _protocolListener == protocolID || PacketFactory.isImportant(protocolID, header))
					{
						var response:IResponse = PacketFactory.getResponse(_io, protocolID, header, encoding);
						if (response)
						{
							_responseSignal.dispatch(response);
						} else
						{
							_logger.error("Unknown Message Received {0}, {1}, {2}", [protocolID, speakerID, header]);
							var msg:ProxyReportCrashRequest = ProxyReportCrashRequest(_serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_REPORT_CRASH));
							msg.dataStr = 'Unknown Message Received ' + protocolID + ', ' + speakerID + ', ' + header;
							_serverController.send(msg);
							if (CONFIG::DEBUG)
								throw new Error("Unknown Message Received");
						}
					}
					_waitingResponseSize = 0;
				} else
				{
					_waitingResponseSize = size;
					break;
				}
			} while (_recordedStream && _recordedStream.bytesAvailable > 0);
		}

		private function unknownMessage( header:int ):void
		{
			_logger.error("Unknown Message Received {0}, {1}, {2}", [header, _recordedStream.bytesAvailable, _recordedStream.readUTFBytes(_recordedStream.bytesAvailable)]);
		}

		private function postTo80Error( e:IOErrorEvent ):void
		{
			e.stopImmediatePropagation();
		}

		private function onError( e:IOErrorEvent ):void
		{
			_logger.error('IOError parsing data for replay');
		}

		public function addResponseListener( callback:Function ):void  { _responseSignal.add(callback); }
		public function removeResponseListener( callback:Function ):void  { _responseSignal.remove(callback); }

		public function get protocolListener():int  { return _protocolListener; }
		public function set protocolListener( v:int ):void  { _protocolListener = v; }
		public function set serverController( value:ServerController ):void  { _serverController = value; }

		public function destroy():void
		{
			_zlibDecoder.dispose();
			_zlibDecoder = null;
			_zlibDecoderBuffer.clear();
			_zlibDecoderBuffer = null;

			_io.clear();
			_io = null;
			_responseSignal.removeAll();
			_responseSignal = null;
			_serverController = null;
			_recordedStream = null;
		}

	}
}
