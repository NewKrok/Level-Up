package levelup.editor.module.script;

import coconut.data.List;
import coconut.ui.RenderResult;
import coconut.ui.View;
import levelup.editor.module.script.ScriptConfig.ScriptData;
import levelup.game.GameState.Trigger;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ScriptEditorView extends View
{
	@:attr var openSelector:ScriptData->Int->Void;
	@:skipCheck @:attr var selectors:List<RenderResult>;
	@:skipCheck @:attr var scripts:List<Trigger>;
	@:skipCheck @:attr var selectedScript:Trigger;

	function render() '
		<div class="lu_editor__properties__container">
			{...selectors}
			<div class="lu_title">
				<i class="fas fa-code lu_right_offset"></i>Script Editor
			</div>
			<div class="lu_script__container">
				<div class="lu_script__list">
					<div class="lu_title lu_bottom_offset--s">Scripts</div>
					<div>
						<for {script in scripts}>
							<div class="lu_script__entry">
								{script.id}
							</div>
						</for>
					</div>
				</div>
				<div class="lu_fill lu_col">
					<div class="lu_title lu_bottom_offset--s">{selectedScript.id}</div>
					<div class="lu_vertical_overflow">
						<div class="lu_script__block">
							<div class="lu_script__block_label">
								<i class="fas fa-calendar-check lu_right_offset"></i>
								Events
							</div>
							<for {event in selectedScript.events}>
								<EntryView data={ScriptConfig.getEventData(event)} openSelector=$openSelector />
							</for>
						</div>
						<div class="lu_script__block">
							<div class="lu_script__block_label">
								<i class="fas fa-project-diagram lu_right_offset"></i>
								Conditions
							</div>
							<EntryView data={ScriptConfig.getConditionData(selectedScript.condition)} openSelector=$openSelector />
						</div>
						<div class="lu_script__block">
							<div class="lu_script__block_label">
								<i class="fas fa-terminal lu_right_offset"></i>
								Actions
							</div>
							<for {action in selectedScript.actions}>
								<EntryView data={ScriptConfig.getActionData(action)} openSelector=$openSelector />
							</for>
						</div>
					</div>
				</div>
			</div>
		</div>
	';
}