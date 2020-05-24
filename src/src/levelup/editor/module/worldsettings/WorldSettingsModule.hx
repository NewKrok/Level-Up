package levelup.editor.module.worldsettings;

import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class WorldSettingsModule
{
	var core:EditorCore = _;

	public function new()
	{
		core.registerView(EditorViewId.VWorldSettingsModule, WorldSettingsView.fromHxx({

		}));
	}
}