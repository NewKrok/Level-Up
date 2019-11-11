package levelup.editor.html;

import coconut.ui.View;
import js.html.SelectElement;
import levelup.Asset.AssetItem;
import tink.pure.List;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorUi extends View
{
	@:attribute var backToLobby:Void->Void;
	@:attribute var previewRequest:AssetItem->Void;

	@:skipCheck @:attribute var environmentsList:List<AssetItem>;
	@:skipCheck @:attribute var propsList:List<AssetItem>;
	@:skipCheck @:attribute var unitsList:List<AssetItem>;

	@:computed var list:List<AssetItem> = switch (selectedListIndex) {
		case 0: environmentsList;
		case 1: propsList;
		case 2: unitsList;
		case _: List.fromArray([]);
	};

	@:state var selectedListIndex:Int = 0;
	@:skipCheck @:state var selectedAsset:AssetItem = null;
	@:skipCheck @:state var hoveredAsset:AssetItem = null;

	function render() '
		<div class="lu_editor">
			<div class="lu_editor_left">
				<div class="lu_editor_menu">
					<div class="lu_button" onclick=$backToLobby>
					<i class="fas fa-times-circle lu_right_margin"></i>Back to Lobby
					</div>
				</div>
			</div>
			<div class="lu_editor_right">
				<div class="lu_editor__library">
					<div class="lu_title"><i class="fas fa-folder-open lu_right_margin"></i>Library</div>
					<select class="lu_selector" onchange={e -> { removeSelection(); selectedListIndex = cast(e.currentTarget, SelectElement).selectedIndex; }}>
						<option>({environmentsList.length}) Environments</option>
						<option>({propsList.length}) Props</option>
						<option>({unitsList.length}) Units</option>
					</select>
					<div class="lu_list_container">
						<ul>
							<for {e in list}>
								<li
									class={"lu_list_element" + (e == selectedAsset ? " lu_list_element--selected" : "")}
									onmouseover={() -> hoveredAsset = e}
									onclick={() -> {if (selectedAsset == e) {previewRequest(null); selectedAsset = null;} else {previewRequest(e); selectedAsset = e;}}}>
									{e.name.replace("SM_", "").replace("_", " ")}
								</li>
							</for>
						</ul>
					</div>
				</div>
				<div class="lu_editor__preview">
					<div class="lu_title"><i class="fas fa-eye lu_right_margin"></i>Preview</div>
					<if {hoveredAsset != null}>
						<if {hoveredAsset.previewUrl == null}>
							<div class="lu_editor__empty_preview"><i class="fas fa-eye-slash"></i></div>
						<else>
							<img class="lu_editor__preview_image" src={hoveredAsset.previewUrl}/>
						</if>
					</if>
				</div>
			</div>
		</div>
	';

	public function removeSelection() { previewRequest(null); selectedAsset = null; }
}