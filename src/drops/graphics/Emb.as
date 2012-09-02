package drops.graphics {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class Emb {
		//-----------------------------------------------------------------
		//	S K I N S
		//-----------------------------------------------------------------
		[Embed(source="/img/button_plus.png")]
		private static const EMB_BUTTON_PLUS:Class;
		public static const BUTTON_PLUS:BitmapData = (new EMB_BUTTON_PLUS() as Bitmap).bitmapData;
		
		[Embed(source="/img/button_minus.png")]
		private static const EMB_BUTTON_MINUS:Class;
		public static const BUTTON_MINUS:BitmapData = (new EMB_BUTTON_MINUS() as Bitmap).bitmapData;
		
		[Embed(source="/img/scrollbar_btn_top.png")]
		private static const EMB_SCROLLBAR_TOP:Class;
		public static const SCROLLBAR_TOP:BitmapData = (new EMB_SCROLLBAR_TOP() as Bitmap).bitmapData;
		
		[Embed(source="/img/scrollbar_btn_bottom.png")]
		private static const EMB_SCROLLBAR_BOTTOM:Class;
		public static const SCROLLBAR_BOTTOM:BitmapData = (new EMB_SCROLLBAR_BOTTOM() as Bitmap).bitmapData;
		
		[Embed(source="/img/scrollbar_track.png")]
		private static const EMB_SCROLLBAR_TRACK:Class;
		public static const SCROLLBAR_TRACK:BitmapData = (new EMB_SCROLLBAR_TRACK() as Bitmap).bitmapData;
		
		[Embed(source="/img/scrollbar_pointer.png")]
		private static const EMB_SCROLLBAR_POINTER:Class;
		public static const SCROLLBAR_POINTER:BitmapData = (new EMB_SCROLLBAR_POINTER() as Bitmap).bitmapData;
		
		[Embed(source="/img/scrollbar_icon_top.png")]
		private static const EMB_SCROLLBAR_ICON_TOP:Class;
		public static const SCROLLBAR_ICON_TOP:BitmapData = (new EMB_SCROLLBAR_ICON_TOP() as Bitmap).bitmapData;
		
		[Embed(source="/img/scrollbar_icon_bottom.png")]
		private static const EMB_SCROLLBAR_ICON_BOTTOM:Class;
		public static const SCROLLBAR_ICON_BOTTOM:BitmapData = (new EMB_SCROLLBAR_ICON_BOTTOM() as Bitmap).bitmapData;
		
		[Embed(source="/img/scrollbar_icon_pointer.png")]
		private static const EMB_SCROLLBAR_ICON_POINTER:Class;
		public static const SCROLLBAR_ICON_POINTER:BitmapData = (new EMB_SCROLLBAR_ICON_POINTER() as Bitmap).bitmapData;
		
		[Embed(source="/img/colorpicker_h_picker.png")]
		private static const EMB_H_PICKER:Class;
		public static const H_PICKER:BitmapData = (new EMB_H_PICKER() as Bitmap).bitmapData;
		
		[Embed(source="/img/colorpicker_sb_picker.png")]
		private static const EMB_SB_PICKER:Class;
		public static const SB_PICKER:BitmapData = (new EMB_SB_PICKER() as Bitmap).bitmapData;
		
		[Embed(source="/img/alert_bg.png")]
		private static const EMB_ALERT_BG:Class;
		public static const ALERT_BG:BitmapData = (new EMB_ALERT_BG() as Bitmap).bitmapData;
		
		[Embed(source="/img/alert_button.png")]
		private static const EMB_ALERT_BUTTON:Class;
		public static const ALERT_BUTTON:BitmapData = (new EMB_ALERT_BUTTON() as Bitmap).bitmapData;
		
		[Embed(source="/img/alert_progress_track.png")]
		private static const EMB_ALERT_PROGRESS_TRACK:Class;
		public static const ALERT_PROGRESS_TRACK:BitmapData = (new EMB_ALERT_PROGRESS_TRACK() as Bitmap).bitmapData;
		
		[Embed(source="/img/alert_progress_progress.png")]
		private static const EMB_ALERT_PROGRESS_PROGRESS:Class;
		public static const ALERT_PROGRESS_PROGRESS:BitmapData = (new EMB_ALERT_PROGRESS_PROGRESS() as Bitmap).bitmapData;
		
		//-----------------------------------------------------------------
		//	C U R S O R S
		//-----------------------------------------------------------------
		[Embed(source="/img/cursors/small_hand.png")]
		private static const EMB_CURSOR_SMALL_HAND:Class;
		public static const CURSOR_SMALL_HAND:BitmapData = (new EMB_CURSOR_SMALL_HAND() as Bitmap).bitmapData;
	}

}