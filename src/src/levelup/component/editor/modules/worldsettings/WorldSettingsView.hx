package levelup.component.editor.modules.worldsettings;

import coconut.data.List;
import coconut.ui.View;
import hpp.util.Language;
import levelup.component.form.dropdown.Dropdown;

/**
 * ...
 * @author Krisztian Somoracz
 */
class WorldSettingsView extends View
{
	@:attr var hasFixedWorldTime:Bool;
	@:attr var setHasFixedWorldTime:Bool->Void;

	function render() '
		<div class="lu_editor__properties">
			<div class="lu_title">
				<i class="fas fa-globe-americas lu_icon"></i>{Language.get("editor.worldconfig.title")}
			</div>
			<div class="lu_block lu_block--fit-content">
				<div class="lu_sub-title">
					<i class="fas fa-sliders-h lu_icon"></i>{Language.get("common.general")}
				</div>
				<div class="lu_entry">
					{Language.get("editor.worldconfig.staticTime")}
					<Dropdown
						selectedIndex={hasFixedWorldTime ? 1 : 0}
						setSelectedIndex={v -> setHasFixedWorldTime(v == 1)}
						values={cast List.fromArray([Language.get("common.on"), Language.get("common.off")])}
					/>
				</div>
			</div>
		</div>
	';
}