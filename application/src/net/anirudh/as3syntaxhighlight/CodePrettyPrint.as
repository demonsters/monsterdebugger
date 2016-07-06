package net.anirudh.as3syntaxhighlight
{
	import mx.managers.ISystemManager;


	public class CodePrettyPrint
	{

		private var PR_TAB_WIDTH:int = 8;
		private var PR_NOCODE:String = 'nocode';

		private function wordSet(words:Object):Object
		{
			words = words.split(/ /g);
			var set:Object = {};
			for (var i:int = words.length; --i >= 0;) {
				var w:Object = words[i];
				if (w) {
					set[w] = null;
				}
			}
			return set;
		}

		private var pr_amp:RegExp = new RegExp("/&/g");
		private var pr_lt:RegExp = new RegExp("/</g");
		private var pr_gt:RegExp = new RegExp("/>/g");
		private var pr_quot:RegExp = new RegExp("\\\"", "g");

		private function attribToHtml(str:String):String
		{
			return str.replace(pr_amp, '&amp;')
			.replace(pr_lt, '&lt;')
			.replace(pr_gt, '&gt;')
			.replace(pr_quot, '&quot;');
		}

		public function textToHtml(str:String):String
		{
			return str.replace(pr_amp, '&amp;')
			.replace(pr_lt, '&lt;')
			.replace(pr_gt, '&gt;');
		}

		private var pr_ltEnt:RegExp = /&lt;/g;
		private var pr_gtEnt:RegExp = /&gt;/g;
		private var pr_aposEnt:RegExp = /&apos;/g;
		private var pr_quotEnt:RegExp = /&quot;/g;
		private var pr_ampEnt:RegExp = /&amp;/g;
		private var pr_nbspEnt:RegExp = /&nbsp;/g;

		private function htmlToText(html:String):String
		{
			var pos:int = html.indexOf('&');
			if (pos < 0) {
				return html;
			}

			for (--pos; (pos = html.indexOf('&#', pos + 1)) >= 0;) {
				var end:int = html.indexOf(';', pos);
				if (end >= 0) {
					var num:String = html.substring(pos + 3, end);
					var radix:int = 10;
					if (num && num.charAt(0) === 'x') {
						num = num.substring(1);
						radix = 16;
					}
					var codePoint:Number = parseInt(num, radix);
					if (!isNaN(codePoint)) {
						html = (html.substring(0, pos) + String.fromCharCode(codePoint) + html.substring(end + 1));
					}
				}
			}

			return html.replace(pr_ltEnt, '<')
			.replace(pr_gtEnt, '>')
			.replace(pr_aposEnt, "'")
			.replace(pr_quotEnt, '"')
			.replace(pr_ampEnt, '&')
			.replace(pr_nbspEnt, ' ');
		}

		private static var FLOW_CONTROL_KEYWORDS:String = "break continue do else for if return while ";
		private static var C_KEYWORDS:String = FLOW_CONTROL_KEYWORDS + "auto case char const default " + "double enum extern float goto int long register short signed sizeof " + "static struct switch typedef union unsigned void volatile ";
		private static var COMMON_KEYWORDS:String = C_KEYWORDS + "catch class delete false import " + "new operator private protected public this throw true try ";
		private static var CPP_KEYWORDS:String = COMMON_KEYWORDS + "alignof align_union asm axiom bool " + "concept concept_map const_cast constexpr decltype " + "dynamic_cast explicit export friend inline late_check " + "mutable namespace nullptr reinterpret_cast static_assert static_cast " + "template typeid typename typeof using virtual wchar_t where ";
		private static var JAVA_KEYWORDS:String = COMMON_KEYWORDS + "boolean byte extends final finally implements import instanceof null " + "native package strictfp super synchronized throws transient ";
		private static var CSHARP_KEYWORDS:String = JAVA_KEYWORDS + "as base by checked decimal delegate descending event " + "fixed foreach from group implicit in interface internal into is lock " + "object out override orderby params readonly ref sbyte sealed " + "stackalloc string select uint ulong unchecked unsafe ushort var ";
		private static var JSCRIPT_KEYWORDS:String = COMMON_KEYWORDS + "debugger eval export function get null set undefined var with " + "Infinity NaN ";
		private static var PERL_KEYWORDS:String = "caller delete die do dump elsif eval exit foreach for " + "goto if import last local my next no our print package redo require " + "sub undef unless until use wantarray while BEGIN END ";
		private static var PYTHON_KEYWORDS:String = FLOW_CONTROL_KEYWORDS + "and as assert class def del " + "elif except exec finally from global import in is lambda " + "nonlocal not or pass print raise try with yield " + "False True None ";
		private static var RUBY_KEYWORDS:String = FLOW_CONTROL_KEYWORDS + "alias and begin case class def" + " defined elsif end ensure false in module next nil not or redo rescue " + "retry self super then true undef unless until when yield BEGIN END ";
		private static var SH_KEYWORDS:String = FLOW_CONTROL_KEYWORDS + "case done elif esac eval fi " + "function in local set then until ";
		private static var ALL_KEYWORDS:String = (
		CPP_KEYWORDS + CSHARP_KEYWORDS + JSCRIPT_KEYWORDS + PERL_KEYWORDS + PYTHON_KEYWORDS + RUBY_KEYWORDS + SH_KEYWORDS);
		private static var PR_STRING:String = 'str';
		private static var PR_KEYWORD:String = 'kwd';
		private static var PR_COMMENT:String = 'com';
		private static var PR_TYPE:String = 'typ';
		private static var PR_LITERAL:String = 'lit';
		private static var PR_PUNCTUATION:String = 'pun';
		private static var PR_PLAIN:String = 'pln';
		private static var PR_TAG:String = 'tag';
		private static var PR_DECLARATION:String = 'dec';
		private static var PR_SOURCE:String = 'src';
		private static var PR_ATTRIB_NAME:String = 'atn';
		private static var PR_ATTRIB_VALUE:String = 'atv';

		private static function isWordChar(ch:String):Boolean
		{
			return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z');
		}

		private function spliceArrayInto(inserted:Array, container:Array, containerPosition:Number, countReplaced:Number):void
		{
			inserted.unshift(containerPosition, countReplaced || 0);
			try {
				container.splice.apply(container, inserted);
			} finally {
				inserted.splice(0, 2);
			}
		}

		private static function regexpPrecederPattern():RegExp
		{
			var preceders:Array = ["!", "!=", "!==", "#", "%", "%=", "&", "&&", "&&=", "&=", "(", "*", "*=", "+=", ",", "-=", "->", "/", "/=", ":", "::", ";", "<", "<<", "<<=", "<=", "=", "==", "===", ">", ">=", ">>", ">>=", ">>>", ">>>=", "?", "@", "[", "^", "^=", "^^", "^^=", "{", "|", "|=", "||", "||=", "~", "break", "case", "continue", "delete", "do", "else", "finally", "instanceof", "return", "throw", "try", "typeof"];
			var pattern:String = '(?:' + '(?:(?:^|[^0-9.])\\.{1,3})|' + '(?:(?:^|[^\\+])\\+)|' + '(?:(?:^|[^\\-])-)';
			for (var i:int = 0; i < preceders.length; ++i) {
				var preceder:String = preceders[i];
				if (isWordChar(preceder.charAt(0))) {
					pattern += '|\\b' + preceder;
				} else {
					pattern += '|' + preceder.replace(/([^=<>:&])/g, '\\$1');
				}
			}
			pattern += '|^)\\s*$';
			return new RegExp(pattern);
		}

		private static var REGEXP_PRECEDER_PATTERN:Function = regexpPrecederPattern;
		private static var pr_chunkPattern:RegExp = /(?:[^<]+|<!--[\s\S]*?-->|<!\[CDATA\[([\s\S]*?)\]\]>|<\/?[a-zA-Z][^>]*>|<)/g;
		private static var pr_commentPrefix:RegExp = /^<!--/;
		private static var pr_cdataPrefix:RegExp = /^<\[CDATA\[/;
		private static var pr_brPrefix:RegExp = /^<br\b/i;
		private static var pr_tagNameRe:RegExp = /^<(\/?)([a-zA-Z]+)/;

		private function makeTabExpander(tabWidth:int):Function
		{
			var SPACES:String = ' ';
			var charInLine:int = 0;

			return function(plainText:String):String {
				var out:Array = null;
				var pos:int = 0;
				for (var i:int = 0, n:int = plainText.length; i < n; ++i) {
					var ch:String = plainText.charAt(i);

					switch (ch) {
						case '\t':
							if (!out) {
								out = [];
							}
							out.push(plainText.substring(pos, i));
							var nSpaces:int = tabWidth - (charInLine % tabWidth);
							charInLine += nSpaces;
							for (; nSpaces >= 0; nSpaces -= SPACES.length) {
								out.push(SPACES.substring(0, nSpaces));
							}
							pos = i + 1;
							break;
						case '\n':
							charInLine = 0;
							break;
						default:
							++charInLine;
					}
				}
				if (!out) {
					return plainText;
				}
				out.push(plainText.substring(pos));
				return out.join('');
			};
		}

		private function extractTags(s:String):Object
		{
			var matches:Array = s.match(pr_chunkPattern);
			var sourceBuf:Array = [];
			var sourceBufLen:int = 0;
			var extractedTags:Array = [];
			if (matches) {
				for (var i:int = 0, n:int = matches.length; i < n; ++i) {
					var match:String = matches[i];
					if (match.length > 1 && match.charAt(0) === '<') {
						if (pr_commentPrefix.test(match)) {
							continue;
						}
						if (pr_cdataPrefix.test(match)) {
							sourceBuf.push(match.substring(9, match.length - 3));
							sourceBufLen += match.length - 12;
						} else if (pr_brPrefix.test(match)) {
							sourceBuf.push('\n');
							++sourceBufLen;
						} else {
							if (match.indexOf(PR_NOCODE) >= 0 && isNoCodeTag(match)) {
								var name:String = match.match(pr_tagNameRe)[2];
								var depth:int = 1;
								end_tag_loop:
								for (var j:int = i + 1; j < n; ++j) {
									var name2:Array = matches[j].match(pr_tagNameRe);
									if (name2 && name2[2] === name) {
										if (name2[1] === '/') {
											if (--depth === 0) {
												break end_tag_loop;
											}
										} else {
											++depth;
										}
									}
								}
								if (j < n) {
									extractedTags.push(sourceBufLen, matches.slice(i, j + 1).join(''));
									i = j;
								} else {
									extractedTags.push(sourceBufLen, match);
								}
							} else {
								extractedTags.push(sourceBufLen, match);
							}
						}
					} else {
						var literalText:String = htmlToText(match);
						sourceBuf.push(literalText);
						sourceBufLen += literalText.length;
					}
				}
			}
			return {source:sourceBuf.join(''), tags:extractedTags};
		}

		private function isNoCodeTag(tag:String):Boolean
		{
			return !!tag
			.replace(/\s(\w+)\s*=\s*(?:\"([^\"]*)\"|'([^\']*)'|(\S+))/g, ' $1="$2$3$4"')
			.match(/[cC][lL][aA][sS][sS]=\"[^\"]*\bnocode\b/);
		}

		private function createSimpleLexer(shortcutStylePatterns:Array, fallthroughStylePatterns:Array):Function
		{
			var shortcuts:Object = {};
			(function():void {
				var allPatterns:Array = shortcutStylePatterns.concat(fallthroughStylePatterns);
				for (var i:int = allPatterns.length; --i >= 0;) {
					var patternParts:Object = allPatterns[i];
					var shortcutChars:Object = patternParts[3];
					if (shortcutChars) {
						for (var c:int = shortcutChars.length; --c >= 0;) {
							shortcuts[shortcutChars.charAt(c)] = patternParts;
						}
					}
				}
			})();

			var nPatterns:int = fallthroughStylePatterns.length;
			var notWs:RegExp = /\S/;

			return function(sourceCode:String, opt_basePos:int = 0):Array {
				opt_basePos = opt_basePos || 0;
				var decorations:Array = [opt_basePos, PR_PLAIN];
				var lastToken:String = '';
				var pos:int = 0;
				var tail:String = sourceCode;

				while (tail.length) {
					var style:String;
					var token:String = null;
					var match:Array;
					var patternParts:Array = shortcuts[tail.charAt(0)];
					if (patternParts) {
						match = tail.match(patternParts[1]);
						token = match[0];
						style = patternParts[0];
					} else {
						for (var i:int = 0; i < nPatterns; ++i) {
							patternParts = fallthroughStylePatterns[i];
							var contextPattern:RegExp = patternParts[2];
							if (contextPattern && contextPattern is RegExp && !contextPattern.test(lastToken)) {
								continue;
							}
							match = tail.match(patternParts[1]);
							if (match) {
								token = match[0];
								style = patternParts[0];
								if ( token == "var" || token == "function" ) {
									style = "spl";
								}
								break;
							}
						}
						if (!token) {
							style = PR_PLAIN;
							token = tail.substring(0, 1);
						}
					}

					decorations.push(opt_basePos + pos, style);
					pos += token.length;
					tail = tail.substring(token.length);
					if (style !== PR_COMMENT && notWs.test(token)) {
						lastToken = token;
					}
				}
				return decorations;
			};
		}

		private var PR_MARKUP_LEXER:Function = createSimpleLexer([], [[PR_PLAIN, /^[^<]+/, null], [PR_DECLARATION, /^<!\w[^>]*(?:>|$)/, null], [PR_COMMENT, /^<!--[\s\S]*?(?:-->|$)/, null], [PR_SOURCE, /^<\?[\s\S]*?(?:\?>|$)/, null], [PR_SOURCE, /^<%[\s\S]*?(?:%>|$)/, null], [PR_SOURCE, /^<(script|style|xmp|mx\:Script)\b[^>]*>[\s\S]*?<\/\1\b[^>]*>/i, null], [PR_TAG, /^<\/?\w[^<>]*>/, null]]);
		private var PR_SOURCE_CHUNK_PARTS:RegExp = /^(<[^>]*>)([\s\S]*)(<\/[^>]*>)$/;

		private function tokenizeMarkup(source:String):Array
		{
			var decorations:Array = PR_MARKUP_LEXER(source);
			for (var i:int = 0; i < decorations.length; i += 2) {
				if (decorations[i + 1] === PR_SOURCE) {
					var start:int, end:int;
					start = decorations[i];
					end = i + 2 < decorations.length ? decorations[i + 2] : source.length;

					var sourceChunk:String = (source as String).substring(start, end);
					var match:Array = sourceChunk.match(PR_SOURCE_CHUNK_PARTS);
					if ( match && match.length > 2 ) {
						decorations.splice(i, 2, start, PR_TAG, start + (match[1] as String).length, PR_SOURCE, start + (match[1] as String).length + ((match[2] as String) || '').length, PR_TAG);
					}
				}
			}
			return decorations;
		}

		private var PR_TAG_LEXER:Function = createSimpleLexer([[PR_ATTRIB_VALUE, /^\'[^\']*(?:\'|$)/, null, "'"], [PR_ATTRIB_VALUE, /^\"[^\"]*(?:\"|$)/, null, '"'], [PR_PUNCTUATION, /^[<>\/=]+/, null, '<>/=']], [[PR_TAG, /^[\w:\-]+/, /^</], [PR_ATTRIB_VALUE, /^[\w\-]+/, /^=/], [PR_ATTRIB_NAME, /^[\w:\-]+/, null], [PR_PLAIN, /^\s+/, null, ' \t\r\n']]);

		private function splitTagAttributes(source:String, decorations:Array):Array
		{
			for (var i:int = 0; i < decorations.length; i += 2) {
				var style:Object = decorations[i + 1];
				if (style === PR_TAG) {
					var start:int, end:int;
					start = decorations[i];
					end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
					var chunk:String = source.substring(start, end);
					var subDecorations:Array = PR_TAG_LEXER(chunk, start);
					spliceArrayInto(subDecorations, decorations, i, 2);
					i += subDecorations.length - 2;
				}
			}
			return decorations;
		}

		private function sourceDecorator(options:Object):Function
		{
			var shortcutStylePatterns:Array = [], fallthroughStylePatterns:Array = [];
			if (options.tripleQuotedStrings) {
				shortcutStylePatterns.push([PR_STRING, /^(?:\'\'\'(?:[^\'\\]|\\[\s\S]|\'{1,2}(?=[^\']))*(?:\'\'\'|$)|\"\"\"(?:[^\"\\]|\\[\s\S]|\"{1,2}(?=[^\"]))*(?:\"\"\"|$)|\'(?:[^\\\']|\\[\s\S])*(?:\'|$)|\"(?:[^\\\"]|\\[\s\S])*(?:\"|$))/, null, '\'"']);
			} else if (options.multiLineStrings) {
				shortcutStylePatterns.push([PR_STRING, /^(?:\'(?:[^\\\']|\\[\s\S])*(?:\'|$)|\"(?:[^\\\"]|\\[\s\S])*(?:\"|$)|\`(?:[^\\\`]|\\[\s\S])*(?:\`|$))/, null, '\'"`']);
			} else {
				shortcutStylePatterns.push([PR_STRING, /^(?:\'(?:[^\\\'\r\n]|\\.)*(?:\'|$)|\"(?:[^\\\"\r\n]|\\.)*(?:\"|$))/, null, '"\'']);
			}
			fallthroughStylePatterns.push([PR_PLAIN, /^(?:[^\'\"\`\/\#]+)/, null, ' \r\n']);
			if (options.hashComments) {
				shortcutStylePatterns.push([PR_COMMENT, /^#[^\r\n]*/, null, '#']);
			}
			if (options.cStyleComments) {
				fallthroughStylePatterns.push([PR_COMMENT, /^\/\/[^\r\n]*/, null]);
				fallthroughStylePatterns.push([PR_COMMENT, /^\/\*[\s\S]*?(?:\*\/|$)/, null]);
			}
			if (options.regexLiterals) {
				var REGEX_LITERAL:String = (
				'^/(?=[^/*])' + '(?:[^/\\x5B\\x5C\\x0A\\x0D]' + '|\\x5C[\\t \\S]' + '|\\x5B(?:[^\\x5C\\x5D]|\\x5C[\\t \\S])*(?:\\x5D|$))+' + '(?:/|$)');
				fallthroughStylePatterns.push([PR_STRING, new RegExp(REGEX_LITERAL), REGEXP_PRECEDER_PATTERN]);
			}

			var keywords:Object = wordSet(options.keywords);

			options = null;

			var splitStringAndCommentTokens:Function = createSimpleLexer(shortcutStylePatterns, fallthroughStylePatterns);
			var styleLiteralIdentifierPuncRecognizer:Function = createSimpleLexer([], [[PR_PLAIN, /^\s+/, null, ' \r\n'], [PR_PLAIN, /^[a-z_$@][a-z_$@0-9]*/i, null], [PR_LITERAL, /^0x[a-f0-9]+[a-z]/i, null], [PR_LITERAL, /^(?:\d(?:_\d+)*\d*(?:\.\d*)?|\.\d+)(?:e[+\-]?\d+)?[a-z]*/i, null, '123456789'], [PR_PUNCTUATION, /^[^\s\w\.$@]+/, null]]);

			function splitNonStringNonCommentTokens(source:String, decorations:Array):Array {
				for (var i:int = 0; i < decorations.length; i += 2) {
					var style:Object = decorations[i + 1];
					if (style === PR_PLAIN) {
						var start:int, end:int, chunk:String, subDecs:Array;
						start = decorations[i];
						end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
						chunk = source.substring(start, end);
						subDecs = styleLiteralIdentifierPuncRecognizer(chunk, start);
						for (var j:int = 0, m:int = subDecs.length; j < m; j += 2) {
							var subStyle:String = subDecs[j + 1];
							if (subStyle === PR_PLAIN) {
								var subStart:int = subDecs[j];
								var subEnd:int = j + 2 < m ? subDecs[j + 2] : chunk.length;
								var token:String = source.substring(subStart, subEnd);
								if (token === '.') {
									subDecs[j + 1] = PR_PUNCTUATION;
								} else if (token in keywords) {
									subDecs[j + 1] = PR_KEYWORD;
								} else if (/^@?[A-Z][A-Z$]*[a-z][A-Za-z$]*$/.test(token)) {
									subDecs[j + 1] = token.charAt(0) === '@' ? PR_LITERAL : PR_TYPE;
								}
							}
						}
						spliceArrayInto(subDecs, decorations, i, 2);
						i += subDecs.length - 2;
					}
				}
				return decorations;
			}

			return function(sourceCode:String):Array {
				var decorations:Array = splitStringAndCommentTokens(sourceCode);
				decorations = splitNonStringNonCommentTokens(sourceCode, decorations);
				return decorations;
			};
		}

		private var decorateSource:Function = sourceDecorator({keywords:ALL_KEYWORDS, hashComments:true, cStyleComments:true, multiLineStrings:true, regexLiterals:true});

		private function splitSourceNodes(source:String, decorations:Array):Array
		{
			for (var i:int = 0; i < decorations.length; i += 2) {
				var style:Object = decorations[i + 1];
				if (style === PR_SOURCE) {
					var start:int, end:int;
					start = decorations[i];
					end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
					var subDecorations:Array = decorateSource(source.substring(start, end));
					for (var j:int = 0, m:int = subDecorations.length; j < m; j += 2) {
						subDecorations[j] += start;
					}
					spliceArrayInto(subDecorations, decorations, i, 2);
					i += subDecorations.length - 2;
				}
			}
			return decorations;
		}

		private var quoteReg:RegExp = new RegExp("^[\\\"\\']", "");

		private function splitSourceAttributes(source:String, decorations:Array):Array
		{
			var nextValueIsSource:Boolean = false;
			for (var i:int = 0; i < decorations.length; i += 2) {
				var style:Object = decorations[i + 1];
				var start:int, end:int;
				if (style === PR_ATTRIB_NAME) {
					start = decorations[i];
					end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
					nextValueIsSource = /^on|^style$/i.test(source.substring(start, end));
				} else if (style === PR_ATTRIB_VALUE) {
					if (nextValueIsSource) {
						start = decorations[i];
						end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
						var attribValue:String = source.substring(start, end);
						var attribLen:int = attribValue.length;
						var quoted:Boolean = (attribLen >= 2 && quoteReg.test(attribValue) && attribValue.charAt(0) === attribValue.charAt(attribLen - 1));
						var attribSource:String;
						var attribSourceStart:int;
						var attribSourceEnd:int;
						if (quoted) {
							attribSourceStart = start + 1;
							attribSourceEnd = end - 1;
							attribSource = attribValue;
						} else {
							attribSourceStart = start + 1;
							attribSourceEnd = end - 1;
							attribSource = attribValue.substring(1, attribValue.length - 1);
						}
						var attribSourceDecorations:Array = decorateSource(attribSource);
						for (var j:int = 0, m:int = attribSourceDecorations.length; j < m; j += 2) {
							attribSourceDecorations[j] += attribSourceStart;
						}
						if (quoted) {
							attribSourceDecorations.push(attribSourceEnd, PR_ATTRIB_VALUE);
							spliceArrayInto(attribSourceDecorations, decorations, i + 2, 0);
						} else {
							spliceArrayInto(attribSourceDecorations, decorations, i, 2);
						}
					}
					nextValueIsSource = false;
				}
			}
			return decorations;
		}

		private function decorateMarkup(sourceCode:String):Array
		{
			var decorations:Array = tokenizeMarkup(sourceCode);
			decorations = splitTagAttributes(sourceCode, decorations);
			decorations = splitSourceNodes(sourceCode, decorations);
			decorations = splitSourceAttributes(sourceCode, decorations);
			return decorations;
		}

		public var mainDecorations:Array;
		public var mainHtml:String;
		public var prettyPrintStopAsyc:Boolean;

		private function recombineTagsAndDecorations(sourceText:String, extractedTags:Array, decorations:Array):String
		{
			var html:Array = [];

			var outputIdx:int = 0;

			var openDecoration:String = null;
			var currentDecoration:String = null;
			var tagPos:int = 0;
			var decPos:int = 0;
			var tabExpander:Function = makeTabExpander(PR_TAB_WIDTH);

			var adjacentSpaceRe:RegExp = /([\r\n ]) /g;
			var startOrSpaceRe:RegExp = /(^| ) /gm;
			var newlineRe:RegExp = /\r\n?|\n/g;
			var trailingSpaceRe:RegExp = /[ \r\n]$/;
			var lastWasSpace:Boolean = true;

			function emitTextUpTo(sourceIdx:int):void {
				if (sourceIdx > outputIdx) {
					if (openDecoration && openDecoration !== currentDecoration) {
						html.push('</span>');
						openDecoration = null;
					}
					if (!openDecoration && currentDecoration) {
						openDecoration = currentDecoration;
						html.push('<span class="', openDecoration, '">');
					}
					var htmlChunk:String = textToHtml(tabExpander(sourceText.substring(outputIdx, sourceIdx)))
					.replace(lastWasSpace ? startOrSpaceRe : adjacentSpaceRe, '$1&nbsp;');
					lastWasSpace = trailingSpaceRe.test(htmlChunk);
					html.push(htmlChunk.replace(newlineRe, '<br />'));
					outputIdx = sourceIdx;
				}
			}

			while (true) {
				var outputTag:Object;
				if (tagPos < extractedTags.length) {
					if (decPos < decorations.length) {
						outputTag = extractedTags[tagPos] <= decorations[decPos];
					} else {
						outputTag = true;
					}
				} else {
					outputTag = false;
				}
				if (outputTag) {
					emitTextUpTo(extractedTags[tagPos]);
					if (openDecoration) {
						html.push('</span>');
						openDecoration = null;
					}
					html.push(extractedTags[tagPos + 1]);
					tagPos += 2;
				} else if (decPos < decorations.length) {
					emitTextUpTo(decorations[decPos]);
					currentDecoration = decorations[decPos + 1];
					decPos += 2;
				} else {
					break;
				}
			}
			emitTextUpTo(sourceText.length);
			if (openDecoration) {
				html.push('</span>');
			}
			return html.join('');
		}

		private var langHandlerRegistry:Object = {};

		private function registerLangHandler(handler:Function, fileExtensions:Array):void
		{
			for (var i:int = fileExtensions.length; --i >= 0;) {
				var ext:Object = fileExtensions[i];
				if (!langHandlerRegistry.hasOwnProperty(ext)) {
					langHandlerRegistry[ext] = handler;
				}
			}
		}

		public function prettyPrintOne(sourceCodeHtml:String, opt_langExtension:String, buildHTML:Boolean = false):String
		{
			try {
				mainDecorations = null;
				if (!langHandlerRegistry.hasOwnProperty(opt_langExtension)) {
					var checkmark:RegExp = /^\s*?</;
					opt_langExtension = checkmark.test(sourceCodeHtml) ? 'default-markup' : 'default-code';
				}
				var decorations:Array = langHandlerRegistry[opt_langExtension].call({}, sourceCodeHtml);
				mainDecorations = decorations;
				if ( buildHTML ) {
					var extractedTags:Array = [];
					return recombineTagsAndDecorations(sourceCodeHtml, extractedTags, decorations);
				}
				return null;
			} catch (e:Error) {
			}
			return null;
		}

		public var asyncRunning:Boolean;
		private var pseudoThread:PseudoThread;
		private var pprintArgs:Array;
		private var chunksLen:int;

		public function prettyPrintAsync(sourceCodeHtml:String, opt_langExtension:String, completeFn:Function, intFn:Function, systemManagerIn:ISystemManager, buildHTML:Boolean = false):void
		{
			var sourceChunks:Array = new Array();
			var len:int = sourceCodeHtml.length;
			var i:int = 100;
			var end:int, start:int = 0, foundIndex:int;
			do {
				end = ( i >= len ) ? len : i;
				foundIndex = sourceCodeHtml.indexOf('\n', end);
				if ( foundIndex != -1 ) {
					i = foundIndex;
				} else {
					foundIndex = sourceCodeHtml.indexOf('\r', end);
					if ( foundIndex != -1 ) {
						i = foundIndex;
					}
				}
				end = ( i >= len ) ? len : i;
				sourceChunks.push(sourceCodeHtml.substring(start, end));
				i += 100;
				start = end;
			} while ( i < len );
			if ( start < i && start < len ) {
				sourceChunks[sourceChunks.length - 1] = sourceChunks[sourceChunks.length - 1] + sourceCodeHtml.substring(start);
			}
			chunksLen = sourceChunks.length;
			mainDecorations = new Array();
			mainHtml = "";
			prettyPrintStopAsyc = false;
			asyncRunning = true;
			pprintArgs = [sourceChunks, 0, completeFn, intFn, opt_langExtension, buildHTML];
			pseudoThread = new PseudoThread(systemManagerIn, prettyPrintAsyncWorker, this, pprintArgs, 1, 1);
		}

		private function prettyPrintAsyncWorker(sourceCodeArr:Array, sourceCodeIdx:int, completeFn:Function, intFn:Function, opt_langExtension:String, buildHTML:Boolean = false):Boolean
		{
			if ( prettyPrintStopAsyc ) {
				mainDecorations = null;
				mainHtml = "";
				asyncRunning = false;
				return false;
			}
			try {
				mainHtml += sourceCodeArr[sourceCodeIdx];
				var sourceAndExtractedTags:Object = {source:"", tags:(mainDecorations == null) ? [] : mainDecorations};
				if (!langHandlerRegistry.hasOwnProperty(opt_langExtension)) {
					var checkmark:RegExp = /^\s*?</;
					opt_langExtension = checkmark.test(mainHtml) ? 'default-markup' : 'default-code';
				}
				var decorations:Array = langHandlerRegistry[opt_langExtension].call({}, mainHtml);
				mainDecorations = decorations;
				if ( sourceCodeIdx + 1 == chunksLen ) {
					if ( buildHTML ) {
						var extractedTags:Array = sourceAndExtractedTags.tags;
						mainHtml = recombineTagsAndDecorations(mainHtml, extractedTags, decorations);
					}
					asyncRunning = false;
					completeFn();
				} else {
					if ( intFn != null ) {
						intFn(sourceCodeIdx, chunksLen);
					}
					return true;
				}
			} catch (e:Error) {
				asyncRunning = false;
				completeFn();
			}
			return false;
		}

		public function CodePrettyPrint()
		{
			regexpPrecederPattern();
			registerLangHandler(decorateSource, ['default-code']);
			registerLangHandler(decorateMarkup, ['default-markup', 'html', 'htm', 'xhtml', 'xml', 'xsl']);
			registerLangHandler(sourceDecorator({keywords:CPP_KEYWORDS, hashComments:true, cStyleComments:true}), ['c', 'cc', 'cpp', 'cs', 'cxx', 'cyc']);
			registerLangHandler(sourceDecorator({keywords:JAVA_KEYWORDS, cStyleComments:true}), ['java']);
			registerLangHandler(sourceDecorator({keywords:SH_KEYWORDS, hashComments:true, multiLineStrings:true}), ['bsh', 'csh', 'sh']);
			registerLangHandler(sourceDecorator({keywords:PYTHON_KEYWORDS, hashComments:true, multiLineStrings:true, tripleQuotedStrings:true}), ['cv', 'py']);
			registerLangHandler(sourceDecorator({keywords:PERL_KEYWORDS, hashComments:true, multiLineStrings:true, regexLiterals:true}), ['perl', 'pl', 'pm']);
			registerLangHandler(sourceDecorator({keywords:RUBY_KEYWORDS, hashComments:true, multiLineStrings:true, regexLiterals:true}), ['rb']);
			registerLangHandler(sourceDecorator({keywords:JSCRIPT_KEYWORDS, cStyleComments:true, regexLiterals:true}), ['js']);
		}
	}
}