package levelup.editor.dialog;

import coconut.ui.View;
import levelup.editor.dialog.EditorDialogManagerModel.EditorDialog;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorDialogManagerView extends View
{
	@:attr var currentDialog:EditorDialog;

	function render() '
		<if {currentDialog == null}>
			<div class="lu_hidden"></div>
		<else>
			<div class="lu_edialog__root">
				{currentDialog.view}
			</div>
		</if>
	';
}