package components.itemrenderers
{
	import mx.controls.treeClasses.TreeItemRenderer;


	public class TreeComponent extends TreeItemRenderer
	{

		private var text:String = "";


		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// Show or hide tooltip
			label.toolTip = "";
			if (label.text.length > 3) {
				if (label.text.substr(label.text.length - 3, 3) == "...") {
					label.toolTip = text;
				}
			}
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (icon) {
				icon.y = 3;
			}
		}

		/**
		 * Converts HTML characters to regular characters
		 * @param s: The string to convert
		 */
		private function htmlUnescape(s:String):String
		{
			if (s) {

				// Remove html elements
				if (s.indexOf("&apos;") != -1) {
					s = s.split("&apos;").join("\'");
				}
				if (s.indexOf("&quot;") != -1) {
					s = s.split("&quot;").join("\"");
				}
				if (s.indexOf("&lt;") != -1) {
					s = s.split("&lt;").join("<");
				}
				if (s.indexOf("&gt;") != -1) {
					s = s.split("&gt;").join(">");
				}
				if (s.indexOf("&amp;") != -1) {
					s = s.split("&amp;").join("&");
				}

				var xml:XML = <a/>;
				xml.replace(0, s);
				return String(xml);
			} else {
				return "";
			}
		}

		/**
		 * Override
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (data != null && listData != null) {
				text = htmlUnescape(listData.label);
				label.text = text;
				label.truncateToFit("...");
			} else {
				text = " ";
				label.text = text;
			}
		}
	}
}