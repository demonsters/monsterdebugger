package com.demonsters.debugger
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;


	public class MonsterDebuggerHistory
	{

		// Recents
		public static var items:Vector.<MonsterDebuggerHistoryItem> = new Vector.<MonsterDebuggerHistoryItem>();	


		/**
		 * Load the history
		 */
		public static function load():void
		{
			// Clear vector
			items.length = 0;

			// Path to the settings xml
			var file:File = File.applicationStorageDirectory.resolvePath("history.xml");

			// Check if the file is there
			if (file.exists) {

				// Read the XML
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				var fileXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
				fileStream.close();

				// Loop through the XML
				var itemXML:XMLList = fileXML..item;
				for (var i:int = 0; i < itemXML.length(); i++) {

					// Add item
					var item:MonsterDebuggerHistoryItem = new MonsterDebuggerHistoryItem();
					item.name = String(itemXML[i].@name);
					item.location = String(itemXML[i].@location);
					item.path = String(itemXML[i].@path);
					item.isFlex = (String(itemXML[i].@isFlex) == "true") ? true : false;
					item.isWebsite = (String(itemXML[i].@isWebsite) == "true") ? true : false;
					items[items.length] = item;
				}
			}
		}


		/**
		 * Add an item
		 */
		public static function add(client:IMonsterDebuggerClient):void
		{
			// Return if no location is known
			if (client.fileLocation == null || client.fileLocation == "") {
				return;
			}
			
			// Check for doubles
			for (var i:int = 0; i < items.length; i++) {
				if (items[i].location == client.fileLocation || encodeURI(items[i].location) == encodeURI(client.fileLocation)) {
					items.splice(i, 1);
				}
			}

			// Website
			if ( client.fileLocation.indexOf("http://") == 0 || client.fileLocation.indexOf("https://") == 0) {

				// Add
				var itemWeb:MonsterDebuggerHistoryItem = new MonsterDebuggerHistoryItem();
				itemWeb.path = client.fileLocation;
				itemWeb.location = client.fileLocation;
				itemWeb.name = client.fileTitle;
				itemWeb.isFlex = client.isFlex;
				itemWeb.isWebsite = true;
				items.unshift(itemWeb);
				if (items.length > 10) {
					items.length = 10;
				}
				return;
			}

			// File
			var file:File = new File(client.fileLocation);
			if (file.exists) {
				
				// Add
				var itemFile:MonsterDebuggerHistoryItem = new MonsterDebuggerHistoryItem();
				itemFile.path = file.nativePath;
				itemFile.location = client.fileLocation;
				itemFile.name = client.fileTitle;
				itemFile.isFlex = client.isFlex;
				itemFile.isWebsite = false;
				items.unshift(itemFile);
				if (items.length > 10) {
					items.length = 10;
				}
				return;
			}
		}


		/**
		 * Save history
		 */
		public static function save():void
		{
			var fileXML:XML = new XML("<items/>");
			var itemXML:XML;

			// Create the xml
			for (var i:int = 0; i < items.length; i++) {
				itemXML = new XML("<item/>");
				itemXML.@name = items[i].name;
				itemXML.@location = items[i].location;
				itemXML.@path = items[i].path;
				itemXML.@isFlex = String(items[i].isFlex);
				itemXML.@isWebsite = String(items[i].isWebsite);
				fileXML.appendChild(itemXML);
			}

			// Save settings
			var file:File = File.applicationStorageDirectory.resolvePath("history.xml");
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(fileXML.toXMLString());
			fileStream.close();
		}


	}
}