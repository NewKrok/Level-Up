package levelup.component.editor.modules.dayandnight;

import coconut.ui.RenderResult;
import js.html.Event;
import levelup.editor.EditorState.EditorCore;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class DayAndNightModule
{
	var core:EditorCore = _;

	var view:RenderResult;

	public function new()
	{
		core.model.registerModule({
			id: "DayAndNightModule",
			icon: "fa-sun",
			instance: cast this
		});

		view = DayAndNightEditorView.fromHxx({
			changeStartingTime: v -> core.model.startingTime = v,
			defaultStartTime: core.model.startingTime,
			changeSunAndMoonOffsetPercent: v -> core.model.sunAndMoonOffsetPercent = v,
			defaultSunAndMoonOffsetPercent: core.model.sunAndMoonOffsetPercent,
			changeDayColor: v -> core.model.dayColor = v,
			dayColor: core.model.dayColor,
			changeNightColor: v -> core.model.nightColor = v,
			nightColor: core.model.nightColor,
			changeSunsetColor: v -> core.model.sunsetColor = v,
			sunsetColor: core.model.sunsetColor,
			changeDawnColor: v -> core.model.dawnColor = v,
			dawnColor: core.model.dawnColor,
		});
	}
}