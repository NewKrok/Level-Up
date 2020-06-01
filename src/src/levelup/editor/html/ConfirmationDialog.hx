package levelup.editor.html;

import coconut.ui.RenderResult;
import coconut.ui.View;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ConfirmationDialog extends View
{
	@:attr var question:RenderResult;
	@:attr var onAccept:Void->Void;
	@:attr var onCancel:Void->Void;

	function render() '
		<div class="lu_edialog__content lu_edialog__content--auto-size">
			<div class="lu_dialog_close" onclick=$onCancel><i class="fas fa-times-circle"></i></div>
			<div class="lu_title lu_warning">
				<i class="fas fa-exclamation-triangle lu_horizontal_offset"></i>Warning
			</div>
			$question
			<div class="lu_row lu_row--center">
				<div class="lu_vertical_offset lu_right_offset lu_button lu_dialog__button lu_dialog__positive_button" onclick=$onAccept>Yes</div>
				<div class="lu_vertical_offset lu_button lu_dialog__button lu_dialog__warning_button" onclick=$onCancel>No</div>
			</div>
		</div>
	';
}