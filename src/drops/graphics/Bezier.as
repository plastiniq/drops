package drops.graphics {
	//import fl.motion.BezierSegment;
	import flash.display.GraphicsPath;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Dmitry M.
	 */
	public class Bezier {
		/*public static function getGraphicsPath(prevPt:BezierPoint, nextPt:BezierPoint):GraphicsPath {
			var path:GraphicsPath = new GraphicsPath();
			
			var nC:Point = prevPt.nextControl ? prevPt.getAbsNextControl() : prevPt.getCoord();
			var pC:Point = nextPt.prevControl ? nextPt.getAbsPrevControl() : nextPt.getCoord();
			
			//path.moveTo(prevPt.getCoord().x, prevPt.getCoord().y);
			//path.cubicCurveTo(nC.x, nC.y, pC.x, pC.y, nextPt.getCoord().x, nextPt.getCoord().y);
			
			path = getQuadBezierPath(prevPt.getCoord(), nC, pC, nextPt.getCoord());
			return path;
		}*/

		public static function getQuadBezierPath(a1:Point, c1:Point, c2:Point, a2:Point):GraphicsPath {
			/*var anchor1:Point = a1.clone();
			var anchor2:Point = a2.clone();
			
			var control1:Point = c1 ? c1.clone() : a1.clone();
			var control2:Point = c2 ? c2.clone() : a2.clone();
			
			var segment:BezierSegment = new BezierSegment(anchor1, control1, control2, anchor2);
			
			var resolution:int = 10;
			var t:Number = 0.;
			var steps:Number = 1. / resolution;
			
			var sliceStart:Point = anchor1;
			var sliceStartTangent:Array = [sliceStart, control1];
			
			var path:GraphicsPath = new GraphicsPath();
			path.moveTo(anchor1.x, anchor1.y);
			
			for (var i:int = 1; i <= resolution; i++) {
				t += steps;
				var sliceEnd:Point = segment.getValue(t);
				
				var sliceEndTangent:Array = calcTangent(t, anchor1, control1, control2, anchor2);
				var quadControl:Point = checkIntersection(sliceStartTangent[0], sliceStartTangent[1], sliceEndTangent[0], sliceEndTangent[1]);
				
				if((Point.distance(quadControl, sliceStart) <= Point.distance(sliceStart, sliceEnd)) && (Point.distance(quadControl, sliceEnd) <= Point.distance(sliceStart, sliceEnd))) {
					sliceStartTangent = sliceEndTangent;
				}
				else {
					t -= steps / 2;
					sliceEnd = segment.getValue(t);
					sliceEndTangent = calcTangent(t, anchor1, control1, control2, anchor2);
					quadControl = checkIntersection(sliceStartTangent[0], sliceStartTangent[1], sliceEndTangent[0], sliceEndTangent[1]);
					
					path.moveTo(sliceStart.x, sliceStart.y);
					path.curveTo(quadControl.x, quadControl.y, sliceEnd.x, sliceEnd.y);
					
					t += steps / 2;
					sliceStart = sliceEnd;
					sliceStartTangent = sliceEndTangent;
					sliceEnd = segment.getValue(t);
					sliceEndTangent = calcTangent(t, anchor1, control1, control2, anchor2);
					quadControl = checkIntersection(sliceStartTangent[0], sliceStartTangent[1], sliceEndTangent[0], sliceEndTangent[1]);
					sliceStartTangent = sliceEndTangent;
				}
				
				path.moveTo(sliceStart.x, sliceStart.y);
				path.curveTo(quadControl.x, quadControl.y, sliceEnd.x, sliceEnd.y);
				sliceStart=sliceEnd;
			}
			
			return path;*/
			return new GraphicsPath();
		}
		
		private static function calcTangent(t:Number, anchor1:Point, control1:Point, control2:Point, anchor2:Point):Array {
			var m_1:Point = Point.interpolate(control1, anchor1, t);
			var m_2:Point = Point.interpolate(control2, control1, t);
			var m_3:Point = Point.interpolate(anchor2, control2, t);
			var h_3:Point = Point.interpolate(m_2, m_1, t);
			var h_4:Point = Point.interpolate(m_3, m_2, t);
			
			return [h_3, h_4];
		}
		
		private static function checkIntersection(p1:Point, p2:Point, p3:Point, p4:Point):Point {
			var numerator_uA:Number = (p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x);
			var denominator_uA:Number = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y);

			var uA:Number = numerator_uA / denominator_uA;
			var numerator_uB:Number = (p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x);
			var denominator_uB:Number = denominator_uA;
			var uB:Number = numerator_uB / denominator_uB;
			
			var s1:Point = (denominator_uA == 0) ? p1 : new Point((p1.x + uA * (p2.x - p1.x)), (p1.y + uA * (p2.y - p1.y)));
			return (s1);
		}
	}

}