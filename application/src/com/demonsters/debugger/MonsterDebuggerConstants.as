package com.demonsters.debugger
{

	public final class MonsterDebuggerConstants
	{

		// Core app id
		public static const ID:String = "com.demonsters.debugger.core";
		
		
		// Paths
		public static const PATH_UPDATE:String = "http://www.monsterdebugger.com/xml/3/update.xml";
		public static const PATH_TICKER:String = "http://www.monsterdebugger.com/xml/3/ticker.xml";
		
		
		// Commands
		public static const COMMAND_HELLO:String = "HELLO";
		public static const COMMAND_INFO:String = "INFO";
		public static const COMMAND_TRACE:String = "TRACE";
		public static const COMMAND_PAUSE:String = "PAUSE";
		public static const COMMAND_RESUME:String = "RESUME";
		public static const COMMAND_BASE:String = "BASE";
		public static const COMMAND_INSPECT:String = "INSPECT";
		public static const COMMAND_GET_OBJECT:String = "GET_OBJECT";
		public static const COMMAND_GET_PROPERTIES:String = "GET_PROPERTIES";
		public static const COMMAND_GET_FUNCTIONS:String = "GET_FUNCTIONS";
		public static const COMMAND_GET_PREVIEW:String = "GET_PREVIEW";
		public static const COMMAND_SET_PROPERTY:String = "SET_PROPERTY";
		public static const COMMAND_CALL_METHOD:String = "CALL_METHOD";
		public static const COMMAND_HIGHLIGHT:String = "HIGHLIGHT";
		public static const COMMAND_START_HIGHLIGHT:String = "START_HIGHLIGHT";
		public static const COMMAND_STOP_HIGHLIGHT:String = "STOP_HIGHLIGHT";
		public static const COMMAND_CLEAR_TRACES:String = "CLEAR_TRACES";
		public static const COMMAND_MONITOR:String = "MONITOR";
		public static const COMMAND_SNAPSHOT:String = "SNAPSHOT";
		public static const COMMAND_NOTFOUND:String = "NOTFOUND";
		
		
		// Types
		public static const TYPE_NULL:String = "null";
		public static const TYPE_VOID:String = "void";
		public static const TYPE_ARRAY:String = "Array";
		public static const TYPE_BOOLEAN:String = "Boolean";
		public static const TYPE_NUMBER:String = "Number";
		public static const TYPE_OBJECT:String = "Object";
		public static const TYPE_VECTOR:String = "Vector.";
		public static const TYPE_STRING:String = "String";
		public static const TYPE_INT:String = "int";
		public static const TYPE_UINT:String = "uint";
		public static const TYPE_XML:String = "XML";
		public static const TYPE_XMLLIST:String = "XMLList";
		public static const TYPE_XMLNODE:String = "XMLNode";
		public static const TYPE_XMLVALUE:String = "XMLValue";
		public static const TYPE_XMLATTRIBUTE:String = "XMLAttribute";
		public static const TYPE_METHOD:String = "MethodClosure";
		public static const TYPE_FUNCTION:String = "Function";
		public static const TYPE_BYTEARRAY:String = "ByteArray";
		public static const TYPE_WARNING:String = "Warning";
		public static const TYPE_NOT_FOUND:String = "Not found";
		public static const TYPE_UNREADABLE:String = "Unreadable";
		
		
		// Access types
		public static const ACCESS_VARIABLE:String = "variable";
		public static const ACCESS_CONSTANT:String = "constant";
		public static const ACCESS_ACCESSOR:String = "accessor";
		public static const ACCESS_METHOD:String = "method";
		public static const ACCESS_DISPLAY_OBJECT:String = "displayObject";
		
		
		// Permission types
		public static const PERMISSION_READWRITE:String = "readwrite";
		public static const PERMISSION_READONLY:String = "readonly";
		public static const PERMISSION_WRITEONLY:String = "writeonly";
		
		
		// Icon types
		public static const ICON_DEFAULT:String = "iconDefault";
		public static const ICON_ROOT:String = "iconRoot";
		public static const ICON_WARNING:String = "iconWarning";
		public static const ICON_VARIABLE:String = "iconVariable";
		public static const ICON_VARIABLE_READONLY:String = "iconVariableReadonly";
		public static const ICON_VARIABLE_WRITEONLY:String = "iconVariableWriteonly";
		public static const ICON_DISPLAY_OBJECT:String = "iconDisplayObject";
		public static const ICON_XMLNODE:String = "iconXMLNode";
		public static const ICON_XMLVALUE:String = "iconXMLValue";
		public static const ICON_XMLATTRIBUTE:String = "iconXMLAttribute";
		public static const ICON_FUNCTION:String = "iconFunction";


		// Path delimiter
		public static const DELIMITER:String = ".";


		public static const URL_AS3_REFERENCE:String = "http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/index.html";
		public static const URL_AS3_ERRORS:String = "http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/runtimeErrors.html";
		public static const URL_AS3_RIA:String = "http://www.adobe.com/devnet-archive/actionscript/articles/atp_ria_guide/atp_ria_guide.pdf";
		public static const URL_AS3_PLAYER:String = "http://www.adobe.com/support/flashplayer/downloads.html";

		public static const URL_FEEDBACK:String = "http://getsatisfaction.com/demonsters/products/demonsters_monster_debugger_3";
		public static const URL_DEMONSTERS:String = "http://www.demonsters.com";
		public static const URL_GAME:String = "http://www.monsterdebugger.com/game";
		public static const URL_SITE:String = "http://www.monsterdebugger.com";
		public static const URL_TWITTER:String = "http://www.twitter.com/monsterdebugger";
		public static const URL_DEMONSTERS_HIRE:String = "http://www.demonsters.com/contact";
		public static const URL_TOUR:String = "http://www.monsterdebugger.com/tour";
		public static const URL_DOCUMENTATION:String = "http://www.monsterdebugger.com/documentation";
		public static const URL_SOURCE:String = "http://code.google.com/p/monsterdebugger";
		public static const URL_FACEBOOK:String = "http://www.facebook.com/pages/De-Monsters/36958528369";
	}
}