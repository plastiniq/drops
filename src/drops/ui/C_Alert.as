package drops.ui {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Background;
	import drops.data.C_Emboss;
	import drops.data.C_Mounts;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.data.C_TaskEntry;
	import drops.graphics.Emb;
	import drops.utils.C_Accessor;
	import drops.utils.C_Text;
	import com.greensock.plugins.TransformMatrixPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Alert {
		
		public static var visible:Boolean = false;
		
		private static const _mirror:Bitmap = new Bitmap();
		private static const _box:Sprite = new Sprite();
		private static const _window:C_SkinnableBox = new C_SkinnableBox();
		private static const _title:C_Label = new C_Label('undefined');
		private static const _textArea:C_TextField = new C_TextField();
		private static const _progressBar:C_ProgressBar = new C_ProgressBar();
		private static const _buttons:C_ButtonBar = new C_ButtonBar();
		private static const _buttonsCache:Vector.<C_Button> = new Vector.<C_Button>();
		private static const _buttonsTextFormat:TextFormat = C_Text.defineFormat(null, 11, null, 0x312d36, 'Tahoma', true);
		private static const _turnTimer:Timer = new Timer(0, 1);
		
		private static var _stage:Stage;
		private static var _stack:Vector.<C_TaskEntry> = new Vector.<C_TaskEntry>();
		private static var _padding:Number;
		private static var _leading:Number;
		private static var _animationBegin:Boolean;
		
		private static const BUTTON_SAMPLE:C_Button = new C_Button();
		BUTTON_SAMPLE.skin.background = new C_Background(Emb.ALERT_BUTTON, null, new Rectangle(8, 8, 4, 10));
		BUTTON_SAMPLE.textFormat = _buttonsTextFormat;
		BUTTON_SAMPLE.label.emboss = new C_Emboss(0.5, 0.15);
		
			
		private static var _closeFunc:Function;
		
		init();
		
		//---------------------------------------------------------------------------
		//	H A N D L E R S
		//---------------------------------------------------------------------------
		private static function turnTimerHandler(e:TimerEvent):void {
			_window.visible = false;
			_mirror.visible = true;
			scaleAroundCenter(_mirror, 0, 0.94, 0.1, completeAnimation);
			visible = false;
		}
		
		private static function resizeStageHandler(e:Event):void {
			refreshBg();
			center();
		}
		
		private static function completeAnimation():void {
			_animationBegin = false;
			if (visible) {
				replaceMirror();
			}
			else {
				if (_stage && _box.parent == _stage) _stage.removeChild(_box);
				_progressBar.visible = false;
			}
			
			var i:int = -1;
			while (++i < _stack.length) {
				setValue(_stack[i].method, _stack[i].target, _stack[i].value);
			}
			_stack.length = 0;
		}
		
		private static function buttonsClickHandler(e:Event):void {
			if (_closeFunc !== null) {
				_closeFunc.apply(_closeFunc, [e.target.text]);
			}
			hide();
		}
		
		//---------------------------------------------------------------------------
		//	S E T  /  G E T
		//---------------------------------------------------------------------------
		public static function get stage():Stage {
			return _stage;
		}
		
		public static function set stage(stage:Stage):void {
			if (stage !== null) {
				stage.addEventListener(Event.RESIZE, resizeStageHandler);
			}
			else if (_stage) {
				_stage.removeEventListener(Event.RESIZE, resizeStageHandler);
			}
			_stage = stage;
			refreshBg();
		}
		
		public static function set buttons(value:Array):void {
			if (_animationBegin) {
				_stack.push( new C_TaskEntry('buttons', C_Alert, value) );
			}
			else {
				buildButtons(value);
				refresh();
			}
		}
		
		public static function get message():String {
			return _textArea.text;
		}
		
		public static function set message(value:String):void {
			if (_animationBegin) {
				_stack.push( new C_TaskEntry('message', C_Alert, value) );
			}
			else {
				_textArea.text = value;
				refresh();
			}
		}
		
		public static function get title():String {
			return _title.text;
		}
		
		public static function set title(value:String):void {
			if (_title.text == value) return;
			_title.text = value;
			refresh();
		}
		
		public static function get progress():Number {
			return _progressBar.progress;
		}
		
		public static function set progress(value:Number):void {
			if (_animationBegin) {
				_stack.push( new C_TaskEntry('progress', C_Alert, value) );
			}
			else {
				_progressBar.progress = value;
				
				if (value < 0) {
					if (_progressBar.visible) {
						_progressBar.visible = false;
						if (visible) refresh();
					}
				}
				else {
					if (_progressBar.visible == false) {
						_progressBar.visible = true;
						if (visible) refresh();
					}
				}
			}
		}
		
		//---------------------------------------------------------------------------
		//	P U B L I C
		//---------------------------------------------------------------------------
		public static function hide(delay:Number = 0):void {
			_turnTimer.delay = delay;
			_turnTimer.reset();
			_turnTimer.start();
		}
		
		public static function show(title:String = 'undefined', message:String = null, buttons:Array = null, onClose:Function = null, vars:Object = null):void {
			_turnTimer.stop();
			buildButtons(buttons);
			_title.text = title;
			_closeFunc = onClose;
			_textArea.text = message;
			refresh();
			center();
			
			if (!visible) {
				if (_stage) {
					_stage.addChild(_box);
					_box.visible = true;
					_window.visible = false;
					_mirror.visible = true;
					_mirror.alpha = 0.5;
					scaleAroundCenter(_mirror, 0.5, 0.85, 0);
					scaleAroundCenter(_mirror, 1, 1, 0.15, completeAnimation);
				}
				visible = true;
			}

			if (vars && vars.onCompleteShow) {
				if (_animationBegin) {
					_stack.push(new C_TaskEntry(vars.onCompleteShow, C_Alert, vars.onCompleteArgs));
				}
				else {
					setValue(vars.onCompleteShow, null, vars.onCompleteArgs);
				}
			}
		}
		
		//---------------------------------------------------------------------------
		//	P R I V A T E
		//---------------------------------------------------------------------------
		private static function refresh():void {
			var oY:int = 0;
			
			_title.x = _padding;
			_title.y = _padding;
			oY += _title.y + _title.height + _leading + 2;
			
			if (_textArea.text) {
				_textArea.mounts = new C_Mounts(_padding, _padding, oY);
				oY += _textArea.height;
			}
	
			if (_progressBar.visible) {
				oY -= 4;
				_progressBar.mounts = new C_Mounts(_padding, _padding, oY);
				oY += _progressBar.height + _leading;
			}
			
			if (_buttons.visible) {
				_buttons.y = Math.round(oY);
				_buttons.x = Math.round((_window.width * 0.5) - (_buttons.width * 0.5));
				oY += _buttons.height + _leading;
			}
	
			_window.height = (_buttons.visible) ? oY : oY + (_padding - _leading);
			
			_mirror.bitmapData = new BitmapData(_window.width, _window.height, true, 0xffffff);
			_mirror.bitmapData.draw(_window, null, null);
			_mirror.smoothing = true;
		}
		
		private static function init():void {
			TweenPlugin.activate([TransformMatrixPlugin]);
			_padding = 14;
			_leading = 8;

			_box.visible = false;
			_box.addChild(_mirror);

			_window.width = 354;
			_window.visible = false;
			_box.addChild(_window);
			
			_title.textFormat = C_Text.defineFormat(_title.textFormat, 11, null, 0xd1cbd6, null, true);
			_title.emboss = new C_Emboss(0, 1, true, 1, 1);
			_window.addChild(_title);
			
			_textArea.textFormat = C_Text.defineFormat(null, 12, null, 0xd1cbd6, null);
			_textArea.autoHeight = true;
			_textArea.selectable = true;
			_window.addChild(_textArea);
			
			initProgressBar();
			_progressBar.visible = false;
			_window.addChild(_progressBar);
			
			_buttons.itemSample = BUTTON_SAMPLE;
			_buttons.height = Emb.ALERT_BUTTON.height;
			_buttons.toggle = false;
			_buttons.fit = C_ButtonBar.NONE;
			_buttons.addEventListener(MouseEvent.CLICK, buttonsClickHandler);
			
			var format:TextFormat = C_Text.defineFormat(null, 11, null, 0x312d36, 'Tahoma', true);
			
			_buttonsCache.push(newButton());
			_buttonsCache.push(newButton());
			
			_buttons.spacing = 6;
			_window.addChild(_buttons);
			
			_turnTimer.addEventListener(TimerEvent.TIMER, turnTimerHandler);
			_window.skin.background = new C_Background(Emb.ALERT_BG, null, new Rectangle(15, 15, 3, 3));
			
			refresh();
		}
		
		private static function initProgressBar():void {
			_progressBar.height = Emb.ALERT_PROGRESS_PROGRESS.height;
			_progressBar.track.skin.background = new C_Background(Emb.ALERT_PROGRESS_TRACK, null, new Rectangle(2, 5, 3, 3));
			_progressBar.progressTrack.skin.background = new C_Background(Emb.ALERT_PROGRESS_PROGRESS, null, new Rectangle(2, 5, 3, 3));
		}
		
		private static function replaceMirror():void {
			_mirror.visible = false;
			_window.visible = true;
		}
		
		private static function setValue(method:*, target:*, data:* = null):void {
			if (target === null) target = C_Alert;
			if (data === undefined) data = null;
			if (data !== null) data = (data is Array) ? data : [data];
					
			if (method is String && target !== null && target.hasOwnProperty(method)) {
				if (target[method] is Function) {
					(target[method] as Function).apply(target, data);
				}
				else {
					target[method] = data;
				}
			}
			else if (method is Function) {
				(method as Function).apply(target, data);
			}
		}
		
		private static function buildButtons(names:Array):void {
			_buttons.clear();
			if (names === null) {
				_buttonsCache[0].text = 'OK';
				_buttons.addItem(_buttonsCache[0]);
			}
			else if (names.length > 0){
				var i:int = -1;
				while (++i < names.length) {
					if (i > (_buttonsCache.length - 1)) {
						_buttonsCache.push(newButton(names[i]));
					}
					else {
						_buttonsCache[i].text = names[i];
					}
					_buttons.addItem(_buttonsCache[i]);
				}
			}
			
			_buttons.visible = (names !== null && names.length > 0);
		}
		
		private static function newButton(label:String = null):C_Button {
			var btn:C_Button = new C_Button(label);
			btn.height = Emb.ALERT_BUTTON.height;
			return btn;
		}
		
		private static function refreshBg():void {
			if (_stage) {
				_box.graphics.beginFill(0, 0);
				_box.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
			}
		}
		
		private static function center():void {
			if (_stage) {
				_window.x = int((_stage.stageWidth * 0.5) - (_window.width * 0.5));
				_window.y = int((_stage.stageHeight * 0.5) - (_window.height * 0.5));
				_mirror.x = int((_stage.stageWidth * 0.5) - (_mirror.width * 0.5));
				_mirror.y = int((_stage.stageHeight * 0.5) - (_mirror.height * 0.5));
			}
		}
		
		private static function scaleAroundCenter(obj:DisplayObject, alpha:Number = 1, scale:Number = 1.0, time:Number = 0.2, onComplete:Function = null):void {
			var startW:Number = obj.width / obj.transform.matrix.a;
			var startH:Number = obj.height / obj.transform.matrix.d;
			
			var startX:Number = obj.x - ((startW - obj.width) * 0.5);
			var startY:Number = obj.y - ((startH - obj.height) * 0.5);
			
			var tx:Number = startX + (startW - (startW * scale)) * 0.5;
			var ty:Number = startY + (startH - (startH * scale)) * 0.5;
			
			_animationBegin = true;
			var vars:Object = { alpha:alpha, transformMatrix: { a:scale, b:0, c:0, d:scale, tx:tx, ty:ty }};
			if (onComplete !== null) vars.onComplete = onComplete;
			TweenMax.to(obj, time, vars);
		}
	}
}