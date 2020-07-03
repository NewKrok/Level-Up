package levelup.util;

import coconut.data.List;
import levelup.game.GameState.Trigger;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TriggerUtil
{
	public static function merge(trigger:Trigger, mergeObject:Dynamic):Trigger
	{
		return {
			actions: mergeObject.actions == null ? trigger.actions : mergeObject.actions,
			comment: mergeObject.comment == null ? trigger.comment : mergeObject.comment,
			condition: mergeObject.condition == null ? trigger.condition : mergeObject.condition,
			events: mergeObject.events == null ? trigger.events : mergeObject.events,
			id: mergeObject.id == null ? trigger.id : mergeObject.id,
			isEnabled: mergeObject.isEnabled == null ? trigger.isEnabled : mergeObject.isEnabled,
			localVariables: mergeObject.localVariables == null ? trigger.localVariables : mergeObject.localVariables
		};
	}

	public static function updateList(prevScript:Trigger, newScript:Trigger, scripts:List<Trigger>):List<Trigger>
	{
		var arr = scripts.toArray();
		var scriptIndex = arr.indexOf(prevScript);
		arr[scriptIndex] = newScript;

		return List.fromArray(arr);
	}
}