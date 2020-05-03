package;

import h3d.Engine;
import haxe.Json;
import haxe.Timer;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hxd.Res;
import js.Browser;
import levelup.AssetCache;
import levelup.EnvironmentData;
import levelup.MapData;
import levelup.ProjectileAnimationData;
import levelup.TerrainAssets;
import levelup.UnitData;
import levelup.component.adventureloader.AdventureLoader;
import levelup.component.layout.Layout;
import levelup.component.layout.LayoutView;
import levelup.core.renderer.Renderer;
import levelup.editor.EditorState;
import levelup.util.SaveUtil;
import react.ReactDOM;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Main extends Base2dApp
{
	public static var editorVersion:String = "0.0.1";

	var gameState:EditorState;
	var assetCache:AssetCache;
	var layout:Layout;
	var adventureLoader:AdventureLoader;

	override function init()
	{
		s3d.renderer = new levelup.core.renderer.Renderer();

		super.init();
		stage.stageScaleMode = StageScaleMode.NO_SCALE;

		assetCache = new AssetCache();
		layout = new Layout();
		adventureLoader = new AdventureLoader(cast this);

		TerrainAssets.init();
		SaveUtil.load();

		ProjectileAnimationData.addData(Json.parse(Res.data.projectile_animation_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.projectile_animation_asset_data.entry.getText()));

		EnvironmentData.addData(Json.parse(Res.data.environment_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.environment_model_data.entry.getText()));

		UnitData.addData(Json.parse(Res.data.neutral_unit_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.neutral_model_data.entry.getText()));

		UnitData.addData(Json.parse(Res.data.elf_unit_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.elf_model_data.entry.getText()));

		UnitData.addData(Json.parse(Res.data.orc_unit_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.orc_model_data.entry.getText()));

		//changeState(EditorState, [stage, s3d, SaveUtil.editorData.customMaps[0]]);
		changeState(EditorState, [stage, s3d, MapData.getRawMap("lobby"), cast this]);
		//changeState(GameState, [stage, s3d, MapData.getRawMap("lobby")]);
		//changeState(GameState, [stage, s3d, SaveUtil.editorData.customMaps[0]]);
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

typedef CoreFeatures =
{
	var assetCache:AssetCache;
	var layout:Layout;
	var adventureLoader:AdventureLoader;
}