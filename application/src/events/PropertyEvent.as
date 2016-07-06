package events
{
	import flash.events.Event;


	public class PropertyEvent extends Event
	{

		// The events
		public static const CHANGE_PROPERTY:String = "changeProperty";


		// The properties
		public var propertyTarget:String;
		public var propertyName:String;
		public var propertyValue:*;


		public function PropertyEvent(type:String)
		{
			super(type, true, false);
		}
	}
}