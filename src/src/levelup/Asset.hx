package levelup;

import hxd.Res;
import hxd.res.Model;

class Asset
{
	static public function getStaticObject(name)
	{
		var foundEnvElements = environment.filter(function (e) { return e.name == name; });
		if (foundEnvElements != null && foundEnvElements.length > 0) return foundEnvElements[0];

		var foundPropElements = props.filter(function (e) { return e.name == name; });
		if (foundPropElements != null && foundPropElements.length > 0) return foundPropElements[0];

		return null;
	}

	static public var environment(default, null):Array<AssetItem>;
	static public var props(default, null):Array<AssetItem>;
	static public var units(default, null):Array<AssetItem>;

	static public function init()
	{
		environment = [
			{
				name: "SM_Altar",
				scale: 0.05,
				model: Res.model.environment.SM_Altar,
				previewUrl: "/asset/img/preview/environment/sm_altar.jpg"
			},
			{
				name: "SM_Banner",
				scale: 0.05,
				zOffset: 4,
				model: Res.model.environment.SM_Banner,
				previewUrl: "/asset/img/preview/environment/sm_banner.jpg"
			},
			{
				name: "SM_Banner_Large",
				scale: 0.05,
				zOffset: 5,
				model: Res.model.environment.SM_Banner_Large,
				previewUrl: "/asset/img/preview/environment/sm_banner_large.jpg"
			},
			{
				name: "SM_Banner_Wide",
				scale: 0.05,
				zOffset: 5,
				model: Res.model.environment.SM_Banner_Wide,
				previewUrl: "/asset/img/preview/environment/sm_banner_wide.jpg"
			},
			{
				name: "SM_Cobweb",
				scale: 0.05,
				model: Res.model.environment.SM_Cobweb,
				previewUrl: "/asset/img/preview/environment/sm_cobweb.jpg"
			},
			{
				name: "SM_Door",
				scale: 0.05,
				model: Res.model.environment.SM_Door,
				previewUrl: "/asset/img/preview/environment/sm_door.jpg"
			},
			{ name: "SM_Fence", scale: 0.05, model: Res.model.environment.SM_Fence },
			{ name: "SM_Fence_Pillar", scale: 0.05, model: Res.model.environment.SM_Fence_Pillar },
			{ name: "SM_Floor_Grate", scale: 0.05, model: Res.model.environment.SM_Floor_Grate },
			{ name: "SM_Forge_Furnace", scale: 0.05, model: Res.model.environment.SM_Forge_Furnace },
			{ name: "SM_Ground_Large", scale: 0.05, model: Res.model.environment.SM_Ground_Large },
			{ name: "SM_Ground_Small", scale: 0.05, model: Res.model.environment.SM_Ground_Small },
			{ name: "SM_Ground_Tiles", scale: 0.05, model: Res.model.environment.SM_Ground_Tiles },
			{ name: "SM_Ground_Tiles_Damaged", scale: 0.05, model: Res.model.environment.SM_Ground_Tiles_Damaged },
			{ name: "SM_Ground_Tiles_Large", scale: 0.05, model: Res.model.environment.SM_Ground_Tiles_Large },
			{ name: "SM_Pillar", scale: 0.05, model: Res.model.environment.SM_Pillar },
			{ name: "SM_Pillar_Center", scale: 0.05, model: Res.model.environment.SM_Pillar_Center },
			{ name: "SM_Pillar_Center_Round", scale: 0.05, model: Res.model.environment.SM_Pillar_Center_Round },
			{ name: "SM_Pillar_Center_Ruined", scale: 0.05, model: Res.model.environment.SM_Pillar_Center_Ruined },
			{ name: "SM_Pillar_Corner", scale: 0.05, model: Res.model.environment.SM_Pillar_Corner },
			{ name: "SM_Prison_Corner", scale: 0.05, model: Res.model.environment.SM_Prison_Corner },
			{ name: "SM_Prison_Door", scale: 0.05, model: Res.model.environment.SM_Prison_Door },
			{ name: "SM_Prison_Half_Wall", scale: 0.05, model: Res.model.environment.SM_Prison_Half_Wall },
			{ name: "SM_Prison_Wall", scale: 0.05, model: Res.model.environment.SM_Prison_Wall },
			{ name: "SM_Prison_Wall_Door", scale: 0.05, model: Res.model.environment.SM_Prison_Wall_Door },
			{ name: "SM_Rug_1_Way", scale: 0.05, model: Res.model.environment.SM_Rug_1_Way },
			{ name: "SM_Rug_1_Way_Half", scale: 0.05, model: Res.model.environment.SM_Rug_1_Way_Half },
			{ name: "SM_Rug_1_Way_Ruined", scale: 0.05, model: Res.model.environment.SM_Rug_1_Way_Ruined },
			{ name: "SM_Rug_2_Way", scale: 0.05, model: Res.model.environment.SM_Rug_2_Way },
			{ name: "SM_Rug_3_Way", scale: 0.05, model: Res.model.environment.SM_Rug_3_Way },
			{ name: "SM_Rug_4_Way", scale: 0.05, model: Res.model.environment.SM_Rug_4_Way },
			{ name: "SM_Rug_End", scale: 0.05, model: Res.model.environment.SM_Rug_End },
			{ name: "SM_Stairs", scale: 0.05, model: Res.model.environment.SM_Stairs },
			{ name: "SM_Stone_Statue", scale: 0.05, model: Res.model.environment.SM_Stone_Statue },
			{ name: "SM_Throne", scale: 0.05, model: Res.model.environment.SM_Throne },
			{ name: "SM_Torch_Holder", scale: 0.05, model: Res.model.environment.SM_Torch_Holder },
			{ name: "SM_Torch_Holder_Off", scale: 0.05, model: Res.model.environment.SM_Torch_Holder_Off },
			{ name: "SM_Wall", scale: 0.05, model: Res.model.environment.SM_Wall },
			{ name: "SM_Wall_Angle", scale: 0.05, model: Res.model.environment.SM_Wall_Angle },
			{ name: "SM_Wall_Door", scale: 0.05, model: Res.model.environment.SM_Wall_Door },
			{ name: "SM_Wall_Prison_Window", scale: 0.05, model: Res.model.environment.SM_Wall_Prison_Window },
			{ name: "SM_Wall_Stairs_Fence", scale: 0.05, model: Res.model.environment.SM_Wall_Stairs_Fence },
			{ name: "SM_Wall_Window", scale: 0.05, model: Res.model.environment.SM_Wall_Window }
		];

		props = [
			{ name: "SM_Armor_Stand", scale: 0.05, model: Res.model.props.SM_Armor_Stand },
			{ name: "SM_Book_Pile_Large", scale: 0.05, model: Res.model.props.SM_Book_Pile_Large },
			{ name: "SM_Bookshelf_1", scale: 0.05, model: Res.model.props.SM_Bookshelf_1 },
			{ name: "SM_Chandelier", scale: 0.05, model: Res.model.props.SM_Chandelier },
			{ name: "SM_Swords_And_Shield", scale: 0.05, model: Res.model.props.SM_Swords_And_Shield },
			{ name: "SM_Wooden_Barrel", scale: 0.05, model: Res.model.props.SM_Wooden_Barrel },
			{ name: "SM_Wooden_Shelf", scale: 0.05, model: Res.model.props.SM_Wooden_Shelf },
			{ name: "SM_Wooden_Table", scale: 0.05, model: Res.model.props.SM_Wooden_Table }
		];

		units = [
			{
				name: "Bandwagon",
				scale: 0.007,
				model: Res.model.character.orc.bandwagon.IdleAnim,
				hasAnimation: true,
				previewUrl: "/asset/img/preview/unit/orc/bandwagon.jpg"
			},
			{
				name: "Berserker",
				scale: 0.008,
				model: Res.model.character.orc.berserker.IdleAnim,
				hasAnimation: true,
				previewUrl: "/asset/img/preview/unit/orc/berserker.jpg"
			},
			{
				name: "Drake",
				scale: 0.0037,
				zOffset: 2.5,
				model: Res.model.character.orc.drake.IdleAnim,
				hasAnimation: true,
				previewUrl: "/asset/img/preview/unit/orc/drake.jpg"
			},
			{
				name: "Grunt",
				scale: 0.008,
				model: Res.model.character.orc.grunt.IdleAnim,
				hasAnimation: true,
				previewUrl: "/asset/img/preview/unit/orc/grunt.jpg"
			},
			{
				name: "Minion",
				scale: 0.008,
				model: Res.model.character.orc.minion.IdleAnim,
				hasAnimation: true,
				previewUrl: "/asset/img/preview/unit/orc/minion.jpg"
			}
		];
	}
}

typedef AssetItem = {
	var name(default, never):String;
	var model(default, never):Model;
	var scale(default, never):Float;
	@:optional var zOffset(default, never):Float;
	@:optional var hasAnimation(default, never):Bool;
	@:optional var previewUrl(default, never):String;
}