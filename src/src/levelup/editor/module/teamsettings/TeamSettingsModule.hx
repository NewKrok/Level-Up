package levelup.editor.module.teamsettings;

import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class TeamSettingsModule
{
	var core:EditorCore = _;

	public function new()
	{
		core.registerView(EditorViewId.VTeamSettingsModule, TeamSettingsView.fromHxx({

		}));
	}
}