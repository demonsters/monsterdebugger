package controllers.panels
{
	import components.panels.BreakpointsPanel;
	import components.windows.CodeWindow;
	import components.windows.HelpWindow;
	import components.windows.StackWindow;
	import com.demonsters.debugger.MonsterDebuggerConstants;
	import mx.events.FlexEvent;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filesystem.File;


	public final class BreakpointsController extends EventDispatcher
	{

		private var _panel:BreakpointsPanel;
		private var _send:Function;
		private var _stack:XML;
		private var _line:int;
		private var _path:String;
		private var _helpWindow:HelpWindow;


		/**
		 * Data handler for the panel
		 */
		public function BreakpointsController(panel:BreakpointsPanel, send:Function)
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
			// Remove eventlistener
			_panel.removeEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			_panel.playButton.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.pauseButton.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.openButton.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.showButton.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.message.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.message.mouseChildren = false;
		}


		/**
		 * One of the buttons has been clicked
		 */
		private function buttonClicked(event:MouseEvent):void
		{
			switch (event.target) {
				case _panel.playButton:
					_send({command:MonsterDebuggerConstants.COMMAND_RESUME});
					break;
				case _panel.pauseButton:
					_send({command:MonsterDebuggerConstants.COMMAND_PAUSE});
					break;
				case _panel.showButton:
					var codeWindow:CodeWindow = new CodeWindow();
					codeWindow.setData(_path, _line);
					codeWindow.open();
					break;
				case _panel.openButton:
					var stackWindow:StackWindow = new StackWindow();
					stackWindow.setData(_stack);
					stackWindow.open();
					break;
				case _panel.message:
					if (_helpWindow == null || _helpWindow.closed) {
						_helpWindow = new HelpWindow();
					}
					_helpWindow.open();
					_helpWindow.activate();
					break;
			}
		}


		/**
		 * Enable or disable breakpoints
		 */
		public function set enabled(value:Boolean):void {
			_panel.message.visible = !value;
		}


		/**
		 * Reset
		 */
		public function reset():void
		{
			if (!_panel.message.visible) {
				_panel.playButton.visible = false;
				_panel.pauseButton.visible = true;
				_panel.labelfield.text = "Running";
				_panel.openButton.enabled = false;
				_panel.showButton.enabled = false;
			}
		}


		/**
		 * Data handler from open tab
		 */
		public function setData(data:Object):void
		{
			switch (data["command"]) {
				case MonsterDebuggerConstants.COMMAND_PAUSE:
					_panel.playButton.visible = true;
					_panel.pauseButton.visible = false;
					_panel.labelfield.text = "Paused";
					_path = "";
					_stack = null;
					_line = 0;

					// Check for stack trace
					if (data["stack"] != null) {

						// Set breakpoint and id
						_panel.labelfield.text = "Paused - " + data["id"];
						_stack = data["stack"];

						// Check for error
						if (XMLList(_stack..error).length() == 0 && XMLList(_stack..node).length() > 0) {

							// If we have a stack then we can show that
							_panel.openButton.enabled = true;

							// Get file
							var fileName:String = XMLList(_stack..node)[0].@file;

							// Save path for code window
							_path = fileName;

							// Remove slash for interface
							var fileSlash:int = Math.max(fileName.lastIndexOf("\\"), fileName.lastIndexOf("/"));
							if (fileSlash != -1) {
								fileName = fileName.substring(fileSlash + 1);
							}

							// Get file
							var file:File = new File(_path);
							if (file.exists) {
								_panel.showButton.enabled = true;
							}

							// Set file
							if (fileName != "") {
								_panel.labelfield.text += "\n" + fileName;

								// Set line number
								var line:String = XMLList(_stack..node)[0].@line;
								if (line != "") {
									_line = parseInt(line);
									_panel.labelfield.text += ":" + line;
								}
							}
						}
					}
					break;

				case MonsterDebuggerConstants.COMMAND_RESUME:
					_panel.playButton.visible = false;
					_panel.pauseButton.visible = true;
					_panel.labelfield.text = "Running";
					_panel.openButton.enabled = false;
					_panel.showButton.enabled = false;
					break;
			}
		}
	}
}