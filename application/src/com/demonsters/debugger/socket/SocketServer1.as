package com.demonsters.debugger.socket
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.events.TimerEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;


	/**
	 * This is the new server
	 * running on port 5840
	 */
	public class SocketServer1
	{

		// Properties
		private static var _port:int;
		private static var _server:ServerSocket;
		private static var _clients:Dictionary;
		private static var _dispatcher:EventDispatcher;
		private static var _timer:Timer;
		
		
		// Callback functions
		// Format: onClientConnect(client:MonsterDebuggerClient, uid:String):void;
		public static var onClientConnect:Function;


		/**
		 * Start the server
		 */
		public static function initialize():void
		{
			// Start the server
			_port = 5840;
			_clients = new Dictionary();
			_server = new ServerSocket();
			_dispatcher = new EventDispatcher();
			_server.addEventListener(Event.CONNECT, onConnect, false, 0, false);
			_timer = new Timer(500, 1);
			_timer.addEventListener(TimerEvent.TIMER, bind, false, 0, false);

			bind();
		}
		
		
		/**
		 * Stop server
		 */
		public static function stop():void {
			if (_server) {
				_server.close();
				_server = null;
			}
		}
		

		private static function bind(e:TimerEvent = null):void
		{
			if (_server.bound) {
				_server.close();
				_server = new ServerSocket();
				_server.addEventListener(Event.CONNECT, onConnect, false, 0, false);
			}
			try {
				_server.bind(_port, "0.0.0.0");
				_server.listen();
			} catch(e:Error) {
				_timer.reset();
				_timer.start();
			}
		}


		/**
		 * Socket error
		 */
		public static function send(uid:String, id:String, data:Object):void
		{
			for (var client:Object in _clients) {
				if (_clients[client] == uid) {
					SocketClient(client).send(id, data);
				}
			}
		}
		

		/**
		 * Socket connected
		 */
		private static function onConnect(event:ServerSocketConnectEvent):void
		{
			// Accept socket
			var socket:Socket = event.socket;
			socket.addEventListener(Event.CLOSE, disconnect, false, 0, false);
			socket.addEventListener(IOErrorEvent.IO_ERROR, disconnect, false, 0, false);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, disconnect, false, 0, false);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler, false, 0, false);
		}


		/**
		 * Socket received the first data
		 */
		private static function dataHandler(event:ProgressEvent):void
		{
			// Get the socket
			var socket:Socket = event.target as Socket;

			// Read the bytes
			var bytes:ByteArray = new ByteArray;
			socket.readBytes(bytes, 0, socket.bytesAvailable);
			bytes.position = 0;

			// Read the command
			var command:String = bytes.readUTFBytes(bytes.bytesAvailable);
			
			// Check XML crossdomain request
			if (command == "<policy-file-request/>") {
				
				// Write the policy file
				var xml:ByteArray = new ByteArray();
				xml.writeUTFBytes('<?xml version="1.0"?>');
				xml.writeUTFBytes('<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">');
				xml.writeUTFBytes('<cross-domain-policy xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.adobe.com/xml/schemas/PolicyFile.xsd">');
				xml.writeUTFBytes('<site-control permitted-cross-domain-policies="master-only"/>');
				xml.writeUTFBytes('<allow-access-from domain="*" to-ports="*" secure="false"/>');
				xml.writeUTFBytes('<allow-http-request-headers-from domain="*" headers="*" secure="false"/>');
				xml.writeUTFBytes('</cross-domain-policy>');
				xml.writeByte(0);
				xml.position = 0;
				socket.writeBytes(xml, 0, xml.bytesAvailable);
				socket.flush();
				return;
			}

			// Configure wrapper
			socket.removeEventListener(Event.CLOSE, disconnect);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, disconnect);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, disconnect);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);

			// Create a new client
			var client:SocketClient = new SocketClient(socket);
			client.onStart = startClient;
			client.onDisconnect = removeClient;

			// Save client
			_clients[client] = {};
		}


		/**
		 * Client is started and ready for a tab
		 * THIS IS A CALLBACK FUNCTION
		 */
		private static function startClient(client:SocketClient):void
		{
			// Connect
			if (onClientConnect != null) {
				onClientConnect(client);
			}
		}
		

		/**
		 * Client is done
		 * THIS IS A CALLBACK FUNCTION
		 */
		private static function removeClient(client:SocketClient):void
		{
			client.onData = null;
			client.onStart = null;
			client.onDisconnect = null;
			if (client in _clients) {
				_clients[client] = null;
				delete _clients[client];
			}
		}


		/**
		 * Socket error
		 */
		private static function disconnect(event:Event):void
		{
			var socket:Socket = event.target as Socket;
			socket.removeEventListener(Event.CLOSE, disconnect);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, disconnect);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, disconnect);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			socket = null;
		}
	}
}