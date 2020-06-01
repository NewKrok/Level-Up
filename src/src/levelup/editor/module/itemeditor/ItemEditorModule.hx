package levelup.editor.module.itemeditor;

import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class ItemEditorModule
{
	var core:EditorCore = _;

	public function new()
	{
		core.registerView(EditorViewId.VItemEditorModule, ItemEditorView.fromHxx({

		}));
	}
}