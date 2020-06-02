package levelup.editor.html;

import coconut.ui.RenderResult;
import coconut.ui.View;
import levelup.Asset.AssetConfig;
import levelup.component.FpsView;
import levelup.editor.EditorModel;
import levelup.editor.EditorState.EditorViewId;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorView extends View
{
	@:attr var backToLobby:Void->Void;
	@:attr var save:Void->Void;
	@:attr var createNewAdventure:Void->Void;
	@:attr var testRun:Void->Void;
	@:attr var model:EditorModel;
	@:attr var getModuleView:EditorViewId->RenderResult;

	@:ref var snapGridInfo:SnapGridInfo;

	function render() '
		<div class="lu_editor">
			<FpsView />
			{getModuleView(EditorViewId.VDialogManager)}
			<EditorHeader
				backToLobby=$backToLobby
				createNewAdventure=$createNewAdventure
				save=$save
				testRun=$testRun
			/>
			{getModuleView(EditorViewId.VEditorTools)}
			<div class="lu_editor__properties">
				<switch {model.toolState}>
					<case {ToolState.WorldSettingsEditor}> {getModuleView(EditorViewId.VWorldSettingsModule)}
					<case {ToolState.TeamSettingsEditor}> {getModuleView(EditorViewId.VTeamSettingsModule)}
					<case {ToolState.SkyboxEditor}> {getModuleView(EditorViewId.VSkyboxModule)}
					<case {ToolState.DayAndNightEditor}> {getModuleView(EditorViewId.VDayAndNightModule)}
					<case {ToolState.WeatherEditor}> {getModuleView(EditorViewId.VWeatherModule)}
					<case {ToolState.TerrainEditor}> {getModuleView(EditorViewId.VTerrainModule)}
					<case {ToolState.HeightMapEditor}> {getModuleView(EditorViewId.VHeightMapModule)}
					<case {ToolState.RegionEditor}> {getModuleView(EditorViewId.VRegionModule)}
					<case {ToolState.CameraEditor}> {getModuleView(EditorViewId.VCameraModule)}
					<case {ToolState.Library}> {getModuleView(EditorViewId.VEditorLibraryModule)}
					<case {ToolState.ScriptEditor}> {getModuleView(EditorViewId.VScriptModule)}
					<case {ToolState.UnitEditor}> {getModuleView(EditorViewId.VUnitEditorModule)}
					<case {ToolState.SkillEditor}> {getModuleView(EditorViewId.VSkillEditorModule)}
					<case {ToolState.ItemEditor}> {getModuleView(EditorViewId.VItemEditorModule)}

					<case {_}>
				</switch>
			</div>
			<div class="lu_editor_footer">
				<LockedDragInfo
					isXDragLocked={model.observables.isXDragLocked}
					isYDragLocked={model.observables.isYDragLocked}
					toggleXDragLock={model.toggleXDragLock}
					toggleYDragLock={model.toggleYDragLock}
				/>
				<SnapGridInfo
					ref={snapGridInfo}
					showGrid={model.observables.showGrid}
					toggleShowGrid={() -> model.showGrid = !model.showGrid}
					currentSnap={model.observables.currentSnap}
					changeSnap = {snap -> model.currentSnap = snap}
				/>
			</div>
		</div>
	';

	public function increaseSnap() snapGridInfo.increaseSnap();
}