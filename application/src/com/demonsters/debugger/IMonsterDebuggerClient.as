package com.demonsters.debugger
{

	public interface IMonsterDebuggerClient
	{
		function send (id:String, data:Object):void;
		
		function get fileLocation():String;
		function get fileTitle():String;
		function get isFlex():Boolean;
		function get isDebugger():Boolean;
		
		function get onData():Function;
		function get onDisconnect():Function;
		
		function set onData(value:Function):void;
		function set onDisconnect(value:Function):void;
	}
}
