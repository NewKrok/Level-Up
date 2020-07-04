package levelup.editor.module.script;

import levelup.game.GameState.TriggerCondition;
import levelup.game.GameState.TriggerEvent;
import levelup.game.GameState.TriggerAction;
import levelup.game.GameState.VariableDefinition;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ScriptConfig
{
	public static function getEventData(event:TriggerEvent):ScriptData return switch(event)
	{
		case TriggerEvent.OnInit: {
			paramTypes: [
			],
			values: [],
			description: "Run this script right after the game has been {highlight_start}inited{highlight_end}."
		}

		case _: { paramTypes: [], values: [], description: "This event is not implemented yet: " + event.getName() }
	};

	public static function getConditionData(condition:TriggerCondition):ScriptData return switch(condition)
	{
		case null: {
			paramTypes: [
			],
			values: [],
			description: "There is no any condition for this script, it will run immediately after it's event is triggered."
		}

		case _: { paramTypes: [], values: [], description: "This condition is not implemented yet: " + condition.getName() }
	};

	public static function getActionData(action:TriggerAction):ScriptData return switch(action)
	{
		case TriggerAction.AnimateCameraToCamera(playerId, camera, time, ease): {
			paramTypes: [
				ParamType.PPlayer,
				ParamType.PCamera,
				ParamType.PNumber,
				ParamType.PString
			],
			values: [playerId, camera, time, ease],
			descriptionParamModifier: [0 => playerIdDescriptionModifier],
			description: "{highlight_start}Animate camera{highlight_end} for {p0} to {p1} under {p2} second(s) with {p3}."
		}

		case TriggerAction.FadeOut(playerId, color, time): {
			paramTypes: [
				ParamType.PPlayer,
				ParamType.PUInt,
				ParamType.PNumber
			],
			values: [playerId, color, time],
			descriptionParamModifier: [0 => playerIdDescriptionModifier],
			description: "{highlight_start}Fade out{highlight_end} the screen for {p0} to color {p1} under {p2} second(s)."
		}

		case TriggerAction.JumpCameraToCamera(playerId, camera): {
			paramTypes: [
				ParamType.PPlayer,
				ParamType.PCamera
			],
			values: [playerId, camera],
			descriptionParamModifier: [0 => playerIdDescriptionModifier],
			description: "{highlight_start}Jump camera{highlight_end} for {p0} to {p1}."
		}

		case TriggerAction.StartCameraShake(playerId, amplitude, time, ease): {
			paramTypes: [
				ParamType.PPlayer,
				ParamType.PNumber,
				ParamType.PNumber,
				ParamType.PString
			],
			values: [playerId, amplitude, time, ease],
			descriptionParamModifier: [0 => playerIdDescriptionModifier],
			description: "{highlight_start}Start camera shake{highlight_end} for {p0} with amplitude {p1} and with frequency time {p2} second(s) with {p3}."
		}

		case TriggerAction.Wait(time): {
			paramTypes: [
				ParamType.PNumber
			],
			values: [time],
			description: "{highlight_start}Wait{highlight_end} {p0} seconds before the next action will be triggered."
		}

		case _: { paramTypes: [], values: [], description: "This action is not implemented yet: " + action.getName() }
	};

	private static function playerIdDescriptionModifier(v) return "Player " + (Std.int(v) + 1);
}

typedef ScriptData = {
	var paramTypes(default, never):Array<ParamType>;
	var values(default, never):Array<Dynamic>;
	var description(default, never):String;
	@:optional var descriptionParamModifier(default, never):Map<Int, Dynamic->Dynamic>;
}

enum ParamType {
	PUInt;
	PNumber;
	PString;
	PPlayer;
	PCamera;
}