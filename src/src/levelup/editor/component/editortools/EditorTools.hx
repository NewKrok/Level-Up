package levelup.editor.component.editortools;

import coconut.ui.View;
import levelup.editor.EditorModel.ToolState;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorTools extends View
{
	@:attr var toolState:ToolState;
	@:attr var changeToolState:ToolState->Void;

	function render() '
		<div class="lu_row lu_editor__tools">
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.WorldSettingsEditor ? " lu_editor__tools__button--selected" : "")}
				onclick={e -> changeToolState(ToolState.WorldSettingsEditor)}
			>
				<i class="fas fa-globe-americas"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.SkyboxEditor ? " lu_editor__tools__button--selected" : "")}
				onclick={e -> changeToolState(ToolState.SkyboxEditor)}
			>
				<i class="fas fa-cloud-moon"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.Library ? " lu_editor__tools__button--selected" : "")}
				onclick={e -> changeToolState(ToolState.Library)}
			>
				<i class="fas fa-folder-open"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.TerrainEditor ? " lu_editor__tools__button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.TerrainEditor)}
			>
				<i class="fas fa-paint-brush"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.HeightMapEditor ? " lu_editor__tools__button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.HeightMapEditor)}
			>
				<i class="fas fa-map"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.DayAndNightEditor ? " lu_editor__tools__button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.DayAndNightEditor)}
			>
				<i class="fas fa-sun"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.WeatherEditor ? " lu_editor__tools__button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.WeatherEditor)}
			>
				<i class="fas fa-cloud"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.RegionEditor ? " lu_editor__tools__button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.RegionEditor)}
			>
				<i class="fas fa-object-ungroup"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.CameraEditor ? " lu_editor__tools__button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.CameraEditor)}
			>
				<i class="fas fa-video"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.ScriptEditor ? " lu_editor__tools__button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.ScriptEditor)}
			>
				<i class="fas fa-code"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.UnitEditor ? " lu_editor__tools__button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.UnitEditor)}
			>
				<i class="fas fa-user-cog"></i>
			</div>
			<div
				class={"lu_editor__tools__button" + (toolState == ToolState.TeamEditor ? " lu_editor__tools__button--selected" : "")}
				onclick = {e -> changeToolState(ToolState.TeamEditor)}
			>
				<i class="fas fa-users-cog"></i>
			</div>
		</div>
	';
}