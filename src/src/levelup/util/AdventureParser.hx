package levelup.util;

import h3d.Quat;
import h3d.Vector;
import haxe.Json;
import levelup.game.GameState.AdventureConfig;
import levelup.game.GameState.InitialUnitData;
import levelup.game.GameState.MathDefinition;
import levelup.game.GameState.PlayerId;
import levelup.game.GameState.PositionDefinition;
import levelup.game.GameState.RegionPositionDefinition;
import levelup.game.GameState.StaticObjectConfig;
import levelup.game.GameState.TerrainLayerInfo;
import levelup.game.GameState.Trigger;
import levelup.game.GameState.GetUnitDefinition;
import levelup.game.GameState.TriggerAction;
import levelup.game.GameState.TriggerCondition;
import levelup.game.GameState.TriggerEvent;
import levelup.game.GameState.UnitDefinition;
import levelup.game.GameState.Filter;
import levelup.game.GameState.VariableDefinition;
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

		var neededModelGroups:Array<String> = [];

		var startingTime = rawWorldConfig.startingTime == null ? 12 : rawWorldConfig.startingTime;
		var sunAndMoonOffsetPercent = rawWorldConfig.sunAndMoonOffsetPercent == null ? 20 : rawWorldConfig.sunAndMoonOffsetPercent;
		var dayColor = rawWorldConfig.dayColor == null ? "#E0E0E0" : rawWorldConfig.dayColor;
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

		for (o in staticObjects)
		{
			var environmentConfig = EnvironmentData.getEnvironmentConfig(o.id);

			if (environmentConfig != null && neededModelGroups.indexOf(environmentConfig.assetGroup) == -1)
				neededModelGroups.push(environmentConfig.assetGroup);
		}

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
				events: [TriggerEvent.OnInit],
				condition: null,
				actions: [
					TriggerAction.JumpCameraToCamera(PlayerId.Player1, VariableDefinition.Value("InitialCamera")),
					TriggerAction.AnimateCameraToCamera(PlayerId.Player1, VariableDefinition.Value("IdleCamera"), VariableDefinition.Value(5), VariableDefinition.Value("linear")),
					TriggerAction.Wait(VariableDefinition.Value(5)),
					TriggerAction.StartCameraShake(VariableDefinition.Value(0.5), VariableDefinition.Value(5))
				]
			}
		];
