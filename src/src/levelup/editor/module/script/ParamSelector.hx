package levelup.editor.module.script;

import coconut.ui.View;
import levelup.editor.module.script.ScriptConfig.ParamType;
import levelup.editor.module.script.ScriptConfig.ScriptData;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ParamSelector extends View
{
	@:skipCheck @:attr var data:ScriptData;
	@:attr var paramIndex:Int;
	@:attr var close:Void->Void;

	function render() '
		<div class="lu_script__param_selector__background">
			<div class="lu_script__param_selector__container">
				<div class="lu_dialog_close" onclick=$close><i class="fas fa-window-close"></i></div>
				<div class="lu_title"><i class="fas fa-wrench lu_right_offset"></i>Set parameter</div>
				{Std.string(data.paramTypes[paramIndex])}
				{Std.string(data.values[paramIndex])}
			</div>
		</div>
	';
}