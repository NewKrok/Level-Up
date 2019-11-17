package levelup.editor.html;

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
class TerrainEditor extends View
{
	@:attr var baseTerrainId:String;
	@:attr var changeBaseTerrainIdRequest:TerrainConfig->Void;

	@:skipCheck @:attr var terrainList:List<TerrainConfig>;

	function render() '
		<div class="lu_editor__base_panel">
			<div>
				<div class="lu_title"><i class="fas fa-map lu_right_offset"></i>Base Terrain</div>
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