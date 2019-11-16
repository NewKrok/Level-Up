package levelup.editor.html;

import coconut.ui.View;
import levelup.Asset.AssetConfig;
import levelup.Terrain.TerrainConfig;
import levelup.editor.EditorState.AssetItem;
import levelup.editor.html.EditorLibrary;
import levelup.editor.html.TerrainEditor;
import tink.pure.List;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorUi extends View
{
	@:attr var backToLobby:Void->Void;
	@:attr var previewRequest:AssetConfig->Void;
	@:attr var changeDefaultTerrainRequest:TerrainConfig->Void;

	@:skipCheck @:attr var environmentsList:List<AssetConfig>;
	@:skipCheck @:attr var propsList:List<AssetConfig>;
	@:skipCheck @:attr var unitsList:List<AssetConfig>;
	@:skipCheck @:attr var selectedWorldAsset:AssetItem;
	@:skipCheck @:attr var terrainsList:List<TerrainConfig>;

	@:skipCheck @:state var hoveredAsset:AssetConfig = null;

	@:state var selectedRightMenu:Int = 0;

	@:ref var editorLibrary:EditorLibrary;
	@:ref var selectedAsset:AssetProperties;

	function render() '
		<div class="lu_editor">
			<div class="lu_editor_left">
				<div class="lu_editor_menu">
					<div class="lu_button" onclick=$backToLobby>
					<i class="fas fa-times-circle lu_right_margin"></i>Back to Lobby
					</div>
				</div>
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
						<i class="fas fa-map"></i>
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
						/>
						<EditorPreview
							assetConfig=$hoveredAsset
						/>
					<case {1}>
						<TerrainEditor
							terrainList={terrainsList}
							changeDefaultTerrainRequest={changeDefaultTerrainRequest}
						/>
				</switch>
			</div>
		</div>
	';

	public function removeSelection() editorLibrary.removeSelection();
	public function forceUpdateSelectedUser() selectedAsset.forceUpdate();
}