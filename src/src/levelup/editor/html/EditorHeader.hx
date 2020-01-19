package levelup.editor.html;

import coconut.ui.View;
import levelup.Asset.AssetConfig;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorHeader extends View
{
	@:attr var backToLobby:Void->Void;
	@:attr var save:Void->Void;
	@:attr var createNewMap:Void->Void;
	@:attr var testRun:Void->Void;

	function render() '
		<div class="lu_editor_header">
			<div class="lu_button lu_right_offset" onclick=$backToLobby>
				<i class="fas fa-times-circle lu_right_offset"></i>Back to Lobby
			</div>
			<div class="lu_button lu_right_offset" onclick=$save>
				<i class="fas fa-save lu_right_offset"></i>Save Map
			</div>
			<div class="lu_button lu_right_offset" onclick=$createNewMap>
				<i class="fas fa-file lu_right_offset"></i>Create New Map
			</div>
			<div class="lu_button" onclick=$testRun>
				<i class="fas fa-play-circle lu_right_offset"></i>Test Run
			</div>
		</div>
	';
}