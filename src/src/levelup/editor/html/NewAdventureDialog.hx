package levelup.editor.html;

import coconut.ui.View;
import levelup.editor.EditorState.AssetItem;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class NewAdventureDialog extends View
{
	function render() '
		<div class="lu_selected_item">
			<div class="lu_title"><i class="fas fa-file lu_right_offset"></i>Create New Adventure</div>
			<div>
				# Map Size
				Small / Normal / Large / Extra Large
			</div>
			<div>
				# Base Terrain
				Selector...
			</div>
			<div>
				# Height Map
				Default height 0-10
				Generate Random Height Map - min / max - Preview...
				Generate Natural border
			</div>
			<div>
				# Select Game template
				Campaign - RPG with Multiple levels
				Dungeon - Simple Hack n Slash game
				Moba - 2 Teams try to beat the oter
				AOS - 3 Teams try to beat the oter
				Hero Survival - Try to survive as much wave as you can
			</div>
		</div>
	';
}