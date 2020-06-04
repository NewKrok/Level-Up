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
import levelup.ProjectileAnimationData;
import levelup.SkyboxData;
import levelup.SoundFxAssets;
import levelup.TerrainAssets;
import levelup.UnitData;
import levelup.component.adventureloader.AdventureLoader;
import levelup.component.layout.Layout;
import levelup.core.renderer.Renderer;
import levelup.editor.EditorState;
import levelup.mainmenu.MainMenuState;
import levelup.util.LanguageUtil;
import levelup.util.SaveUtil;
import tink.CoreApi.Future;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Main extends Base2dApp
{
	public static var editorVersion:String = "0.0.1";

	var assetCache:AssetCache;
	var soundFxAssets:SoundFxAssets;

	var layout:Layout;
	var adventureLoader:AdventureLoader;

	override function init()
	{
		s3d.renderer = new levelup.core.renderer.Renderer();

		super.init();
		stage.stageScaleMode = StageScaleMode.NO_SCALE;

		assetCache = new AssetCache();
		soundFxAssets = new SoundFxAssets();
		layout = new Layout();
		adventureLoader = new AdventureLoader(cast this);

		SaveUtil.load();
		TerrainAssets.init();

		//Engine.ANTIALIASING = SaveUtil.gameData.app.antialias;

		assetCache.setTextureQuality(SaveUtil.appData.graphics.textureQuality);

		SkyboxData.addData(Json.parse(Res.data.asset.skybox_data.entry.getText()));

		ProjectileAnimationData.addData(Json.parse(Res.data.asset.projectile_animation_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.projectile_animation_asset_data.entry.getText()));

		EnvironmentData.addData(Json.parse(Res.data.asset.environment_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.environment_model_data.entry.getText()));

		UnitData.addData(Json.parse(Res.data.asset.neutral_unit_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.neutral_model_data.entry.getText()));

		UnitData.addData(Json.parse(Res.data.asset.human_unit_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.human_model_data.entry.getText()));

		UnitData.addData(Json.parse(Res.data.asset.elf_unit_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.elf_model_data.entry.getText()));

		UnitData.addData(Json.parse(Res.data.asset.orc_unit_data.entry.getText()));
		assetCache.addData(Json.parse(Res.data.asset.orc_model_data.entry.getText()));

		soundFxAssets.load([SoundFxKey.Click]).handle(function (o):Void switch(o)
		{
			case Success(_):
				LanguageUtil.loadLanguage().handle(function (o):Void switch(o)
				{
					case Success(_):
						//changeState(MainMenuState, [s3d, cast this]);
						changeState(EditorState, [stage, s3d, SaveUtil.editorData.customAdventures[0], cast this]);

						/*Browser.window.fetch("data/level/mainmenu/main_menu_elf_theme.json").then(res -> res.text()).then(res -> {
							changeState(EditorState, [stage, s3d, res, cast this]);
							onResize();
						});*/

						onResize();

					case Failure(e): trace("Couldn't load the initial language: " + SaveUtil.appData.language.textLanguage + ", error: " + e);
				});

			case Failure(e): trace("Couldn't load initial sound fx pack: " + e);
		});
	}

	override function onResize()
	{
		super.onResize();

		if (SaveUtil.appData != null)
		{
			engine.resize(
				Math.floor(Browser.window.innerWidth * SaveUtil.appData.graphics.resolutionQuality),
				Math.floor(Browser.window.innerHeight * SaveUtil.appData.graphics.resolutionQuality)
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