package levelup.component.editor.modules.teamsettings;

import coconut.ui.RenderResult;
import levelup.editor.EditorState.EditorCore;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class TeamSettingsModule
{
	var core:EditorCore = _;

	var view:RenderResult;

	public function new()
	{
		core.model.registerModule({
			id: "TeamSettingsModule",
			icon: "fa-users-cog",
			instance: cast this
		});

		view = TeamSettingsView.fromHxx({

		});
	}
}