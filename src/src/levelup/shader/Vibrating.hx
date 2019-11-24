package levelup.shader;

import h3d.shader.BaseMesh;
import hxsl.Shader;
import hxsl.Types.Vec;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Vibrating extends Shader
{
	static var SRC =
	{
		@:import h3d.shader.BaseMesh;

		@param var speed:Float = 5;
		@param var intensity:Float = 1;

		function vertex()
		{
			relativePosition.z += cos(global.time * speed * (relativePosition.x * relativePosition.y)) * intensity;
		}
	};
}