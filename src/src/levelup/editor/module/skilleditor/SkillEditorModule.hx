package levelup.editor.module.skilleditor;

import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class SkillEditorModule
{
	var core:EditorCore = _;

	public function new()
	{
		core.registerView(EditorViewId.VSkillEditorModule, SkillEditorView.fromHxx({

		}));
	}
}