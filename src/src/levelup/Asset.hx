package levelup;

import hxd.Res;
import hxd.res.Model;
import levelup.game.GameState.RaceId;

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

		var foundUnitElements = units.filter(function (e) { return e.id == id; });
		if (foundUnitElements != null && foundUnitElements.length > 0) return foundUnitElements[0];

		return null;
	}

	static public var environment(default, null):Array<AssetConfig>;
	static public var props(default, null):Array<AssetConfig>;
	static public var units(default, null):Array<AssetConfig>;

	static public function init()
	{
		environment = [
			{
				id: "SM_Altar",
				name: "SM_Altar",
				scale: 0.05,
				model: Res.model.environment.SM_Altar,
				previewUrl: "./asset/img/preview/environment/sm_altar.jpg"
			},
			{
				id: "SM_Banner",
				name: "SM_Banner",
				scale: 0.05,
				zOffset: 4,
				model: Res.model.environment.SM_Banner,
				previewUrl: "./asset/img/preview/environment/sm_banner.jpg"
			},
			{
				id: "SM_Banner_Large",
				name: "SM_Banner_Large",
				scale: 0.05,
				zOffset: 5,
				model: Res.model.environment.SM_Banner_Large,
				previewUrl: "./asset/img/preview/environment/sm_banner_large.jpg"
			},
			{
				id: "SM_Banner_Wide",
				name: "SM_Banner_Wide",
				scale: 0.05,
				zOffset: 5,
				model: Res.model.environment.SM_Banner_Wide,
				previewUrl: "./asset/img/preview/environment/sm_banner_wide.jpg"
			},
			{
				id: "SM_Cobweb",
				name: "SM_Cobweb",
				scale: 0.05,
				model: Res.model.environment.SM_Cobweb,
				previewUrl: "./asset/img/preview/environment/sm_cobweb.jpg"
			},
			{
				id: "SM_Door",
				name: "SM_Door",
				scale: 0.05,
				model: Res.model.environment.SM_Door,
				previewUrl: "./asset/img/preview/environment/sm_door.jpg"
			},
			{ id: "SM_Fence", name: "SM_Fence", scale: 0.05, model: Res.model.environment.SM_Fence },
			{ id: "SM_Fence_Pillar", name: "SM_Fence_Pillar", scale: 0.05, model: Res.model.environment.SM_Fence_Pillar },
			{ id: "SM_Floor_Grate", name: "SM_Floor_Grate", scale: 0.05, model: Res.model.environment.SM_Floor_Grate },
			{ id: "SM_Forge_Furnace", name: "SM_Forge_Furnace", scale: 0.05, model: Res.model.environment.SM_Forge_Furnace },
			{ id: "SM_Ground_Large", name: "SM_Ground_Large", scale: 0.05, model: Res.model.environment.SM_Ground_Large },
			{ id: "SM_Ground_Small", name: "SM_Ground_Small", scale: 0.05, model: Res.model.environment.SM_Ground_Small },
			{ id: "SM_Ground_Tiles", name: "SM_Ground_Tiles", scale: 0.05, model: Res.model.environment.SM_Ground_Tiles },
			{ id: "SM_Ground_Tiles_Damaged", name: "SM_Ground_Tiles_Damaged", scale: 0.05, model: Res.model.environment.SM_Ground_Tiles_Damaged },
			{ id: "SM_Ground_Tiles_Large", name: "SM_Ground_Tiles_Large", scale: 0.05, model: Res.model.environment.SM_Ground_Tiles_Large },
			{ id: "SM_Pillar", name: "SM_Pillar", scale: 0.05, model: Res.model.environment.SM_Pillar },
			{ id: "SM_Pillar_Center", name: "SM_Pillar_Center", scale: 0.05, model: Res.model.environment.SM_Pillar_Center },
			{ id: "SM_Pillar_Center_Round", name: "SM_Pillar_Center_Round", scale: 0.05, model: Res.model.environment.SM_Pillar_Center_Round },
			{ id: "SM_Pillar_Center_Ruined", name: "SM_Pillar_Center_Ruined", scale: 0.05, model: Res.model.environment.SM_Pillar_Center_Ruined },
			{ id: "SM_Pillar_Corner", name: "SM_Pillar_Corner", scale: 0.05, model: Res.model.environment.SM_Pillar_Corner },
			{ id: "SM_Prison_Corner", name: "SM_Prison_Corner", scale: 0.05, model: Res.model.environment.SM_Prison_Corner },
			{ id: "SM_Prison_Door", name: "SM_Prison_Door", scale: 0.05, model: Res.model.environment.SM_Prison_Door },
			{ id: "SM_Prison_Half_Wall", name: "SM_Prison_Half_Wall", scale: 0.05, model: Res.model.environment.SM_Prison_Half_Wall },
			{ id: "SM_Prison_Wall", name: "SM_Prison_Wall", scale: 0.05, model: Res.model.environment.SM_Prison_Wall },
			{ id: "SM_Prison_Wall_Door", name: "SM_Prison_Wall_Door", scale: 0.05, model: Res.model.environment.SM_Prison_Wall_Door },
			{ id: "SM_Rug_1_Way", name: "SM_Rug_1_Way", scale: 0.05, model: Res.model.environment.SM_Rug_1_Way },
			{ id: "SM_Rug_1_Way_Half", name: "SM_Rug_1_Way_Half", scale: 0.05, model: Res.model.environment.SM_Rug_1_Way_Half },
			{ id: "SM_Rug_1_Way_Ruined", name: "SM_Rug_1_Way_Ruined", scale: 0.05, model: Res.model.environment.SM_Rug_1_Way_Ruined },
			{ id: "SM_Rug_2_Way", name: "SM_Rug_2_Way", scale: 0.05, model: Res.model.environment.SM_Rug_2_Way },
			{ id: "SM_Rug_3_Way", name: "SM_Rug_3_Way", scale: 0.05, model: Res.model.environment.SM_Rug_3_Way },
			{ id: "SM_Rug_4_Way", name: "SM_Rug_4_Way", scale: 0.05, model: Res.model.environment.SM_Rug_4_Way },
			{ id: "SM_Rug_End", name: "SM_Rug_End", scale: 0.05, model: Res.model.environment.SM_Rug_End },
			{ id: "SM_Stairs", name: "SM_Stairs", scale: 0.05, model: Res.model.environment.SM_Stairs },
			{ id: "SM_Stone_Statue", name: "SM_Stone_Statue", scale: 0.05, model: Res.model.environment.SM_Stone_Statue },
			{ id: "SM_Throne", name: "SM_Throne", scale: 0.05, model: Res.model.environment.SM_Throne },
			{ id: "SM_Torch_Holder", name: "SM_Torch_Holder", scale: 0.05, model: Res.model.environment.SM_Torch_Holder },
			{ id: "SM_Torch_Holder_Off", name: "SM_Torch_Holder_Off", scale: 0.05, model: Res.model.environment.SM_Torch_Holder_Off },
			{ id: "SM_Wall", name: "SM_Wall", scale: 0.05, model: Res.model.environment.SM_Wall },
			{ id: "SM_Wall_Angle", name: "SM_Wall_Angle", scale: 0.05, model: Res.model.environment.SM_Wall_Angle },
			{ id: "SM_Wall_Door", name: "SM_Wall_Door", scale: 0.05, model: Res.model.environment.SM_Wall_Door },
			{ id: "SM_Wall_Prison_Window", name: "SM_Wall_Prison_Window", scale: 0.05, model: Res.model.environment.SM_Wall_Prison_Window },
			{ id: "SM_Wall_Stairs_Fence", name: "SM_Wall_Stairs_Fence", scale: 0.05, model: Res.model.environment.SM_Wall_Stairs_Fence },
			{ id: "SM_Wall_Window", name: "SM_Wall_Window", scale: 0.05, model: Res.model.environment.SM_Wall_Window }
		];

		props = [
			{ id: "SM_Armor_Stand", name: "SM_Armor_Stand", scale: 0.05, model: Res.model.props.SM_Armor_Stand },
			{ id: "SM_Book_Pile_Large", name: "SM_Book_Pile_Large", scale: 0.05, model: Res.model.props.SM_Book_Pile_Large },
			{ id: "SM_Bookshelf_1", name: "SM_Bookshelf_1", scale: 0.05, model: Res.model.props.SM_Bookshelf_1 },
			{ id: "SM_Chandelier", name: "SM_Chandelier", scale: 0.05, model: Res.model.props.SM_Chandelier },
			{ id: "SM_Swords_And_Shield", name: "SM_Swords_And_Shield", scale: 0.05, model: Res.model.props.SM_Swords_And_Shield },
			{ id: "SM_Wooden_Barrel", name: "SM_Wooden_Barrel", scale: 0.05, model: Res.model.props.SM_Wooden_Barrel },
			{ id: "SM_Wooden_Shelf", name: "SM_Wooden_Shelf", scale: 0.05, model: Res.model.props.SM_Wooden_Shelf },
			{ id: "SM_Wooden_Table", name: "SM_Wooden_Table", scale: 0.05, model: Res.model.props.SM_Wooden_Table }
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
			}
			,
			{
				race: RaceId.Human,
				id: "footman",
				name: "Footman",
				scale: 0.008,
				model: Res.model.character.human.footman.IdleAnim,
				hasAnimation: true,
				previewUrl: "./asset/img/preview/unit/human/footman.jpg"
			}
		];
	}
}

typedef AssetConfig = {
	var id(default, never):String;
	var name(default, never):String;
	var model(default, never):Model;
	var scale(default, never):Float;
	@:optional var race(default, never):RaceId;
	@:optional var zOffset(default, never):Float;
	@:optional var hasAnimation(default, never):Bool;
	@:optional var previewUrl(default, never):String;
}