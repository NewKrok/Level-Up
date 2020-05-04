package levelup.editor.module.camera;

import coconut.data.Model;
import coconut.data.List;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CameraModel implements Model
{
	@:skipCheck @:observable var cameras:List<EditorCamera> = List.fromArray([]);

	@:transition function addCamera(camera:EditorCamera) return { cameras: cameras.append(camera) };
	@:transition function addCameras(cameraArr:Array<EditorCamera>) return { cameras: List.fromArray(cameraArr) };
}

typedef EditorCamera =
{
	var name:String;
}