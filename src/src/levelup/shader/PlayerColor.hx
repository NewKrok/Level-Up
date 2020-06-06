package levelup.shader;

class PlayerColor extends hxsl.Shader {

	static var SRC = {

		@param var playerColor:Vec4;
		@param var texture:Sampler2D;

		var calculatedUV:Vec2;
		var pixelColor:Vec4;

		function fragment()
		{
			var maskColor:Vec3 = texture.get(calculatedUV).rgb;
			if (maskColor.r > 0.1)
			{
				pixelColor.r = abs(pixelColor.r - playerColor.r) / 2;
				pixelColor.g = abs(pixelColor.g - playerColor.g) / 2;
				pixelColor.b = abs(pixelColor.b - playerColor.b) / 2;
			}
		}
	}

	public function new(tex, playerColor)
	{
		super();

		this.texture = tex;
		this.playerColor.setColor(playerColor);
	}
}