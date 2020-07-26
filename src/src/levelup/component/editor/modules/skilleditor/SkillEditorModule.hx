package levelup.component.editor.modules.skilleditor;

import coconut.ui.RenderResult;
import levelup.editor.EditorModel.EditorModuleId;
import levelup.editor.EditorState.EditorCore;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class SkillEditorModule
{
	var core:EditorCore = _;

	var view:RenderResult;

	public function new()
	{
		core.model.registerModule({
			id: EditorModuleId.MSkillEditor,
			icon: "fa-book-medical",
			instance: cast this
		});

		view = SkillEditorView.fromHxx({

		});
	}
}