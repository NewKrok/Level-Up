package levelup.component.form.slider;

import coconut.ui.View;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Slider extends View
{
	@:attr var min:Float = 0.0;
	@:attr var max:Float = 100.0;
	@:attr var step:Float = 1.0;
	@:attr var startValue:Float = 0.0;
	@:attr var onChange:Float->Void = null;
	@:attr var className:String = "";

	@:state var value:Float = 0;

	function viewDidMount()
	{
		value = startValue;
		normalizeValue();
	}

	function render() '
		<div class={"lu_slider" + (className != "" ? " " + className : "")}>
			<input
				type="range"
				min={Std.string(min)}
				max={Std.string(max)}
				step={Std.string(step)}
				class="lu_native_slider"
				onchange={e -> {
					e.preventDefault();
					value = Std.parseFloat(e.currentTarget.value);
					onChange(value);
				}}
			/>
			<div class="lu_slider__thumb_container">
				<div class="lu_slider__thumb" style=${getStyle()}>
				</div>
			</div>
		</div>
	';

	function getStyle()
	{
		return "width:" + Math.max((value - min) / (max - min) * 100, 0) + "%";
	}

	function normalizeValue()
	{
		value = Math.max(value, min);
		value = Math.min(value, max);
	}
}