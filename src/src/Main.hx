package;

import h3d.Engine;
import haxe.Json;
import haxe.Timer;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hxd.Res;
import levelup.AssetCache;
import levelup.MapData;
import levelup.TerrainAssets;
import levelup.UnitData;
import levelup.editor.EditorState;
import levelup.game.GameState;
import levelup.util.SaveUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Main extends Base2dApp
{
	public static var editorVersion:String = "0.0.1";

	var gameState:EditorState;

	override function init()
	{
		super.init();
		stage.stageScaleMode = StageScaleMode.NO_SCALE;
		/*Asset.init();*/
		TerrainAssets.init();
		SaveUtil.load();
		UnitData.addData(Json.parse(Res.data.elf_unit_data.entry.getText()));
		UnitData.addData(Json.parse(Res.data.orc_unit_data.entry.getText()));
		AssetCache.addData(Json.parse(Res.data.elf_model_data.entry.getText()));
		AssetCache.addData(Json.parse(Res.data.orc_model_data.entry.getText()));

		//changeState(EditorState, [stage, s3d, SaveUtil.editorData.customMaps[0]]);
		//changeState(EditorState, [stage, s3d, MapData.getRawMap("lobby")]);
		//changeState(GameState, [stage, s3d, MapData.getRawMap("lobby")]);
		changeState(GameState, [stage, s3d, SaveUtil.editorData.customMaps[0]]);

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