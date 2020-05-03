package levelup.editor.html;

import coconut.ui.View;
import js.html.SelectElement;
import levelup.Asset.AssetConfig;
import levelup.UnitData.RaceId;
import levelup.editor.EditorState.AssetItem;
import levelup.game.GameState.PlayerId;
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

	@:computed var list:List<AssetConfig> = switch (selectedListIndex) {
		case 0: cast List.fromArray(getUnitList());
		case 1: cast List.fromArray(getEnvironmentList());
		case _: List.fromArray([]);
	};

	function getEnvironmentList()
	{
		var arr = [];

		for (k in EnvironmentData.config.keys())
		{
			var c = EnvironmentData.config.get(k);
			arr.push(c);
		}
		return arr;
	}

	function getUnitList()
	{
		var arr = [];

		for (k in UnitData.config.keys())
		{
			var c = UnitData.config.get(k);
			if (c.race == selectedRace) arr.push(c);
		}
		return arr;
	}

	@:state var selectedListIndex:Int = 0;
	@:state var selectedRace:RaceId = RaceId.Human;
	@:skipCheck @:state var selectedAsset:AssetConfig = null;

	function render() '
		<div class="lu_editor__base_panel">
			<select class="lu_selector lu_offset" onchange={e -> { removeSelection(); selectedListIndex = cast(e.currentTarget, SelectElement).selectedIndex; }}>
				<option>({UnitData.count}) Units</option>
				<option>({EnvironmentData.count}) Environments</option>
			</select>
			<if {selectedListIndex == 0}>
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
					<select class="lu_selector lu_offset" onchange={e -> selectedRace = cast(e.currentTarget, SelectElement).value}>
						<option selected={selectedRace == RaceId.Human} value="human">({UnitData.humanCount}) Human</option>
						<option selected={selectedRace == RaceId.Elf} value="elf">({UnitData.elfCount}) Elf</option>
						<option selected={selectedRace == RaceId.Orc} value="orc">({UnitData.orcCount}) Orc</option>
						<option selected={selectedRace == RaceId.Undead} value="undead">({UnitData.undeadCount}) Undead</option>
						<option selected={selectedRace == RaceId.Neutral} value="neutral">({UnitData.neutralCount}) Neutral</option>
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
							{e.name}
						</li>
					</for>
				</ul>
			</div>
		</div>
	';

	public function removeSelection() { previewRequest(null); selectedAsset = null; }
}