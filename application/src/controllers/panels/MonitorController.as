package controllers.panels
{
	import components.panels.MonitorPanel;
	import com.demonsters.debugger.MonsterDebuggerConstants;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.events.EventDispatcher;


	public final class MonitorController extends EventDispatcher
	{

		private var _panel:MonitorPanel;
		private var _send:Function;
		private var _shapeFPS:Shape;
		private var _shapeMEM:Shape;
		private var _shape:Shape;
		private var _mask:Shape;
		private var _ready:Boolean = false;


		// Data
		private var monitorData:Vector.<Object> = new Vector.<Object>();


		// Colors
		private const COLOR_FPS:uint = 0xFFFFFF;
		private const COLOR_MEM:uint = 0xFFF000;
		private const COLOR_BACKGROUND:uint = 0x3F3F3F;
		private const COLOR_GRID:uint = 0x696969;


		// Max values
		private var maxFPS:Number = 70;
		private var maxMEM:Number = 50 * 1024 * 1024;


		// Constants for interface
		private const STEP:int = 3;
		private const GRID_SIZE:int = 50;
		private const OFFSET_TOP:int = 70;


		/**
		 * Data handler for the panel
		 */
		public function MonitorController(panel:MonitorPanel, send:Function)
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
			// Create
			_shapeFPS = new Shape();
			_shapeMEM = new Shape();
			_shape = new Shape();
			_mask = new Shape();
			_ready = true;

			// Draw
			_panel.removeEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			_panel.addEventListener(ResizeEvent.RESIZE, resize);
			_panel.container.addChild(_shape);
			_panel.container.addChild(_shapeMEM);
			_panel.container.addChild(_shapeFPS);
			_panel.container.mask = _mask;
		}


		/**
		 * Resized
		 */
		private function resize(event:ResizeEvent = null):void
		{
			draw();
		}


		/**
		 * Draw the background
		 */
		private function draw():void
		{
			if (_ready) {
				
				// Size
				var w:int = _panel.container.width;
				var h:int = _panel.container.height;

				// Draw background
				_shape.graphics.clear();
				_shape.graphics.beginFill(COLOR_BACKGROUND);
				_shape.graphics.drawRect(0, 0, w, h);
				_shape.graphics.endFill();

				// Draw mask
				_mask.graphics.clear();
				_mask.graphics.beginFill(0);
				_mask.graphics.drawRect(0, 0, w, h);
				_mask.graphics.endFill();

				// Clear
				_shapeFPS.graphics.clear();
				_shapeMEM.graphics.clear();

				// Lines
				_shapeFPS.graphics.lineStyle(1, COLOR_FPS, 1, true, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND, 3);
				_shapeMEM.graphics.lineStyle(1, COLOR_MEM, 1, true, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND, 3);
				_shape.graphics.lineStyle(1, COLOR_GRID, 1, true, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND, 3);

				// Check if there are values
				if (monitorData.length > 0 && w > 1 && h > 1) {
					
					// Build grid
					var offset:int = (monitorData.length * STEP) % GRID_SIZE;
					_shape.graphics.moveTo(w - offset, 0);
					for (x = w - offset; x > -GRID_SIZE; x -= GRID_SIZE) {
						_shape.graphics.moveTo(x, 0);
						_shape.graphics.lineTo(x, h);
					}

					// Remove pixels from top
					h -= OFFSET_TOP;

					// Calculate the height ratio
					var ratioFPS:Number = h / maxFPS;
					var ratioMEM:Number = h / maxMEM;

					// First point
					_shapeFPS.graphics.moveTo(w, OFFSET_TOP + int(h - (monitorData[monitorData.length - 1].fps * ratioFPS)));
					_shapeMEM.graphics.moveTo(w, OFFSET_TOP + int(h - (monitorData[monitorData.length - 1].memory * ratioMEM)));

					// Build
					var position:int = monitorData.length;
					var x:int;
					for (x = w; x > -STEP; x -= STEP) {
						position--;
						if (position > 0) {
							_shapeFPS.graphics.lineTo(x, OFFSET_TOP + int(h - (monitorData[position].fps * ratioFPS)));
							_shapeMEM.graphics.lineTo(x, OFFSET_TOP + int(h - (monitorData[position].memory * ratioMEM)));
						}
					}
				}
			}
		}


		/**
		 * Clear data
		 */
		public function clear():void
		{
			monitorData.length = 0;
		}


		/**
		 * Data handler from open tab
		 */
		public function setData(data:Object):void
		{
			switch (data["command"]) {
				case MonsterDebuggerConstants.COMMAND_MONITOR:
					
					// Panel
					_panel.fieldFPS.text = "FPS: " + data.fps.toFixed(0);
					_panel.fieldMEM.text = "MEM: " + (data.memory / 1024 / 1024).toFixed(2) + "MB";
					
					// Check for fps movie
					if (data.fpsMovie != 0) {
						_panel.fieldFPS.text += " / " + data.fpsMovie.toFixed(0);
					}
					
					// Save
					monitorData[monitorData.length] = data;
					if (data.fps > maxFPS) maxFPS = data.fps;
					if (data.memory > maxMEM) maxMEM = data.memory;
					draw();
					break;
			}
		}
	}
}