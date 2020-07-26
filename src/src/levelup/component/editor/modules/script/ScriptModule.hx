package levelup.component.editor.modules.script;

import coconut.data.List;
import coconut.ui.RenderResult;
import haxe.EnumTools;
import levelup.editor.EditorModel.EditorModuleId;
import levelup.editor.EditorState.EditorCore;
import levelup.component.editor.modules.script.ScriptConfig.ScriptData;
import levelup.game.GameState.Trigger;
import levelup.game.GameState.TriggerAction;
import levelup.util.TriggerUtil;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class ScriptModule
{
	var core:EditorCore = _;

	var view:RenderResult;

	private var scripts:State<List<Trigger>> = new State<List<Trigger>>(List.fromArray([]));
	private var selectedScript:State<Trigger> = new State<Trigger>(null);
	private var selectors:State<List<RenderResult>> = new State<List<RenderResult>>(List.fromArray([]));

	public function new()
	{
		core.model.registerModule({
			id: EditorModuleId.MScript,
			icon: "fa-code",
			instance: cast this
		});

		scripts.set(List.fromArray(core.adventureConfig.worldConfig.triggers));
		if (scripts.value.length > 0) selectedScript.set(scripts.value.toArray()[0]);

		view = ScriptEditorView.fromHxx({
			selectors: selectors,
			scripts: scripts,
			selectedScript: selectedScript,
			openSelector: openSelector,
			setComment: setComment
		});
	}

	function setComment(comment:String):Void
	{
		var newScript = TriggerUtil.merge(selectedScript.value, { comment: comment });
		scripts.set(TriggerUtil.updateList(
			selectedScript.value,
			newScript,
			scripts.value
		));
		selectedScript.set(newScript);
	}

	function openSelector(type:String, index:Int, data:ScriptData, paramIndex:Int):Void
	{
		var selector = new ParamSelector({
			script: selectedScript,
			close: closeLastSelector,
			data: data,
			setValue: v ->
			{
				switch(type)
				{
					case "action":
						var name = selectedScript.value.actions[index].getName();
						var params = selectedScript.value.actions[index].getParameters();
						var newParams:Array<Dynamic> = [];

						for (i in 0...params.length)
						{
							if (i == paramIndex)
							{
								newParams.push(v);
							}
							else
							{
								newParams.push(params[i]);
							}
						}

						var newActions = selectedScript.value.actions.concat([]);
						newActions[index] = EnumTools.createByName(TriggerAction, name, newParams);
						var newScript = TriggerUtil.merge(selectedScript.value, { actions: newActions });
						scripts.set(TriggerUtil.updateList(
							selectedScript.value,
							newScript,
							scripts.value
						));
						selectedScript.set(newScript);

					case _:
				}
			},
			paramIndex: paramIndex
		});
		selectors.set(selectors.value.append(selector.reactify()));
	}

	function closeLastSelector():Void
	{
		selectors.set(List.fromArray(selectors.value.toArray().slice(0, selectors.value.length - 2)));
	}

	public function getScripts() return scripts.value.toArray();
}