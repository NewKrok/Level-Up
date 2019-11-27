package levelup.shader;

class Opacity extends hxsl.Shader
{
	static var SRC =
	{
		var pixelColor:Vec4;

		@param var opacity:Float;

		function fragment()
		{
			pixelColor.a = opacity;
		}
	}

	public function new(opacity)
	{
		super();

		this.opacity = opacity;
	}
}
