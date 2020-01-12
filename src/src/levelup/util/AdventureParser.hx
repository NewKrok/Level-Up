package levelup.util;

import h3d.Quat;
import h3d.Vector;
import haxe.Json;
import levelup.game.GameState.InitialUnitData;
import levelup.game.GameState.StaticObjectConfig;
import levelup.game.GameState.Trigger;
import levelup.game.GameState.WorldConfig;
import levelup.game.GameState.WorldEntity;
import levelup.game.GameWorld.Region;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AdventureParser
{
	public static function loadLevel(rawDataStr:String):WorldConfig
	{
		var rawData = Json.parse(rawDataStr);

		var startingTime = rawData.startingTime == null ? 12 : rawData.startingTime;
		var sunAndMoonOffsetPercent = rawData.sunAndMoonOffsetPercent == null ? 20 : rawData.sunAndMoonOffsetPercent;
		var dayColor = rawData.dayColor == null ? "#FFFFFF" : rawData.dayColor;
		var nightColor = rawData.nightColor == null ? "#333399" : rawData.nightColor;
		var sunsetColor = rawData.sunsetColor == null ? "#CC9919" : rawData.sunsetColor;
		var dawnColor = rawData.dawnColor == null ? "#808080" : rawData.dawnColor;

		var pathFindingMap:Array<Array<WorldEntity>> = rawData.pathFindingMap;

		var staticObjects:Array<StaticObjectConfig> = [for (o in cast(rawData.staticObjects, Array<Dynamic>)) {
			id: o.id,
			name: o.name,
			x: o.x,
			y: o.y,
			z: o.z,
			zOffset: o.zOffset,
			scale: o.scale,
			rotation: new Quat(o.rotation.x, o.rotation.y, o.rotation.z, o.rotation.w)
		}];

		var units:Array<InitialUnitData> = [for (o in cast(rawData.units, Array<Dynamic>)) {
			owner: o.owner,
			id: o.id,
			name: o.name,
			x: o.x,
			y: o.y,
			z: o.z,
			zOffset: o.zOffset,
			scale: o.scale,
			rotation: new Quat(o.rotation.x, o.rotation.y, o.rotation.z, o.rotation.w)
		}];

		var regions:Array<Region> = [for (r in cast(rawData.regions, Array<Dynamic>)) {
			id: r.id,
			name: r.name,
			x: r.x,
			y: r.y,
			width: r.width,
			height: r.height
		}];

		var triggers:Array<Trigger> = [];/*[for (t in cast(rawData.triggers, Array<Dynamic>)) {
			id: t.id != null ? t.id.toLowerCase() : Std.string(Math.random() * 9999999),
			isEnabled: t.isEnabled != null ? t.isEnabled : true,
			event: switch (t.event.toLowerCase().split(" ")) {
				case [event, regionName] if (event.toLowerCase() == "enterregion"): EnterRegion(getRegion(regions, regionName));
				case [event, time] if (event.toLowerCase() == "timeelapsed"): TimeElapsed(time);
				case [event, time] if (event.toLowerCase() == "timeperiodic"): TimePeriodic(time);
				case _: null;
			},
			condition: t.condition == null ? null : switch (t.condition.toLowerCase().split(" ")) {
				case [condition, unitDefinition, expectedPlayer] if (condition.toLowerCase() == "ownerof"):
					OwnerOf(switch(unitDefinition.toLowerCase())
					{
						case "triggeringunit": TriggeringUnit;
						case _: null;
					}, expectedPlayer);
				case _: null;
			},
			actions: [for(actionEntry in cast(t.actions, Array<Dynamic>)) switch (actionEntry.toLowerCase().split(" ")) {
				case [action, message] if (action.toLowerCase() == "log"): Log(message);
				case [action, levelName] if (action.toLowerCase() == "loadlevel"): LoadLevel(levelName);
				case [action, triggerId] if (action.toLowerCase() == "enabletrigger"): EnableTrigger(triggerId);
				case [action, unitId, owner] if (action.toLowerCase() == "createunit"): CreateUnit(unitId, owner);
				case _: null;
			}],
		}];*/

		var editorLastCamPosition = rawData.editorLastCamPosition == null ? null : new Vector(
			rawData.editorLastCamPosition.x,
			rawData.editorLastCamPosition.y,
			rawData.editorLastCamPosition.z
		);

		return {
			name: rawData.name,
			size: rawData.size,
			startingTime: startingTime,
			sunAndMoonOffsetPercent: sunAndMoonOffsetPercent,
			dayColor: dayColor,
			nightColor: nightColor,
			sunsetColor: sunsetColor,
			dawnColor: dawnColor,
			pathFindingMap: pathFindingMap,
			regions: regions,
			triggers: triggers,
			units: units,
			staticObjects: staticObjects,
			terrainLayers: rawData.terrainLayers,
			heightMap: rawData.heightMap,
			editorLastCamPosition: editorLastCamPosition
		};
	}

	static function getRegion(regions:Array<Region>, id:String) return regions.filter(function (r) { return r.id == id; })[0];
}