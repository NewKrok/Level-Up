package levelup.editor.html;

import coconut.ui.View;
import levelup.Asset.AssetConfig;
import levelup.Terrain.TerrainConfig;
import levelup.editor.EditorModel;
import levelup.editor.EditorState.AssetItem;
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
	@:attr var testRun:Void->Void;
	@:attr var previewRequest:AssetConfig->Void;
	@:attr var changeBaseTerrainIdRequest:TerrainConfig->Void;
	@:attr var model:EditorModel;

	@:skipCheck @:attr var environmentsList:List<AssetConfig>;
	@:skipCheck @:attr var propsList:List<AssetConfig>;
	@:skipCheck @:attr var unitsList:List<AssetConfig>;
	@:skipCheck @:attr var selectedWorldAsset:AssetItem;
	@:skipCheck @:attr var terrainsList:List<TerrainConfig>;

	@:skipCheck @:state var hoveredAsset:AssetConfig = null;

	@:state var selectedRightMenu:Int = 0;

	@:ref var editorLibrary:EditorLibrary;
	@:ref var selectedAsset:AssetProperties;
	@:ref var snapGridInfo:SnapGridInfo;

	function render() '
		<div class="lu_editor">
			<EditorHeader
				backToLobby=$backToLobby
				save=$save
				testRun=$testRun
			/>
			<div class="lu_row">
				<div class="lu_editor_left">
					<if {selectedWorldAsset != null}>
						<AssetProperties
							ref={selectedAsset}
							asset=$selectedWorldAsset
						/>
						<EditorPreview
							assetConfig={selectedWorldAsset.config}
						/>
					</if>
				</div>
				<div class="lu_editor_right">
					<div class="lu_row lu_tab_menu">
						<div class={"lu_title lu_button lu_button--secondary" + (selectedRightMenu == 0 ? " lu_button--selected" : "")} onclick={e -> selectedRightMenu = 0}>
							<i class="fas fa-folder-open"></i>
						</div>
						<div class={"lu_title lu_button lu_button--secondary" + (selectedRightMenu == 1 ? " lu_button--selected" : "")} onclick={e -> selectedRightMenu = 1}>
							<i class="fas fa-paint-brush"></i>
						</div>
					</div>
					<switch {selectedRightMenu}>
						<case {0}>
							<EditorLibrary
								ref={editorLibrary}
								environmentsList={environmentsList}
								propsList={propsList}
								unitsList={unitsList}
								previewRequest={previewRequest}
								onAssetMouseOver={asset -> hoveredAsset = asset}
								onPlayerSelect={id -> model.selectedPlayer = id}
								selectedPlayer={model.observables.selectedPlayer}
							/>
							<EditorPreview
								assetConfig=$hoveredAsset
							/>
						<case {1}>
							<TerrainEditor
								terrainList={terrainsList}
								baseTerrainId={model.observables.baseTerrainId}
								changeBaseTerrainIdRequest={changeBaseTerrainIdRequest}
							/>
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