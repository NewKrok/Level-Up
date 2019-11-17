package levelup.editor.html;

import coconut.ui.View;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LockedDragInfo extends View
{
	@:attr var isXDragLocked:Bool;
	@:attr var isYDragLocked:Bool;
	@:attr var toggleXDragLock:Void->Void;
	@:attr var toggleYDragLock:Void->Void;

	function render() '
		<div class={"lu_lock_info_panel" + (isXDragLocked && isYDragLocked ? " lu_warning" : "")}>
			{createLockView("Y", "Shift", isYDragLocked)}
			{createLockView("X", "Ctrl", isXDragLocked)}
		</div>
	';

	function createLockView(dir, key, condition) return hxx('
		<div class="lu_editor_footer__block lu_editor_footer__block--button" onclick={dir == "X" ? toggleXDragLock() : toggleYDragLock()}>
			<div><span class="lu_highlight">{dir}-position</span> {condition ? "is locked" : "is free"}</div>
			<div class="lu_lock_info">click or press <span class="lu_highlight">$key</span> to {condition ? "unlock" : "lock"}</div>
			<i class={"fas fa-" + (condition ? "lock lu_highlight" : "unlock") + " lu_lock_info_panel__lock"}></i>
		</div>
	');
}