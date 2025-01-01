package com.service.server
{
	import com.Application;
	import com.controller.ServerController;
	import com.enum.server.EncodingEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.model.player.CurrentUser;
	import com.service.ExternalInterfaceAPI;
	import com.service.server.outgoing.proxy.ProxyReportCrashRequest;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;
	import org.zlibfromscratch.ZlibDecoder;
	import org.zlibfromscratch.ZlibDecoderError;

	public class TinCan
	{
		public static const CONNECTED:int         = 0;
		public static const CONNECTION_LOST:int   = 1;
		public static const CONNECTION_FAILED:int = 2;
		public static const GAME:int              = 0;
		public static const CHAT:int              = 1;

		private const _logger:ILogger             = getLogger("TinCan");
		private var _connectionSignal:Signal;
		private var _i:BinaryInputStream;
		private var _o:BinaryInputStream;
		private var _ip:String;
		private var _port:int;
		private var _devConnection:Boolean;
		private var _fullSize:uint 				  = 0;
		private var _simRead:int 				  = 0;
		private var _simWrite:int 				  = 0;
		private var _lockRead:int                 = 0;
		private var _protocolListener:int         = -1;
		private var _responseSignal:Signal;
		private var _serverController:ServerController;
		private var _zlibDecoderBuffer:ByteArray;
		private var _zlibDecoder:ZlibDecoder;
		private var _socket:Socket;
		private var _waitingResponseSize:uint     = 0;

		public function init( ip:String, port:int, policy:String, type:int, devConnection:Boolean = false ):void
		{
			_devConnection = devConnection;
			_connectionSignal = new Signal(int);
			_i = new BinaryInputStream();
			_o = new BinaryInputStream();
			_responseSignal = new Signal(IResponse);

			Security.loadPolicyFile(policy);

			_zlibDecoderBuffer = new ByteArray();
			_zlibDecoderBuffer.endian = Endian.BIG_ENDIAN;
			_zlibDecoder = new ZlibDecoder();

			_socket = new Socket();
			_socket.endian = Endian.BIG_ENDIAN;

			_socket.addEventListener(Event.CONNECT, onConnect);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, onReceive);
			_socket.addEventListener(Event.CLOSE, onClose);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);

			_ip = ip;
			_port = port;
			_logger.info('Connecting to {0}:{1}', [_ip, _port]);

			connectToServer();
		}

		public function connectToServer():void
		{
			//close the current connection and connect to the new server
			if (_socket.connected)
			{
				_socket.readBytes(new ByteArray(), _socket.bytesAvailable);
				_socket.close();
			}

			_zlibDecoder.reset(false, false);
			_socket.connect(_ip, _port);
		}

		private function onConnect( e:Event ):void
		{
			_logger.info('Connected to {0}:{1}', [_ip, _port]);
			_connectionSignal.dispatch(CONNECTED);
		}

		public function send( request:IRequest ):void
		{
			if (!active)
			{
				_logger.error("Cannot send message, not connected to server!");
				return;
			}
			
			if(_simWrite>0)
			{
				_logger.error("This IO is already in use!");
				return;
			}
			
			_simWrite++;

			//clear out the old data
			_i.clear();
			request.write(_i);
			_socket.writeShort(_i.length + 2);
			_socket.writeBytes(_i);
			_socket.flush();
			ObjectPool.give(request);
			
			_simWrite--;
		}

		private function onReceive( e:ProgressEvent ):void
		{
			if (_lockRead > 0)
				return;
			
			if(_simRead>0)
			{
				_logger.error("This IO is already in use!");
				return;
			}
			
			_simRead++;
			
			do
			{
				var size:uint;
				if (_waitingResponseSize > 0)
				{
					size = _waitingResponseSize;
				} else
				{
					_o.clear();
					if (_socket.bytesAvailable >= 4)
					{
						size = _socket.readUnsignedInt() - 4;
						_fullSize = size;
					}
					else
						break;
				}
				if(_socket.bytesAvailable >= 62000)
				{
					_logger.error("This IO is broken!");
				}
				if (_socket.bytesAvailable >= 0)
				{
					var waitingByteSize:uint = Math.min(_socket.bytesAvailable,size);
					_socket.readBytes(_o, _o.bytesAvailable, waitingByteSize);
					size -= waitingByteSize;
					
					if(size<0)
					{
						_logger.error("TinCan - Critical input error!");
						return;
					}
					if (size == 0)
					{
						//_socket.readBytes(_o, 0, size);
						var protocolID:int = _o.readByte();
						var speakerID:int  = _o.readByte();
						var header:int     = _o.readByte();
						var encoding:int   = _o.readByte();
						if (encoding == EncodingEnum.BINARYZLIBCOMPRESSED)
						{
							// Read compressed input into _zlibDecoderBuffer.
							_zlibDecoderBuffer.length = _o.bytesAvailable + 4;
							_zlibDecoderBuffer.position = 0;
							_o.readBytes(_zlibDecoderBuffer,0, _o.bytesAvailable);
	
							// Append the zlib sync-flush byte sequence.
							_zlibDecoderBuffer.position = _zlibDecoderBuffer.length - 4;
							_zlibDecoderBuffer.writeByte(0x00);
							_zlibDecoderBuffer.writeByte(0x00);
							_zlibDecoderBuffer.writeByte(0xff);
							_zlibDecoderBuffer.writeByte(0xff);
	
							// Uncompress the input to _io.
							_zlibDecoderBuffer.position = 0;
							_o.clear();
							var bytesRead:uint = _zlibDecoder.feed(_zlibDecoderBuffer, _o);
							if (bytesRead != _zlibDecoderBuffer.length || (_zlibDecoder.lastError != ZlibDecoderError.NEED_MORE_DATA && _zlibDecoder.lastError != ZlibDecoderError.NO_ERROR))
								throw new Error("Failed to uncompress network message");
	
							_o.position = 0;
							encoding = EncodingEnum.BINARY;
						}
						if (_protocolListener == -1 || _protocolListener == protocolID || PacketFactory.isImportant(protocolID, header))
						{
							var ioLength:uint = _o.length;
							var response:IResponse = PacketFactory.getResponse(_o, protocolID, header, encoding);
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
						//break;
					}
				}
			} while (active && _socket.bytesAvailable > 0);
			
			_simRead--;
		}

		private function unknownMessage( header:int ):void
		{
			_logger.error("Unknown Message Received {0}, {1}, {2}", [header, _socket.bytesAvailable, _socket.readUTFBytes(_socket.bytesAvailable)]);
		}

		private function onClose( e:Event ):void
		{
			_logger.info('Connection to {0}:{1} closed', [_ip, _port]);
			_connectionSignal.dispatch(CONNECTION_LOST);
		}

		protected function sendFailed( reason:String ):void
		{
			var myrequest:URLRequest = new URLRequest("https://" + ExternalInterfaceAPI.getLoginHostname() + "/" + reason + CurrentUser.id);
			myrequest.method = URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, postTo80Error, false, 0, true);
			loader.load(myrequest);
			_logger.info('sendFailed - Failed Message Sent To "https://{1}:80/{2}{3}', [ExternalInterfaceAPI.getLoginHostname(), reason, CurrentUser.id]);
		}

		private function postTo80Error( e:IOErrorEvent ):void
		{
			e.stopImmediatePropagation();
		}

		private function onError( e:IOErrorEvent ):void
		{
			_logger.error('IOError on connection to {0}:{1} {2}', [_ip, _port, e.toString()]);

			if (_devConnection && _port < 20020)
			{
				++_port;
				connectToServer();
			}

			if (CONFIG::DEBUG)
				_connectionSignal.dispatch(CONNECTED);
			else
			{
				sendFailed("Failed-to-connect-to-proxy-ioerror-");
				_connectionSignal.dispatch(CONNECTION_FAILED);
				connectToServer();
			}
		}

		private function onSecurityError( e:SecurityErrorEvent ):void
		{
			_logger.error('Security error on connection to {0}:{1} {2}', [_ip, _port, e.toString()]);
			sendFailed("Failed-to-connect-to-proxy-securityerror-");
		}

		public function addConnectionListener( callback:Function ):void  { _connectionSignal.add(callback); }
		public function removeConnectionListener( callback:Function ):void  { _connectionSignal.remove(callback); }

		public function addResponseListener( callback:Function ):void  { _responseSignal.add(callback); }
		public function removeResponseListener( callback:Function ):void  { _responseSignal.remove(callback); }

		public function get active():Boolean  { return (_socket) ? _socket.connected : false; }

		public function set lockRead( v:Boolean ):void
		{
			_lockRead += v ? 1 : -1;
			if (_lockRead == 0 && _socket && _socket.connected && _socket.bytesAvailable > 0)
				onReceive(null);
		}

		public function get protocolListener():int  { return _protocolListener; }
		public function set protocolListener( v:int ):void  { _protocolListener = v; }
		public function set serverController( value:ServerController ):void  { _serverController = value; }

		public function destroy():void
		{
			if (_socket.connected)
			{
				_socket.readBytes(new ByteArray(), _socket.bytesAvailable);
				_socket.close();
			}

			_socket.removeEventListener(Event.CONNECT, onConnect);
			_socket.removeEventListener(ProgressEvent.SOCKET_DATA, onReceive);
			_socket.removeEventListener(Event.CLOSE, onClose);
			_socket.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);

			_zlibDecoder.dispose();
			_zlibDecoder = null;
			_zlibDecoderBuffer.clear();
			_zlibDecoderBuffer = null;

			_connectionSignal.removeAll();
			_connectionSignal = null;
			_o.clear();
			_o = null;
			_i.clear();
			_i = null;
			_responseSignal.removeAll();
			_responseSignal = null;
			_serverController = null;
			_socket = null;
		}

	}
}
