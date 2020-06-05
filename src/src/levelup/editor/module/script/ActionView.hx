package levelup.editor.module.script;

import coconut.ui.View;
import levelup.game.GameState.TriggerAction;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ActionView extends View
{
	@:skipCheck @:attr var action:TriggerAction;

	function render() '
		<div class="lu_row">
			<i class="fas fa-circle"></i>
			<switch {action}>
				<case {TriggerAction.AnimateCameraToCamera(_, _, _, _)}>
					<div>AnimateCameraToCamera</div>

				<case {_}> Unhandled Action
			</switch>
		</div>
	';
}