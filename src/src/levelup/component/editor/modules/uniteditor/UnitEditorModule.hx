package levelup.component.editor.modules.uniteditor;

import coconut.ui.RenderResult;
import levelup.editor.EditorModel.EditorModuleId;
import levelup.editor.EditorState.EditorCore;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class UnitEditorModule
{
	var core:EditorCore = _;

	var view:RenderResult;

	public function new()
	{
		core.model.registerModule({
			id: EditorModuleId.MUnitEditor,
			icon: "fa-user-cog",
			instance: cast this
		});

		view = UnitEditorView.fromHxx({

		});
	}
}