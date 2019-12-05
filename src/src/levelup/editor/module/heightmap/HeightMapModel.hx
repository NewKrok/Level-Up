package levelup.editor.module.heightmap;

import coconut.data.Model;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HeightMapModel implements Model
{
	@:editable var selectedBrushId:Int = 0;
	@:editable var brushSize:Float = 3;
	@:editable var brushOpacity:Float = 0.05;
	@:editable var brushGradient:Float = 0;
	@:editable var brushNoise:Float = 0;
	@:editable var drawSpeed:Float = 90;
}