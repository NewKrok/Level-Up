package levelup.component.form.colorpicker;

import coconut.ui.View;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ColorPicker extends View
{
	@:attr var value:String = "0";
	@:attr var onChange:String->Void = null;

	function render() '
		<input
			type="color"
			class="lu_color_picker"
			value=$value
			onchange=${e -> onChange(e.currentTarget.value)}
		/>
	';
}