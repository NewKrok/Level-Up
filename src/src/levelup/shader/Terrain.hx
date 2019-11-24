package levelup.shader;

import h3d.shader.BaseMesh;
import hxsl.Shader;
import hxsl.Types.Sampler2D;
import hxsl.Types.Vec;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Terrain extends Shader
{
	static var SRC =
	{
		@:import h3d.shader.BaseMesh;

		var calculatedUV : Vec2;

		//@param var heightMap:Array[Array[Float]];
		//@param var blockSize:Float = 1;
		//@param var t:Sampler2D;


		function vertex()
		{
			relativePosition.z = 5 * sin(input.position.y);//sin(relativePosition.y * global.time) * 5;//heightMap[floor(relativePosition.x / blockSize) * blockSize][floor(relativePosition.y / blockSize * blockSize)];
			//relativePosition.z += amplitude * cos(global.time * speed);
		}

		/*function fragment() {
			relativePosition.z = 5 * sin(input.position.y + global.time);
		}*/

		/*function fragment() {
			var n = transformedNormal;
			var nf = unpackNormal(t.get(calculatedUV));
			//var tanX = transformedTangent.xyz.normalize();
			//var tanY = n.cross(tanX) * -transformedTangent.w;
			transformedNormal = (nf.x + nf.y + nf.z * n);//.normalize();
		}*/
	}
}