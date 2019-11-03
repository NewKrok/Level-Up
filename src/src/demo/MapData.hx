package demo;

import hxd.Res;

class MapData
{
	static public function getRawMap(name) return switch(name)
	{
		case "lobby": Res.data.lobby.entry.getText();
		case "hero_survival": Res.data.hero_survival.entry.getText();

		case _: null;
	}
}