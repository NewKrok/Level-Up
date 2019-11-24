package levelup.editor.dialog;

import coconut.ui.RenderResult;
import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;
import levelup.editor.dialog.EditorDialogManagerModel.EditorDialog;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class EditorDialogManager
{
	var core:EditorCore = _;

	var model:EditorDialogManagerModel = new EditorDialogManagerModel();

	public function new()
	{
		core.registerView(EditorViewId.VDialogManager, EditorDialogManagerView.fromHxx({
			currentDialog: model.currentDialog
		}));
	}

	public function openDialog(content:EditorDialog) model.openDialog(content);
	public function closeCurrentDialog() model.closeCurrentDialog();
}