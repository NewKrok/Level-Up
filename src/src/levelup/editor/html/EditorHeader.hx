package levelup.editor.html;

import coconut.ui.View;
import hpp.util.Language;
import levelup.Asset.AssetConfig;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorHeader extends View
{
	@:attr var backToLobby:Void->Void;
	@:attr var save:Void->Void;
	@:attr var createNewAdventure:Void->Void;
	@:attr var testRun:Void->Void;

	function render() '
		<div class="lu_editor_header">
			<div class="lu_row lu_fill_height">
				<div class="lu_editor_header__button lu_right_offset" onclick=$save>
					<i class="fas fa-save lu_right_offset lu_text--l"></i>{Language.get("Save")}
				</div>
				<div class="lu_editor_header__button lu_right_offset" onclick=$createNewAdventure>
					<i class="fas fa-file lu_right_offset lu_text--l"></i>{Language.get("Create new Adventure")}
				</div>
				<div class="lu_editor_header__button" onclick=$testRun>
					<i class="fas fa-play-circle lu_right_offset lu_text--l"></i>{Language.get("Test Run")}
				</div>
			</div>
			<div class="lu_editor_header__button lu_text--l" onclick=$backToLobby>
				<i class="fas fa-times-circle"></i>
			</div>
		</div>
	';
}