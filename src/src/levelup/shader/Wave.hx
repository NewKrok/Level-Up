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

		@param var speed:Float;
		@param var amplitude:Float;
		@param var zOffset:Float;

		function vertex()
		{
			relativePosition.z += zOffset + amplitude * cos(global.time + relativePosition.x * relativePosition.y);
		}
	}

	public function new(speed:Float = 0.0001, amplitude:Float = 0.2, zOffset:Float = 0.2)
	{
		super();

		this.speed = speed;
		this.amplitude = amplitude;
		this.zOffset = zOffset;
	}
}