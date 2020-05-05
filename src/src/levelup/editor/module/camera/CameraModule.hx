package levelup.editor.module.camera;

import h3d.scene.Object;
import levelup.editor.EditorModel.ToolState;
import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class CameraModule
{
	var core:EditorCore = _;

	var model:CameraModel;
	var cameraContainer:Object;

	public function new()
	{
		model = new CameraModel();

		core.registerView(EditorViewId.VCameraModule, CameraEditorView.fromHxx({
			cameras: model.observables.cameras,
			addCamera: createCamera,
			jumpToCamera: cam -> {
				core.camDistance = cam.camDistance;
				core.camAngle = cam.camAngle;
				core.camRotation = cam.camRotation;
				core.jumpCamera(
					cam.position.x,
					cam.position.y,
					cam.position.z
				);
			}
		}));

		cameraContainer = new Object(core.s3d);
		cameraContainer.visible = false;

		core.model.observables.toolState.bind(v ->
		{
			cameraContainer.visible = v == ToolState.CameraEditor;
		});

		model.addCameras(core.adventureConfig.worldConfig.cameras);
	}

	function createCamera()
	{
		var nameIndex = model.cameras.length;
		var name = "Untitled Camera " + nameIndex;
		while (model.cameras.length != 0 && model.cameras.toArray().filter(cam -> cam.name == name).length > 0)
		{
			nameIndex++;
			name = "Untitled Camera " + nameIndex;
		}

		model.addCamera({
			name: name,
			position: core.s3d.camera.target.clone(),
			camDistance: core.camDistance,
			camAngle: core.camAngle,
			camRotation: core.camRotation
		});
	}

	public function getCameras() return model.cameras;
}