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

		var triggers:Array<Trigger> = [for (t in cast(rawWorldConfig.triggers, Array<Dynamic>)) {
			id: t.id != null ? t.id.toLowerCase() : Std.string(Math.random() * 999999999),
			isEnabled: t.isEnabled != null ? t.isEnabled : true,
			event: switch (stringEnumToArray(t.event)) {
				case [event, regionName] if (event == "enterregion"): EnterRegion(getRegion(regions, regionName));
				case [event, time] if (event == "timeelapsed"): TimeElapsed(Std.parseFloat(time));
				case [event, time] if (event == "timeperiodic"): TimePeriodic(Std.parseFloat(time));
				case _: null;
			},
			condition: t.condition == null ? null : switch (stringEnumToArray(t.condition)) {
				case [condition, unitDefinition, expectedPlayer] if (condition == "ownerof"):
					OwnerOf(switch(unitDefinition.toLowerCase())
					{
						case "triggeringunit": TriggeringUnit;
						case _: null;
					}, cast expectedPlayer);
				case _: null;
			},
			actions: [for(actionEntry in cast(t.actions, Array<Dynamic>)) switch (stringEnumToArray(actionEntry)) {
				case [action, message] if (action == "log"): Log(message);
				case [action, levelName] if (action == "loadlevel"): LoadLevel(levelName);
				case [action, triggerId] if (action == "enabletrigger"): EnableTrigger(triggerId);
				case [action, unitId, owner, region] if (action == "createunit"): CreateUnit(unitId, cast owner, region);
				case [action, unitId, region] if (action == "attackmovetoregion"): AttackMoveToRegion(cast unitId, region);
				case _: null;
			}],
		}];

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

	static function stringEnumToArray(e)
	{
		var mainData = Std.string(e).split("(");
		var params = mainData[1].substr(0, mainData[1].length - 1).split(",");

		return [mainData[0].toLowerCase()].concat(params);
	}

	static function getRegion(regions:Array<Region>, id:String) return regions.filter(function (r) { return r.id == id; })[0];
}