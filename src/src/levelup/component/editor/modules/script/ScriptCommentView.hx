package levelup.component.editor.modules.script;

import coconut.ui.View;
import hpp.util.Language;
import levelup.component.MultilineInput;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ScriptCommentView extends View
{
	@:attr var scriptId:String;
	@:attr var comment:String;
	@:attr var setComment:String->Void;

	function render() '
		<div class="lu_script__block">
			<MultilineInput
				className="lu_top_offset lu_fill"
				value=$comment
				placeHolder={Language.get("editor.script.commentPlaceholder")}
				onValueChange=$setComment
			/>
		</div>
	';
}