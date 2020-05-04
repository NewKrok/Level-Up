package levelup;

import hxd.Res;

class MapData
{
	static public function getRawMap(name) return switch(name)
	{
		case "lobby": Res.data.level.lobby.entry.getText();
		case "hero_survival": Res.data.level.hero_survival.entry.getText();
		case "main_menu_elf_theme": Res.data.level.main_menu_elf_theme.entry.getText();

		case _: null;
	}
}