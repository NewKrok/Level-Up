package levelup.editor.module.worldsettings;

import coconut.ui.View;
import hpp.util.Language;

/**
 * ...
 * @author Krisztian Somoracz
 */
class WorldSettingsView extends View
{
	@:attr var hasFixedWorldTime:Bool;
	@:attr var setHasFixedWorldTime:Bool->Void;

	function render() '
		<div class="lu_editor__properties__container">
			<div class="lu_title">
				<i class="fas fa-globe-americas lu_right_offset"></i>World settings
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-sliders-h lu_right_offset"></i>General
				</div>
				<div class="lu_row lu_row--space_between">
					Static world time
					<select onChange={e -> setHasFixedWorldTime(e.currentTarget.value == "1")} class="lu_form__select">
						<option selected={hasFixedWorldTime} value="1">{Language.get("On")}</option>
						<option selected={!hasFixedWorldTime} value="0">{Language.get("Off")}</option>
					</select>
				</div>
			</div>
		</div>
	';
}