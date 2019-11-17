package levelup.editor.html;

import coconut.ui.View;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SnapGridInfo extends View
{
	@:attr var currentSnap:Float;
	@:attr var changeSnap:Float->Void;

	var snapOptions:Array<Float> = [0, 0.25, 0.5, 1, 2.5];

	function render() '
		<div class="lu_snap_info_panel lu_editor_footer__block">
			<i class="fas fa-th-large lu_right_offset lu_text--l"></i>
			<for {o in snapOptions}>
				<div
					class={"lu_snap__button" + (currentSnap == o ? " lu_snap__button--selected" : "")}
					onclick={changeSnap(o)}
				>
					{o == 0 ? "Free" : o}
				</div>
			</for>
		</div>
	';

	public function increaseSnap()
	{
		for (i in 0...snapOptions.length)
		{
			if (snapOptions[i] == currentSnap)
			{
				if (i == snapOptions.length - 1) changeSnap(snapOptions[0]);
				else changeSnap(snapOptions[i + 1]);

				return;
			}
		}
	}
}