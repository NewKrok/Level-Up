package levelup.editor.html;

import coconut.ui.View;
import js.html.SelectElement;
import levelup.Asset.AssetConfig;
import levelup.editor.EditorState.AssetItem;
import levelup.game.GameState.PlayerId;
import levelup.game.GameState.RaceId;
import tink.pure.List;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorLibrary extends View
{
	@:attr var previewRequest:AssetConfig->Void;
	@:attr var onAssetMouseOver:AssetConfig->Void;
	@:attr var onPlayerSelect:PlayerId->Void;
	@:attr var selectedPlayer:PlayerId;

	@:skipCheck @:attr var environmentsList:List<AssetConfig>;
	@:skipCheck @:attr var propsList:List<AssetConfig>;
	@:skipCheck @:attr var buildingList:List<AssetConfig>;
	@:skipCheck @:attr var unitsList:List<AssetConfig>;

	@:computed var list:List<AssetConfig> = switch (selectedListIndex) {
		case 0: environmentsList.filter(e -> return e.environmentId == selectedEnvironmentIndex);
		case 1: propsList;
		case 2: buildingList;
		case 3: unitsList.filter(e -> return e.race == selectedRace);
		case _: List.fromArray([]);
	};

	@:state var selectedListIndex:Int = 0;
	@:state var selectedEnvironmentIndex:Int = 0;
	@:state var selectedRace:RaceId = RaceId.Human;
	@:skipCheck @:state var selectedAsset:AssetConfig = null;

	function render() '
		<div class="lu_editor__base_panel">
			<select class="lu_selector lu_offset" onchange={e -> { removeSelection(); selectedListIndex = cast(e.currentTarget, SelectElement).selectedIndex; }}>
				<option>({environmentsList.length}) Environments</option>
				<option>({propsList.length}) Props</option>
				<option>({buildingList.length}) Buildings</option>
				<option>({unitsList.length}) Units</option>
			</select>
			<if {selectedListIndex == 0}>
				<div class="lu_row">
					<select class="lu_selector lu_offset" onchange={e -> selectedEnvironmentIndex = cast cast(e.currentTarget, SelectElement).value}>
						<option selected={selectedEnvironmentIndex == 0} value="0">Bridge</option>
						<option selected={selectedEnvironmentIndex == 4} value="4">Plant</option>
						<option selected={selectedEnvironmentIndex == 1} value="1">Rock</option>
						<option selected={selectedEnvironmentIndex == 2} value="2">Tree</option>
						<option selected={selectedEnvironmentIndex == 3} value="3">Trunk</option>
					</select>
				</div>
			</if>
			<if {selectedListIndex == 3}>
				<div class="lu_row">
					<div class="lu_player_color_box lu_left_offset" style={"background-color: #" + PlayerColor.colors[selectedPlayer]} ></div>
					<select class="lu_selector lu_horizontal_offset" onchange={e -> onPlayerSelect(cast(e.currentTarget, SelectElement).selectedIndex)}>
						<for {i in 0...10}>
							<option selected={i == selectedPlayer} style={"color: #" + PlayerColor.colors[i]}>
								Player {i + 1}
							</option>
						</for>
					</select>
				</div>
				<div class="lu_row">
					<select class="lu_selector lu_offset" onchange={e -> selectedRace = cast(e.currentTarget, SelectElement).selectedIndex}>
						<option selected={selectedRace == 0}>Human</option>
						<option selected={selectedRace == 1}>Orc</option>
						<option selected={selectedRace == 2}>Elf</option>
						<option selected={selectedRace == 3}>Undead</option>
					</select>
				</div>
			</if>
			<div class="lu_list_container lu_library_list_container">
				<ul>
					<for {e in list}>
						<li
							class={"lu_list_element lu_list_element--interactive" + (e == selectedAsset ? " lu_list_element--selected" : "")}
							onmouseover={() -> onAssetMouseOver(e)}
							onclick={() -> {if (selectedAsset == e) {previewRequest(null); selectedAsset = null;} else {previewRequest(e); selectedAsset = e;}}}>
							{e.name.replace("SM_", "").replace("_", " ")}
						</li>
					</for>
				</ul>
			</div>
		</div>
	';

	public function removeSelection() { previewRequest(null); selectedAsset = null; }
}