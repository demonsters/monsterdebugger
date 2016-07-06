package com.demonsters.utils
{
	import flash.utils.ByteArray;


	final public class Base64
	{

		private static const _encodeChars:Vector.<int> = initEncodeChar();
		private static const _decodeChars:Vector.<int> = initDecodeChar();


		/**
		 * Encode ByteArray to base64 string
		 */
		public static function encode(data:ByteArray):String
		{
			var out:ByteArray = new ByteArray();

			out.length = (2 + data.length - ((data.length + 2) % 3)) * 4 / 3;
			var i:int = 0;
			var r:int = data.length % 3;
			var len:int = data.length - r;
			var c:int;

			while (i < len) {
				c = data[i++] << 16 | data[i++] << 8 | data[i++];
				c = (_encodeChars[c >>> 18] << 24) | (_encodeChars[c >>> 12 & 0x3f] << 16) | (_encodeChars[c >>> 6 & 0x3f] << 8) | _encodeChars[c & 0x3f];
				out.writeInt(c);
			}

			if (r == 1) {
				c = data[i];
				c = (_encodeChars[c >>> 2] << 24) | (_encodeChars[(c & 0x03) << 4] << 16) | 61 << 8 | 61;
				out.writeInt(c);
			} else if (r == 2) {
				c = data[i++] << 8 | data[i];
				c = (_encodeChars[c >>> 10] << 24) | (_encodeChars[c >>> 4 & 0x3f] << 16) | (_encodeChars[(c & 0x0f) << 2] << 8) | 61;
				out.writeInt(c);
			}

			out.position = 0;
			return out.readUTFBytes(out.length);
		}


		/**
		 * Decode ByteArray to base64 string
		 */
		public static function decode(str:String):ByteArray
		{
			var c1:int;
			var c2:int;
			var c3:int;
			var c4:int;
			var i:int;
			var len:int;
			var out:ByteArray;
			len = str.length;
			i = 0;
			out = new ByteArray();
			var byteString:ByteArray = new ByteArray();
			byteString.writeUTFBytes(str);
			while (i < len) {
				do {
					c1 = _decodeChars[byteString[i++]];
				} while (i < len && c1 == -1);
				if (c1 == -1) break;

				do {
					c2 = _decodeChars[byteString[i++]];
				} while (i < len && c2 == -1);
				if (c2 == -1) break;

				out.writeByte((c1 << 2) | ((c2 & 0x30) >> 4));

				do {
					c3 = byteString[i++];
					if (c3 == 61) return out;
					c3 = _decodeChars[c3];
				} while (i < len && c3 == -1);
				if (c3 == -1) break;

				out.writeByte(((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2));

				do {
					c4 = byteString[i++];
					if (c4 == 61) return out;
					c4 = _decodeChars[c4];
				} while (i < len && c4 == -1);
				if (c4 == -1) break;

				out.writeByte(((c3 & 0x03) << 6) | c4);
			}
			return out;
		}


		public static function initEncodeChar():Vector.<int>
		{
			var encodeChars:Vector.<int> = new Vector.<int>();
			var chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
			for (var i:int = 0; i < 64; i++) {
				encodeChars.push(chars.charCodeAt(i));
			}
			return encodeChars;
		}


		public static function initDecodeChar():Vector.<int>
		{
			var decodeChars:Vector.<int> = new Vector.<int>();
			decodeChars.push(-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1 - 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
			return decodeChars;
		}
	}
}

