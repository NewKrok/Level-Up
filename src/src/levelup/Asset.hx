package levelup;

import hxd.Res;

class Asset
{
	static public function getStaticObject(name) return switch(name)
	{
		case "SM_Wall_Prison_Window": Res.model.environment.SM_Wall_Prison_Window;
		case "SM_Wall": Res.model.environment.SM_Wall;
		case "SM_Pillar_Center": Res.model.environment.SM_Pillar_Center;
		case "SM_Stone_Statue": Res.model.environment.SM_Stone_Statue;
		case "SM_Rug_1_Way": Res.model.environment.SM_Rug_1_Way;
		case "SM_Wall_Door": Res.model.environment.SM_Wall_Door;
		case "SM_Banner_Large": Res.model.environment.SM_Banner_Large;
		case "SM_Ground_Large": Res.model.environment.SM_Ground_Large;
		case "SM_Ground_Small": Res.model.environment.SM_Ground_Small;
		case "SM_Ground_Tiles": Res.model.environment.SM_Ground_Tiles;
		case "SM_Ground_Tiles_Damaged": Res.model.environment.SM_Ground_Tiles_Damaged;
		case "SM_Ground_Tiles_Large": Res.model.environment.SM_Ground_Tiles_Large;

		case "SM_Swords_And_Shield": Res.model.props.SM_Swords_And_Shield;

		case _: null;
	}
}