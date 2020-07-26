package levelup.component.editor.modules.light;

import coconut.ui.RenderResult;
import js.html.Event;
import levelup.editor.EditorModel.EditorModuleId;
import levelup.editor.EditorState.EditorCore;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class LightModule
{
	var core:EditorCore = _;

	var view:RenderResult;

	var sunAndMoonOffsetPercent:State<Float> = new State<Float>(0);
	var shadowPower:State<Float> = new State<Float>(0);
	var dayColor:State<String> = new State<String>("");
	var nightColor:State<String> = new State<String>("");
	var sunsetColor:State<String> = new State<String>("");
	var dawnColor:State<String> = new State<String>("");

	public function new()
	{
		core.model.registerModule({
			id: EditorModuleId.MLight,
			icon: "fa-sun",
			instance: cast this
		});

		view = LightView.fromHxx({
			changeSunAndMoonOffsetPercent: v -> sunAndMoonOffsetPercent.set(v),
			defaultSunAndMoonOffsetPercent: sunAndMoonOffsetPercent,
			changeShadowPower: v -> shadowPower.set(v),
			defaultShadowPower: shadowPower,
			changeDayColor: v -> dayColor.set(v),
			dayColor: dayColor,
			changeNightColor: v -> nightColor.set(v),
			nightColor: nightColor,
			changeSunsetColor: v -> sunsetColor.set(v),
			sunsetColor: sunsetColor,
			changeDawnColor: v -> dawnColor.set(v),
			dawnColor: dawnColor
		});

		sunAndMoonOffsetPercent.set(core.adventureConfig.worldConfig.light.sunAndMoonOffsetPercent);
		shadowPower.set(core.adventureConfig.worldConfig.light.shadowPower);
		dayColor.set(core.adventureConfig.worldConfig.light.dayColor);
		nightColor.set(core.adventureConfig.worldConfig.light.nightColor);
		sunsetColor.set(core.adventureConfig.worldConfig.light.sunsetColor);
		dawnColor.set(core.adventureConfig.worldConfig.light.dawnColor);

		sunAndMoonOffsetPercent.observe().bind(v -> core.world.setSunAndMoonOffsetPercent(v));
		shadowPower.observe().bind(v -> core.world.setShadowPowerPercent(v));
		dayColor.observe().bind(v -> core.world.setDayColor(v));
		nightColor.observe().bind(v -> core.world.setNightColor(v));
		sunsetColor.observe().bind(v -> core.world.setSunsetColor(v));
		dawnColor.observe().bind(v -> core.world.setDawnColor(v));
	}

	public function getData() return {
		sunAndMoonOffsetPercent: sunAndMoonOffsetPercent.value,
		shadowPower: shadowPower.value,
		dayColor: dayColor.value,
		nightColor: nightColor.value,
		sunsetColor: sunsetColor.value,
		dawnColor: dawnColor.value
	};
}