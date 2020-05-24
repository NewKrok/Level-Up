package levelup.editor.module.skybox;

import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class SkyboxModule
{
	var core:EditorCore = _;

	public function new()
	{
		core.registerView(EditorViewId.VSkyboxModule, SkyboxView.fromHxx({

		}));
	}
}