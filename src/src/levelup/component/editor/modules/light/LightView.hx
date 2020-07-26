package levelup.component.editor.modules.light;

import coconut.ui.View;
import hpp.util.Language;
import js.html.InputElement;
import levelup.component.form.slider.Slider;
import levelup.component.form.colorpicker.ColorPicker;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LightView extends View
{
	@:attr var changeSunAndMoonOffsetPercent:Float->Void;
	@:attr var defaultSunAndMoonOffsetPercent:Float;
	@:attr var defaultShadowPower:Float;
	@:attr var changeShadowPower:Float->Void;
	@:attr var changeDayColor:String->Void;
	@:attr var dayColor:String;
	@:attr var changeNightColor:String->Void;
	@:attr var nightColor:String;
	@:attr var changeSunsetColor:String->Void;
	@:attr var sunsetColor:String;
	@:attr var changeDawnColor:String->Void;
	@:attr var dawnColor:String;

	function render() '
		<div class="lu_editor__properties">
			<div class="lu_title">
				<i class="fas fa-sun lu_icon"></i>{Language.get("editor.light.title")}
			</div>
			<div class="lu_block">
				<div class="lu_sub-title">
					<i class="fas fa-sliders-h lu_icon"></i>{Language.get("common.general")}
				</div>
				<div class="lu_entry">
					{Language.get("editor.light.vOffset")}
					<Slider
						min={0}
						max={100}
						startValue=$defaultSunAndMoonOffsetPercent
						step={1}
						onChange=$changeSunAndMoonOffsetPercent
					/>
				</div>
				<div class="lu_entry">
					{Language.get("editor.light.shadowPower")}
					<Slider
						min={0}
						max={100}
						startValue=$defaultShadowPower
						step={1}
						onChange=$changeShadowPower
					/>
				</div>
			</div>
			<div class="lu_block">
				<div class="lu_sub-title">
					<i class="fas fa-palette lu_icon"></i>{Language.get("editor.light.colors")}
				</div>
				<div class="lu_entry">
					{Language.get("editor.light.dayColor")}
					<ColorPicker
						value=$dayColor
						onChange=$changeDayColor
					/>
				</div>
				<div class="lu_entry">
					{Language.get("editor.light.nightColor")}
					<ColorPicker
						value=$nightColor
						onChange=$changeNightColor
					/>
				</div>
				<div class="lu_entry">
					{Language.get("editor.light.sunsetColor")}
					<ColorPicker
						value=$sunsetColor
						onChange=$changeSunsetColor
					/>
				</div>
				<div class="lu_entry">
					{Language.get("editor.light.dawnColor")}
					<ColorPicker
						value=$dawnColor
						onChange=$changeDawnColor
					/>
				</div>
			</div>
		</div>
	';
}