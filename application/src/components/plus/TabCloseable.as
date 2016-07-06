package components.plus
{
	import spark.components.Button;
	import spark.components.ButtonBarButton;
	import mx.events.ListEvent;
	import flash.events.MouseEvent;


	public class TabCloseable extends ButtonBarButton
	{

		public static const CLOSE_TAB:String = "closeTab";
		public static const CLOSE_APPLICATION:String = "closeApplication";

		private var _closeIncluded:Boolean;


		[SkinPart(required="false")]
		public var closeBtn:Button;


		public function get canClose():Boolean {
			return _closeIncluded;
		}


		public function set canClose(value:Boolean):void {
			_closeIncluded = value;
			skin.invalidateDisplayList();
		}
		

		private function closeBtn_clickHandler(event:MouseEvent):void
		{
			dispatchEvent(new ListEvent(CLOSE_TAB, true, false, -1, itemIndex));
		}
		

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == closeBtn) {
				closeBtn.addEventListener(MouseEvent.CLICK, closeBtn_clickHandler, false, 0, true);
			}
		}


		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			if (instance == closeBtn) {
				closeBtn.removeEventListener(MouseEvent.CLICK, closeBtn_clickHandler);
			}
		}
	}
}