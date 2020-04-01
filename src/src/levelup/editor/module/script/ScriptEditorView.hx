package levelup.editor.module.script;

import coconut.ui.View;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ScriptEditorView extends View
{
	function render() '
		<div class="lu_editor__base_panel">
			<div class="lu_relative lu_fill_height">
				<div class="lu_title"><i class="fas fa-code lu_right_offset"></i>Script Editor</div>
			</div>
			<div>
				<div>
					<div class="lu_title">Packages</div>
					<div>
						Folder A
						<div>Script A</div>
					</div>
				</div>
				<div>
					<div class="lu_title">Selected Script</div>
					<div>
						<div>Events</div>
						<div>OnInit</div>
						<div>TimePeriodic(10)</div>
					</div>
					<div>
						<div>Conditions</div>
						<div>OwnerOf(TriggeringUnit, Player1)</div>
					</div>
					<div>
						<div>Actions</div>
						<div>CreateUnit(minion, Player1, "Region 0")</div>
						<div>AttackMoveToRegion(LastCreatedUnit, "Region 3")</div>
					</div>
				</div>
			</div>
		</div>
	';
}