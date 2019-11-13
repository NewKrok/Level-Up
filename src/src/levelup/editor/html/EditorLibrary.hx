package levelup.editor.html;

import coconut.ui.View;
import js.html.SelectElement;
import levelup.Asset.AssetConfig;
import levelup.editor.EditorState.AssetItem;
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

	@:skipCheck @:attr var environmentsList:List<AssetConfig>;
	@:skipCheck @:attr var propsList:List<AssetConfig>;
	@:skipCheck @:attr var unitsList:List<AssetConfig>;

	@:computed var list:List<AssetConfig> = switch (selectedListIndex) {
		case 0: environmentsList;
		case 1: propsList;
		case 2: unitsList;
		case _: List.fromArray([]);
	};

	@:state var selectedListIndex:Int = 0;
	@:skipCheck @:state var selectedAsset:AssetConfig = null;

	function render() '
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