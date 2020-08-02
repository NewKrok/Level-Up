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
			/*worldDist = zIndex;*/
		}

		function fragment() {
			output.color = pixelColor;
			output.depth = zIndex;
			output.normal = transformedNormal;
			output.worldDist = worldDist;
		}
	}

	public function new(zIndex:Float = 0)
	{
		super();

		this.zIndex = zIndex;
	}
}
