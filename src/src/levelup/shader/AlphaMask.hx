package levelup.shader;

class AlphaMask extends hxsl.Shader
{
	static var SRC =
	{
		var calculatedUV:Vec2;
		var pixelColor:Vec4;

		@param var texture:Sampler2D;
		@param var uvScale:Vec2;

		function fragment()
		{
			var newA = texture.get(calculatedUV * uvScale).a;
			if (newA == 0) discard;
			pixelColor.a = newA;
		}
	}

	public function new(texture)
	{
		super();

		uvScale.set(1, 1);
		this.texture = texture;
	}
}
