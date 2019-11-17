package levelup.game.html;

import coconut.ui.View;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameUi extends View
{
	@:attribute var isTestRun:Bool;
	@:attribute var openLobby:Void->Void;
	@:attribute var closeTestRun:Void->Void;

	function render() '
		<div class="lu_game_ui">
			<div class="lu_game__header">
				<if {isTestRun}>
					<div class="lu_button" onclick=$closeTestRun>
						<i class="fas fa-times-circle lu_right_offset"></i>Close Test Run
					</div>
				<else>
					<div class="lu_button" onclick=$openLobby>
						<i class="fas fa-times-circle lu_right_offset"></i>Close Game
					</div>
				</if>
			</div>
		</div>
	';
}