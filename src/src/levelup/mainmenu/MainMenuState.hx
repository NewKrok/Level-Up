package levelup.mainmenu;

import com.greensock.TweenLite;
import h3d.scene.Object;
import h3d.scene.Scene;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import levelup.component.FpsView;
import levelup.component.layout.LayoutView.LayoutId;
import levelup.core.camera.ActionCamera;
import levelup.core.trigger.TriggerExecutor;
import levelup.editor.EditorState;
import levelup.game.GameState;
import levelup.game.unit.BaseUnit;
import levelup.mainmenu.html.MainMenuView;
import levelup.game.GameState.AdventureConfig;
import levelup.game.GameWorld;
import levelup.util.AdventureParser;
import Main.CoreFeatures;
import levelup.util.SaveUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class MainMenuState extends Base2dState
{
	var s3d:Scene = _;
	var cf:CoreFeatures = _;

	var triggerExecutor:TriggerExecutor;
	var adventureConfig:AdventureConfig;

	var world:GameWorld;
	var camera:ActionCamera;
	var view:MainMenuView;

	public function new(stage:Base2dStage)
	{
		super(stage);

		// TODO It should be configurable
		var neededImages = [
			"asset/texture/skybox_a/sb_1.jpg",
			"asset/texture/skybox_a/sb_2.jpg",
			"asset/texture/skybox_a/sb_3.jpg",
			"asset/texture/skybox_a/sb_4.jpg",
			"asset/texture/skybox_a/sb_5.jpg",
			"asset/texture/skybox_a/sb_6.jpg"
		];

		adventureConfig = AdventureParser.loadLevel(MapData.getRawMap("main_menu_elf_theme"));
		cf.assetCache.load(adventureConfig.neededModelGroups, adventureConfig.neededTextures, neededImages).handle(o -> switch (o)
		{
			case Success(_): loaded(s3d);
			case Failure(e):
		});
	}

	function loaded(s3d:Scene)
	{
		createWorld();

		camera = new ActionCamera(s3d.camera);
		triggerExecutor = new TriggerExecutor(cast stage, s3d, world, camera, adventureConfig.worldConfig.triggers, adventureConfig.worldConfig.cameras, adventureConfig.worldConfig.regions);

		createUi();
	}

	function createWorld()
	{
		world = new GameWorld(s3d, adventureConfig.size, adventureConfig.worldConfig, 1, 64, 64);

		createUnits();
		createStaticObjects();

		world.done();
	}

	function createUnits()
	{
		for (u in adventureConfig.worldConfig.units)
		{
			var unit = new BaseUnit(null, world, u.owner, UnitData.getUnitConfig(u.id), _ -> {});

			unit.view.x = u.x * world.blockSize + world.blockSize / 2;
			unit.view.y = u.y * world.blockSize + world.blockSize / 2;
			if (u.scale != null) unit.view.setScale(u.scale);
			if (u.rotation != null) unit.view.setRotationQuat(u.rotation);

			world.addEntity(unit);
		}
	}

	function createStaticObjects()
	{
		for (o in adventureConfig.worldConfig.staticObjects.concat([]))
		{
			var config = EnvironmentData.getEnvironmentConfig(o.id);
			var instance:Object = config == null ? AssetCache.instance.getUndefinedModel() : AssetCache.instance.getModel(config.assetGroup);

			if (config != null && config.hasTransparentTexture != null && config.hasTransparentTexture)
				for (m in instance.getMaterials()) m.textureShader.killAlpha = true;
			else if (config == null)
				trace('Warning! There is a static object in the world without proper config with this id: ${o.id}');

			world.addToWorldPoint(instance, o.x, o.y, o.z, config == null ? 1 : o.scale, o.rotation);
		}
	}

	function createUi()
	{
		view = new MainMenuView({
			openAdventure: levelId ->
			{
				TweenLite.delayedCall(
					0.4,
					HppG.changeState.bind(
						GameState,
						[stage, s3d, SaveUtil.editorData.customAdventures.filter(adv -> return adv.indexOf(levelId) != -1)[0], cf]
					)
				);
			},
			openAdventureEditor: levelId ->
			{
				TweenLite.delayedCall(
					0.4,
					HppG.changeState.bind(
						EditorState,
						[stage, s3d, levelId == null ? null : SaveUtil.editorData.customAdventures.filter(adv -> return adv.indexOf(levelId) != -1)[0], cf]
					)
				);
			}
		});
		cf.layout.registerView(LayoutId.MainMenuUi, view.reactify());
	}

	override function update(d:Float)
	{
		if (world == null) return;

		world.update(d);
		camera.update(d);
	}

	override public function dispose():Void
	{
		super.dispose();

		world.remove();
		world.dispose();
		world = null;

		stage.removeChildren();
		s3d.removeChildren();

		cf.layout.removeView(LayoutId.MainMenuUi);
	}
}