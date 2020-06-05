package levelup.editor.module.script;

import coconut.data.List;
import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;
import levelup.game.GameState.Trigger;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class ScriptModule
{
	var core:EditorCore = _;

	private var scripts:State<List<Trigger>> = new State<List<Trigger>>(List.fromArray([]));
	private var selectedScript:State<Trigger> = new State<Trigger>(null);

	public function new()
	{
		scripts.set(List.fromArray(core.adventureConfig.worldConfig.triggers));
		if (scripts.value.length > 0) selectedScript.set(scripts.value.toArray()[0]);

		core.registerView(EditorViewId.VScriptModule, ScriptEditorView.fromHxx({
			scripts: scripts,
			selectedScript: selectedScript
		}));
	}
}