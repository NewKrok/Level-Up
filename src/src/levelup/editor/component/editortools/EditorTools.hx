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

	var tools:Array<ToolDefinition> = [
		{
			icon: "fas fa-globe-americas",
			state: ToolState.WorldSettingsEditor,
		},
		{
			icon: "fas fa-users-cog",
			state: ToolState.TeamSettingsEditor,
		},
		{
			icon: "fas fa-cloud-moon",
			state: ToolState.SkyboxEditor,
		},
		{
			icon: "fas fa-sun",
			state: ToolState.DayAndNightEditor,
		},
		{
			icon: "fas fa-cloud",
			state: ToolState.WeatherEditor,
		},
		{
			icon: "fas fa-map",
			state: ToolState.HeightMapEditor,
		},
		{
			icon: "fas fa-paint-brush",
			state: ToolState.TerrainEditor,
		},
		{
			icon: "fas fa-object-ungroup",
			state: ToolState.RegionEditor,
		},
		{
			icon: "fas fa-video",
			state: ToolState.CameraEditor,
		},
		{
			icon: "fas fa-folder-open",
			state: ToolState.Library,
		},
		{
			icon: "fas fa-user-cog",
			state: ToolState.UnitEditor,
		},
		{
			icon: "fas fa-code",
			state: ToolState.ScriptEditor,
		}
	];

	function render() '
		<div class="lu_row lu_editor__tools">
			<for {tool in tools}>
				<div
				class={"lu_editor__tools__button" + (toolState == tool.state ? " lu_editor__tools__button--selected" : "")}
				onclick={e -> changeToolState(tool.state)}
				>
					<i class={tool.icon}></i>
				</div>
			</for>
		</div>
	';
}

typedef ToolDefinition = {
	var icon:String;
	var state:ToolState;
}