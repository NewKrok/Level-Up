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
			addCamera: () -> {}
		}));

		cameraContainer = new Object(core.s3d);
		cameraContainer.visible = false;

		core.model.observables.toolState.bind(v ->
		{
			cameraContainer.visible = v == ToolState.CameraEditor;
		});

		//model.addRegions(core.model.regions);
	}
}