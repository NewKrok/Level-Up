package levelup.editor.module.weather;

import coconut.ui.View;
import hpp.util.Language;

/**
 * ...
 * @author Krisztian Somoracz
 */
class WeatherView extends View
{
	@:attr var setGlobalWeather:Int->Void;
	@:attr var selectedGlobalWeather:Int;

	function render() '
		<div class="lu_editor__properties__container">
			<div class="lu_title">
				<i class="fas fa-cloud lu_right_offset"></i>Weather
			</div>
			<div class="lu_editor__properties__block">
				<div class="lu_bottom_offset">
					<i class="fas fa-expand-arrows-alt lu_right_offset"></i>Global weather
				</div>
				<select onChange={e -> setGlobalWeather(Std.parseInt(e.currentTarget.value))} class="lu_form__select lu_fill_width">
					<option selected={selectedGlobalWeather == 0} value="0">{Language.get("Normal")}</option>
					<option selected={selectedGlobalWeather == 1} value="1">{Language.get("Snowfall")}</option>
					{/**<option selected={selectedGlobalWeather == 2} value="2">{Language.get("Rain")}</option>*/}
				</select>
			</div>
		</div>
	';
}