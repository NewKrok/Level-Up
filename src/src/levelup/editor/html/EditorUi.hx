package levelup.editor.html;

import coconut.ui.RenderResult;
import coconut.ui.View;
import levelup.Asset.AssetConfig;
import levelup.TerrainAssets.TerrainConfig;
import levelup.component.FpsView;
import levelup.editor.EditorModel;
import levelup.editor.EditorState.AssetItem;
import levelup.editor.EditorState.EditorViewId;
import levelup.editor.html.EditorLibrary;
import tink.pure.List;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorUi extends View
{
	@:attr var backToLobby:Void->Void;
	@:attr var save:Void->Void;
	@:attr var createNewAdventure:Void->Void;
	@:attr var testRun:Void->Void;
	@:attr var previewRequest:AssetConfig->Void;
	@:attr var model:EditorModel;
	@:attr var getModuleView:EditorViewId->RenderResult;

	@:skipCheck @:attr var environmentsList:List<AssetConfig>;
	@:skipCheck @:attr var propsList:List<AssetConfig>;
	@:skipCheck @:attr var buildingList:List<AssetConfig>;
	@:skipCheck @:attr var unitsList:List<AssetConfig>;
	@:skipCheck @:attr var selectedWorldAsset:AssetItem;

	@:skipCheck @:state var hoveredAsset:AssetConfig = null;

	@:state var selectedRightMenu:Int = 0;

	@:ref var editorLibrary:EditorLibrary;
	@:ref var selectedAsset:AssetProperties;
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
			<EditorMainMenu
				toolState={model.toolState}
				changeToolState=${s -> model.toolState = s}
			/>
			<div class="lu_row">
				<div class="lu_editor_left">
					<if {selectedWorldAsset != null}>
						<AssetProperties
							ref={selectedAsset}
							asset=$selectedWorldAsset
						/>
					</if>
				</div>
				<div class="lu_editor_right">
					<switch {model.toolState}>
						<case {ToolState.Library}>
							<EditorLibrary
								ref={editorLibrary}
								environmentsList={environmentsList}
								propsList={propsList}
								buildingList={buildingList}
								unitsList={unitsList}
								previewRequest={previewRequest}
								onAssetMouseOver={asset -> hoveredAsset = asset}
								onPlayerSelect={id -> model.selectedPlayer = id}
								selectedPlayer={model.observables.selectedPlayer}
							/>
							<EditorPreview
								assetConfig=$hoveredAsset
							/>

						<case {ToolState.TerrainEditor}>
							{getModuleView(EditorViewId.VTerrainModule)}

						<case {ToolState.HeightMapEditor}>
							{getModuleView(EditorViewId.VHeightMapModule)}

						<case {ToolState.DayAndNightEditor}>
							{getModuleView(EditorViewId.VDayAndNightModule)}

						<case {ToolState.RegionEditor}>
							{getModuleView(EditorViewId.VRegionModule)}

						<case {ToolState.CameraEditor}>
							{getModuleView(EditorViewId.VCameraModule)}

						<case {ToolState.WeatherEditor}>
							{getModuleView(EditorViewId.VWeatherModule)}

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
		</div>
	';

	public function removeSelection() editorLibrary.removeSelection();
	public function forceUpdateSelectedUser() selectedAsset.forceUpdate();
	public function increaseSnap() snapGridInfo.increaseSnap();
}