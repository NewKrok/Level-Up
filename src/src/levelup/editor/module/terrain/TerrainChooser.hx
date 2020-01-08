package levelup.editor.module.terrain;

import coconut.ui.View;
import levelup.TerrainAssets.TerrainConfig;
import levelup.TerrainAssets.TerrainType;
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
	@:state var selectedTerrainType:TerrainType = TerrainType.All;

	var terrainTypeList:Array<TerrainType> = [
		TerrainType.Cliff,
		TerrainType.Desert,
		TerrainType.Dirt,
		TerrainType.Grass,
		TerrainType.Forest,
		TerrainType.Ice,
		TerrainType.Lava,
		TerrainType.Road,
		TerrainType.Stone,
		TerrainType.Tile,
		TerrainType.Water,
		TerrainType.Wood,
		TerrainType.Other,
		TerrainType.All
	];

	function render() '
		<div class="lu_edialog__content">
			<div class="lu_dialog_close" onclick=$close><i class="fas fa-window-close"></i></div>
			<div class="lu_title"><i class="fas fa-palette lu_right_offset"></i>Select Terrain Texture</div>
			<div class="lu_row lu_row--space_evenly">
				<for {t in terrainTypeList}>
					<div
						class={"lu_button" + (t == selectedTerrainType ? " lu_button--selected" : "")}
						onclick={e -> selectedTerrainType = t}
					>
						$t
					</div>
				</for>
			</div>
			<div class="lu_terrain_list">
				<for {e in terrainList}>
					<if {selectedTerrainType == TerrainType.All || e.type == selectedTerrainType}>
						<div
							class={"lu_terrain_preview " + (e.id == selectedTerrainId ? " lu_terrain_preview--selected" : "")}
							style={"background-image: url(" + e.previewUrl + ")"}
							onclick={() -> selectTerrain(e.id)}>
						</div>
					</if>
				</for>
			</div>
		</div>
	';

	public function setSelectedTerrainId(id:String) selectedTerrainId = id;
}