package levelup;

import h3d.mat.BlendMode;
import hxd.Res;
import hxd.res.Model;
import levelup.EnvironmentData;
import levelup.UnitData.RaceId;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Asset
{
	static public function getAsset(id)
	{
		var foundEnvElements = environment.filter(function (e) { return e.id == id; });
		if (foundEnvElements != null && foundEnvElements.length > 0) return foundEnvElements[0];

		var foundPropElements = props.filter(function (e) { return e.id == id; });
		if (foundPropElements != null && foundPropElements.length > 0) return foundPropElements[0];

		var foundBuildingElements = buildings.filter(function (e) { return e.id == id; });
		if (foundBuildingElements != null && foundBuildingElements.length > 0) return foundBuildingElements[0];

		var foundUnitElements = units.filter(function (e) { return e.id == id; });
		if (foundUnitElements != null && foundUnitElements.length > 0) return foundUnitElements[0];

		return null;
	}

	static public var environment(default, null):Array<AssetConfig> = [];
	static public var props(default, null):Array<AssetConfig> = [];
	static public var buildings(default, null):Array<AssetConfig> = [];
	static public var units(default, null):Array<AssetConfig> = [];

	static public function init()
	{
		/*environment = [

			{
				id: "Plant01",
				name: "Plant 01",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant01,
				previewUrl: "./asset/img/preview/environment/plant/plant_01.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant02",
				name: "Plant 02",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant02,
				previewUrl: "./asset/img/preview/environment/plant/plant_02.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant03",
				name: "Plant 03",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant03,
				previewUrl: "./asset/img/preview/environment/plant/plant_03.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant04",
				name: "Plant 04",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant04,
				previewUrl: "./asset/img/preview/environment/plant/plant_04.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant05",
				name: "Plant 05",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant05,
				previewUrl: "./asset/img/preview/environment/plant/plant_05.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant06",
				name: "Plant 06",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant06,
				previewUrl: "./asset/img/preview/environment/plant/plant_06.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant07",
				name: "Plant 07",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant07,
				previewUrl: "./asset/img/preview/environment/plant/plant_07.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant08",
				name: "Plant 08",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant08,
				previewUrl: "./asset/img/preview/environment/plant/plant_08.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant09",
				name: "Plant 09",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant09,
				previewUrl: "./asset/img/preview/environment/plant/plant_09.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant10",
				name: "Plant 10",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant10,
				previewUrl: "./asset/img/preview/environment/plant/plant_10.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant11",
				name: "Plant 11",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant11,
				previewUrl: "./asset/img/preview/environment/plant/plant_11.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant12",
				name: "Plant 12",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant12,
				previewUrl: "./asset/img/preview/environment/plant/plant_12.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant13",
				name: "Plant 13",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant13,
				previewUrl: "./asset/img/preview/environment/plant/plant_13.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant14",
				name: "Plant 14",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant14,
				previewUrl: "./asset/img/preview/environment/plant/plant_14.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant15",
				name: "Plant 15",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant15,
				previewUrl: "./asset/img/preview/environment/plant/plant_15.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant16",
				name: "Plant 16",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant16,
				previewUrl: "./asset/img/preview/environment/plant/plant_16.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant17",
				name: "Plant 17",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant17,
				previewUrl: "./asset/img/preview/environment/plant/plant_17.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant18",
				name: "Plant 18",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant18,
				previewUrl: "./asset/img/preview/environment/plant/plant_18.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant19",
				name: "Plant 19",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant19,
				previewUrl: "./asset/img/preview/environment/plant/plant_19.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant20",
				name: "Plant 20",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant20,
				previewUrl: "./asset/img/preview/environment/plant/plant_20.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant21",
				name: "Plant 21",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant21,
				previewUrl: "./asset/img/preview/environment/plant/plant_21.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant22",
				name: "Plant 22",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant22,
				previewUrl: "./asset/img/preview/environment/plant/plant_22.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant23",
				name: "Plant 23",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant23,
				previewUrl: "./asset/img/preview/environment/plant/plant_23.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant24",
				name: "Plant 24",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant24,
				previewUrl: "./asset/img/preview/environment/plant/plant_24.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant25",
				name: "Plant 25",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant25,
				previewUrl: "./asset/img/preview/environment/plant/plant_25.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant26",
				name: "Plant 26",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant26,
				previewUrl: "./asset/img/preview/environment/plant/plant_26.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant27",
				name: "Plant 27",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant27,
				previewUrl: "./asset/img/preview/environment/plant/plant_27.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant28",
				name: "Plant 28",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant28,
				previewUrl: "./asset/img/preview/environment/plant/plant_28.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant29",
				name: "Plant 29",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant29,
				previewUrl: "./asset/img/preview/environment/plant/plant_29.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant30",
				name: "Plant 30",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant30,
				previewUrl: "./asset/img/preview/environment/plant/plant_30.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant31",
				name: "Plant 31",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant31,
				previewUrl: "./asset/img/preview/environment/plant/plant_31.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant32",
				name: "Plant 32",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant32,
				previewUrl: "./asset/img/preview/environment/plant/plant_32.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant33",
				name: "Plant 33",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant33,
				previewUrl: "./asset/img/preview/environment/plant/plant_33.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant34",
				name: "Plant 34",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant34,
				previewUrl: "./asset/img/preview/environment/plant/plant_34.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant35",
				name: "Plant 35",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant35,
				previewUrl: "./asset/img/preview/environment/plant/plant_35.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant36",
				name: "Plant 36",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant36,
				previewUrl: "./asset/img/preview/environment/plant/plant_36.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant37",
				name: "Plant 37",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant37,
				previewUrl: "./asset/img/preview/environment/plant/plant_37.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant38",
				name: "Plant 38",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant38,
				previewUrl: "./asset/img/preview/environment/plant/plant_38.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant39",
				name: "Plant 39",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant39,
				previewUrl: "./asset/img/preview/environment/plant/plant_39.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant40",
				name: "Plant 40",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant40,
				previewUrl: "./asset/img/preview/environment/plant/plant_40.jpg",
				isPathBlocker: false
			},
			{
				id: "Plant41",
				name: "Plant 41",
				scale: 0.008,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Plant,
				model: Res.model.environment.plant.Plant41,
				previewUrl: "./asset/img/preview/environment/plant/plant_41.jpg",
				isPathBlocker: false
			},

			{
				id: "Tree01",
				name: "Tree 01",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree01,
				previewUrl: "./asset/img/preview/environment/tree/tree_01.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree02",
				name: "Tree 02",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree02,
				previewUrl: "./asset/img/preview/environment/tree/tree_02.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree03",
				name: "Tree 03",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree03,
				previewUrl: "./asset/img/preview/environment/tree/tree_03.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree04",
				name: "Tree 04",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree04,
				previewUrl: "./asset/img/preview/environment/tree/tree_04.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree05",
				name: "Tree 05",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree05,
				previewUrl: "./asset/img/preview/environment/tree/tree_05.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree07",
				name: "Tree 07",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree07,
				previewUrl: "./asset/img/preview/environment/tree/tree_07.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree08",
				name: "Tree 08",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree08,
				previewUrl: "./asset/img/preview/environment/tree/tree_08.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree09",
				name: "Tree 09",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree09,
				previewUrl: "./asset/img/preview/environment/tree/tree_09.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree10",
				name: "Tree 10",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree10,
				previewUrl: "./asset/img/preview/environment/tree/tree_10.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree11",
				name: "Tree 11",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree11,
				previewUrl: "./asset/img/preview/environment/tree/tree_11.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree12",
				name: "Tree 12",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree12,
				previewUrl: "./asset/img/preview/environment/tree/tree_12.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree13",
				name: "Tree 13",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree13,
				previewUrl: "./asset/img/preview/environment/tree/tree_13.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree14",
				name: "Tree 14",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree14,
				previewUrl: "./asset/img/preview/environment/tree/tree_14.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree15",
				name: "Tree 15",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree15,
				previewUrl: "./asset/img/preview/environment/tree/tree_15.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree16",
				name: "Tree 16",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree16,
				previewUrl: "./asset/img/preview/environment/tree/tree_16.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree17",
				name: "Tree 17",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree17,
				previewUrl: "./asset/img/preview/environment/tree/tree_17.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree18",
				name: "Tree 18",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree18,
				previewUrl: "./asset/img/preview/environment/tree/tree_18.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree19",
				name: "Tree 19",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree19,
				previewUrl: "./asset/img/preview/environment/tree/tree_19.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree20",
				name: "Tree 20",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree20,
				previewUrl: "./asset/img/preview/environment/tree/tree_20.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree21",
				name: "Tree 21",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree21,
				previewUrl: "./asset/img/preview/environment/tree/tree_21.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree22",
				name: "Tree 22",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree22,
				previewUrl: "./asset/img/preview/environment/tree/tree_22.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree23",
				name: "Tree 23",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree23,
				previewUrl: "./asset/img/preview/environment/tree/tree_23.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree24",
				name: "Tree 24",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree24,
				previewUrl: "./asset/img/preview/environment/tree/tree_24.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree25",
				name: "Tree 25",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree25,
				previewUrl: "./asset/img/preview/environment/tree/tree_25.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree26",
				name: "Tree 26",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree26,
				previewUrl: "./asset/img/preview/environment/tree/tree_26.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree27",
				name: "Tree 27",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree27,
				previewUrl: "./asset/img/preview/environment/tree/tree_27.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree28",
				name: "Tree 28",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree28,
				previewUrl: "./asset/img/preview/environment/tree/tree_28.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree29",
				name: "Tree 29",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree29,
				previewUrl: "./asset/img/preview/environment/tree/tree_29.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree30",
				name: "Tree 30",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree30,
				previewUrl: "./asset/img/preview/environment/tree/tree_30.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree31",
				name: "Tree 31",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree31,
				previewUrl: "./asset/img/preview/environment/tree/tree_31.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree32",
				name: "Tree 32",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree32,
				previewUrl: "./asset/img/preview/environment/tree/tree_32.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree33",
				name: "Tree 33",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree33,
				previewUrl: "./asset/img/preview/environment/tree/tree_33.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree34",
				name: "Tree 34",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree34,
				previewUrl: "./asset/img/preview/environment/tree/tree_34.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree35",
				name: "Tree 35",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree35,
				previewUrl: "./asset/img/preview/environment/tree/tree_35.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree36",
				name: "Tree 36",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree36,
				previewUrl: "./asset/img/preview/environment/tree/tree_36.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree37",
				name: "Tree 37",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree37,
				previewUrl: "./asset/img/preview/environment/tree/tree_37.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree38",
				name: "Tree 38",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree38,
				previewUrl: "./asset/img/preview/environment/tree/tree_38.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree39",
				name: "Tree 39",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree39,
				previewUrl: "./asset/img/preview/environment/tree/tree_39.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree40",
				name: "Tree 40",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree40,
				previewUrl: "./asset/img/preview/environment/tree/tree_40.jpg",
				isPathBlocker: true
			},
			{
				id: "Tree41",
				name: "Tree 41",
				scale: 0.005,
				hasTransparentTexture: true,
				environmentId: EnvironmentId.Tree,
				model: Res.model.environment.tree.Tree41,
				previewUrl: "./asset/img/preview/environment/tree/tree_41.jpg",
				isPathBlocker: true
			},
			{
				id: "Trunk01",
				name: "Trunk 01",
				scale: 0.005,
				environmentId: EnvironmentId.Trunk,
				model: Res.model.environment.trunk.Trunk01,
				previewUrl: "./asset/img/preview/environment/tree/tree_08.jpg",
				isPathBlocker: true
			},
			{
				id: "SM_Altar",
				name: "SM_Altar",
				scale: 0.05,
				model: Res.model.environment.SM_Altar,
				previewUrl: "./asset/img/preview/environment/sm_altar.jpg",
				isPathBlocker: true
			},
			{
				id: "SM_Banner",
				name: "SM_Banner",
				scale: 0.05,
				zOffset: 4,
				model: Res.model.environment.SM_Banner,
				previewUrl: "./asset/img/preview/environment/sm_banner.jpg",
				isPathBlocker: true
			},
			{
				id: "SM_Banner_Large",
				name: "SM_Banner_Large",
				scale: 0.05,
				zOffset: 5,
				model: Res.model.environment.SM_Banner_Large,
				previewUrl: "./asset/img/preview/environment/sm_banner_large.jpg",
				isPathBlocker: true
			},
			{
				id: "SM_Banner_Wide",
				name: "SM_Banner_Wide",
				scale: 0.05,
				zOffset: 5,
				model: Res.model.environment.SM_Banner_Wide,
				previewUrl: "./asset/img/preview/environment/sm_banner_wide.jpg",
				isPathBlocker: true
			},
			{
				id: "SM_Cobweb",
				name: "SM_Cobweb",
				scale: 0.05,
				model: Res.model.environment.SM_Cobweb,
				previewUrl: "./asset/img/preview/environment/sm_cobweb.jpg",
				isPathBlocker: true
			},
			{
				id: "SM_Door",
				name: "SM_Door",
				scale: 0.05,
				model: Res.model.environment.SM_Door,
				previewUrl: "./asset/img/preview/environment/sm_door.jpg",
				isPathBlocker: true
			},
			{ id: "SM_Fence", name: "SM_Fence", scale: 0.05, model: Res.model.environment.SM_Fence, isPathBlocker: true },
			{ id: "SM_Fence_Pillar", name: "SM_Fence_Pillar", scale: 0.05, model: Res.model.environment.SM_Fence_Pillar, isPathBlocker: true },
			{ id: "SM_Floor_Grate", name: "SM_Floor_Grate", scale: 0.05, model: Res.model.environment.SM_Floor_Grate, isPathBlocker: true },
			{ id: "SM_Forge_Furnace", name: "SM_Forge_Furnace", scale: 0.05, model: Res.model.environment.SM_Forge_Furnace, isPathBlocker: true },
			{ id: "SM_Ground_Large", name: "SM_Ground_Large", scale: 0.05, model: Res.model.environment.SM_Ground_Large, isPathBlocker: true },
			{ id: "SM_Ground_Small", name: "SM_Ground_Small", scale: 0.05, model: Res.model.environment.SM_Ground_Small, isPathBlocker: true },
			{ id: "SM_Ground_Tiles", name: "SM_Ground_Tiles", scale: 0.05, model: Res.model.environment.SM_Ground_Tiles, isPathBlocker: true },
			{ id: "SM_Ground_Tiles_Damaged", name: "SM_Ground_Tiles_Damaged", scale: 0.05, model: Res.model.environment.SM_Ground_Tiles_Damaged, isPathBlocker: true },
			{ id: "SM_Ground_Tiles_Large", name: "SM_Ground_Tiles_Large", scale: 0.05, model: Res.model.environment.SM_Ground_Tiles_Large, isPathBlocker: true },
			{ id: "SM_Pillar", name: "SM_Pillar", scale: 0.05, model: Res.model.environment.SM_Pillar, isPathBlocker: true },
			{ id: "SM_Pillar_Center", name: "SM_Pillar_Center", scale: 0.05, model: Res.model.environment.SM_Pillar_Center, isPathBlocker: true },
			{ id: "SM_Pillar_Center_Round", name: "SM_Pillar_Center_Round", scale: 0.05, model: Res.model.environment.SM_Pillar_Center_Round, isPathBlocker: true },
			{ id: "SM_Pillar_Center_Ruined", name: "SM_Pillar_Center_Ruined", scale: 0.05, model: Res.model.environment.SM_Pillar_Center_Ruined, isPathBlocker: true },
			{ id: "SM_Pillar_Corner", name: "SM_Pillar_Corner", scale: 0.05, model: Res.model.environment.SM_Pillar_Corner, isPathBlocker: true },
			{ id: "SM_Prison_Corner", name: "SM_Prison_Corner", scale: 0.05, model: Res.model.environment.SM_Prison_Corner, isPathBlocker: true },
			{ id: "SM_Prison_Door", name: "SM_Prison_Door", scale: 0.05, model: Res.model.environment.SM_Prison_Door, isPathBlocker: true },
			{ id: "SM_Prison_Half_Wall", name: "SM_Prison_Half_Wall", scale: 0.05, model: Res.model.environment.SM_Prison_Half_Wall, isPathBlocker: true },
			{ id: "SM_Prison_Wall", name: "SM_Prison_Wall", scale: 0.05, model: Res.model.environment.SM_Prison_Wall, isPathBlocker: true },
			{ id: "SM_Prison_Wall_Door", name: "SM_Prison_Wall_Door", scale: 0.05, model: Res.model.environment.SM_Prison_Wall_Door, isPathBlocker: true },
			{ id: "SM_Rug_1_Way", name: "SM_Rug_1_Way", scale: 0.05, model: Res.model.environment.SM_Rug_1_Way, isPathBlocker: true },
			{ id: "SM_Rug_1_Way_Half", name: "SM_Rug_1_Way_Half", scale: 0.05, model: Res.model.environment.SM_Rug_1_Way_Half, isPathBlocker: true },
			{ id: "SM_Rug_1_Way_Ruined", name: "SM_Rug_1_Way_Ruined", scale: 0.05, model: Res.model.environment.SM_Rug_1_Way_Ruined, isPathBlocker: true },
			{ id: "SM_Rug_2_Way", name: "SM_Rug_2_Way", scale: 0.05, model: Res.model.environment.SM_Rug_2_Way, isPathBlocker: true },
			{ id: "SM_Rug_3_Way", name: "SM_Rug_3_Way", scale: 0.05, model: Res.model.environment.SM_Rug_3_Way, isPathBlocker: true },
			{ id: "SM_Rug_4_Way", name: "SM_Rug_4_Way", scale: 0.05, model: Res.model.environment.SM_Rug_4_Way, isPathBlocker: true },
			{ id: "SM_Rug_End", name: "SM_Rug_End", scale: 0.05, model: Res.model.environment.SM_Rug_End, isPathBlocker: true },
			{ id: "SM_Stairs", name: "SM_Stairs", scale: 0.05, model: Res.model.environment.SM_Stairs, isPathBlocker: true },
			{ id: "SM_Stone_Statue", name: "SM_Stone_Statue", scale: 0.05, model: Res.model.environment.SM_Stone_Statue, isPathBlocker: true },
			{ id: "SM_Throne", name: "SM_Throne", scale: 0.05, model: Res.model.environment.SM_Throne, isPathBlocker: true },
			{ id: "SM_Torch_Holder", name: "SM_Torch_Holder", scale: 0.05, model: Res.model.environment.SM_Torch_Holder, isPathBlocker: true },
			{ id: "SM_Torch_Holder_Off", name: "SM_Torch_Holder_Off", scale: 0.05, model: Res.model.environment.SM_Torch_Holder_Off, isPathBlocker: true },
			{ id: "SM_Wall", name: "SM_Wall", scale: 0.05, model: Res.model.environment.SM_Wall, isPathBlocker: true },
			{ id: "SM_Wall_Angle", name: "SM_Wall_Angle", scale: 0.05, model: Res.model.environment.SM_Wall_Angle, isPathBlocker: true },
			{ id: "SM_Wall_Door", name: "SM_Wall_Door", scale: 0.05, model: Res.model.environment.SM_Wall_Door, isPathBlocker: true },
			{ id: "SM_Wall_Prison_Window", name: "SM_Wall_Prison_Window", scale: 0.05, model: Res.model.environment.SM_Wall_Prison_Window, isPathBlocker: true },
			{ id: "SM_Wall_Stairs_Fence", name: "SM_Wall_Stairs_Fence", scale: 0.05, model: Res.model.environment.SM_Wall_Stairs_Fence, isPathBlocker: true },
			{ id: "SM_Wall_Window", name: "SM_Wall_Window", scale: 0.05, model: Res.model.environment.SM_Wall_Window, isPathBlocker: true }
		];

		props = [
			{ id: "SM_Armor_Stand", name: "SM_Armor_Stand", scale: 0.05, model: Res.model.props.SM_Armor_Stand, isPathBlocker: true },
			{ id: "SM_Book_Pile_Large", name: "SM_Book_Pile_Large", scale: 0.05, model: Res.model.props.SM_Book_Pile_Large, isPathBlocker: true },
			{ id: "SM_Bookshelf_1", name: "SM_Bookshelf_1", scale: 0.05, model: Res.model.props.SM_Bookshelf_1, isPathBlocker: true },
			{ id: "SM_Chandelier", name: "SM_Chandelier", scale: 0.05, model: Res.model.props.SM_Chandelier, isPathBlocker: true },
			{ id: "SM_Swords_And_Shield", name: "SM_Swords_And_Shield", scale: 0.05, model: Res.model.props.SM_Swords_And_Shield, isPathBlocker: true },
			{ id: "SM_Wooden_Barrel", name: "SM_Wooden_Barrel", scale: 0.05, model: Res.model.props.SM_Wooden_Barrel, isPathBlocker: true },
			{ id: "SM_Wooden_Shelf", name: "SM_Wooden_Shelf", scale: 0.05, model: Res.model.props.SM_Wooden_Shelf, isPathBlocker: true },
			{ id: "SM_Wooden_Table", name: "SM_Wooden_Table", scale: 0.05, model: Res.model.props.SM_Wooden_Table, isPathBlocker: true }
		];

		buildings = [
			{
				id: "House01",
				name: "House 01",
				scale: 0.005,
				model: Res.model.building.House01,
				previewUrl: "./asset/img/preview/building/House01.jpg",
				isPathBlocker: true
			}
		];

		units = [
			{
				race: RaceId.Orc,
				id: "bandwagon",
				name: "Bandwagon",
				scale: 0.007,
				model: Res.model.character.orc.bandwagon.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/orc/bandwagon.jpg"
			},
			{
				race: RaceId.Orc,
				id: "berserker",
				name: "Berserker",
				scale: 0.008,
				model: Res.model.character.orc.berserker.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/orc/berserker.jpg"
			},
			{
				race: RaceId.Orc,
				id: "drake",
				name: "Drake",
				scale: 0.0037,
				zOffset: 2.5,
				model: Res.model.character.orc.drake.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/orc/drake.jpg"
			},
			{
				race: RaceId.Orc,
				id: "grunt",
				name: "Grunt",
				scale: 0.008,
				model: Res.model.character.orc.grunt.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/orc/grunt.jpg"
			},
			{
				race: RaceId.Orc,
				id: "minion",
				name: "Minion",
				scale: 0.008,
				model: Res.model.character.orc.minion.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/orc/minion.jpg"
			},
			{
				race: RaceId.Human,
				id: "archer",
				name: "Archer",
				scale: 0.008,
				model: Res.model.character.human.archer.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/human/archer.jpg"
			},
			{
				race: RaceId.Human,
				id: "footman",
				name: "Footman",
				scale: 0.008,
				model: Res.model.character.human.footman.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/human/footman.jpg"
			},
			{
				race: RaceId.Elf,
				id: "knome",
				name: "Knome",
				scale: 0.008,
				model: Res.model.character.elf.knome.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/elf/knome.jpg"
			},
			{
				race: RaceId.Elf,
				id: "demonhunter",
				name: "Demon Hunter",
				scale: 0.008,
				model: Res.model.character.elf.demonhunter.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/elf/demonhunter.jpg"
			},
			{
				race: RaceId.Elf,
				id: "druid",
				name: "Druid",
				scale: 0.008,
				model: Res.model.character.elf.druid.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/elf/druid.jpg"
			},
			{
				race: RaceId.Elf,
				id: "dryad",
				name: "Dryad",
				scale: 0.008,
				model: Res.model.character.elf.dryad.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/elf/dryad.jpg"
			},
			{
				race: RaceId.Elf,
				id: "ranger",
				name: "Ranger",
				scale: 0.008,
				model: Res.model.character.elf.ranger.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/elf/ranger.jpg"
			},
			{
				race: RaceId.Elf,
				id: "rockgolem",
				name: "Rock Golem",
				scale: 0.008,
				model: Res.model.character.elf.rockgolem.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/elf/rockgolem.jpg"
			},
			{
				race: RaceId.Elf,
				id: "treeant",
				name: "Treeant",
				scale: 0.008,
				model: Res.model.character.elf.treeant.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/elf/treeant.jpg"
			},
			{
				race: RaceId.Elf,
				id: "battleowl",
				name: "Battle Owl",
				scale: 0.004,
				model: Res.model.character.elf.battleowl.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/elf/battleowl.jpg"
			}
		];*/
	}
}

typedef AssetConfig = {
	@:optional var id(default, never):String;
	@:optional var name(default, never):String;
	@:optional var assetGroup(default, never):String;
	@:optional var modelScale(default, never):Float;
	@:optional var unitName(default, never):String;
	@:optional var environmentId(default, never):EnvironmentId;
	@:optional var race(default, never):RaceId;
	@:optional var zOffset(default, never):Float;
	@:optional var hasAnimation(default, never):Bool;
	@:optional var previewUrl(default, never):String;
	@:optional var hasTransparentTexture(default, never):Bool;
	@:optional var isPathBlocker(default, never):Bool;
}