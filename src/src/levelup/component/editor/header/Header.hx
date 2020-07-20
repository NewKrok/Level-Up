package levelup.component.editor.header;

import coconut.ui.View;
import hpp.util.Language;
import levelup.Asset.AssetConfig;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Header extends View
{
	@:attr var backToLobby:Void->Void;
	@:attr var toggleFullScreen:Void->Void;
	@:attr var save:Void->Void;
	@:attr var createNewAdventure:Void->Void;
	@:attr var testRun:Void->Void;

	function render() '
		<div class="lu_editor_header">
			<div class="lu_menu">
				<div class="lu_button" onclick=$save>
					<i class="fas fa-save"></i>{/*Language.get("Save")*/}
				</div>
				<div class="lu_button" onclick=$createNewAdventure>
					<i class="fas fa-file"></i>{/*Language.get("Create new Adventure")*/}
				</div>
				<div class="lu_button" onclick=$testRun>
					<i class="fas fa-play-circle"></i>{/*Language.get("Test Run")*/}
				</div>
			</div>
			<div class="lu_controls">
				<div class="lu_button" onclick=$toggleFullScreen>
					<i class="far fa-window-restore"></i>
				</div>
				<div class="lu_button" onclick=$backToLobby>
					<i class="fas fa-times-circle"></i>
				</div>
			</div>
		</div>
	';
}