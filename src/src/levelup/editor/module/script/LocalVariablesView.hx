package levelup.editor.module.script;

import coconut.ui.View;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LocalVariablesView extends View
{
	@:attr var scriptId:String;

	function render() '
		<div class="lu_script__block">
			<div class="lu_script__block_label">
				<i class="fas fa-database lu_right_offset"></i>
				Local variables for $scriptId script
			</div>
		</div>
	';
}