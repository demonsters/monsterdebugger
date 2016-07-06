package controllers.tabs
{
	import components.panels.ApplicationPanel;
	import components.panels.BreakpointsPanel;
	import components.panels.MethodPanel;
	import components.panels.MonitorPanel;
	import components.panels.PropertiesPanel;
	import components.panels.TracePanel;
	import components.tabs.Tab;
	import components.tabs.TabContainer;
	import controllers.panels.ApplicationController;
	import controllers.panels.BreakpointsController;
	import controllers.panels.MethodController;
	import controllers.panels.MonitorController;
	import controllers.panels.PropertiesController;
	import controllers.panels.TraceController;
	import events.PanelEvent;
	import com.demonsters.debugger.IMonsterDebuggerClient;
	import com.demonsters.debugger.MonsterDebuggerConstants;
	import com.demonsters.debugger.MonsterDebuggerData;
	import com.demonsters.debugger.MonsterDebuggerMenu;
	import mx.events.FlexEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;


	public final class TabController extends EventDispatcher
	{

		// Linked client
		private var _client:IMonsterDebuggerClient;


		// The tab component
		public var _tab:Tab;
		private var _tabContainer:TabContainer;


		// The panels
		private var _tracePanel:TracePanel;
		private var _propertiesPanel:PropertiesPanel;
		private var _methodPanel:MethodPanel;
		private var _liveApplicationPanel:ApplicationPanel;
		private var _breakpointsPanel:BreakpointsPanel;
		private var _monitorPanel:MonitorPanel;


		// The panel controllers
		private var _traceController:TraceController;
		private var _propertiesController:PropertiesController;
		private var _methodController:MethodController;
		private var _applicationController:ApplicationController;
		private var _breakpointsController:BreakpointsController;
		private var _monitorController:MonitorController;


		// Menu items
		private var _toggleLiveApplicationViewMenuItem:Boolean;
		private var _toggleBreakpointsViewMenuItem:Boolean;
		private var _toggleMonitorViewMenuItem:Boolean;
		private var _toggleTraceViewMenuItem:Boolean;
		private var _active:Boolean;
		

		/**
		 * Create a new tab controller
		 */
		public function TabController(container:TabContainer, aClient:IMonsterDebuggerClient)
		{
			_toggleLiveApplicationViewMenuItem = true;
			_toggleBreakpointsViewMenuItem = true;
			_toggleMonitorViewMenuItem = true;
			_toggleTraceViewMenuItem = true;

			// Create a new tab
			_tab = new Tab();
			_tabContainer = container;
			_tab.addEventListener(FlexEvent.INITIALIZE, onInit, false, 0, true);
			container.addTab(_tab);
			
			// Save client and set label
			client = aClient;
			
			// Highlight and inspect
			MonsterDebuggerMenu.addEventListener(MonsterDebuggerMenu.HIGHLIGHT_INSPECT, menuHighlight);
		}


		private function menuHighlight(event:Event):void
		{
			if (_active) {
				_applicationController.panel.inspectCheckbox.selected = true;
				send({command:MonsterDebuggerConstants.COMMAND_START_HIGHLIGHT});
			}
		}



		/**
		 * Create the panels
		 */
		private function onInit(event:FlexEvent):void
		{
			// Remove
			_tab.removeEventListener(FlexEvent.INITIALIZE, onInit);

			// Create the panels
			_tracePanel = new TracePanel();
			_propertiesPanel = new PropertiesPanel();
			_methodPanel = new MethodPanel();
			_liveApplicationPanel = new ApplicationPanel();
			_breakpointsPanel = new BreakpointsPanel();
			_monitorPanel = new MonitorPanel();

			// Create the names
			_tracePanel.name = "Traces";
			_propertiesPanel.name = "";
			_propertiesPanel.label = "Properties";
			_methodPanel.name = "Methods";
			_methodPanel.label = "Methods";
			_liveApplicationPanel.name = "Application";
			_liveApplicationPanel.label = "Application";
			_breakpointsPanel.name = "Breakpoints";
			_monitorPanel.name = "Memory Monitor";

			// Add the panels
			_tab.bottomPanel.addPanelItem(_tracePanel);
			_tab.middlePanel.addPanelItem(_propertiesPanel);
			_tab.middlePanel.addPanelItem(_methodPanel);
			_tab.leftPanel.addPanelItem(_liveApplicationPanel);
			_tab.rightPanelTop.addPanelItem(_breakpointsPanel);
			_tab.rightPanelBottom.addPanelItem(_monitorPanel);

			// Create the controllers
			_traceController = new TraceController(_tracePanel, send);
			_propertiesController = new PropertiesController(_propertiesPanel, send);
			_methodController = new MethodController(_methodPanel, send);
			_applicationController = new ApplicationController(_liveApplicationPanel, send);
			_breakpointsController = new BreakpointsController(_breakpointsPanel, send);
			_monitorController = new MonitorController(_monitorPanel, send);

			// Panel listeners
			MonsterDebuggerMenu.addEventListener(MonsterDebuggerMenu.TOGGLE_TRACE_VIEW, hideBottomPanel);
			MonsterDebuggerMenu.addEventListener(MonsterDebuggerMenu.TOGGLE_INSPECTOR, hideInspector);
			MonsterDebuggerMenu.addEventListener(MonsterDebuggerMenu.TOGGLE_BREAKPOINT_VIEW, hideRightPanelTop);
			MonsterDebuggerMenu.addEventListener(MonsterDebuggerMenu.TOGGLE_MEMORY_MONITOR_VIEW, hideRightPanelBottom);
			MonsterDebuggerMenu.addEventListener(MonsterDebuggerMenu.CLEAR_TRACES, clearTraces);

			// Add event listeners for communication between controllers
			_applicationController.addEventListener(PanelEvent.CLEAR_PROPERTIES, clearProperties, false, 0, true);
		}


		/**
		 * Clear the tab
		 */
		public function clear():void
		{
			_traceController.clear();
			_propertiesController.clear();
			_methodController.clear();
			_applicationController.clear();
			_monitorController.clear();
			_client.onData = null;
			_client = null;
		}


		/**
		 * Link the client to this tab
		 */
		public function set client(value:IMonsterDebuggerClient):void {
			_client = value;
			if (_client != null) {
				_client.onData = dataHandler;
				_client.onDisconnect = closedConnection;
				_breakpointsController.reset();
				_breakpointsController.enabled = _client.isDebugger;
				_tab.label = _client.fileTitle;
				_traceController.clear();
				_propertiesController.clear();
				_methodController.clear();
				_applicationController.clear();
				_monitorController.clear();

				_tab.disconnectMessageBox.visible = false;
				_tab.disconnectMessageBox.includeInLayout = false;
			} else {
				_breakpointsController.reset();
				_breakpointsController.enabled = false;
				_tab.label = "Waiting...";
			}
		}
		

		/**
		 * Return the linked client
		 */
		public function get client():IMonsterDebuggerClient {
			return _client;
		}


		/**
		 * Clear properties
		 */
		private function clearProperties(event:PanelEvent):void
		{
			_propertiesController.clear();
			_methodController.clear();
		}


		/**
		 * Send data to the client
		 * Note: This is called from the panel controller
		 */
		private function send(data:Object):void
		{
			if (_client != null) {
				_client.send(MonsterDebuggerConstants.ID, data);
			}
		}


		/**
		 * Incomming data from the client 
		 */
		private function dataHandler(item:MonsterDebuggerData):void
		{
			if (item.id == MonsterDebuggerConstants.ID) {
				
				// Set data in controlers
				_traceController.setData(item.data);
				_propertiesController.setData(item.data);
				_methodController.setData(item.data);
				_applicationController.setData(item.data);
				_monitorController.setData(item.data);
				_breakpointsController.setData(item.data);

				// In case of a new base, get the previews
				switch (item.data["command"]) {
					case MonsterDebuggerConstants.COMMAND_BASE:
					case MonsterDebuggerConstants.COMMAND_INSPECT:
						_client.send(MonsterDebuggerConstants.ID, {command:MonsterDebuggerConstants.COMMAND_GET_PROPERTIES, target:""});
						_client.send(MonsterDebuggerConstants.ID, {command:MonsterDebuggerConstants.COMMAND_GET_FUNCTIONS, target:""});
						_client.send(MonsterDebuggerConstants.ID, {command:MonsterDebuggerConstants.COMMAND_GET_PREVIEW, target:""});
						break;
				}
			}
		}


		private function closedConnection(target:IMonsterDebuggerClient):void
		{
			_tab.disconnectMessageBox.visible = true;
			_tab.disconnectMessageBox.includeInLayout = true;
		}


		private function hideBottomPanel(e:Event):void
		{
			if (active) {
				_toggleTraceViewMenuItem = ! _toggleTraceViewMenuItem;
				_tab.bottomPanel.visible = _toggleTraceViewMenuItem;
				_tab.bottomPanel.includeInLayout = _toggleTraceViewMenuItem;
				windowCheck();
			}
		}
		

		private function hideInspector(e:Event):void
		{
			if (active) {
				_toggleLiveApplicationViewMenuItem = !_toggleLiveApplicationViewMenuItem;
				_tab.middlePanel.visible = _toggleLiveApplicationViewMenuItem;
				_tab.middlePanel.includeInLayout = _toggleLiveApplicationViewMenuItem;
				_tab.leftPanel.visible = _toggleLiveApplicationViewMenuItem;
				_tab.leftPanel.includeInLayout = _toggleLiveApplicationViewMenuItem;
				windowCheck();
			}
		}


		private function hideRightPanelTop(e:Event):void
		{
			if (active) {
				_toggleBreakpointsViewMenuItem = !_toggleBreakpointsViewMenuItem;
				_tab.rightPanelTop.visible = _toggleBreakpointsViewMenuItem;
				_tab.rightPanelTop.includeInLayout = _toggleBreakpointsViewMenuItem;
				windowCheck();
			}
		}


		private function hideRightPanelBottom(e:Event):void
		{
			if (active) {
				_toggleMonitorViewMenuItem = !_toggleMonitorViewMenuItem;
				_tab.rightPanelBottom.visible = _toggleMonitorViewMenuItem;
				_tab.rightPanelBottom.includeInLayout = _toggleMonitorViewMenuItem;
				windowCheck();
			}
		}


		private function windowCheck():void
		{
			if (_tab.leftPanel.visible == false && _tab.middlePanel.visible == false && _tab.rightPanelTop.visible == false && _tab.rightPanelBottom.visible == false) {
				_tab.horizontalsplit.visible = false;
				_tab.horizontalsplit.includeInLayout = false;
				_tab.rightGroup.visible = false;
				_tab.rightGroup.includeInLayout = false;
			} else if (_tab.leftPanel.visible == false && _tab.middlePanel.visible == false && _tab.rightPanelBottom.visible == false) {
				_tab.horizontalsplit.height = 110;
				_tab.rightGroup.visible = true;
				_tab.rightGroup.includeInLayout = true;
				_tab.horizontalsplit.visible = true;
				_tab.horizontalsplit.includeInLayout = true;
			} else if ( _tab.rightPanelTop.visible == false && _tab.rightPanelBottom.visible == false) {
				_tab.rightGroup.visible = false;
				_tab.rightGroup.includeInLayout = false;
				_tab.horizontalsplit.visible = true;
				_tab.horizontalsplit.includeInLayout = true;
				_tab.horizontalsplit.percentHeight = 50;
			} else {
				_tab.horizontalsplit.visible = true;
				_tab.horizontalsplit.includeInLayout = true;
				_tab.horizontalsplit.percentHeight = 50;
				_tab.rightGroup.visible = true;
				_tab.rightGroup.includeInLayout = true;
			}
		}


		private function clearTraces(e:Event):void
		{
			if (active) {
				_traceController.clear();
			}
		}


		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			if(value)
			{
				MonsterDebuggerMenu.toggleBreakpointsViewMenuItem.checked = _toggleBreakpointsViewMenuItem;
				MonsterDebuggerMenu.toggleLiveApplicationViewMenuItem.checked = _toggleLiveApplicationViewMenuItem;
				MonsterDebuggerMenu.toggleMonitorViewMenuItem.checked = _toggleMonitorViewMenuItem;
				MonsterDebuggerMenu.toggleTraceViewMenuItem.checked = _toggleTraceViewMenuItem;

				_tab.bottomPanel.visible = _toggleTraceViewMenuItem;
				_tab.bottomPanel.includeInLayout = _toggleTraceViewMenuItem;
				
				_tab.leftPanel.visible = _toggleLiveApplicationViewMenuItem;
				_tab.leftPanel.includeInLayout = _toggleLiveApplicationViewMenuItem;
				_tab.middlePanel.visible = _toggleLiveApplicationViewMenuItem;
				_tab.middlePanel.includeInLayout = _toggleLiveApplicationViewMenuItem;

				_tab.rightPanelTop.visible = _toggleBreakpointsViewMenuItem;
				_tab.rightPanelTop.includeInLayout = _toggleBreakpointsViewMenuItem;

				_tab.rightPanelBottom.visible = _toggleMonitorViewMenuItem;
				_tab.rightPanelBottom.includeInLayout = _toggleMonitorViewMenuItem;
			}
			_active = value;
		}
	}
}