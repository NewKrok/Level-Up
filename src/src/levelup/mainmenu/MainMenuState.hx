package levelup.mainmenu;

import h3d.scene.Scene;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import levelup.game.GameWorld;
import levelup.util.AdventureParser;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MainMenuState extends Base2dState
{
	public function new(stage:Base2dStage, s3d:Scene, cf:CoreFeatures)
	{
		super(stage);
		this.cf = cf;

		this.s3d = s3d;
		this.s2d = s2d;

		var adventureConfig = AdventureParser.loadLevel(MapData.getRawMap("main_menu_elf_theme"));
		cf.assetCache.load(adventureConfig.neededModelGroups, adventureConfig.neededTextures).handle(o -> switch (o)
		{
			case Success(_): loaded();
			case Failure(e):
		});
	}

	function loaded()
	{
		world = new GameWorld(s3d, adventureConfig.size, adventureConfig.worldConfig, 1, 64, 64);
		world.done();
	}
}