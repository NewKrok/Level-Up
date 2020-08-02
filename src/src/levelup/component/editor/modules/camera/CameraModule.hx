package levelup.component.editor.modules.camera;

import coconut.data.List;
import coconut.Ui.hxx;
import coconut.ui.RenderResult;
import h3d.scene.Object;
import hpp.util.Language;
import levelup.core.camera.ActionCamera.CameraData;
import levelup.editor.EditorModel.EditorModuleId;
import levelup.editor.EditorState.EditorCore;
import levelup.editor.html.ConfirmationDialog;
import levelup.util.LanguageUtil;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class CameraModule
{
	var core:EditorCore = _;

	var view:RenderResult;

	var cameras:State<List<CameraData>> = new State<List<CameraData>>(List.fromArray([]));
	var cameraContainer:Object;

	public function new()
	{
		core.model.registerModule({
			id: EditorModuleId.MCamera,
			icon: "fa-video",
			instance: cast this
		});

		view = CameraEditorView.fromHxx({
			cameras: cameras,
			addCamera: addCamera,
			updateCamera: updateCamera,
			removeCamera: removeCamera,
			changeCamName: changeCamName,
			jumpToCamera: cam -> {
				core.camDistance = cam.camDistance;
				core.camAngle = cam.camAngle;
				core.camRotation = cam.cameraRotation;
				core.jumpCamera(
					cam.position.x,
					cam.position.y,
					cam.position.z
				);
			}
		});

		cameraContainer = new Object(core.s3d);
		cameraContainer.visible = false;

		/*core.model.observables.toolState.bind(v ->
		{
			cameraContainer.visible = v == ModuleId.CameraEditor;
		});*/

		cameras.set(List.fromArray(core.adventureConfig.worldConfig.cameras));
	}

	function addCamera()
	{
		var nameIndex = cameras.value.length;
		var name = Language.get("Untitled Camera") + " " + nameIndex;
		while (cameras.value.length != 0 && cameras.value.toArray().filter(cam -> cam.name == name).length > 0)
		{
			nameIndex++;
			name = Language.get("Untitled Camera") + " " + nameIndex;
		}

		cameras.set(
			cameras.value.append({
				name: name,
				position: core.s3d.camera.target.clone(),
				camDistance: core.camDistance,
				camAngle: core.camAngle,
				cameraRotation: core.camRotation
			})
		);
	}

	function removeCamera(camName:String)
	{
		core.dialogManager.openDialog({view: new ConfirmationDialog({
			question: LanguageUtil.replaceGeneralPlaceHolders("editor.camera.deleteWarning", "lu_offset", ["{camName}" => camName]),
			onAccept: () ->
			{
				core.dialogManager.closeCurrentDialog();
				cameras.set(List.fromArray(cameras.value.toArray().filter(c -> return c.name != camName)));
			},
			onCancel: core.dialogManager.closeCurrentDialog
		}).reactify()});
	}

	function changeCamName(camName:String, newCamName:String)
	{
		cameras.set(
			List.fromArray(cameras.value.toArray().map(c -> return c.name == camName
				? {
					name: newCamName,
					position: c.position,
					camDistance: c.camDistance,
					camAngle: c.camAngle,
					cameraRotation: c.cameraRotation
				}
				: c
			))
		);
	}

	function updateCamera(camName:String)
	{
		core.dialogManager.openDialog({view: new ConfirmationDialog({
			question: LanguageUtil.replaceGeneralPlaceHolders("editor.camera.updateWarning", "lu_offset", ["{camName}" => camName]),
			onAccept: () ->
			{
				core.dialogManager.closeCurrentDialog();
				cameras.set(
					List.fromArray(cameras.value.toArray().map(c -> return c.name == camName
						? {
							name: camName,
							position: core.s3d.camera.target.clone(),
							camDistance: core.camDistance,
							camAngle: core.camAngle,
							cameraRotation: core.camRotation
						}
						: c
					))
				);
			},
			onCancel: core.dialogManager.closeCurrentDialog
		}).reactify()});
	}

	public function getCameras() return cameras.value.toArray();
}