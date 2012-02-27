package drops.utils {
	import com.adobe.net.MimeTypeMap;
	import drops.data.C_Emboss;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.CSMSettings;
	import flash.text.engine.CFFHinting;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.Kerning;
	import flash.text.engine.LigatureLevel;
	import flash.text.engine.RenderingMode;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.TextColorType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.Font;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextRenderer;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Text {
		public static const FORMAT_PROPS:Array = ["font", "size", "color", "bold", "italic", "underline", "url", "target", "align", "leftMargin", "rightMargin", "indent", "leading"];
		
		
		public static function defineFormat(format:TextFormat = null, 
											fontSize:Object = null,  
											align:String = null, 
											color:Object = null,
											font:String = null, 
											bold:Object = null, 
											italic:Object = null):TextFormat {
			
												
			if (!format) {
				format = new TextFormat();
				format.kerning = true;
				format.size = 13;
				format.color = 0x241d1d;
				format.align = "left";
				format.blockIndent = 0;
				format.indent = 0;
				format.leading = 2;
				format.leftMargin = 0;
				
				var myEmbeddedFonts:Array = Font.enumerateFonts(true);
				var i:int = myEmbeddedFonts.length;
				var styleName:String;
				
				if (bold && italic) {
					styleName = 'boldItalic';
				}
				else if(bold) {
					styleName = 'bold';
				}
				else if (italic) {
					styleName = 'italic';
				}
				else {
					styleName = 'regular';
				}
				while (--i > -1) {
					if (myEmbeddedFonts[i].fontStyle == styleName) {
						format.font = myEmbeddedFonts[i].fontName;
					}
				}
				
				if (!format.font) format.font = '_serif';
			}
			else {
				format = cloneFormat(format);
			}

			if (fontSize !== null)	format.size = fontSize;
			if (align !== null)		format.align = align;
			if (color !== null)		format.color = color;
			if (font !== null)		format.font = font;
			if (bold != null) 		format.bold = bold;
			if (italic != null)		format.italic = italic;

			return format;
		}

		public static function defineTF(tf:TextField = null,  
										text:String = null, 
										format:TextFormat = null,
										sizeRect:Rectangle = null, 
										multi:Object = null, 
										select:Object = null):TextField {
			
			var newField:Boolean;
			if (!tf) {
				tf = new TextField();
				newField = true;
			}
			
			if (!format) format = C_Text.defineFormat();
			
			if (TextField.isFontCompatible(format.font, "normal") || TextField.isFontCompatible(format.font, "bold")) {
				tf.embedFonts = true;
				tf.antiAliasType = AntiAliasType.ADVANCED;
				tf.gridFitType = GridFitType.PIXEL;
				tf.thickness = -30;
				tf.sharpness = 60;
				var csmSettings:CSMSettings = new CSMSettings(format.size as Number, 0.4, -0.4);
				TextRenderer.setAdvancedAntiAliasingTable(format.font, "normal", TextColorType.DARK_COLOR, [csmSettings]);
				TextRenderer.setAdvancedAntiAliasingTable(format.font, "bold", TextColorType.DARK_COLOR, [csmSettings]);
			}
			else {
				tf.embedFonts = false;
			}
			
			if (text) tf.text = text;
			if (format) {
				tf.setTextFormat(format);
				tf.defaultTextFormat = format;
			}
			if (sizeRect) {
				tf.x = sizeRect.x;
				tf.y = sizeRect.y;
			}

			if (multi != null) tf.multiline = multi;
			if (select != null) tf.selectable = select;

			if (newField) autoSize(tf, sizeRect);
			
			return tf;
		}
		
		public static function cloneFormat(source:TextFormat, target:TextFormat = null):TextFormat {
			if (!source) return null;
			if (!target) target = new TextFormat();
			var prop:String;
			
			for each (prop in FORMAT_PROPS) {
				target[prop] = source[prop];
			}
			return target;
		}
		
		public static function clone(source:TextField, target:TextField = null):TextField {
			if (!target) target = new TextField();
			
			with (target) {
				defaultTextFormat = source.getTextFormat();
				x = source.x;
				y = source.y;
				align = source.align;
				width = source.width;
				height = source.height;
				text = source.text;
				multiline = source.multiline;
				selectable = source.selectable;
				embedFonts = source.embedFonts;
				antiAliasType = source.antiAliasType;
				gridFitType = source.gridFitType;
				sharpness = source.sharpness;
				type = source.type;
			}
			
			return target;
		}
		
		public static function formatToElementFormat(format:TextFormat, renderingMode:String = 'cff'):ElementFormat {
			var weight:String = (format.bold) ?  FontWeight.BOLD : FontWeight.NORMAL; 
			var posture:String = (format.italic) ? FontPosture.ITALIC : FontPosture.NORMAL;
			var fName:String = (format.font) ? format.font : '_serif';
			var fLookup:String = (FontDescription.isFontCompatible(format.font, weight, posture)) ? FontLookup.EMBEDDED_CFF : FontLookup.DEVICE;
			var fd:FontDescription = new FontDescription(fName, weight, posture, fLookup, renderingMode, CFFHinting.HORIZONTAL_STEM);
			var ef:ElementFormat = new ElementFormat(fd, Number(format.size), uint(format.color));
			ef.kerning = Kerning.AUTO;
			return ef;
		}
		
		public static function autoSize(tf:TextField, sizeRect:Rectangle = null):TextField {
			tf.width = (sizeRect == null || (!sizeRect.width) || sizeRect.width == -1) ? tf.textWidth + 4 : sizeRect.width;
			tf.height = (sizeRect == null || (!sizeRect.height)  || sizeRect.height == -1) ? Math.max(4, tf.textHeight + (tf.numLines * 2)) : sizeRect.height;
			//tf.text = tf.text; //	Need for update scroll value
			return tf;
		}
		
		public static function autoFontSize(tf:TextField):TextField {
			C_Text.defineTF(tf, null, C_Text.defineFormat(tf.getTextFormat(), tf.height * 0.8 - 2));
			return tf;
		}
		
		public static function baseLine(tf:TextField):Number {
			//return tf.textHeight - tf.getLineMetrics(0).descent - tf.getLineMetrics(0).leading;
			return tf.y + tf.getLineMetrics(0).ascent + 2;
		}
		
		public static function embossField(target:DisplayObject, emboss:C_Emboss):* {
			var filters:Array = [];
			if (emboss !== null) {
				if (emboss.innerStrength > 0) filters.push(new DropShadowFilter(1, 90, (emboss.invert) ? 0xffffff : 0x000000, 1, emboss.blurX, emboss.blurY, emboss.innerStrength, 1, true));
				if (emboss.dropStrength > 0) filters.push(new DropShadowFilter(1, 90, (emboss.invert) ? 0x000000 : 0xffffff, 1, emboss.blurX, emboss.blurY, emboss.dropStrength, 1, false));
			}
			target.filters = filters;
			return target;
		}
		
		public static function compareFormat(format1:TextFormat, format2:TextFormat):Array {
			if (!format1 || !format2) return null;
			if (format1 === format2) return [];
			var i:int = FORMAT_PROPS.length;
			var result:Array = [];
			var prop:String;
			
			while (--i > -1) {
				prop = FORMAT_PROPS[i];
				if (format1[prop] !== format2[prop]) result.push(prop);
			}
			return result;
		}
		
	}

}