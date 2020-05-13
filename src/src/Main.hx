package;

import com.greensock.TweenLite;
import h3d.Engine;
import haxe.Json;
import haxe.Timer;
import hpp.heaps.Base2dApp;
import hpp.heaps.Base2dStage.StageScaleMode;
import hpp.heaps.HppG;
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
import levelup.game.GameState;
import levelup.mainmenu.MainMenuState;
import levelup.util.SaveUtil;
import react.ReactDOM;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Main extends Base2dApp
{
	public static var editorVersion:String = "0.0.1";

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

		SaveUtil.load();
		TerrainAssets.init();

		//Engine.ANTIALIASING = SaveUtil.gameData.app.antialias;

		ProjectileAnimationData.addData(Json.parse(Res.data.asset.projectile_animation_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.projectile_animation_asset_data.entry.getText()));

		EnvironmentData.addData(Json.parse(Res.data.asset.environment_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.environment_model_data.entry.getText()));

		UnitData.addData(Json.parse(Res.data.asset.neutral_unit_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.neutral_model_data.entry.getText()));

		UnitData.addData(Json.parse(Res.data.asset.elf_unit_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.elf_model_data.entry.getText()));

		UnitData.addData(Json.parse(Res.data.asset.orc_unit_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.orc_model_data.entry.getText()));

		//changeState(EditorState, [stage, s3d, SaveUtil.editorData.customMaps[0]]);
		//changeState(EditorState, [stage, s3d, MapData.getRawMap("lobby"), cast this]);
		//changeState(GameState, [stage, s3d, MapData.getRawMap("main_menu_elf_theme"), cast this]);
		//changeState(EditorState, [stage, s3d, MapData.getRawMap("main_menu_elf_theme"), cast this]);
		//changeState(GameState, [stage, s3d, MapData.getRawMap("lobby")]);
		//changeState(GameState, [stage, s3d, SaveUtil.editorData.customMaps[0]]);

		changeState(MainMenuState, [s3d, cast this]);
		onResize();
	}

	override function onResize()
	{
		super.onResize();

		if (SaveUtil.appData != null)
		{
			engine.resize(
				Math.floor(Browser.window.innerWidth * SaveUtil.appData.video.resolutionQuality),
				Math.floor(Browser.window.innerHeight * SaveUtil.appData.video.resolutionQuality)
			);
		}
	}

	static function main()
	{
		Engine.ANTIALIASING = 1;
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