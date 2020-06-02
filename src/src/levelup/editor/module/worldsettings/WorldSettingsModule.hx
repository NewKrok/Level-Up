package levelup.editor.module.worldsettings;

import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class WorldSettingsModule
{
	var core:EditorCore = _;

	var hasFixedWorldTime:State<Bool> = new State<Bool>(false);

	public function new()
	{
		hasFixedWorldTime.set(core.adventureConfig.worldConfig.hasFixedWorldTime);

		core.registerView(EditorViewId.VWorldSettingsModule, WorldSettingsView.fromHxx({
			hasFixedWorldTime: hasFixedWorldTime,
			setHasFixedWorldTime: v -> hasFixedWorldTime.set(v)
		}));
	}

	public function getHasFixedWorldTime() return hasFixedWorldTime.value;
}