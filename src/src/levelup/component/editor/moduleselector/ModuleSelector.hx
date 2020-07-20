package levelup.component.editor.moduleselector;

import levelup.editor.EditorModel.EditorViewId;
import levelup.editor.EditorState.EditorCore;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class ModuleSelector
{
	var core:EditorCore = _;

	public function new()
	{
		var view = new ModuleSelectorView({
			modules: core.model.observables.modules,
			selectedModule: core.model.observables.selectedModule,
			changeModule: m -> core.model.selectedModule = m
		});

		core.model.registerView(EditorViewId.VEditorTools, view.reactify());
	}
}