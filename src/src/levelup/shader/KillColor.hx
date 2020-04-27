package levelup.shader;

class KillColor extends hxsl.Shader {

	static var SRC =
	{
		@param var colorKey:Vec4;
		@param var threshold:Float;

		var pixelColor:Vec4;

		function fragment()
		{
			var diff =
				abs(pixelColor.r - colorKey.r) +
				abs(pixelColor.g - colorKey.g) +
				abs(pixelColor.b - colorKey.b);
			if (diff < threshold) discard;
			else pixelColor.a *= diff * 0.2;
		}
	}

	public function new(color = 0, threshold = 0.00001)
	{
		super();
		colorKey.setColor(color);
		this.threshold = threshold;
	}
}