package levelup.editor.module.script;

import coconut.data.List;
import coconut.ui.View;
import levelup.game.GameState.Trigger;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ScriptEditorView extends View
{
	@:skipCheck @:attr var scripts:List<Trigger>;
	@:skipCheck @:attr var selectedScript:Trigger;

	function render() '
		<div class="lu_editor__properties__container">
			<div class="lu_title">
				<i class="fas fa-code lu_right_offset"></i>Script Editor
			</div>
			<div class="lu_script__container">
				<div class="lu_script__list">
					<div class="lu_title">Scripts</div>
					<div>
						<for {script in scripts}>
							{script.id}
						</for>
					</div>
				</div>
				<div class="lu_fill">
					<div class="lu_title">Selected Script</div>
					<div>
						<div class="lu_script__block">
							<div class="lu_script__block_label">Events</div>
							<for {event in selectedScript.events}>
								<EventView event=$event />
							</for>
						</div>
						<div class="lu_script__block">
							<div class="lu_script__block_label">Conditions</div>
							<div>
								<ConditionView condition={selectedScript.condition} />
							</div>
						</div>
						<div class="lu_script__block">
							<div class="lu_script__block_label">Actions</div>
							<for {action in  selectedScript.actions}>
								<ActionView action=$action />
							</for>
						</div>
					</div>
				</div>
			</div>
		</div>
	';
}