/**
 * Copyright 2010 Thanh Tran - trongthanh@gmail.com
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package vn.karaokeplayer.lyrics {
	import vn.karaokeplayer.karplayer_internal;
	import vn.karaokeplayer.Version;
	import vn.karaokeplayer.data.LyricStyle;
	import org.osflash.signals.Signal;
	import vn.karaokeplayer.data.BlockInfo;
	import vn.karaokeplayer.data.LineInfo;
	import flash.display.Sprite;
	/**
	 * A line of text
	 * @author Thanh Tran
	 * TODO: pass screen width from LyricPlayer and auto reduce font size if text line width exceed
	 */
	public class TextLine extends Sprite implements ISeekable, ILine {
		public static const VERSION: String = Version.VERSION;	
		
		private var _completed: Signal;
		public var blocks: Array;
		public var index: int;
		// these style are set from SongLyrics
		public var normalStyle: LyricStyle;
		public var syncStyle: LyricStyle;
		
		private var _data: LineInfo;
		/* number of blocks */
		private var _len: uint;
		private var _playing: Boolean;
		private var _complete: Boolean;
		/** milliseconds */
		private var _dur: Number = 0;
		/** milliseconds */
		private var _begin: Number;
		/** milliseconds */
		private var _pos: Number;

		public function TextLine() {
			_completed = new Signal(TextLine);
		}

		public function init(data: LineInfo): void {
			this._data = data;
			checkStyle();
			_len = data.lyricBlocks.length;
			_begin = data.startTime;
			_dur = data.duration;
			
			blocks = new Array();
			var blockInfo: BlockInfo;
			var block: TextBlock;
			var lastX: Number = 0;
			var begin: Number = data.startTime;
			for (var i : int = 0; i < _len; i++) {
				blockInfo = data.lyricBlocks[i];
				block = new TextBlock();
				block.setStyle(normalStyle, syncStyle);
				block.begin = begin;
				block.duration = blockInfo.duration;
				begin += blockInfo.duration; 
				block.text = blockInfo.text;
				block.completed.add(textBitCompleteHandler);
				blocks.push(block);
				if(i > 0) {
					TextBlock(blocks[i - 1]).next = block;
				}
				//render
				block.x = lastX;
				addChild(block);
				lastX += block.width;
			}
			
		}
		
		private function checkStyle(): void {
			syncStyle = _data.songLyrics.syncLyricStyle;
			switch(_data.styleName) {
				case LyricStyle.MALE:
					normalStyle = _data.songLyrics.maleLyricStyle;
					break;
				case LyricStyle.FEMALE:
					normalStyle = _data.songLyrics.femaleLyricStyle;
					break;
				case LyricStyle.BASIC:
				default:
					normalStyle = _data.songLyrics.basicLyricStyle;
			}
		}
		
		private function textBitCompleteHandler(tb: TextBlock): void {
//			trace('text bit ' + tb.text + ' complete, next:  ' + (tb.next));
			if(tb.next) {
				//tb.next.play();
			} else {
				_playing = false;
				_complete = true;
				_completed.dispatch(this);
			}
		}
		/*
		public function play(): void {
			for (var i : int = 0; i < _len; i++) {
				blocks[i].reset();
			}
			blocks[0].play();
			_playing = true;
		}
		*/
		public function reset(): void {
			for (var i : int = 0; i < _len; i++) {
				blocks[i].reset();
			}
		}

		public function dispose(): void {
			for (var i : int = 0; i < _len; i++) {
				blocks[i].dispose();
				removeChild(blocks[i]);
			}
			blocks = null;
			_playing = false;
			_complete = true;
		}
		
		
		public function get playing(): Boolean {
			return _playing;
		}
		
		public function get complete(): Boolean {
			return _complete;
		}
		
		override public function get width(): Number { 
			if (blocks && blocks.length) {
				var lastBlock: TextBlock = blocks[blocks.length - 1];
				return (lastBlock.x + lastBlock.karplayer_internal::noSpaceWidth);
			} else {
				return super.width; 
			}
		}
		
		override public function set width(value: Number): void {
			//super.width = value;
			trace("this component has read-only width");
		}
		
		override public function toString(): String {
			var str: String = "Line {";
			for (var i : int = 0; i < _len; i++) {
				str += blocks[i].text;
			}
			return str + "}";
		}
		
		public function get position(): Number {
			return _pos;
		}
				
		public function set position(value: Number): void {
			_pos = value;
			for (var i : int = 0; i < _len; i++) {
				blocks[i].position = _pos;
			}
		}
		public function get begin(): Number {
			return _begin;
		}
		
		public function get duration(): Number {
			return _dur;
		}
		
		public function get end(): Number {
			return _begin + _dur;
		}
		
		/* complete event, param: TextLine */
		public function get completed(): Signal {
			return _completed;
		}
	}
}