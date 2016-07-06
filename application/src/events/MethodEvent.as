package events
{
	import flash.events.Event;


	public class MethodEvent extends Event
	{

		// The events
		public static const CALL_METHOD:String = "callMethod";


		// The properties
		public var methodParameters:Array;
		public var methodTarget:String;
		public var methodReturnType:String;
		public var methodID:String;


		public function MethodEvent(type:String)
		{
			super(type, true, false);
		}
	}
}