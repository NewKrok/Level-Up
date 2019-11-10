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

	static public function init()
	{
		environment = [
			{ name: "SM_Altar", model: Res.model.environment.SM_Altar },
			{ name: "SM_Banner", model: Res.model.environment.SM_Banner },
			{ name: "SM_Banner_Large", model: Res.model.environment.SM_Banner_Large },
			{ name: "SM_Banner_Wide", model: Res.model.environment.SM_Banner_Wide },
			{ name: "SM_Cobweb", model: Res.model.environment.SM_Cobweb },
			{ name: "SM_Door", model: Res.model.environment.SM_Door },
			{ name: "SM_Fence", model: Res.model.environment.SM_Fence },
			{ name: "SM_Fence_Pillar", model: Res.model.environment.SM_Fence_Pillar },
			{ name: "SM_Floor_Grate", model: Res.model.environment.SM_Floor_Grate },
			{ name: "SM_Forge_Furnace", model: Res.model.environment.SM_Forge_Furnace },
			{ name: "SM_Ground_Large", model: Res.model.environment.SM_Ground_Large },
			{ name: "SM_Ground_Small", model: Res.model.environment.SM_Ground_Small },
			{ name: "SM_Ground_Tiles", model: Res.model.environment.SM_Ground_Tiles },
			{ name: "SM_Ground_Tiles_Damaged", model: Res.model.environment.SM_Ground_Tiles_Damaged },
			{ name: "SM_Ground_Tiles_Large", model: Res.model.environment.SM_Ground_Tiles_Large },
			{ name: "SM_Pillar", model: Res.model.environment.SM_Pillar },
			{ name: "SM_Pillar_Center", model: Res.model.environment.SM_Pillar_Center },
			{ name: "SM_Pillar_Center_Round", model: Res.model.environment.SM_Pillar_Center_Round },
			{ name: "SM_Pillar_Center_Ruined", model: Res.model.environment.SM_Pillar_Center_Ruined },
			{ name: "SM_Pillar_Corner", model: Res.model.environment.SM_Pillar_Corner },
			{ name: "SM_Prison_Corner", model: Res.model.environment.SM_Prison_Corner },
			{ name: "SM_Prison_Door", model: Res.model.environment.SM_Prison_Door },
			{ name: "SM_Prison_Half_Wall", model: Res.model.environment.SM_Prison_Half_Wall },
			{ name: "SM_Prison_Wall", model: Res.model.environment.SM_Prison_Wall },
			{ name: "SM_Prison_Wall_Door", model: Res.model.environment.SM_Prison_Wall_Door },
			{ name: "SM_Rug_1_Way", model: Res.model.environment.SM_Rug_1_Way },
			{ name: "SM_Rug_1_Way_Half", model: Res.model.environment.SM_Rug_1_Way_Half },
			{ name: "SM_Rug_1_Way_Ruined", model: Res.model.environment.SM_Rug_1_Way_Ruined },
			{ name: "SM_Rug_2_Way", model: Res.model.environment.SM_Rug_2_Way },
			{ name: "SM_Rug_3_Way", model: Res.model.environment.SM_Rug_3_Way },
			{ name: "SM_Rug_4_Way", model: Res.model.environment.SM_Rug_4_Way },
			{ name: "SM_Rug_End", model: Res.model.environment.SM_Rug_End },
			{ name: "SM_Stairs", model: Res.model.environment.SM_Stairs },
			{ name: "SM_Stone_Statue", model: Res.model.environment.SM_Stone_Statue },
			{ name: "SM_Throne", model: Res.model.environment.SM_Throne },
			{ name: "SM_Torch_Holder", model: Res.model.environment.SM_Torch_Holder },
			{ name: "SM_Torch_Holder_Off", model: Res.model.environment.SM_Torch_Holder_Off },
			{ name: "SM_Wall", model: Res.model.environment.SM_Wall },
			{ name: "SM_Wall_Angle", model: Res.model.environment.SM_Wall_Angle },
			{ name: "SM_Wall_Door", model: Res.model.environment.SM_Wall_Door },
			{ name: "SM_Wall_Prison_Window", model: Res.model.environment.SM_Wall_Prison_Window },
			{ name: "SM_Wall_Stairs_Fence", model: Res.model.environment.SM_Wall_Stairs_Fence },
			{ name: "SM_Wall_Window", model: Res.model.environment.SM_Wall_Window }
		];

		props = [
			{ name: "SM_Armor_Stand", model: Res.model.props.SM_Armor_Stand },
			{ name: "SM_Book_Pile_Large", model: Res.model.props.SM_Book_Pile_Large },
			{ name: "SM_Bookshelf_1", model: Res.model.props.SM_Bookshelf_1 },
			{ name: "SM_Chandelier", model: Res.model.props.SM_Chandelier },
			{ name: "SM_Swords_And_Shield", model: Res.model.props.SM_Swords_And_Shield },
			{ name: "SM_Wooden_Barrel", model: Res.model.props.SM_Wooden_Barrel },
			{ name: "SM_Wooden_Shelf", model: Res.model.props.SM_Wooden_Shelf },
			{ name: "SM_Wooden_Table", model: Res.model.props.SM_Wooden_Table }
		];
	}
}

typedef AssetItem = {
	var name(default, never):String;
	var model(default, never):Model;
}