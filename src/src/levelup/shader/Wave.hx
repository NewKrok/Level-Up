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

		@param var speed:Float = 4;
		@param var amplitude:Float = 2;
		@param var zOffset:Float = 2;

		function vertex()
		{
			relativePosition.z += zOffset + amplitude * cos(global.time * speed);
		}
	}
}