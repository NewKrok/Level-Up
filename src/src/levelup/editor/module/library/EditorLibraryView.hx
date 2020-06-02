package levelup.editor.module.library;

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
class EditorLibraryView extends View
{
	@:attr var previewRequest:AssetConfig->Void;
	@:attr var selectedRace:RaceId;
	@:attr var setSelectedRace:RaceId->Void;
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

	@:state var itemSize:Int = 1;
	@:state var selectedListIndex:Int = 0;
	@:skipCheck @:state var selectedAsset:AssetConfig = null;

	function render() '
		<div class="lu_editor__properties__container">
			<div class="lu_title">
				<i class="fas fa-folder-open lu_horizontal_offset"></i>Library
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-sliders-h lu_right_offset"></i>Filters
				</div>
				<select onchange={e -> { removeSelection(); selectedListIndex = cast(e.currentTarget, SelectElement).selectedIndex; }} class="lu_form__select lu_fill_width lu_vertical_offset">
					<option selected={selectedListIndex == 0} value="0">({UnitData.count}) Units</option>
					<option selected={selectedListIndex == 1} value="1">({EnvironmentData.count}) Environments</option>
				</select>

				<if {selectedListIndex == 0}>
					<select class="lu_form__select lu_fill_width lu_vertical_offset" onchange={e -> setSelectedRace(cast(e.currentTarget, SelectElement).value)}>
						<option selected={selectedRace == RaceId.Human} value="human">({UnitData.humanCount}) Human</option>
						<option selected={selectedRace == RaceId.Elf} value="elf">({UnitData.elfCount}) Elf</option>
						<option selected={selectedRace == RaceId.Orc} value="orc">({UnitData.orcCount}) Orc</option>
						<option selected={selectedRace == RaceId.Undead} value="undead">({UnitData.undeadCount}) Undead</option>
						<option selected={selectedRace == RaceId.Neutral} value="neutral">({UnitData.neutralCount}) Neutral</option>
					</select>
					<div class="lu_row">
						<div class="lu_player_color_box lu_right_offset" style={"background-color: #" + Player.colors[selectedPlayer]} ></div>
						<select class="lu_form__select lu_fill_width" onchange={e -> onPlayerSelect(cast(e.currentTarget, SelectElement).selectedIndex)}>
							<for {i in 0...10}>
								<option selected={i == selectedPlayer} style={"color: #" + Player.colors[i]}>
									Player {i + 1}
								</option>
							</for>
						</select>
					</div>
				</if>
			</div>
			<div class="lu_editor__properties__block lu_editor__properties__block--header">
				<div class="lu_bottom_offset lu_row lu_row--space_between">
					<div>
						<i class="fas fa-list lu_right_offset"></i>Items
					</div>
					<div class="lu_row">
						<i class={"fas fa-search-minus lu_icon_button lu_right_offset" + (itemSize == 0 ? " lu_icon_button--disabled" : "")} onclick=$decreaseItemSize></i>
						<i class={"fas fa-search-plus lu_icon_button" + (itemSize == 2 ? " lu_icon_button--disabled" : "")} onclick=$increaseItemSize></i>
					</div>
				</div>
			</div>
			<div class="lu_editor__properties__block lu_editor__properties__block--content lu_row lu_row--breakable lu_row--space_evenly">
				<for {e in list}>
					<div class={"lu_editor_library__list_element"
								+ (e == selectedAsset ? " lu_editor_library__list_element--selected" : "")
								+ (itemSize == 0 ? " lu_editor_library__list_element--small" : "")
								+ (itemSize == 2 ? " lu_editor_library__list_element--large" : "")}
						onClick={() -> {if (selectedAsset == e) {previewRequest(null); selectedAsset = null;} else {previewRequest(e); selectedAsset = e;}}}
					>
						<img
							class="lu_editor_library__list_element__image"
							src={AssetCache.instance.getModelPreviewUrl(e.assetGroup)}
						/>
						<div class="lu_editor_library__list_element__name">
							{e.name}
						</div>
					</div>
				</for>
			</div>
		</div>
	';

	function decreaseItemSize()
	{
		itemSize = cast Math.max(itemSize - 1, 0);
	}

	function increaseItemSize()
	{
		itemSize = cast Math.min(itemSize + 1, 2);
	}

	public function removeSelection() { previewRequest(null); selectedAsset = null; }
}