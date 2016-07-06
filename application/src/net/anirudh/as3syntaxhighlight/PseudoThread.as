package net.anirudh.as3syntaxhighlight
{
	import mx.managers.ISystemManager;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;


	public class PseudoThread
	{

		private var _threadFunction:Function;
		private var _threadArgs:Array;
		private var _threadScope:Object;
		private var _stage:Stage;
		private var _start:Number;
		private var _due:Number;
		private var _incIdx:int;
		private var _incBy:int;

		public function PseudoThread(sm:ISystemManager, threadFunction:Function, threadScope:Object, threadArgs:Array, incField:int, incDelta:int)
		{
			_threadFunction = threadFunction;
			_threadScope = threadScope;
			_threadArgs = threadArgs;
			_incIdx = incField;
			_incBy = incDelta;
			_stage = sm.stage;
			_stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

		private function enterFrameHandler(event:Event):void
		{
			_start = getTimer();
			_due = _start + Math.floor(1000 / _stage.frameRate);
			while (getTimer() < _due) {
				if (!_threadFunction.apply(_threadScope, _threadArgs)) {
					stop();
					return;
				} else {
					_threadArgs[_incIdx] += _incBy;
				}
			}
		}

		public function stop():void
		{
			_stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
	}
}