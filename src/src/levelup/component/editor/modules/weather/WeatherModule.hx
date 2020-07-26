package levelup.component.editor.modules.weather;

import coconut.ui.RenderResult;
import levelup.editor.EditorModel.EditorModuleId;
import levelup.editor.EditorState.EditorCore;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class WeatherModule
{
	var core:EditorCore = _;

	var globalWeather:State<Int> = new State<Int>(0);

	var view:RenderResult;

	public function new()
	{
		core.model.registerModule({
			id: EditorModuleId.MWeather,
			icon: "fa-cloud",
			instance: cast this
		});

		view = WeatherView.fromHxx({
			setGlobalWeather: v ->
			{
				globalWeather.set(v);
				core.world.setGlobalWeatherEffect(v);
			},
			selectedGlobalWeather: globalWeather
		});
	}

	public function getGlobalWeather() return globalWeather.value;
}