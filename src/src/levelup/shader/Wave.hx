package levelup.shader;

import h3d.shader.BaseMesh;
import hxsl.Shader;
import hxsl.Types.Vec;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Wave extends Shader
{
	static var SRC =
	{
		@:import h3d.shader.BaseMesh;

		@param var speed:Float = 0.0001;
		@param var amplitude:Float = 0.2;
		@param var zOffset:Float = 0;

		function vertex()
		{
			relativePosition.z += zOffset + amplitude * cos(global.time * speed * (relativePosition.x * relativePosition.y));
		}
	}
}