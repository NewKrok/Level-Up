package levelup.util;

import h3d.col.Point;
import hpp.util.GeomUtil.SimplePoint;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GeomUtil3D
{
	public static function isPointInATriangle(p:SimplePoint, trianglePoint1:SimplePoint, trianglePoint2:SimplePoint, trianglePoint3:SimplePoint)
	{
		var d1 = sign(p, trianglePoint1, trianglePoint2);
		var d2 = sign(p, trianglePoint2, trianglePoint3);
		var d3 = sign(p, trianglePoint3, trianglePoint1);

		return !(((d1 < 0) || (d2 < 0) || (d3 < 0)) && ((d1 > 0) || (d2 > 0) || (d3 > 0)));
	}

	static function sign(p1:SimplePoint, p2:SimplePoint, p3:SimplePoint)
	{
		return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
	}

	public static function zFromTriangle(pos:SimplePoint, p1:Point, p2:Point, p3:Point)
	{
		var calc1 = ((p2.x - p1.x) * (p3.z - p1.z) - (p3.x - p1.x) * (p2.z - p1.z));
		var calc2 = ((p2.x - p1.x) * (p3.y - p1.y) - (p3.x - p1.x) * (p2.y - p1.y));
		var calc3 = ((p2.y - p1.y) * (p3.z - p1.z) - (p3.y - p1.y) * (p2.z - p1.z));
		var calc4 = ((p2.x - p1.x) * (p3.y - p1.y) - (p3.x - p1.x) * (p2.y - p1.y));

		return p1.z + (calc1 / calc2) * (pos.y - p1.y) - (calc3 / calc4) * (pos.x - p1.x);
	}
}