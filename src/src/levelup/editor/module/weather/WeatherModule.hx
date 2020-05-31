package levelup.editor.module.weather;

import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class WeatherModule
{
	var core:EditorCore = _;

	var globalWeather:State<Int> = new State<Int>(0);

	public function new()
	{
		core.registerView(EditorViewId.VWeatherModule, WeatherView.fromHxx({
			setGlobalWeather: v ->
			{
				globalWeather.set(v);
				core.world.setGlobalWeatherEffect(v);
			},
			selectedGlobalWeather: globalWeather
		}));
	}

	public function getGlobalWeather() return globalWeather.value;
}