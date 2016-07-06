package com.demonsters.debugger.netgroup
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.Dictionary;


	public class NetgroupServer
	{

		// Group pin
		private static const PIN:String = "monsterdebugger";
		
		
		// Properties
		private static var _clients:Dictionary;
		private static var _dispatcher:EventDispatcher;
		
		
		// Connection properties
		private static var _multiCastIP:String = "225.225.0.1";
		private static var _multiCastPort:String = "58000";
		private static var _connection:NetConnection;
		private static var _group:NetGroup;
		private static var _id:String;
		
		
		// Callback functions
		// Format: onClientConnect(client:MonsterDebuggerClient, uid:String):void;
		public static var onClientConnect:Function;


		/**
		 * Start the server
		 */
		public static function initialize():void
		{
			// Start the server
			_clients = new Dictionary();
			_dispatcher = new EventDispatcher();
			
			// Create rtfmp
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			_connection.connect('rtmfp:');
		}
		
		
		/**
		 * Stop server
		 */
		public static function stop():void {
			if (_connection) {
				_connection.close();
				_connection = null;
			}
		}
		

		/**
		 * Called whenever something happens on the peer-to-peer connection.
		 * Once the connection is established a group is joined.
		 * Once the group was joined, we setup messaging.
		 */
		private static function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					joinGroup();
					break;
				case "NetGroup.Connect.Success":
					_id = _group.convertPeerIDToGroupAddress(_connection.nearID);
					break;
			}
		}


		/**
		 * Creates a new or joins an existing NetGroup on the peer-2-peer connection
		 * that allows multicast communication.
		 */
		private static function joinGroup():void
		{
			// Create group specifications
			var groupSpec:GroupSpecifier = new GroupSpecifier(PIN);
			groupSpec.ipMulticastMemberUpdatesEnabled = true;
			groupSpec.routingEnabled = true;
			groupSpec.addIPMulticastAddress(_multiCastIP + ':' + _multiCastPort);

			// Create a new net group to receive posts
			_group = new NetGroup(_connection, groupSpec.groupspecWithoutAuthorizations());
			_group.addEventListener(NetStatusEvent.NET_STATUS, onGroupUpdates, false, 0, true);
		}


		/**
		 * Called whenever something happens in the group we've joined on the peer-to-peer
		 * group. Other neighbors messages are being evaluated and we send out our own
		 * address as soon as we join successfully.
		 */
		private static function onGroupUpdates(event:NetStatusEvent):void
		{
			switch (event.info.code) {
				case "NetGroup.Neighbor.Connect":
					
					// Create a new client
					var client:NetgroupClient = new NetgroupClient(_group, event.info.neighbor);
					client.onStart = startClient;
					client.onDisconnect = removeClient;
					
					// Save client
					_clients[client] = {};
					break;
			}
		}


		/**
		 * Socket error
		 */
		public static function send(uid:String, id:String, data:Object):void
		{
			for (var client:Object in _clients) {
				if (_clients[client] == uid) {
					NetgroupClient(client).send(id, data);
				}
			}
		}


		/**
		 * Client is started and ready for a tab
		 * THIS IS A CALLBACK FUNCTION
		 */
		private static function startClient(client:NetgroupClient):void
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
		private static function removeClient(client:NetgroupClient):void
		{
			client.onData = null;
			client.onStart = null;
			client.onDisconnect = null;
			if (client in _clients) {
				_clients[client] = null;
				delete _clients[client];
			}
		}

	}
}