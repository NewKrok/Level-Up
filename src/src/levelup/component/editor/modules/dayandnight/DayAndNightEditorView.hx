package levelup.component.editor.modules.dayandnight;

import coconut.ui.View;
import js.html.InputElement;
import levelup.component.Slider;
import tink.pure.List;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class DayAndNightEditorView extends View
{
	@:attr var changeStartingTime:Float->Void;
	@:attr var defaultStartTime:Float;
	@:attr var changeSunAndMoonOffsetPercent:Float->Void;
	@:attr var defaultSunAndMoonOffsetPercent:Float;
	@:attr var changeDayColor:String->Void;
	@:attr var dayColor:String;
	@:attr var changeNightColor:String->Void;
	@:attr var nightColor:String;
	@:attr var changeSunsetColor:String->Void;
	@:attr var sunsetColor:String;
	@:attr var changeDawnColor:String->Void;
	@:attr var dawnColor:String;

	@:ref var dayColorPicker:InputElement;
	@:ref var nightColorPicker:InputElement;
	@:ref var sunsetColorPicker:InputElement;
	@:ref var dawnColorPicker:InputElement;

	function render() '
		<div class="lu_editor__properties">
			<div class="lu_title">
				<i class="fas fa-sun lu_right_offset"></i>Light Settings
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-clock lu_right_offset"></i>Starting Time
				</div>
				<Slider
					min={0}
					max={24}
					startValue={defaultStartTime}
					step={0.1}
					onChange=$changeStartingTime

				/>
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-arrows-alt-v lu_right_offset"></i>Horizontal Offset
				</div>
				<Slider
					min={0}
					max={100}
					startValue={defaultSunAndMoonOffsetPercent}
					step={1}
					onChange=$changeSunAndMoonOffsetPercent
				/>
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-palette lu_right_offset"></i>Day Color
				</div>
				<input
					ref=$dayColorPicker
					type="color"
					id="day"
					class="lu_color_picker lu_fill_width"
					value=$dayColor
					onchange=${e -> changeDayColor(e.currentTarget.value)}
				/>
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-palette lu_right_offset"></i>Night Color
				</div>
				<input
					ref=$nightColorPicker
					type="color"
					id="night"
					class="lu_color_picker lu_fill_width"
					value=$nightColor
					onchange=${e -> changeNightColor(e.currentTarget.value)}
				/>
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-palette lu_right_offset"></i>Sunset Color
				</div>
				<input
					ref=$sunsetColorPicker
					type="color"
					id="sunset"
					class="lu_color_picker lu_fill_width"
					value=$sunsetColor
					onchange=${e -> changeSunsetColor(e.currentTarget.value)}
				/>
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-palette lu_right_offset"></i>Dawn Color
				</div>
				<input
					ref=$dawnColorPicker
					type="color"
					id="dawn"
					class="lu_color_picker lu_fill_width"
					value=$dawnColor
					onchange=${e -> changeDawnColor(e.currentTarget.value)}
				/>
			</div>
		</div>
	';
}