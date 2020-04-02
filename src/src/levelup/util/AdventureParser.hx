package levelup.util;

import h3d.Quat;
import h3d.Vector;
import haxe.Json;
import levelup.game.GameState.AdventureConfig;
import levelup.game.GameState.InitialUnitData;
import levelup.game.GameState.PlayerId;
import levelup.game.GameState.StaticObjectConfig;
import levelup.game.GameState.TerrainLayerInfo;
import levelup.game.GameState.Trigger;
import levelup.game.GameState.GetUnitDefinition;
import levelup.game.GameState.TriggerAction;
import levelup.game.GameState.TriggerCondition;
import levelup.game.GameState.TriggerEvent;
import levelup.game.GameState.UnitDefinition;
import levelup.game.GameState.Filter;
import levelup.game.GameState.WorldConfig;
import levelup.game.GameWorld.Region;
import lzstring.LZString;

using StringTools;

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

		var staticObjects:Array<StaticObjectConfig> = [];/*[for (o in cast(rawWorldConfig.staticObjects, Array<Dynamic>)) {
			id: o.id,
			name: o.name,
			x: o.x,
			y: o.y,
			z: o.z,
			zOffset: o.zOffset,
			scale: o.scale,
			rotation: new Quat(o.rotation.x, o.rotation.y, o.rotation.z, o.rotation.w),
			isPathBlocker: o.isPathBlocker
		}];*/

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

		// TODO remove it
		rawWorldConfig.triggers = [
			{
				id: "initial",
				isEnabled: true,
				event: TriggerEvent.OnInit,
				condition: null,
				actions: [
					TriggerAction.SetLocalVariable("unit", UnitDefinition.GetUnit(UnitOfPlayer(PlayerId.Player1, Filter.Index(0)))),
					TriggerAction.JumpCameraToUnit(PlayerId.Player1, UnitDefinition.GetLocalVariable("unit")),
					TriggerAction.SelectUnit(PlayerId.Player1, UnitDefinition.GetLocalVariable("unit")),
				]
			},
			{
				id: "teamA-enemies-1",
				isEnabled: true,
				event: TriggerEvent.TimePeriodic(10),
				condition: null,
				actions: [
					TriggerAction.CreateUnit("minion", PlayerId.Player2, "Region 0"),
					TriggerAction.AttackMoveToRegion(UnitDefinition.LastCreatedUnit, "Region 3")
				]
			},
			{
				id: "teamA-enemies-2",
				isEnabled: true,
				event: TriggerEvent.TimePeriodic(35),
				condition: null,
				actions: [
					TriggerAction.CreateUnit("bandwagon", PlayerId.Player2, "Region 0"),
					TriggerAction.AttackMoveToRegion(UnitDefinition.LastCreatedUnit, "Region 3")
				]
			},
			{
				id: "teamB-enemies",
				isEnabled: true,
				event: TriggerEvent.TimePeriodic(10),
				condition: null,
				actions: [
					TriggerAction.CreateUnit("knome", PlayerId.Player3, "Region 2"),
					TriggerAction.AttackMoveToRegion(UnitDefinition.LastCreatedUnit, "Region 3")
				]
			},
			{
				id: "teamB-enemies-2",
				isEnabled: true,
				event: TriggerEvent.TimePeriodic(35),
				condition: null,
				actions: [
					TriggerAction.CreateUnit("rockgolem", PlayerId.Player2, "Region 2"),
					TriggerAction.AttackMoveToRegion(UnitDefinition.LastCreatedUnit, "Region 3")
				]
			}
		];

		var triggers:Array<Trigger> = [for (t in cast(rawWorldConfig.triggers, Array<Dynamic>)) {
			id: t.id != null ? t.id.toLowerCase() : Std.string(Math.random() * 999999999),
			isEnabled: t.isEnabled != null ? t.isEnabled : true,
			event: switch (t.event) {
				case EnterRegion(region): EnterRegion(getRegion(regions, region.id));
				case _: t.event;
			},
			condition: t.condition == null ? null : switch (t.condition) {
				case _: t.condition;
			},
			actions: t.actions
		}];

		var editorLastCamPosition = rawWorldConfig.editorLastCamPosition == null ? null : new Vector(
			rawWorldConfig.editorLastCamPosition.x,
			rawWorldConfig.editorLastCamPosition.y,
			rawWorldConfig.editorLastCamPosition.z
		);

		var neededModelGroups:Array<String> = [];
		for (u in units)
		{
			var unitConfig = UnitData.getUnitConfig(u.id);
			if (neededModelGroups.indexOf(unitConfig.modelGroup) == -1) neededModelGroups.push(unitConfig.modelGroup);
		}
		for (trigger in triggers)
		{
			for (a in trigger.actions)
			{
				switch (a)
				{
					case TriggerAction.CreateUnit(unitId, _, _):
						var unitConfig = UnitData.getUnitConfig(unitId);
						if (neededModelGroups.indexOf(unitConfig.modelGroup) == -1)
							neededModelGroups.push(unitConfig.modelGroup);

					case _:
				};
			}
		}

		var terrainLayers:Array<TerrainLayerInfo> = rawWorldConfig.terrainLayers;
		var neededTextures:Array<String> = [];
		for (layer in terrainLayers)
		{
			var textureInfo = TerrainAssets.getTerrain(layer.textureId);
			neededTextures.push(textureInfo.textureUrl);
			if (textureInfo.normalMapUrl != null) neededTextures.push(textureInfo.normalMapUrl);
		}

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
				terrainLayers: terrainLayers,
				heightMap: rawWorldConfig.heightMap,
				levellingHeightMap: rawWorldConfig.levellingHeightMap,
				editorLastCamPosition: editorLastCamPosition
			},
			neededModelGroups: neededModelGroups,
			neededTextures: neededTextures
		};
	}

	static function getRegion(regions:Array<Region>, id:String) return regions.filter(function (r) { return r.id == id; })[0];
}