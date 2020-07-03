package levelup.editor.module.script;

import coconut.ui.View;
import levelup.editor.module.script.ScriptConfig.ScriptData;
import levelup.game.GameState.Trigger;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ScriptView extends View
{
	@:attr var openSelector:String->Int->ScriptData->Int->Void;
	@:skipCheck @:attr var selectedScript:Trigger;

	function render() '
		<div>
			<div class="lu_script__block">
				<div class="lu_script__block_label">
					<i class="fas fa-calendar-check lu_right_offset"></i>
					Events
				</div>
				<for {i in 0...selectedScript.events.length}>
					<EntryView data={ScriptConfig.getEventData(selectedScript.events[i])} openSelector=$openSelector type="event" index=$i />
				</for>
			</div>
			<div class="lu_script__block">
				<div class="lu_script__block_label">
					<i class="fas fa-project-diagram lu_right_offset"></i>
					Conditions
				</div>
				<EntryView data={ScriptConfig.getConditionData(selectedScript.condition)} openSelector=$openSelector type="condition" index=${0} />
			</div>
			<div class="lu_script__block">
				<div class="lu_script__block_label">
					<i class="fas fa-terminal lu_right_offset"></i>
					Actions
				</div>
				<for {i in 0...selectedScript.actions.length}>
					<EntryView data={ScriptConfig.getActionData(selectedScript.actions[i])} openSelector=$openSelector type="action" index=$i />
				</for>
			</div>
		</div>
	';
}