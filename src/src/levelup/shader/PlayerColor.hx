package levelup.shader;

class PlayerColor extends hxsl.Shader {

	static var SRC = {

		@param var playerColor:Vec4;
		@param var maskKeyColor:Vec4;
		@param var texture:Sampler2D;

		var calculatedUV:Vec2;
		var pixelColor:Vec4;

		function fragment()
		{
			var maskPixelColor = texture.get(calculatedUV).rgb;

			var diff =
				abs(maskPixelColor.r - maskKeyColor.r) +
				abs(maskPixelColor.g - maskKeyColor.g) +
				abs(maskPixelColor.b - maskKeyColor.b);

			if (diff < 0.1)
			{
				pixelColor.r = (pixelColor.r / 10 + playerColor.r * .5);
				pixelColor.g = (pixelColor.g / 10 + playerColor.g * .5);
				pixelColor.b = (pixelColor.b / 10 + playerColor.b * .5);
			}
		}
	}

	public function new(tex, playerColor, maskKeyColor)
	{
		super();

		this.texture = tex;
		this.playerColor.setColor(playerColor);
		this.maskKeyColor.setColor(maskKeyColor);
	}
}