package levelup.editor.module.uniteditor;

import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class UnitEditorModule
{
	var core:EditorCore = _;

	public function new()
	{
		core.registerView(EditorViewId.VUnitEditorModule, UnitEditorView.fromHxx({

		}));
	}
}