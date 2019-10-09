package demo;

import hxd.Res;

class Asset
{
	static public function getStaticObject(name) return switch(name)
	{
		case "SM_Wall_Prison_Window": Res.model.environment.SM_Wall_Prison_Window;
		case "SM_Wall": Res.model.environment.SM_Wall;
		case "SM_Pillar_Center": Res.model.environment.SM_Pillar_Center;
		case _: null;
	}
}