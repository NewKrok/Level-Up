package levelup.core.renderer;

class DefaultForwardComposite extends h3d.shader.ScreenShader
{
	static var SRC = {
		@param var texture:Sampler2D;
		@param var outline:Sampler2D;
		@param var color:Vec4;

		function fragment()
		{
			pixelColor = texture.get(calculatedUV);
			var outval = outline.get(calculatedUV).rgba;
			if (outval.a < 0.4 && outval.a > 0)
			{
				pixelColor.rgba = color;
			}
		}
	}

	public function new(v = 0)
	{
		super();
		color.setColor(v);
	}
}

class Renderer extends h3d.scene.fwd.Renderer {

	var composite: h3d.pass.ScreenFx<DefaultForwardComposite>;
	var outlineBlur = new h3d.pass.Blur(0.5);

	public function new()
	{
		super();
		composite = new h3d.pass.ScreenFx(new DefaultForwardComposite(0x11111111));
	}

	override function render() {

		var output = allocTarget("output");
		setTarget(output);
		clear(h3d.Engine.getCurrent().backgroundColor, 1);

		if (has("shadow"))
			renderPass(shadow, get("shadow"));

		if (has("depth"))
			renderPass(depth, get("depth"));

		if (has("normal"))
			renderPass(normal, get("normal"));

		renderPass(defaultPass, get("default") );
		renderPass(defaultPass, get("alpha"), backToFront );
		renderPass(defaultPass, get("additive") );

		var outlineTex = allocTarget("outlineBlur", false);
		var outlineSrcTex = allocTarget("outline", false);
		setTarget(outlineSrcTex);
		clear(0);
		draw("highlight");
		resetTarget();
		outlineBlur.apply(ctx, outlineSrcTex, outlineTex);

		resetTarget();
		composite.shader.texture = output;
		composite.shader.outline = outlineTex;
		composite.render();
	}
}