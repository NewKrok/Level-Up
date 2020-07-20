package levelup.component.editor.modules.worldsettings;

import coconut.ui.RenderResult;
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

	var view:RenderResult;

	public function new()
	{
		core.model.registerModule({
			id: "WorldSettingsModule",
			icon: "fa-globe-americas",
			instance: cast this,
		});

		view = WorldSettingsView.fromHxx({
			hasFixedWorldTime: hasFixedWorldTime,
			setHasFixedWorldTime: v -> hasFixedWorldTime.set(v)
		});

		hasFixedWorldTime.set(core.adventureConfig.worldConfig.hasFixedWorldTime);
	}

	public function getHasFixedWorldTime() return hasFixedWorldTime.value;
}