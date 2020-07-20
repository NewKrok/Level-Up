package levelup.component.editor.modules.skilleditor;

import coconut.ui.RenderResult;
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
			id: "SkillEditorModule",
			icon: "fa-book-medical",
			instance: cast this
		});

		view = SkillEditorView.fromHxx({

		});
	}
}