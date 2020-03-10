package levelup.util;

import h3d.Quat;
import h3d.Vector;
import haxe.Json;
import levelup.game.GameState.AdventureConfig;
import levelup.game.GameState.InitialUnitData;
import levelup.game.GameState.StaticObjectConfig;
import levelup.game.GameState.Trigger;
import levelup.game.GameState.WorldConfig;
import levelup.game.GameWorld.Region;
import lzstring.LZString;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AdventureParser
{
	public static function loadLevel(rawDataStr:String):AdventureConfig
	{
		var compressor:LZString = new LZString();
		var rawData = Json.parse(rawDataStr);
		var rawWorldConfig = Json.parse(compressor.decompressFromEncodedURIComponent(rawData.worldConfig));

		var startingTime = rawWorldConfig.startingTime == null ? 12 : rawWorldConfig.startingTime;
		var sunAndMoonOffsetPercent = rawWorldConfig.sunAndMoonOffsetPercent == null ? 20 : rawWorldConfig.sunAndMoonOffsetPercent;
		var dayColor = rawWorldConfig.dayColor == null ? "#FFFFFF" : rawWorldConfig.dayColor;
		var nightColor = rawWorldConfig.nightColor == null ? "#333399" : rawWorldConfig.nightColor;
		var sunsetColor = rawWorldConfig.sunsetColor == null ? "#CC9919" : rawWorldConfig.sunsetColor;
		var dawnColor = rawWorldConfig.dawnColor == null ? "#808080" : rawWorldConfig.dawnColor;

		var staticObjects:Array<StaticObjectConfig> = [for (o in cast(rawWorldConfig.staticObjects, Array<Dynamic>)) {
			id: o.id,
			name: o.name,
			x: o.x,
			y: o.y,
			z: o.z,
			zOffset: o.zOffset,
			scale: o.scale,
			rotation: new Quat(o.rotation.x, o.rotation.y, o.rotation.z, o.rotation.w),
			isPathBlocker: o.isPathBlocker
		}];

		var units:Array<InitialUnitData> = [for (o in cast(rawWorldConfig.units, Array<Dynamic>)) {
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

		var regions:Array<Region> = [for (r in cast(rawWorldConfig.regions, Array<Dynamic>)) {
			id: r.id,
			name: r.name,
			x: r.x,
			y: r.y,
			width: r.width,
			height: r.height
		}];

		var triggers:Array<Trigger> = [];/*[for (t in cast(rawWorldConfig.triggers, Array<Dynamic>)) {
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

		var editorLastCamPosition = rawWorldConfig.editorLastCamPosition == null ? null : new Vector(
			rawWorldConfig.editorLastCamPosition.x,
			rawWorldConfig.editorLastCamPosition.y,
			rawWorldConfig.editorLastCamPosition.z
		);

		return {
			name: rawData.name,
			editorVersion: rawData.editorVersion,
			size: rawData.size,
			worldConfig: {
				startingTime: startingTime,
				sunAndMoonOffsetPercent: sunAndMoonOffsetPercent,
				dayColor: dayColor,
				nightColor: nightColor,
				sunsetColor: sunsetColor,
				dawnColor: dawnColor,
				regions: regions,
				triggers: triggers,
				units: units,
				staticObjects: staticObjects,
				terrainLayers: rawWorldConfig.terrainLayers,
				heightMap: rawWorldConfig.heightMap,
				levellingHeightMap: rawWorldConfig.levellingHeightMap,
				editorLastCamPosition: editorLastCamPosition
			}
		};
	}

	static function getRegion(regions:Array<Region>, id:String) return regions.filter(function (r) { return r.id == id; })[0];
}