package levelup.shader;

import h3d.shader.BaseMesh;

class TopLayer extends hxsl.Shader
{
	static var SRC =
	{
		@:import h3d.shader.BaseMesh;

		function vertex()
		{
			projectedPosition.z = 10;
		}
	}
}
