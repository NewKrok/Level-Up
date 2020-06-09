package levelup.editor.module.script;

import coconut.data.List;
import coconut.ui.RenderResult;
import levelup.editor.EditorState.EditorCore;
import levelup.editor.EditorState.EditorViewId;
import levelup.editor.module.script.ScriptConfig.ScriptData;
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
	private var selectors:State<List<RenderResult>> = new State<List<RenderResult>>(List.fromArray([]));

	public function new()
	{
		scripts.set(List.fromArray(core.adventureConfig.worldConfig.triggers));
		if (scripts.value.length > 0) selectedScript.set(scripts.value.toArray()[0]);

		core.registerView(EditorViewId.VScriptModule, ScriptEditorView.fromHxx({
			selectors: selectors,
			scripts: scripts,
			selectedScript: selectedScript,
			openSelector: openSelector
		}));
	}

	function openSelector(data:ScriptData, paramIndex:Int):Void
	{
		var selector = new ParamSelector({
			close: closeLastSelector,
			data: data,
			paramIndex: paramIndex
		});
		selectors.set(selectors.value.append(selector.reactify()));
	}

	function closeLastSelector():Void
	{
		selectors.set(List.fromArray(selectors.value.toArray().slice(0, selectors.value.length - 2)));
	}
}