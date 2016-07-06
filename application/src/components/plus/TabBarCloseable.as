package components.plus
{
	import skins.tabpanel.closeable.TabBarCloseableSkin;
	import spark.components.TabBar;
	import spark.events.RendererExistenceEvent;
	import mx.collections.IList;
	import mx.events.ListEvent;


	[Style(name="tabSkin", type="Class", inherit="no")]
	[Style(name="gap", type="Number", format="Length", inherit="no")]
	public class TabBarCloseable extends TabBar
	{

		static public const CLOSE_ALWAYS:String = "always";
		static public const CLOSE_NEVER:String = "never";
		
		
		private var _closePolicy:String = CLOSE_ALWAYS;


		public function TabBarCloseable()
		{
			super();
			setStyle("skinClass", Class(TabBarCloseableSkin));
		}


		[Inspectable(type="String", format="String", enumeration="never,always", defaultValue="always")]
		public function get closePolicy():String {
			return _closePolicy;
		}
		public function set closePolicy(val:String):void {
			_closePolicy = val;
		}


		protected function tabAdded(e:RendererExistenceEvent):void
		{
			var tab:TabCloseable = dataGroup.getElementAt(e.index) as TabCloseable;
			var tabSkinCls:Class = getStyle("tabSkin");
			if (tabSkinCls) {
				tab.setStyle("skinClass", tabSkinCls);
			}
			if (e.index > 0) {
				tab.canClose = true;
				tab.minWidth = 170;
				tab.maxWidth = 170;
			} else {
				tab.canClose = false;
			}
		}


		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == dataGroup) {
				dataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, tabAdded, false, 0, true);
			}
		}
		

		protected override function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			if (instance == dataGroup) {
				dataGroup.removeEventListener(TabCloseable.CLOSE_TAB, onCloseTabClicked);
				dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_ADD, tabAdded);
			}
		}


		public function onCloseTabClicked(event:ListEvent):void
		{

			var index:int = event.rowIndex;
			if (dataProvider is IList) {
				dataProvider.removeItemAt(index);
			}
		}
	}
}