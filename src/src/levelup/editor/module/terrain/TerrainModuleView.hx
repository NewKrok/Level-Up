package levelup.editor.module.terrain;

import coconut.ui.View;
import js.html.SelectElement;
import levelup.Asset.AssetConfig;
import levelup.Terrain.TerrainConfig;
import levelup.editor.EditorState.AssetItem;
import levelup.game.GameState.PlayerId;
import levelup.game.GameState.RaceId;
import tink.pure.List;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TerrainModuleView extends View
{
	@:attr var baseTerrainId:String;
	@:attr var changeBaseTerrainIdRequest:TerrainConfig->Void;
	@:attr var selectedBrushId:Int;
	@:attr var changeSelectedBrushRequest:Int->Void;

	@:skipCheck @:attr var terrainList:List<TerrainConfig>;

	function render() '
		<div class="lu_editor__base_panel">
			<div>
				<div class="lu_title"><i class="fas fa-paint-brush lu_right_offset"></i>Terrain Brushes</div>
				<div class="">
					<div class="lu_terrain_brush_selector">
						<for {i in 0...8}>
							<div
								class={"lu_terrain_brush_preview" + (selectedBrushId == i ? " lu_terrain_brush_preview--selected" : "")}
								style={"background-image: url(asset/img/brush/brush_" + i + ".png)"}
								onclick={() -> changeSelectedBrushRequest(i)}>
							</div>
						</for>
					</div>
				</div>
				<div class="lu_title"><i class="fas fa-layer-group lu_right_offset"></i>Terrain Layers</div>
				<div class="lu_terrain_list">
					<for {e in terrainList}>
						<div
							class={"lu_terrain_preview " + (e.id == baseTerrainId ? " lu_terrain_preview--selected" : "")}
							style={"background-image: url(asset/img/preview/terrain/" + e.id + ".jpg)"}
							onclick={() -> changeBaseTerrainIdRequest(e)}>
						</div>
					</for>
				</div>
			</div>
		</div>
	';
}