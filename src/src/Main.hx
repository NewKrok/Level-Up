package;

import demo.MapData;
import demo.game.GameState;
import haxe.Timer;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Main extends Base2dApp
{
	var gameState:GameState;

	override function init()
	{
		super.init();
		stage.stageScaleMode = StageScaleMode.SHOW_ALL;
		changeState(GameState, [s2d, s3d, MapData.getRawMap("lobby")]);
		//changeState(GameState, [s2d, s3d, MapData.getRawMap("hero_survival")]);
	}

	static function main()
	{
		Res.initEmbed();
		// It looks Heaps need a little time to init assets, but I don't see related event to handle it properly
		// Without this delay sometimes it use wrong font
		Timer.delay(function() { new Main(); }, 500);
	}
}