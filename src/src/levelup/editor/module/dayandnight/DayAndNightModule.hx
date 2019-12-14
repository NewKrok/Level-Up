package levelup.editor.module.dayandnight;

import js.html.Event;
import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class DayAndNightModule
{
	var core:EditorCore = _;

	public function new()
	{
		core.registerView(EditorViewId.VDayAndNightModule, DayAndNightEditorView.fromHxx({
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
		}));
	}
}