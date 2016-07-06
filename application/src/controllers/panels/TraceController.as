package controllers.panels
{
	import components.Filter;
	import components.panels.TracePanel;
	import components.windows.SnapshotWindow;
	import components.windows.TraceWindow;
	import com.demonsters.debugger.MonsterDebuggerConstants;
	import com.demonsters.debugger.MonsterDebuggerUtils;
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.utils.StringUtil;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;


	public final class TraceController extends EventDispatcher
	{

		[Bindable]
		private var _dataFilterd:ArrayCollection = new ArrayCollection();
		
		private var _data:ArrayCollection = new ArrayCollection();
		private var _panel:TracePanel;
		private var _send:Function;


		/**
		 * Save panel
		 */
		public function TraceController(panel:TracePanel, send:Function)
		{
			_panel = panel;
			_send = send;
			_panel.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete, false, 0, true);
		}


		/**
		 * Panel is ready to link data providers
		 */
		private function creationComplete(e:FlexEvent):void
		{
			_panel.removeEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			_panel.datagrid.dataProvider = _dataFilterd;
			_panel.datagrid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, showTrace, false, 0, true);
			_panel.filter.addEventListener(Filter.CHANGED, filterChanged, false, 0, true);
			_panel.clearButton.addEventListener(MouseEvent.CLICK, clear, false, 0, true);
		}

		
		/**
		 * Show a trace in an output window
		 */
		private function filterChanged(event:Event):void
		{
			_dataFilterd.removeAll();
			
			// Check if a filter term is given
			if (_panel.filter.words.length == 0) {
				for (var i:int = 0; i < _data.length; i++) {
					_dataFilterd.addItem(_data[i]);
				}
				return;
			}
			for (var n:int = 0; n < _data.length; n++) {
				if (checkFilter(_data[n])) {
					_dataFilterd.addItem(_data[n]);
				}
			}
		}
		
		
		private function addItem(item:Object):void
		{
			if (_panel.filter.words.length == 0) {
				_dataFilterd.addItem(item);
				return;
			}
			if (checkFilter(item)) {
				_dataFilterd.addItem(item);
			}
		}

		
		/**
		 * Loop through the search terms and compare strings
		 */
		private function checkFilter(item:Object):Boolean
		{
			var message:String = item.message;
			var target:String = item.target;
			var label:String = item.label;
			var person:String = item.person;
			if (message == null) message = "";
			if (target == null) target = "";
			if (label == null) label = "";
			if (person == null) person = "";
			message = StringUtil.trim(message).toLowerCase();
			target = StringUtil.trim(target).toLowerCase();
			label = StringUtil.trim(label).toLowerCase();
			person = StringUtil.trim(person).toLowerCase();
			var i:int;
			
			// Clone words
			var words:Array = [];
			for (i = 0; i < _panel.filter.words.length; i++) {
				words[i] = _panel.filter.words[i];
			}
			
			if (message != "") {
				for (i = 0; i < words.length; i++) {
					if (message.indexOf(words[i]) != -1) {
						words.splice(i, 1);
						i--;
					}
				}
			}
			if (words.length == 0) return true;
			if (target != "") {
				for (i = 0; i < words.length; i++) {
					if (target.indexOf(words[i]) != -1) {
						words.splice(i, 1);
						i--;
					}
				}
			}
			if (words.length == 0) return true;
			if (label != "") {
				for (i = 0; i < words.length; i++) {
					if (label.indexOf(words[i]) != -1) {
						words.splice(i, 1);
						i--;
					}
				}
			}
			if (words.length == 0) return true;
			if (person != "") {
				for (i = 0; i < words.length; i++) {
					if (person.indexOf(words[i]) != -1) {
						words.splice(i, 1);
						i--;
					}
				}
			}
			if (words.length == 0) return true;
			return false;
		}
		
		
		/**
		 * Show a trace in an output window
		 */
		private function showTrace(event:ListEvent):void
		{
			// Check if the selected item is still available
			if (event.currentTarget.selectedItem != null) {
				
				// Get the data
				var item:Object = _dataFilterd.getItemAt(event.currentTarget.selectedIndex);

				// Check the window to open
				if (item.message == "Snapshot" && item.xml == null) {
					var snapshotWindow:SnapshotWindow = new SnapshotWindow();
					snapshotWindow.setData(item);
					snapshotWindow.open();
				} else {
					var traceWindow:TraceWindow = new TraceWindow();
					traceWindow.setData(item);
					traceWindow.open();
				}
			}
		}


		/**
		 * Clear traces
		 */
		public function clear(event:MouseEvent = null):void
		{
			_data.removeAll();
			_dataFilterd.removeAll();
			_panel.datagrid.horizontalScrollPosition = 0;
		}


		/**
		 * Data handler from client
		 */
		public function setData(data:Object):void
		{
			// Vars for loop
			var date:Date;
			var hours:String;
			var minutes:String;
			var seconds:String;
			var miliseconds:String;
			var time:String;
			var memory:String;
			var obj:Object;

			switch (data["command"]) {
				
				case MonsterDebuggerConstants.COMMAND_CLEAR_TRACES:
					clear();
					break;
					
				case MonsterDebuggerConstants.COMMAND_TRACE:
					
					// Format the properties
					date = data["date"];
					hours = (date.getHours() < 10) ? "0" + date.getHours().toString() : date.getHours().toString();
					minutes = (date.getMinutes() < 10) ? "0" + date.getMinutes().toString() : date.getMinutes().toString();
					seconds = (date.getSeconds() < 10) ? "0" + date.getSeconds().toString() : date.getSeconds().toString();
					miliseconds = date.getMilliseconds().toString();
					time = hours + ":" + minutes + ":" + seconds + "." + miliseconds;
					memory = Math.round(data["memory"] / 1024) + " Kb";
					
					// Create the trace object
					obj = {};
					
					// Check the label
					if (data["xml"]..node.length() > 1 && data["xml"]..node.length() <= 3) {
						if (data["xml"].node[0].@type == MonsterDebuggerConstants.TYPE_STRING || data["xml"].node[0].@type == MonsterDebuggerConstants.TYPE_BOOLEAN || data["xml"].node[0].@type == MonsterDebuggerConstants.TYPE_NUMBER || data["xml"].node[0].@type == MonsterDebuggerConstants.TYPE_INT || data["xml"].node[0].@type == MonsterDebuggerConstants.TYPE_UINT) {
							obj.message = MonsterDebuggerUtils.stripBreaks(MonsterDebuggerUtils.htmlUnescape(data["xml"].node.children()[0].@label));
						} else {
							obj.message = MonsterDebuggerUtils.stripBreaks(MonsterDebuggerUtils.htmlUnescape(data["xml"].node.@label)) + " ...";
						}
					} else {
						obj.message = MonsterDebuggerUtils.stripBreaks(MonsterDebuggerUtils.htmlUnescape(data["xml"].node.@label)) + " ...";
					}
					
					// Add extra info
					obj.line = _data.length + 1;
					obj.time = time;
					obj.memory = memory;
					obj.reference = data["reference"];
					obj.target = data["target"];
					obj.label = data["label"];
					obj.person = data["person"];
					obj.color = data["color"];
					obj.xml = data["xml"];
					
					// Add to list
					_data.addItem(obj);
					addItem(obj);
					break;
					
				case MonsterDebuggerConstants.COMMAND_SNAPSHOT:
					
					// Format the properties
					date = data["date"];
					hours = (date.getHours() < 10) ? "0" + date.getHours().toString() : date.getHours().toString();
					minutes = (date.getMinutes() < 10) ? "0" + date.getMinutes().toString() : date.getMinutes().toString();
					seconds = (date.getSeconds() < 10) ? "0" + date.getSeconds().toString() : date.getSeconds().toString();
					miliseconds = date.getMilliseconds().toString();
					time = hours + ":" + minutes + ":" + seconds + "." + miliseconds;
					memory = Math.round(data["memory"] / 1024) + " Kb";
					
					// Read the bitmap
					try {
						var bitmapData:BitmapData = new BitmapData(data["width"], data["height"]);
						bitmapData.setPixels(new Rectangle(0, 0, data["width"], data["height"]), data["bytes"]);
					} catch(e:Error) {
						return;
					}
					
					// Create the trace object
					obj = {};
					obj.line = _data.length + 1;
					obj.time = time;
					obj.memory = memory;
					obj.width = data["width"];
					obj.height = data["height"];
					obj.bitmapData = bitmapData;
					obj.message = "Snapshot";
					obj.target = data["target"];
					obj.label = data["label"];
					obj.person = data["person"];
					obj.color = data["color"];
					obj.xml = null;
					
					// Add to list
					_data.addItem(obj);
					addItem(obj);
					break;
			}
		}
	}
}
