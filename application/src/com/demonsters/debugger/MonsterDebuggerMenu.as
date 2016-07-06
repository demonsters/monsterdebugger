package com.demonsters.debugger
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;


	/**
	 * Static class that handles the native menu content and the global key handling
	 */
	public class MonsterDebuggerMenu extends EventDispatcher
	{

		public static const SAVE:String = "save";
		public static const SAVE_AS:String = "saveAs";
		
		public static const NEXT_TAB:String = "nextTab";
		public static const PREVIOUS_TAB:String = "previousTab";
		
		public static const CLOSE_TAB:String = "closeTab";

		public static const EXPORT_CLIENT_SWC:String = "exportclientclasses";
		public static const EXPORT_CLIENT_MOBILE_SWC:String = "exportclientswc";
	
		public static const TOGGLE_TRACE_VIEW:String = "toggletraceview";
		public static const TOGGLE_INSPECTOR:String = "toggleinspectorview";		
		public static const TOGGLE_BREAKPOINT_VIEW:String = "togglebreakpointview"; 
		public static const TOGGLE_MEMORY_MONITOR_VIEW:String = "togglememorymonitorview";

		public static const CLEAR_TRACES:String = "cleartraces";
		public static const ALWAYS_ON_TOP:String = "alwaysontop";
		public static const HIGHLIGHT_INSPECT:String = "highlightinspect";
		
		public static const HELP_WINDOW:String = "helpwindow";
		public static const DEBUGGER_GAME:String = "debuggerGame";
		public static const ABOUT_MONSTERS:String = "aboutmonsters";
		public static const PRODUCT_WEBSITE:String = "productwebsite";
		public static const FEEDBACK:String = "feedback";
		public static const AS3_REFERENCE:String = "as3reference";
		public static const AS3_RUNTIME_ERRORS:String = "as3runtimeerrors";
		public static const RIA_GUIDE:String = "riaguide";
		public static const FLASH_PLAYERS:String = "flashplayers";

		
		
		// The main menu item
		private static var _nativeMenu:NativeMenu;


		// Menu
		public static var toggleTraceViewMenuItem:NativeMenuItem;
		public static var toggleLiveApplicationViewMenuItem:NativeMenuItem;
		public static var toggleBreakpointsViewMenuItem:NativeMenuItem;
		public static var toggleMonitorViewMenuItem:NativeMenuItem;

		private static var _fileMenu:NativeMenuItem;
		private static var _viewMenu:NativeMenuItem;
		private static var _windowMenu:NativeMenuItem;
		private static var _helpMenu:NativeMenuItem;

		private static var _exportClientSWC:NativeMenuItem;
		private static var _exportClientMobileSWC:NativeMenuItem;
		private static var _closeTabItem:NativeMenuItem;
		private static var _closeWindowItem:NativeMenuItem;

		private static var _nextTab:NativeMenuItem;
		private static var _previousTab:NativeMenuItem;
		private static var _clearTracesMenuItem:NativeMenuItem;
		private static var _highlightInspect:NativeMenuItem;

		private static var _helpSubMenuItem:NativeMenuItem;
		private static var _aboutMenuItem:NativeMenuItem;
		private static var _websiteMenuItem:NativeMenuItem;
		private static var _feedbackMenuItem:NativeMenuItem;
		private static var _documentationSubMenuItem:NativeMenuItem;

		private static var _as3RefMenuItem:NativeMenuItem;
		private static var _as3RunMenuItem:NativeMenuItem;
		private static var _riaGuideMenuItem:NativeMenuItem;
		private static var _playersMenuItem:NativeMenuItem;

		private static var _onTopMenuItem:NativeMenuItem;
		private static var _saveMenuItem:NativeMenuItem;
		private static var _saveAsMenuItem:NativeMenuItem;
		private static var _gameMenuItem:NativeMenuItem;


		// Dispatcher
		private static var _dispatcher:EventDispatcher = new EventDispatcher();

		
		// Main window
		private static var _mainWindow:NativeWindow;
		

		/**
		 * Initialize the menu
		 */
		public static function initialize(mainWindow:NativeWindow):void
		{
			_mainWindow = mainWindow;
			if (Capabilities.os.substr(0, 3) == "Mac") {
				createNativeMacMenu();
				_mainWindow.addEventListener(Event.ACTIVATE, focusMainWindow, false, 0, false);
				_mainWindow.addEventListener(Event.DEACTIVATE, unfocusMainWindow, false, 0, false);
			} else {
				_mainWindow.menu = createTopMenu();
			}
		}
		
		
		/**
		 * Get the main window
		 */
		public static function get mainWindow():NativeWindow {
			return _mainWindow;
		}
		

		/**
		 * When the main window gain focus
		 */
		private static function focusMainWindow(event:Event):void
		{
			if (_closeTabItem != null) {
				_closeTabItem.label = "Close Tab";
			}
		}


		/**
		 * When the main window loses the focus
		 */
		private static function unfocusMainWindow(event:Event):void
		{
			if (_closeTabItem != null) {
				_closeTabItem.label = "Close Window";
			}
		}


		public static function createTopMenu():NativeMenu
		{
			_nativeMenu = new NativeMenu();

			_fileMenu = new NativeMenuItem("File");
			_fileMenu.data = "file";
			_fileMenu.submenu = createFileMenu();
			_nativeMenu.addItem(_fileMenu);

			_viewMenu = new NativeMenuItem("View");
			_viewMenu.data = "view";
			_viewMenu.submenu = createViewMenu();
			_nativeMenu.addItem(_viewMenu);
			
			_windowMenu = new NativeMenuItem("Window");
			_windowMenu.data = "window";
			_windowMenu.submenu = createWindowMenu();
			_nativeMenu.addItem(_windowMenu);
			
			_helpMenu = new NativeMenuItem("Help");
			_helpMenu.data = "help";
			_helpMenu.submenu = createHelpMenu();
			_nativeMenu.addItem(_helpMenu);

			return _nativeMenu;
		}


		public static function createNativeMacMenu():NativeMenu
		{
			var menu:NativeMenu = NativeApplication.nativeApplication.menu;
			
			// About
			var nativeMenu:NativeMenuItem = menu.getItemAt(0);
			nativeMenu.submenu.removeItemAt(0);
			var aboutMenu:NativeMenuItem = new NativeMenuItem("About Monster Debugger");
			aboutMenu.addEventListener(Event.SELECT, function(e:Event):void {
				_dispatcher.dispatchEvent(new Event(ABOUT_MONSTERS));
			});
			nativeMenu.submenu.addItemAt(aboutMenu, 0);
			
			// Retrieve File menu
			var fileMenuItem:NativeMenuItem = new NativeMenuItem("File");
			fileMenuItem.submenu = createFileMenu();
			menu.removeItemAt(1);
			menu.addItemAt(fileMenuItem, 1);

			// Create View menu
			var viewMenuItem:NativeMenuItem = new NativeMenuItem("View1");
			viewMenuItem.submenu = createViewMenu();
			menu.addItemAt(viewMenuItem, 3);

			_windowMenu = new NativeMenuItem("Window");
			_windowMenu.submenu = createMacWindowMenu();
			menu.removeItemAt(4);
			menu.addItemAt(_windowMenu, 4);

			// Create help menu
			var helpMenuItem:NativeMenuItem = new NativeMenuItem("Help");
			helpMenuItem.submenu = createHelpMenu();
			menu.addItem(helpMenuItem);

			return menu;
		}


		public static function enableSaveItem(saveAs:Boolean = false):void
		{
			if (_saveMenuItem) {
				_saveMenuItem.enabled = true;
				if (saveAs) {
					_saveAsMenuItem.enabled = true;
				}
			}
		}


		public static function disableSaveItem(saveAs:Boolean = false):void
		{
			if (_saveMenuItem) {
				_saveMenuItem.enabled = false;
				if (saveAs) {
					_saveAsMenuItem.enabled = false;
				}
			}
		}


		private static function createFileMenu():NativeMenu
		{
			var menuFile:NativeMenu = new NativeMenu();

			if (Capabilities.os.substr(0, 3) == "Mac") {
				_saveMenuItem = new NativeMenuItem("Save");
				_saveMenuItem.data = new Event(SAVE);
				_saveMenuItem.keyEquivalent = "s";
				_saveMenuItem.enabled = false;
				_saveMenuItem.addEventListener(Event.SELECT, eventHandler);
				menuFile.addItem(_saveMenuItem);

				_saveAsMenuItem = new NativeMenuItem("Save As");
				_saveAsMenuItem.data = new Event(SAVE_AS);
				_saveAsMenuItem.keyEquivalent = "S";
				_saveAsMenuItem.enabled = false;
				_saveAsMenuItem.addEventListener(Event.SELECT, eventHandler);
				menuFile.addItem(_saveAsMenuItem);

				// Separator
				menuFile.addItem(new NativeMenuItem("", true));
			}

			_exportClientSWC = new NativeMenuItem("Export SWC");
			_exportClientSWC.data = new Event(EXPORT_CLIENT_SWC);
			_exportClientSWC.addEventListener(Event.SELECT, eventHandler);
			menuFile.addItem(_exportClientSWC);

			_exportClientMobileSWC = new NativeMenuItem("Export Mobile SWC");
			_exportClientMobileSWC.data = new Event(EXPORT_CLIENT_MOBILE_SWC);
			_exportClientMobileSWC.addEventListener(Event.SELECT, eventHandler);
			menuFile.addItem(_exportClientMobileSWC);
			
			menuFile.addItem(new NativeMenuItem("", true));

			_closeTabItem = new NativeMenuItem("Close Tab");
			_closeTabItem.data = new Event(CLOSE_TAB);
			_closeTabItem.addEventListener(Event.SELECT, closeTabHandler);
			_closeTabItem.keyEquivalent = "w";
			menuFile.addItem(_closeTabItem);

			if (Capabilities.os.substr(0, 3) != "Mac") {
				_closeWindowItem = new NativeMenuItem("Close");
				_closeWindowItem.addEventListener(Event.SELECT, closeApplicationHandler);
				menuFile.addItem(_closeWindowItem);
			}

			return menuFile;
		}


		public static function createViewMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();

			toggleLiveApplicationViewMenuItem = new NativeMenuItem("Show Application view");
			toggleLiveApplicationViewMenuItem.data = new Event(TOGGLE_INSPECTOR, true);
			toggleLiveApplicationViewMenuItem.checked = true;
			toggleLiveApplicationViewMenuItem.keyEquivalent = "1";
			toggleLiveApplicationViewMenuItem.addEventListener(Event.SELECT, toggleCheckedHandler);
			menu.addItem(toggleLiveApplicationViewMenuItem);

			toggleBreakpointsViewMenuItem = new NativeMenuItem("Show Breakpoint panel");
			toggleBreakpointsViewMenuItem.data = new Event(TOGGLE_BREAKPOINT_VIEW, true);
			toggleBreakpointsViewMenuItem.checked = true;
			toggleBreakpointsViewMenuItem.keyEquivalent = "2";
			toggleBreakpointsViewMenuItem.addEventListener(Event.SELECT, toggleCheckedHandler);
			menu.addItem(toggleBreakpointsViewMenuItem);

			toggleMonitorViewMenuItem = new NativeMenuItem("Show Memory panel");
			toggleMonitorViewMenuItem.data = new Event(TOGGLE_MEMORY_MONITOR_VIEW, true);
			toggleMonitorViewMenuItem.checked = true;
			toggleMonitorViewMenuItem.keyEquivalent = "3";
			toggleMonitorViewMenuItem.addEventListener(Event.SELECT, toggleCheckedHandler);
			menu.addItem(toggleMonitorViewMenuItem);

			toggleTraceViewMenuItem = new NativeMenuItem("Show Trace panel");
			toggleTraceViewMenuItem.data = new Event(TOGGLE_TRACE_VIEW, true);
			toggleTraceViewMenuItem.checked = true;
			toggleTraceViewMenuItem.keyEquivalent = "4";
			toggleTraceViewMenuItem.addEventListener(Event.SELECT, toggleCheckedHandler);
			menu.addItem(toggleTraceViewMenuItem);

			// Separator
			menu.addItem(new NativeMenuItem("", true));

			_nextTab = new NativeMenuItem("Next Tab");
			_nextTab.data = new Event(NEXT_TAB, true);
			_nextTab.keyEquivalent = "]";
			_nextTab.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_nextTab);

			_previousTab = new NativeMenuItem("Previous Tab");
			_previousTab.data = new Event(PREVIOUS_TAB, true);
			_previousTab.keyEquivalent = "[";
			_previousTab.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_previousTab);

			// Separator
			menu.addItem(new NativeMenuItem("", true));

			// Clear traces
			_clearTracesMenuItem = new NativeMenuItem("Clear Traces");
			_clearTracesMenuItem.keyEquivalent = "e";
			_clearTracesMenuItem.data = new Event(CLEAR_TRACES, true);
			_clearTracesMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_clearTracesMenuItem);

			_highlightInspect = new NativeMenuItem("Highlight & Inspect");
			_highlightInspect.keyEquivalent = "h";
			_highlightInspect.data = new Event(HIGHLIGHT_INSPECT, true);
			_highlightInspect.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_highlightInspect);

			return menu;
		}


		private static function createHelpMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();

			// Debugger Help
			_helpSubMenuItem = new NativeMenuItem("Debugger Help");
			_helpSubMenuItem.data = new Event(HELP_WINDOW, true);
			_helpSubMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_helpSubMenuItem);

			_gameMenuItem = new NativeMenuItem("Debugger Game");
			_gameMenuItem.data = new Event(DEBUGGER_GAME, true);
			_gameMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_gameMenuItem);

			// Separator
			menu.addItem(new NativeMenuItem("", true));

			// Debugger Help
			_documentationSubMenuItem = new NativeMenuItem("Online documentation");
			_documentationSubMenuItem.submenu = createDocumentationMenu();
			menu.addItem(_documentationSubMenuItem);

			// Separator
			menu.addItem(new NativeMenuItem("", true));

			if (Capabilities.os.substr(0, 3) != "Mac") {
				_aboutMenuItem = new NativeMenuItem("About");
				_aboutMenuItem.data = new Event(ABOUT_MONSTERS, true);
				_aboutMenuItem.addEventListener(Event.SELECT, eventHandler);
				menu.addItem(_aboutMenuItem);
			}

			_websiteMenuItem = new NativeMenuItem("Product Website");
			_websiteMenuItem.data = new Event(PRODUCT_WEBSITE, true);
			_websiteMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_websiteMenuItem);

			_feedbackMenuItem = new NativeMenuItem("Feedback");
			_feedbackMenuItem.data = new Event(FEEDBACK, true);
			_feedbackMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_feedbackMenuItem);

			return menu;
		}


		private static function createMacWindowMenu():NativeMenu
		{
			var menu:NativeMenu = NativeApplication.nativeApplication.menu.getItemAt(4).submenu;
			_onTopMenuItem = new NativeMenuItem("Always on top");
			_onTopMenuItem.checked = false;
			_onTopMenuItem.data = new Event(ALWAYS_ON_TOP, true);
			_onTopMenuItem.addEventListener(Event.SELECT, toggleCheckedHandler);
			menu.addItemAt(_onTopMenuItem, 3);
			return menu;
		}


		private static function createWindowMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();
			_onTopMenuItem = new NativeMenuItem("Always on top");
			_onTopMenuItem.checked = false;
			_onTopMenuItem.data = new Event(ALWAYS_ON_TOP, true);
			_onTopMenuItem.addEventListener(Event.SELECT, toggleCheckedHandler);
			menu.addItem(_onTopMenuItem);
			return menu;
		}


		private static function createDocumentationMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();

			_as3RefMenuItem = new NativeMenuItem("Actionscript 3.0 Reference");
			_as3RefMenuItem.data = new Event(AS3_REFERENCE);
			_as3RefMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_as3RefMenuItem);

			_as3RunMenuItem = new NativeMenuItem("Actionscript 3.0 Runtime Errors");
			_as3RunMenuItem.data = new Event(AS3_RUNTIME_ERRORS);
			_as3RunMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_as3RunMenuItem);

			_riaGuideMenuItem = new NativeMenuItem("Adobe Flash RIA Guide (PDF)");
			_riaGuideMenuItem.data = new Event(RIA_GUIDE);
			_riaGuideMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_riaGuideMenuItem);

			_playersMenuItem = new NativeMenuItem("Adobe Flash Players");
			_playersMenuItem.data = new Event(FLASH_PLAYERS);
			_playersMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_playersMenuItem);

			return menu;
		}


		/**
		 * Close handlers 
		 */
		private static function closeTabHandler(event:Event):void
		{
			if (NativeApplication.nativeApplication.activeWindow == _mainWindow) {
				_dispatcher.dispatchEvent(new Event(CLOSE_TAB));
			} else {
				NativeApplication.nativeApplication.activeWindow.close();
			}
		}
		private static function closeApplicationHandler(event:Event):void
		{
			_mainWindow.close();
		}


		private static function eventHandler(e:Event):void
		{
			var ref:NativeMenuItem = e.target as NativeMenuItem;
			if (ref.data is Event) {
				_dispatcher.dispatchEvent(ref.data as Event);
			}
		}


		private static function toggleCheckedHandler(e:Event):void
		{
			var ref:NativeMenuItem = e.target as NativeMenuItem;
			ref.checked = !ref.checked;
			if (ref.data is Event) {
				_dispatcher.dispatchEvent(ref.data as Event);
			}
		}


		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}


		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}

	}
}