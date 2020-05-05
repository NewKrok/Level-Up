package levelup.editor.module.camera;

import coconut.data.Model;
import coconut.data.List;
import h3d.Vector;
import levelup.game.GameState.CameraData;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CameraModel implements Model
{
	@:skipCheck @:observable var cameras:List<CameraData> = List.fromArray([]);

	@:transition function addCamera(camera:CameraData) return { cameras: cameras.append(camera) };
	@:transition function addCameras(cameraArr:Array<CameraData>) return { cameras: List.fromArray(cameraArr) };
}