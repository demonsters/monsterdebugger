package com.demonsters.debugger
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Screen;
	import flash.geom.Point;
	import flash.net.SharedObject;


	final public class MonsterDebuggerUtils
	{

		/**
		 * Strip the breaks from a string
		 * @param s: The string to strip
		 */
		public static function stripBreaks(s:String):String
		{
			s = s.replace("\n", " ");
			s = s.replace("\r", " ");
			s = s.replace("\t", " ");
			return s;
		}


		/**
		 * Converts HTML characters to regular characters
		 * @param s: The string to convert
		 */
		public static function htmlUnescape(s:String):String
		{
			if (s) {
				// Remove html elements
				if (s.indexOf("&apos;") != -1) {
					s = s.split("&apos;").join("\'");
				}
				if (s.indexOf("&quot;") != -1) {
					s = s.split("&quot;").join("\"");
				}
				if (s.indexOf("&lt;") != -1) {
					s = s.split("&lt;").join("<");
				}
				if (s.indexOf("&gt;") != -1) {
					s = s.split("&gt;").join(">");
				}
				if (s.indexOf("&amp;") != -1) {
					s = s.split("&amp;").join("&");
				}

				var xml:XML = <a/>;
				xml.replace(0, s);
				return String(xml);
			} else {
				return "";
			}
		}
		
		
		/**
		 * Load window settings and show window
		 */
		public static function loadWindowOptions(window:NativeWindow, id:String):void
		{
			// Get the preferences
			var so:SharedObject = SharedObject.getLocal(id);
			
			// Check if there is any data saved
			if (so.data["saved"] == true)
			{
				// Bug with minimize and close:
				// If you close a minimized window in Windows
				// The x and y values are -32000
				if (so.data["x"] != null) window.x = so.data["x"];
				if (so.data["y"] != null) window.y = so.data["y"];
				if (so.data["width"] != null) window.width = so.data["width"];
				if (so.data["height"] != null) window.height = so.data["height"];
			}

			// First check if the window is on a screen
			// If not we resize the window to match the main screen size
			// Then we center the window on the main screen
			var screen:Screen = getScreenUnderPoint(new Point(window.x, window.y));
			if (screen == null) {
				screen = Screen.mainScreen;
			}
			
			// Check if the window is in a screen
			if (window.x + window.width < screen.bounds.x || window.x > screen.bounds.x + screen.bounds.width) {
				if (window.width > screen.bounds.width) {
					window.width = screen.bounds.width;
				}
				window.x = int((screen.bounds.width - window.width) * 0.5);
			}
			if (window.y + window.height < screen.bounds.y || window.y > screen.bounds.y + screen.bounds.height) {
				if (window.height > screen.bounds.height) {
					window.height = screen.bounds.height;
				}
				window.y = int((screen.bounds.height - window.height) * 0.5);
			}
			
			// Show window
			window.visible = true;
			window.activate();
			if (so.data["maximized"] == true) {
				window.maximize();
			}

			// Save SO
			saveWindowOptions(window, id);
		}
		
		
		/**
		 * Allign to screen
		 */
		public static function saveWindowOptions(window:NativeWindow, id:String):void
		{
			// Get the preferences
			var so:SharedObject = SharedObject.getLocal(id);
			
			// Save the data
			if (!window.closed) {
				
				// Check for maximized or minimized options
				if (window.displayState == NativeWindowDisplayState.MAXIMIZED) {
					so.data["maximized"] = true;
				} else if (window.displayState == NativeWindowDisplayState.NORMAL) {
			 		so.data["maximized"] = false;
			 		so.data["x"] = window.x;
					so.data["y"] = window.y;
			 		so.data["width"] = window.width;
					so.data["height"] = window.height;
				}
				
				// Save
				so.data["saved"] = true;
				so.flush();
			}
		}
		
		
		/**
		 * Get the screen under a point
		 */
		public static function getScreenUnderPoint(point:Point):Screen
		{
			var screens:Array = Screen.screens;
			for (var i:int = 0; i < screens.length; i++) {
				var screen:Screen = screens[i];
				if (screen.bounds.containsPoint(point)) {
					return screen;
				}
			}
			return null;
		}
	}
}