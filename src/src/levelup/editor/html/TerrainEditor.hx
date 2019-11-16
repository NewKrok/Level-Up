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
	@:attr var changeDefaultTerrainRequest:TerrainConfig->Void;

	@:skipCheck @:attr var terrainList:List<TerrainConfig>;

	@:skipCheck @:state var selectedTerrain:TerrainConfig = null;

	function render() '
		<div class="lu_editor__library">
			<div class="lu_list_container">
				<ul>
					<for {e in terrainList}>
						<li
							class={"lu_list_element lu_list_element--interactive" + (e == selectedTerrain ? " lu_list_element--selected" : "")}
							onclick={() -> {if (selectedTerrain == e) {selectedTerrain = null;} else {changeDefaultTerrainRequest(e); selectedTerrain = e;}}}>
							{e.name}
						</li>
					</for>
				</ul>
			</div>
		</div>
	';

	public function removeSelection() { selectedTerrain = null; }
}