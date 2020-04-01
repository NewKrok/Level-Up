package levelup.editor.module.script;

import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class ScriptModule
{
	var core:EditorCore = _;

	public var model:ScriptModel;

	public function new()
	{
		model = new ScriptModel();

		core.registerView(EditorViewId.VScriptModule, ScriptEditorView.fromHxx({

		}));
	}
}