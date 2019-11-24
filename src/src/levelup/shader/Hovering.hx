package levelup.shader;

import h3d.shader.BaseMesh;
import hxsl.Shader;
import hxsl.Types.Vec;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Hovering extends Shader
{
	static var SRC =
	{
		@:import h3d.shader.BaseMesh;

		@param var speed:Float = 10;
		@param var delay:Float = 2;

		function vertex()
		{
			relativePosition.z += cos(relativePosition.x * delay + global.time * speed);
		}
	};
}