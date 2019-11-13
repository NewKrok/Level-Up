package levelup.editor.html;

import coconut.ui.View;
import js.html.SelectElement;
import levelup.Asset.AssetConfig;
import levelup.editor.EditorState.AssetItem;
import levelup.editor.html.EditorLibrary;
import tink.pure.List;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorUi extends View
{
	@:attr var backToLobby:Void->Void;
	@:attr var previewRequest:AssetConfig->Void;

	@:skipCheck @:attr var environmentsList:List<AssetConfig>;
	@:skipCheck @:attr var propsList:List<AssetConfig>;
	@:skipCheck @:attr var unitsList:List<AssetConfig>;
	@:skipCheck @:attr var selectedWorldAsset:AssetItem;

	@:skipCheck @:state var hoveredAsset:AssetConfig = null;

	@:ref var editorLibrary:EditorLibrary;
	@:ref var selectedAsset:AssetProperties;

	function render() '
		<div class="lu_editor">
			<div class="lu_editor_left">
				<div class="lu_editor_menu">
					<div class="lu_button" onclick=$backToLobby>
					<i class="fas fa-times-circle lu_right_margin"></i>Back to Lobby
					</div>
				</div>
				<if {selectedWorldAsset != null}>
					<AssetProperties
						ref={selectedAsset}
						asset=$selectedWorldAsset
					/>
					<EditorPreview
						assetConfig={selectedWorldAsset.config}
					/>
				</if>
			</div>
			<div class="lu_editor_right">
				<EditorLibrary
					ref={editorLibrary}
					environmentsList={environmentsList}
					propsList={propsList}
					unitsList={unitsList}
					previewRequest={previewRequest}
					onAssetMouseOver={asset -> hoveredAsset = asset}
				/>
				<EditorPreview
					assetConfig=$hoveredAsset
				/>
			</div>
		</div>
	';

	public function removeSelection() editorLibrary.removeSelection();
	public function forceUpdateSelectedUser() selectedAsset.forceUpdate();
}