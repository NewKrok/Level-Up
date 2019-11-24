package levelup.editor.module.terrain;

import coconut.ui.View;
import levelup.TerrainAssets.TerrainConfig;
import tink.pure.List;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TerrainChooser extends View
{
	@:attr var close:Void->Void;
	@:attr var selectTerrain:String->Void;

	@:skipCheck @:attr var terrainList:List<TerrainConfig>;

	@:state var selectedTerrainId:String = "";

	function render() '
		<div class="lu_edialog__content">
			<div class="lu_dialog_close" onclick=$close><i class="fas fa-window-close"></i></div>
			<div class="lu_title"><i class="fas fa-palette lu_right_offset"></i>Select Terrain Texture</div>
			<div class="lu_terrain_list">
				<for {e in terrainList}>
					<div
						class={"lu_terrain_preview " + (e.id == selectedTerrainId ? " lu_terrain_preview--selected" : "")}
						style={"background-image: url(asset/img/preview/terrain/" + e.id + ".jpg)"}
						onclick={() -> selectTerrain(e.id)}>
					</div>
				</for>
			</div>
		</div>
	';

	public function setSelectedTerrainId(id:String) selectedTerrainId = id;
}