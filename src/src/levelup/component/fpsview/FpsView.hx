package levelup.component.fpsview;

import coconut.ui.View;
import h3d.Engine;
import haxe.Timer;

/**
 * ...
 * @author Krisztian Somoracz
 */
class FpsView extends View
{
	@:state var fps:String = "00.00fps";
	@:state var fpsInNumber:Float = 0;

	var t:Timer;

	function viewDidMount() updateView();
	function viewWillUnmount() stopTimer();

	function updateView()
	{
		t = Timer.delay(updateView, 1000);

		fpsInNumber = Math.floor(Engine.getCurrent().fps);
		fps = (fpsInNumber < 10 ? "0" + fpsInNumber : Std.string(fpsInNumber)) + " FPS";
	}

	function stopTimer()
	{
		if (t != null)
		{
			t.stop();
			t = null;
		}
	}

	function render() '
		<div class={"lu_fps_view lu_fps_view--bl" + (fpsInNumber < 30 ? " lu_fps_view--low" : "")}>
			$fps
		</div>
	';
}