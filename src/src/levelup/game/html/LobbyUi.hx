package levelup.game.html;

import coconut.ui.View;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LobbyUi extends View
{
	@:attribute var openEditor:Void->Void;

	function render() '
		<div class="lu_lobby">
			<div class="lu_button" onclick=$openEditor>
				<i class="fas fa-drafting-compass lu_right_margin"></i>Open Adventure Editor
			</div>
		</div>
	';
}