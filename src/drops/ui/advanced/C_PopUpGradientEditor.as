package drops.ui.advanced {
	import drops.core.C_Box;
	import drops.data.C_Mounts;
	import drops.data.C_Skin;
	import drops.data.effects.C_GradientData;
	import drops.events.C_Event;
	import drops.ui.C_Button;
	import drops.ui.C_TileBox;
	import drops.ui.C_Window;
	import drops.ui.C_WindowActionType;
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_PopUpGradientEditor extends C_Button {
		private static const _editor:C_GradientEditor = new C_GradientEditor();;
		private static const _window:C_Window = createWindow(_editor, 80, 3);
			
		private var _gradientMatrix:Matrix;
		
		private var _cancelColors:Array;
		private var _cancelAlphas:Array;
		private var _cancelRatios:Array;
		
		private var _colors:Array;
		private var _alphas:Array;
		private var _ratios:Array;
		
		private var _gradientData:C_GradientData;
		
		public function C_PopUpGradientEditor() {
			_gradientMatrix = new Matrix();

			_colors = [0xff0000, 0xffff00];
			_alphas = [1, 1];
			_ratios = [0, 255];
			
			_gradientData = new C_GradientData(_colors, _alphas, _ratios);
			
			skin = new C_Skin();
			
			addEventListener(C_Event.RESIZE, resizeHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			refreshSample();
		}
		
		//-----------------------------------------------------------------
		//	H A N D L E R S
		//-----------------------------------------------------------------
		private function clickHandler(e:MouseEvent):void {
			expand();
		}
		
		private function editorChangeHandler(inside:Boolean, complete:Boolean):void {
			_colors = _editor.colors.slice();
			_alphas = _editor.alphas.slice();
			_ratios = _editor.ratios.slice();

			change(false, inside);
			
			if (complete) {
				change(true, inside);
			}
		}
		
		private function resizeHandler(e:C_Event):void {
			refreshSample();
		}
		
		//-----------------------------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------------------------
		public function get gradientData():C_GradientData {
			_gradientData.colors = _colors;
			_gradientData.alphas = _alphas;
			_gradientData.ratios = _ratios;
			return _gradientData;
		}
		
		public function set gradientData(value:C_GradientData):void {
			_gradientData  = value;
			
			if (value) {
				_colors = value.colors;
				_alphas = value.alphas;
				_ratios = value.ratios;
			}
			else {
				_colors = [];
				_alphas = [];
				_ratios = [];
			}
			
			_editor.load(_colors, _alphas, _ratios);
			refreshSample();
		}
		
		public function get editor():C_GradientEditor {
			return _editor;
		}
		
		public function get window():C_Window {
			return _window;
		}
		
		//-----------------------------------------------------------------
		//	P U B L I C
		//-----------------------------------------------------------------
		public function turn():void {
			_window.turn();
		}
		
		public function expand():void {
			if (stage) {
				if (_window.parent !== stage) {
					stage.addChild(_window);
					_window.x = Math.min(stage.stageWidth - _window.width, stage.mouseX);
					_window.y = Math.min(stage.stageHeight - _window.height, stage.mouseY);
				}
				
				_cancelColors = _colors.slice();
				_cancelAlphas = _alphas.slice();
				_cancelRatios = _ratios.slice();
				
				_editor.load(_colors, _alphas, _ratios);
				_editor.changeFunction = editorChangeHandler;
				
				_window.actionHandler = handleWindow;
				_window.expand(false);
			}
		}
		
		//-----------------------------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------------------------
		private function refreshSample():void {
			_gradientMatrix.createGradientBox(width, height, 0, 0, 0);
			this.graphics.clear();
			this.graphics.beginGradientFill(GradientType.LINEAR, _colors, _alphas, _ratios, _gradientMatrix);
			this.graphics.drawRect(0, 0, width, height);
			
		}
		
		private function handleWindow(type:String):void {
			if (type == C_WindowActionType.APPLY) {
				_window.turn();
			}
			else if (type == C_WindowActionType.CANCEL) {
				_colors = _cancelColors;
				_alphas = _cancelAlphas;
				_ratios = _cancelRatios;
				
				change(false, true);
				change(true, true);

				_window.turn();
			}
		}

		private function change(complete:Boolean, inside:Boolean):void {
			if (complete) refreshSample();
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
		
		//---------------------------------------------------------------
		//	S T A T I C
		//---------------------------------------------------------------
		private static function createWindow(editor:C_GradientEditor, buttonsWidth:Number, buttonsSpacing:Number):C_Window {
			var window:C_Window = new C_Window('Gardient Editor', true);
			window.width = 250;
			window.height = 250;
			window.x = 400;
			window.y = 200;
			window.turn();
			window.animation = true;
			editor.mounts = new C_Mounts(0, buttonsWidth + 10, 0, 0);
			window.content.addChild(editor);
			
			var tBox:C_TileBox = new C_TileBox('100%');
			tBox.autoHeight = true;
			tBox.tileAutoHeight = true;
			tBox.tilePaddingBottom = buttonsSpacing;
			tBox.width = buttonsWidth;
			tBox.right = 0;
			window.content.addChild(tBox);
			
			var okButton:C_Button = new C_Button('Ok');
			okButton.mounts = new C_Mounts(0, 0);
			tBox.addChild(okButton);
			
			var cancelButton:C_Button = new C_Button('Cancel');
			cancelButton.mounts = new C_Mounts(0, 0);
			tBox.addChild(cancelButton);
			
			window.okButton = okButton;
			window.cancelButton = cancelButton;
			
			return window;
		}
	}

}