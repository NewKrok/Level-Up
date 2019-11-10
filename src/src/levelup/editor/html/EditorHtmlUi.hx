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
class EditorHtmlUi extends View
{
	@:attribute var backToLobby:Void->Void;

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

	function render() '
		<div class="lu_editor">
			<div class="lu_editor_left">
				<div class="lu_editor_menu">
					<div class="lu_button" onclick=$backToLobby>
					<i class="fas fa-times-circle lu_right_margin"></i>Back to Lobby
				</div>
				</div>
				<div class="lu_editor__preview">
					<div class="lu_title"><i class="fas fa-eye lu_right_margin"></i>Preview</div>
				</div>
			</div>
			<div class="lu_editor__library">
				<div class="lu_title"><i class="fas fa-folder-open lu_right_margin"></i>Library</div>
				<select class="lu_selector" onchange={e -> selectedListIndex = cast(e.currentTarget, SelectElement).selectedIndex}>
					<option>({environmentsList.length}) Environments</option>
					<option>({propsList.length}) Props</option>
					<option>({unitsList.length}) Units</option>
				</select>
				<div class="lu_list_container">
					<ul>
						<for {e in list}>
							<li class="lu_list_element">{e.name.replace("SM_", "").replace("_", " ")}</li>
						</for>
					</ul>
				</div>
			</div>
		</div>
	';
}