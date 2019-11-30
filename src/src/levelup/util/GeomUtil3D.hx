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

	public static function getHeightByPosition(heightGrid:Array<Point>, posX:Float, posY:Float)
	{
		var worldPosX = Math.floor(posX);
		var worldPosY = Math.floor(posY);
		var pos = { x: posX, y: posY };

		var pLT = searchForPoint(heightGrid, worldPosX, worldPosY);
		var pRT = searchForPoint(heightGrid, worldPosX + 1, worldPosY);
		var pLB = searchForPoint(heightGrid, worldPosX, worldPosY + 1);
		var pRB = searchForPoint(heightGrid, worldPosX + 1, worldPosY + 1);

		var triangleCheckA = GeomUtil3D.isPointInATriangle(pos, pLT, pRT, pLB);
		var triangleCheckB = GeomUtil3D.isPointInATriangle(pos, pLT, pRT, pRB);
		var triangleCheckC = GeomUtil3D.isPointInATriangle(pos, pRT, pRB, pLB);
		var triangleCheckD = GeomUtil3D.isPointInATriangle(pos, pLT, pRB, pLB);

		if (triangleCheckA && triangleCheckB)
		{
			if (pLT.z < pRB.z)
			{
				return GeomUtil3D.zFromTriangle(pos, pLT, pRT, pLB);
			}
			else
			{
				return GeomUtil3D.zFromTriangle(pos, pLT, pRT, pRB);
			}
		}
		else if (triangleCheckB && triangleCheckC)
		{
			if (pRT.z < pRB.z)
			{
				return GeomUtil3D.zFromTriangle(pos, pLT, pRT, pLB);
			}
			else
			{
				return GeomUtil3D.zFromTriangle(pos, pRT, pRB, pLB);
			}
		}
		else if (triangleCheckC && triangleCheckD)
		{
			if (pRB.z < pLB.z)
			{
				return GeomUtil3D.zFromTriangle(pos, pRT, pRB, pLB);
			}
			else
			{
				return GeomUtil3D.zFromTriangle(pos, pLT, pRB, pLB);
			}
		}
		else if (triangleCheckD && triangleCheckA)
		{
			if (pLB.z < pLT.z)
			{
				return GeomUtil3D.zFromTriangle(pos, pLT, pRT, pLB);
			}
			else
			{
				return GeomUtil3D.zFromTriangle(pos, pLT, pRB, pLB);
			}
		}

		return 0;
	}

	public static function searchForPoint(heightGrid:Array<Point>, posX:Float, posY:Float)
	{
		for (p in heightGrid) if (p.x == posX && p.y == posY) return p;
		return new Point(posX, posY, 0);
	}
}