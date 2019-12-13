package levelup.shader;

import h3d.shader.BaseMesh;

class ForcedZIndex extends hxsl.Shader
{
	static var SRC =
	{
		@:import h3d.shader.BaseMesh;

		@param var zIndex:Float;

		function vertex()
		{
			projectedPosition.z = zIndex;
		}
	}

	public function new(zIndex:Float = 0)
	{
		super();

		this.zIndex = zIndex;
	}
}
