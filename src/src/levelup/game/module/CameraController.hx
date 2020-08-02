package levelup.game.module;

import h2d.Scene;
import hpp.heaps.HppG;
import hxd.Key;
import js.Browser;
import levelup.core.camera.ActionCamera;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class CameraController
{
	var camera:ActionCamera = _;

	var size = 100;
	var cameraSpeed = 0.4;
	var posChanged = false;
	var isMouseInsideTheWindow = true;

	var camTargetPoint = { x: 0.0, y: 0.0, z: 0.0 };
	var camTargetPointObject = { getPosition: () -> return { x: 0.0, y: 0.0, z: 0.0 } };

	public function new()
	{
		camTargetPoint.x = camera.currentCameraPoint.x;
		camTargetPoint.y = camera.currentCameraPoint.y;

		camTargetPointObject.getPosition = () -> return camTargetPoint;
		camera.setCameraTarget(cast camTargetPointObject);

		Browser.document.addEventListener("mouseenter", onMouseEnter);
		Browser.document.addEventListener("mouseleave", onMouseLeave);
	}

	function onMouseEnter(e) isMouseInsideTheWindow = true;
	function onMouseLeave(e) isMouseInsideTheWindow = false;

	public function onUpdate(d:Float)
	{
		if (!isMouseInsideTheWindow) return;

		if (HppG.stage2d.mouseX < size || Key.isDown(Key.LEFT))
		{
			camTargetPoint.y -= cameraSpeed;
		}
		if (HppG.stage2d.mouseY < size || Key.isDown(Key.UP))
		{
			camTargetPoint.x += cameraSpeed;
		}
		if (HppG.stage2d.mouseX > HppG.stage2d.width - size || Key.isDown(Key.RIGHT))
		{
			camTargetPoint.y += cameraSpeed;
		}
		if (HppG.stage2d.mouseY > HppG.stage2d.height - size || Key.isDown(Key.DOWN))
		{
			camTargetPoint.x -= cameraSpeed;
		}
	}

	public function dispose()
	{
		Browser.window.removeEventListener("mouseenter", onMouseEnter);
		Browser.window.removeEventListener("mouseleave", onMouseLeave);
	}
}