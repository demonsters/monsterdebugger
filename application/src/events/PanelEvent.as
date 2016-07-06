package events
{
	import flash.events.Event;


	public final class PanelEvent extends Event
	{

		// Events
		public static const CLEAR_PROPERTIES:String = "clearProperties";


		public function PanelEvent(type:String)
		{
			super(type, false, false);
		}
	}
}