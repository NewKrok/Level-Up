package levelup.component.editor.moduleselector;

import coconut.ui.View;
import coconut.data.List;
import levelup.editor.EditorModel.EditorModule;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ModuleSelectorView extends View
{
	@:attr var modules:List<EditorModule>;
	@:attr var selectedModule:EditorModule;
	@:attr var changeModule:EditorModule->Void;

	function render() '
		<div class="lu_editor__tools">
			<for {module in modules}>
				<div
				class={"lu_editor__tools__button" + (selectedModule.id == module.id ? " lu_editor__tools__button--selected" : "")}
				onclick={e -> changeModule(module)}
				>
					<i class={"fas " + module.icon}></i>
				</div>
			</for>
		</div>
	';
}