/*
			{
				id: "initial",
				isEnabled: true,
				events: [TriggerEvent.OnInit],
				condition: null,
				actions: [
					TriggerAction.SetLocalVariable("unit", UnitDefinition.GetUnit(UnitOfPlayer(PlayerId.Player1, Filter.Index(0)))),
					TriggerAction.JumpCameraToUnit(PlayerId.Player1, UnitDefinition.GetLocalVariable("unit")),
					TriggerAction.SelectUnit(PlayerId.Player1, UnitDefinition.GetLocalVariable("unit")),
					TriggerAction.CreateUnit("crystalTower", PlayerId.Player2, PositionDefinition.RegionPosition(RegionPositionDefinition.CenterOf("Region 0"))),
					TriggerAction.CreateUnit("crystalTower", PlayerId.Player3, PositionDefinition.RegionPosition(RegionPositionDefinition.CenterOf("Region 2")))
				]
			},
			{
				id: "teamA-enemies-1",
				isEnabled: true,
				events: [TriggerEvent.TimePeriodic(10)],
				condition: null,
				actions: [
					TriggerAction.CreateUnit("minion", PlayerId.Player2, PositionDefinition.RegionPosition(RegionPositionDefinition.RandomPointOf("Region 0"))),
					TriggerAction.AttackMoveToRegion(UnitDefinition.LastCreatedUnit, PositionDefinition.RegionPosition(RegionPositionDefinition.CenterOf("Region 2")))
				]
			},
			{
				id: "teamA-enemies-2",
				isEnabled: true,
				events: [TriggerEvent.TimePeriodic(35)],
				condition: null,
				actions: [
					TriggerAction.CreateUnit("bandwagon", PlayerId.Player2, PositionDefinition.RegionPosition(RegionPositionDefinition.RandomPointOf("Region 0"))),
					TriggerAction.AttackMoveToRegion(UnitDefinition.LastCreatedUnit, PositionDefinition.RegionPosition(RegionPositionDefinition.CenterOf("Region 2")))
				]
			},
			{
				id: "teamB-enemies",
				isEnabled: true,
				event: [TriggerEvent.TimePeriodic(10)],
				condition: null,
				actions: [
					TriggerAction.CreateUnit("knome", PlayerId.Player3, PositionDefinition.RegionPosition(RegionPositionDefinition.RandomPointOf("Region 2"))),
					TriggerAction.AttackMoveToRegion(UnitDefinition.LastCreatedUnit, PositionDefinition.RegionPosition(RegionPositionDefinition.CenterOf("Region 0")))
				]
			},
			{
				id: "teamB-enemies-2",
				isEnabled: true,
				events: [TriggerEvent.TimePeriodic(35)],
				condition: null,
				actions: [
					TriggerAction.CreateUnit("rockgolem", PlayerId.Player3, PositionDefinition.RegionPosition(RegionPositionDefinition.RandomPointOf("Region 2"))),
					TriggerAction.AttackMoveToRegion(UnitDefinition.LastCreatedUnit, PositionDefinition.RegionPosition(RegionPositionDefinition.CenterOf("Region 0")))
				]
			}
		];*/

		var editorLastCamPosition = rawWorldConfig.editorLastCamPosition == null ? null : new Vector(
			rawWorldConfig.editorLastCamPosition.x,
			rawWorldConfig.editorLastCamPosition.y,
			rawWorldConfig.editorLastCamPosition.z
		);

		for (u in units)
		{
			var unitConfig = UnitData.getUnitConfig(u.id);
			if (neededModelGroups.indexOf(unitConfig.assetGroup) == -1) neededModelGroups.push(unitConfig.assetGroup);
			if (unitConfig.projectileConfig != null)
			{
				var projData = ProjectileAnimationData.getConfig(unitConfig.projectileConfig.projectileAnimationId);
				if (neededModelGroups.indexOf(projData.assetGroup) == -1) neededModelGroups.push(projData.assetGroup);
			}
		}
		for (trigger in cast(rawWorldConfig.triggers, Array<Dynamic>))
		{
			for (a in cast(trigger.actions, Array<Dynamic>))
			{
				switch (a)
				{
					case TriggerAction.CreateUnit(unitId, _, _):
						var unitConfig = UnitData.getUnitConfig(unitId);
						if (neededModelGroups.indexOf(unitConfig.assetGroup) == -1)
							neededModelGroups.push(unitConfig.assetGroup);
						if (unitConfig.projectileConfig != null)
						{
							var projData = ProjectileAnimationData.getConfig(unitConfig.projectileConfig.projectileAnimationId);
							if (neededModelGroups.indexOf(projData.assetGroup) == -1) neededModelGroups.push(projData.assetGroup);
						}

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

		if (rawWorldConfig.skybox == null) rawWorldConfig.skybox = {
			id: "skybox.ls_sunny_01",
			zOffset: 0,
			rotation: 0,
			scale: 0
		};

		var neededImages:Array<String> = [];
		neededImages = neededImages.concat(SkyboxData.getConfig(rawWorldConfig.skybox.id).assets);

		return {
			id: rawData.id,
			title: rawData.title,
			subTitle: rawData.subTitle,
			description: rawData.description,
			preloaderImage: "asset/preloader/moba.jpg",//rawData.preloaderImage,
			editorVersion: rawData.editorVersion,
			size: rawData.size,
			worldConfig: {
				skybox: rawWorldConfig.skybox,
				startingTime: startingTime,
				sunAndMoonOffsetPercent: sunAndMoonOffsetPercent,
				dayColor: dayColor,
				nightColor: nightColor,
				sunsetColor: sunsetColor,
				dawnColor: dawnColor,
				globalWeather: rawWorldConfig.globalWeather == null ? 0 : rawWorldConfig.globalWeather,
				regions: regions,
				cameras: rawWorldConfig.cameras == null ? [] : rawWorldConfig.cameras,
				triggers: rawWorldConfig.triggers,
				units: units,
				staticObjects: staticObjects,
				terrainLayers: terrainLayers,
				heightMap: rawWorldConfig.heightMap,
				editorLastCamPosition: editorLastCamPosition
			},
			neededModelGroups: neededModelGroups,
			neededTextures: neededTextures,
			neededImages: neededImages
		};
	}

	static function getRegion(regions:Array<Region>, id:String) return regions.filter(function (r) { return r.id == id; })[0];
}