package levelup.game.html;

import coconut.ui.View;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LobbyUi extends View
{
	@:attribute var isTestRun:Bool;
	@:attribute var openEditor:Void->Void;
	@:attribute var closeTestRun:Void->Void;

	function render() '
		<div class="lu_lobby">
			<if {isTestRun}>
				<div class="lu_button" onclick=$closeTestRun>
					<i class="fas fa-drafting-compass lu_right_offset"></i>Close Test Run
				</div>
			<else>
				<div class="lu_button" onclick=$openEditor>
					<i class="fas fa-drafting-compass lu_right_offset"></i>Open Adventure Editor
				</div>
			</if>
		</div>
	';
}