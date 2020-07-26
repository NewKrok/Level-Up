package levelup.component.editor.modules.worldsettings;

import coconut.ui.RenderResult;
import levelup.editor.EditorModel.EditorModuleId;
import levelup.editor.EditorState.EditorCore;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class WorldSettingsModule
{
	var core:EditorCore = _;

	var hasFixedWorldTime:State<Bool> = new State<Bool>(false);
	var startingTime:State<Float> = new State<Float>(0);

	var view:RenderResult;

	public function new()
	{
		core.model.registerModule({
			id: EditorModuleId.MWorldSettings,
			icon: "fa-globe-americas",
			instance: cast this,
		});

		view = WorldSettingsView.fromHxx({
			hasFixedWorldTime: hasFixedWorldTime,
			setHasFixedWorldTime: v -> hasFixedWorldTime.set(v),
			changeStartingTime: v -> startingTime.set(v),
			defaultStartTime: startingTime
		});

		hasFixedWorldTime.set(core.adventureConfig.worldConfig.general.hasFixedWorldTime);
		startingTime.set(core.adventureConfig.worldConfig.general.startingTime);

		startingTime.observe().bind(v -> core.world.setTime(v));
	}

	public function getData() return {
		hasFixedWorldTime: hasFixedWorldTime.value,
		startingTime: startingTime.value
	};
}