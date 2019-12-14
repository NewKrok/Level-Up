package levelup.editor.html;

import coconut.ui.View;
import levelup.editor.EditorModel.ToolState;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorMainMenu extends View
{
	@:attr var toolState:ToolState;
	@:attr var changeToolState:ToolState->Void;

	function render() '
		<div class="lu_row lu_editor_main_menu">
			<div
				class={"lu_title lu_button lu_button--secondary" + (toolState == ToolState.Library ? " lu_button--selected" : "")}
				onclick={e -> changeToolState(ToolState.Library)}
			>
				<i class="fas fa-folder-open"></i>
			</div>
			<div
				class={"lu_title lu_button lu_button--secondary" + (toolState == ToolState.TerrainEditor ? " lu_button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.TerrainEditor)}
			>
				<i class="fas fa-paint-brush"></i>
			</div>
			<div
				class={"lu_title lu_button lu_button--secondary" + (toolState == ToolState.HeightMapEditor ? " lu_button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.HeightMapEditor)}
			>
				<i class="fas fa-map"></i>
			</div>
			<div
				class={"lu_title lu_button lu_button--secondary" + (toolState == ToolState.DayAndNightEditor ? " lu_button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.DayAndNightEditor)}
			>
				<i class="fas fa-sun"></i>
			</div>
			<div
				class={"lu_title lu_button lu_button--secondary" + (toolState == ToolState.WeatherEditor ? " lu_button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.WeatherEditor)}
			>
				<i class="fas fa-cloud"></i>
			</div>
			<div
				class={"lu_title lu_button lu_button--secondary" + (toolState == ToolState.RegionEditor ? " lu_button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.RegionEditor)}
			>
				<i class="fas fa-object-ungroup"></i>
			</div>
			<div
				class={"lu_title lu_button lu_button--secondary" + (toolState == ToolState.CameraEditor ? " lu_button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.CameraEditor)}
			>
				<i class="fas fa-video"></i>
			</div>
			<div
				class={"lu_title lu_button lu_button--secondary" + (toolState == ToolState.ScriptEditor ? " lu_button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.ScriptEditor)}
			>
				<i class="fas fa-code"></i>
			</div>
			<div
				class={"lu_title lu_button lu_button--secondary" + (toolState == ToolState.UnitEditor ? " lu_button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.UnitEditor)}
			>
				<i class="fas fa-user-cog"></i>
			</div>
			<div
				class={"lu_title lu_button lu_button--secondary" + (toolState == ToolState.TeamEditor ? " lu_button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.TeamEditor)}
			>
				<i class="fas fa-users-cog"></i>
			</div>
		</div>
	';
}