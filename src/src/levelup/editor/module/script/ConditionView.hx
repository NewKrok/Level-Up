package levelup.editor.module.script;

import coconut.ui.View;
import levelup.game.GameState.TriggerCondition;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ConditionView extends View
{
	@:skipCheck @:attr var condition:TriggerCondition;

	function render() '
		<div class="lu_row">
			<i class="fas fa-circle"></i>
			<switch {condition}>
				<case {_}> Unhandled Condition
			</switch>
		</div>
	';
}