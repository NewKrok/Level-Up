package levelup.component.editor.modules.itemeditor;

import coconut.ui.RenderResult;
import levelup.editor.EditorModel.EditorModuleId;
import levelup.editor.EditorState.EditorCore;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class ItemEditorModule
{
	var core:EditorCore = _;

	var view:RenderResult;

	public function new()
	{
		core.model.registerModule({
			id: EditorModuleId.MItemEditor,
			icon: "fa-box-open",
			instance: cast this
		});

		view = ItemEditorView.fromHxx({

		});
	}
}