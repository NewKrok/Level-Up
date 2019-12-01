package;

import h3d.Engine;
import haxe.Timer;
import levelup.Asset;
import levelup.MapData;
import levelup.TerrainAssets;
import levelup.editor.EditorState;
import levelup.game.GameState;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hxd.Res;
import levelup.util.SaveUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Main extends Base2dApp
{
	var gameState:EditorState;

	override function init()
	{
		super.init();
		stage.stageScaleMode = StageScaleMode.SHOW_ALL;
		Asset.init();
		TerrainAssets.init();
		SaveUtil.load();

		//changeState(EditorState, [stage, s3d, SaveUtil.editorData.customMaps[0]]);
		//changeState(EditorState, [stage, s3d, MapData.getRawMap("lobby")]);
		changeState(GameState, [stage, s3d, MapData.getRawMap("lobby")]);
		//changeState(GameState, [s2d, s3d, MapData.getRawMap("hero_survival")]);
	}

	static function main()
	{
		Engine.ANTIALIASING = 2;
		Res.initEmbed();
		// It looks Heaps need a little time to init assets, but I don't see related event to handle it properly
		// Without this delay sometimes it use wrong font
		Timer.delay(function() { new Main(); }, 500);
	}
}