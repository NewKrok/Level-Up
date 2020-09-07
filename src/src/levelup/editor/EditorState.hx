package levelup.editor;

import Main.CoreFeatures;
import coconut.ui.RenderResult;
import com.greensock.easing.Quad;
import h2d.Scene;
import h3d.Quat;
import h3d.Vector;
import h3d.mat.Material;
import h3d.mat.Pass;
import h3d.mat.Texture;
import h3d.prim.Grid;
import h3d.scene.Graphics;
import h3d.scene.Interactive;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.shader.AlphaMap;
import haxe.Json;
import haxe.crypto.Base64;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hpp.util.JsFullScreenUtil;
import hxd.BitmapData;
import hxd.Event;
import hxd.Key;
import hxd.Window;
import js.Browser;
import levelup.Asset.AssetConfig;
import levelup.UnitData;
import levelup.component.editor.modules.camera.CameraModule;
import levelup.component.editor.modules.light.LightModule;
import levelup.component.editor.modules.heightmap.HeightMapModule;
import levelup.component.editor.modules.itemeditor.ItemEditorModule;
import levelup.component.editor.modules.library.EditorLibraryModule;
import levelup.component.editor.modules.region.RegionModule;
import levelup.component.editor.modules.script.ScriptModule;
import levelup.component.editor.modules.skilleditor.SkillEditorModule;
import levelup.component.editor.modules.skybox.SkyboxModule;
import levelup.component.editor.modules.teamsettings.TeamSettingsModule;
import levelup.component.editor.modules.terrain.TerrainChooser;
import levelup.component.editor.modules.terrain.TerrainModule;
import levelup.component.editor.modules.uniteditor.UnitEditorModule;
import levelup.component.editor.modules.weather.WeatherModule;
import levelup.component.editor.modules.worldsettings.WorldSettingsModule;
import levelup.component.editor.moduleselector.ModuleSelector;
import levelup.component.layout.LayoutView.LayoutId;
import levelup.core.camera.ActionCamera;
import levelup.editor.dialog.EditorDialogManager;
import levelup.editor.html.EditorView;
import levelup.editor.html.NewAdventureDialog;
import levelup.editor.EditorModel;
import levelup.game.GameState;
import levelup.game.GameState.WorldConfig;
import levelup.game.GameWorld;
import levelup.mainmenu.MainMenuState;
import levelup.shader.ForcedZIndex;
import levelup.shader.PlayerColor;
import levelup.util.AdventureParser;
import levelup.util.GeomUtil3D;
import levelup.util.SaveUtil;
import lzstring.LZString;
import motion.Actuate;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorState extends Base2dState
{
	public var id(default, never):UInt = Math.floor(Math.random() * 1000);

	var cf:CoreFeatures;

	var world:GameWorld;
	var adventureConfig:AdventureConfig;
	var model:EditorModel;

	var s2d:h2d.Scene;
	var s3d:h3d.scene.Scene;

	var editorUi:EditorView;
	var dialogManager:EditorDialogManager;

	var moduleSelector:ModuleSelector;

	var grid:Grid;
	var gridMesh:Mesh;

	var pathFindingLayer:Graphics;

	var debugRegions:Graphics;
	var debugUnitPath:Graphics;
	var debugDetectionRadius:Graphics;

	var isDisposed:Bool = false;

	var isMapDragActive:Bool = false;
	var isMouseDrawActive:Bool = false;
	var cameraDragStartPoint:SimplePoint = { x: 0, y: 0 };
	var dragStartObjectPoint:SimplePoint = { x: 0, y: 0 };

	// TODO: Create a separated cam class
	var cameraObject:Object = new Object();
	var currentCameraPoint: { x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var cameraSpeed:Vector = new Vector(10, 10, 5);
	var camAngle:Float = Math.PI - Math.PI / 4;
	var camRotation:Float = Math.PI / 2;
	// --
	var camera:ActionCamera;

	var lastMouseMove2dPoint:Vector = new Vector();
	var currentMouseMove2dPoint:Vector = new Vector();

	var selectedWorldAsset:State<AssetItem> = new State<AssetItem>(null);
	var selectedAssetConfig:AssetConfig;
	var previewInstance:Object;

	var lastEscPressTime:Float = 0;

	var draggedInstance:Object;
	var dragInstanceAbsStartPoint:SimplePoint;
	var dragInstanceWorldStartPoint:SimplePoint;
	var dragInstanceStartPoint:SimplePoint;
	var draggedInteractive:Interactive;

	var worldInstances:Array<AssetWorldInstance> = [];
	var activeWorldInstance:AssetWorldInstance = null;

	var actionHistory:Array<EditorAction> = [];
	var actionIndex:Int = 0;
	var isLevelLoaded:Bool = false;
	var hadActiveCommandWithCtrl:Bool = false;

	public var isPathFindingLayerDirty:Bool = false;
	var lastPathRenderTime:Float = 0;

	var compressor:LZString;

	public function new(stage:Base2dStage, s2d:h2d.Scene, s3d:h3d.scene.Scene, rawMap:String, cf:CoreFeatures)
	{
		super(stage);
		this.cf = cf;

		this.s3d = s3d;
		this.s2d = s2d;

		compressor = new LZString();

		if (rawMap == null)
		{
			rawMap = createNewAdventureRawData({
				size: { x: 100, y: 100 },
				defaultTerrainTextureId: TerrainAssets.terrains[0].id
			});
		}

		cf.adventureLoader.load(rawMap, true).handle(o -> switch (o)
		{
			case Success(result):
				adventureConfig = result.config;
				onLoaded(rawMap);

			case Failure(e):
				trace('Fatal error, couldn\'t load resources for {rawMap.id} with title: {rawMap.title}. Error message $e');
		});
	}

	function onLoaded(rawMap)
	{
		model = new EditorModel(
		{
			id: adventureConfig.id,
			title: adventureConfig.title,
			subTitle: adventureConfig.subTitle,
			description: adventureConfig.description,
			preloaderImage: adventureConfig.preloaderImage,
			size: adventureConfig.size,
			regions: adventureConfig.worldConfig.regions,
			units: [],
			staticObjects: [],
			showGrid: SaveUtil.editorData.showGrid,
			defaultTerrainIdForNewAdventure: TerrainAssets.terrains[0].id
		});

		model.observables.showGrid.bind(v -> v ? showGrid() : hideGrid());
		/*model.observables.toolState.bind(v ->
		{
			if (v == ModuleId.Library) enableAssetInteractives();
			else
			{
				disableAssetInteractives();
				createPreview(null);
			}
		});*/

		dialogManager = new EditorDialogManager(cast this);

		pathFindingLayer = new Graphics(s3d);
		pathFindingLayer.material.mainPass.addShader(new ForcedZIndex(10));

		debugRegions = new Graphics(s3d);
		debugRegions.z = 0.2;
		debugUnitPath = new Graphics(s3d);
		debugUnitPath.z = 0.2;
		debugDetectionRadius = new Graphics(s3d);
		debugDetectionRadius.z = 0.2;

		world = new GameWorld(s3d, adventureConfig.size, adventureConfig.worldConfig, 1, 64, 128);
		world.disableDayTime();
		world.done();

		world.onWorldClick = e ->
		{
			/*for (m in modules) if (m.onWorldClick != null) m.onWorldClick(e);*/
		}
		world.onWorldMouseDown = e ->
		{
			/*for (m in modules) if (m.onWorldMouseDown != null) m.onWorldMouseDown(e);*/

			if (e.button == 0)
			{
				dragStartObjectPoint.x = cameraObject.x;
				dragStartObjectPoint.y = cameraObject.y;
				isMouseDrawActive = true;
			}
			else if (e.button == 1)
			{
				disableAssetInteractives();
				isMapDragActive = true;
				cameraDragStartPoint.x = e.relX;
				cameraDragStartPoint.y = e.relY;
				dragStartObjectPoint.x = cameraObject.x;
				dragStartObjectPoint.y = cameraObject.y;
			}
		}
		world.onWorldMouseUp = e ->
		{
			//for (m in modules) if (m.onWorldMouseUp != null) m.onWorldMouseUp(e);

			if (e.button == 0)
			{
				/*if (model.toolState == ModuleId.Library && previewInstance == null) enableAssetInteractives();*/

				if (draggedInstance == null)
				{
					isMouseDrawActive = false;
				}

				if (dragStartObjectPoint != null && previewInstance != null && GeomUtil.getDistance(cast dragStartObjectPoint, cast cameraObject) < 0.2)
				{
					createAsset(
						selectedAssetConfig,
						previewInstance.x,
						previewInstance.y,
						previewInstance.z,
						previewInstance.scaleX,
						previewInstance.getRotationQuat().clone(),
						model.selectedPlayer
					);
				}
				else if (draggedInstance != null && GeomUtil.getDistance(cast draggedInstance, dragInstanceStartPoint) < 0.2)
				{
					selectedWorldAsset.set({ instance: draggedInstance, config: activeWorldInstance.config });
				}
				else if (GeomUtil.getDistance({ x: e.relX, y: e.relY }, cameraDragStartPoint) < 0.2)
				{
					selectedWorldAsset.set(null);
				}

				if (draggedInstance != null)
				{
					logAction(
					{
						actionType: EditorActionType.Move,
						target: draggedInstance,
						oldValueSimplePoint: dragInstanceAbsStartPoint,
						newValueSimplePoint: { x: draggedInstance.x, y: draggedInstance.y }
					});
					draggedInstance = null;
					dragInstanceWorldStartPoint = null;
					draggedInteractive.visible = true;
				};
			}
			else if (e.button == 1)
			{
				isMapDragActive = false;
				/*if (model.toolState == ModuleId.Library && previewInstance == null) enableAssetInteractives();*/
			}
		}
		world.onWorldMouseMove = e ->
		{
			currentMouseMove2dPoint = s3d.camera.project(e.relX, e.relY, e.relZ, HppG.stage2d.width, HppG.stage2d.height);

			/*for (m in modules) if (m.onWorldMouseMove != null) m.onWorldMouseMove(e);*/

			if (previewInstance != null)
			{
				if (!model.isYDragLocked) previewInstance.x = snapPosition(e.relX);
				if (!model.isXDragLocked) previewInstance.y = snapPosition(e.relY);
				previewInstance.z = GeomUtil3D.getHeightByPosition(
					world.heightGrid,
					previewInstance.x,
					previewInstance.y
				) + (selectedAssetConfig.zOffset != null ? selectedAssetConfig.zOffset : 0);
			}

			if (draggedInstance != null)
			{
				if (dragInstanceWorldStartPoint == null)
				{
					dragInstanceStartPoint = { x: draggedInstance.x, y: draggedInstance.y };
					dragInstanceWorldStartPoint = { x: e.relX, y: e.relY };
					selectedWorldAsset.set({ instance: draggedInstance, config: activeWorldInstance.config });
				}
				draggedInstance.setPosition(
					snapPosition(model.isYDragLocked ? dragInstanceStartPoint.x : dragInstanceStartPoint.x + (e.relX - dragInstanceWorldStartPoint.x)),
					snapPosition(model.isXDragLocked ? dragInstanceStartPoint.y : dragInstanceStartPoint.y + (e.relY - dragInstanceWorldStartPoint.y)),
					draggedInstance.z
				);
			}
			else if (isMapDragActive)
			{
				if (hadActiveCommandWithCtrl)
				{
					camRotation += (lastMouseMove2dPoint.x - currentMouseMove2dPoint.x) * Math.PI / 1800;
					camAngle += (lastMouseMove2dPoint.y - currentMouseMove2dPoint.y) * Math.PI / 1800;
				}
				else
				{
					cameraObject.x = dragStartObjectPoint.x + (cameraDragStartPoint.x - e.relX) * 2;
					cameraObject.y = dragStartObjectPoint.y + (cameraDragStartPoint.y - e.relY) * 2;
				}
			}
			else if (isMouseDrawActive)
			{

			}

			if (previewInstance != null || draggedInstance != null) isPathFindingLayerDirty = true;

			lastMouseMove2dPoint = currentMouseMove2dPoint.clone();
		}
		world.onWorldWheel = e ->
		{
			if (Key.isDown(Key.CTRL) || Key.isDown(Key.SHIFT))
			{
				if (previewInstance != null || selectedWorldAsset.value != null)
				{
					var activeInstance = previewInstance != null ? previewInstance : selectedWorldAsset.value.instance;

					if (Key.isDown(Key.CTRL)) activeInstance.scale(e.wheelDelta < 0 ? 0.9 : 1.1);
					else if (Key.isDown(Key.SHIFT))  activeInstance.rotate(0, 0, e.wheelDelta < 0 ? -Math.PI / 8 : Math.PI / 8);
				}
				else
				{
					var camStep = Math.PI / 60;
					if (Key.isDown(Key.CTRL))
					{
						camAngle += e.wheelDelta < 0 ? camStep : -camStep;
						camAngle = Math.max(camAngle, Math.PI / 2 + 0.001);
						camAngle = Math.min(camAngle, Math.PI);
					}
					else
					{
						camRotation += e.wheelDelta < 0 ? camStep : -camStep;
					}
				}
			}
			else
			{
				/*for (m in modules) if (m.onWorldWheel != null) m.onWorldWheel(e);*/

				camera.camDistance += e.wheelDelta * 8;
			}
		}

		for (o in adventureConfig.worldConfig.staticObjects.concat([]))
		{
			var config = EnvironmentData.getEnvironmentConfig(o.id);
			if (config != null) createAsset(cast config, o.x, o.y, o.z, o.scale == null ? config.modelScale : o.scale, o.rotation);
			else trace("Couldn't create asset with id: " + o.id);
		}

		for (o in adventureConfig.worldConfig.units.concat([]))
		{
			var config = UnitData.getUnitConfig(o.id);
			if (config != null) createUnit(cast config, o.x, o.y, o.z, o.scale == null ? config.modelScale : o.scale, o.rotation, o.owner);
			else trace("Couldn't create unit with id: " + o.id);
		}

		s3d.addChild(cameraObject);
		s3d.camera.target.x = s3d.camera.pos.x;
		s3d.camera.target.y = s3d.camera.pos.y;

		initCamera();

		moduleSelector = new ModuleSelector(cast this);

		new WorldSettingsModule(cast this);
		new TeamSettingsModule(cast this);
		new SkyboxModule(cast this);
		new LightModule(cast this);
		new WeatherModule(cast this);
		new HeightMapModule(cast this);
		new TerrainModule(cast this);
		new RegionModule(cast this);
		new CameraModule(cast this);
		new EditorLibraryModule(cast this, createPreview);
		new UnitEditorModule(cast this);
		new SkillEditorModule(cast this);
		new ItemEditorModule(cast this);
		new ScriptModule(cast this);

		editorUi = new EditorView(
		{
			backToLobby: () -> HppG.changeState(MainMenuState, [s3d, cf]),
			toggleFullScreen: JsFullScreenUtil.toggleFullScreen,
			createNewAdventure: dialogManager.openDialog.bind({
				view: new NewAdventureDialog({
					createNewAdventure: createNewAdventure,
					close: dialogManager.closeCurrentDialog,
					defaultTerrainIdForNewAdventure: model.defaultTerrainIdForNewAdventure,
					openTerrainChooser: dialogManager.openDialog.bind({
						forceOpen: true, view: new TerrainChooser({
							close: dialogManager.closeCurrentDialog,
							terrainList: TerrainAssets.terrains,
							selectTerrain: id ->
							{
								model.defaultTerrainIdForNewAdventure = id;
								dialogManager.closeCurrentDialog();
							}
						}).reactify()
					})
				}).reactify()
			}),
			save: save,
			testRun: () -> HppG.changeState(GameState, [stage, s3d, save(), cf, { isTestRun: true }]),
			model: model
		});

		cf.layout.registerView(LayoutId.EditorUi, editorUi.reactify());

		createGrid();

		Window.getInstance().addEventTarget(onKeyEvent);
		isLevelLoaded = true;
	}

	function initCamera()
	{
		camera = new ActionCamera(s3d.camera);
		camera.maxCameraDistance = 200;
		camera.camDistance = 30;
		camera.cameraRotationSpeed = 20;
		camera.cameraAngleSpeed = 10;
		/*camera.startCameraShake(1, 2, Quad.easeInOut);
		camera.setCameraTarget(cast world.car, {
			useTargetsAngle: true,
			angleOffset: 0,
			maxCamAngle: Math.PI / 4,
			minCamAngle: -Math.PI / 4,
			useTargetsRotation: true,
			offset: { x: 0, y: 3, z: -10 }
		});*/
		camera.setCameraTarget(cast cameraObject);
		if (adventureConfig.worldConfig.editorLastCamPosition == null) camera.jumpCamera(10, 10);
		else
		{
			camera.camDistance = adventureConfig.worldConfig.editorLastCamPosition.z;
			camera.jumpCamera(adventureConfig.worldConfig.editorLastCamPosition.x, adventureConfig.worldConfig.editorLastCamPosition.y);
		}
	}

	function createAsset(config:AssetConfig, x, y, z, scale, rotation, owner = null)
	{
		var instance:Object = AssetCache.instance.getModel(config.assetGroup + (config.race == null ? "" : ".idle" ));
		if (config.hasTransparentTexture != null && config.hasTransparentTexture) for (m in instance.getMaterials()) m.textureShader.killAlpha = true;

		var interactive = new Interactive(instance.getCollider(), world);

		if (config.race == null)
		{
			model.staticObjects.push(
			{
				id: config.id,
				name: config.name,
				x: x,
				y: y,
				z: z,
				zOffset: config.zOffset,
				scale: scale,
				rotation: rotation,
				instance: instance,
				isPathBlocker: config.isPathBlocker
			});

			isPathFindingLayerDirty = true;
		}
		else
		{
			model.units.push(
			{
				id: config.id,
				name: config.name,
				x: x,
				y: y,
				z: z,
				zOffset: config.zOffset,
				scale: scale,
				rotation: rotation,
				owner: owner,
				instance: instance
			});

			if (config.race != RaceId.Neutral)
			{
				var colorMask = AssetCache.instance.getTexture("asset/model/" + config.race + "/unit/MaskTex.jpg");

				var maskKey = [
					RaceId.Elf => 0xFF0000,
					RaceId.Orc => 0x00FF00,
					RaceId.Undead => 0xFF0000,
					RaceId.Human => 0xFF0000
				];
				instance.getMaterials()[0].mainPass.addShader(
					new PlayerColor(colorMask, Std.parseInt("0x" + Player.colors[owner]), maskKey.get(config.race))
				);
			}
		}

		worldInstances.push(
		{
			instance: instance,
			config: config,
			interactive: interactive
		});

		if (config.race != null)
		{
			instance.playAnimation(AssetCache.instance.getAnimation(config.assetGroup + ".idle"));
		}

		var dragPoint:Vector;
		interactive.onPush = e ->
		{
			activeWorldInstance = worldInstances.filter(i -> return i.instance == instance)[0];
			draggedInstance = instance;
			dragInstanceAbsStartPoint = { x: draggedInstance.x, y: draggedInstance.y };
			dragInstanceStartPoint = { x: draggedInstance.x, y: draggedInstance.y };
			draggedInteractive = interactive;
			interactive.visible = false;

			disableAssetInteractives(interactive);
		};

		interactive.onRelease = e -> if (e.button == 0 && previewInstance == null) enableAssetInteractives();

		var onOverRoutines = [];
		var onOutRoutines = [];

		for (m in instance.getMaterials())
		{
			var p = new Pass("editorHighlight", null, m.mainPass);
			p.culling = None;
			p.depthWrite = false;
			onOverRoutines.push(() -> m.addPass(p));
			onOutRoutines.push(() -> m.removePass(p));
		}

		interactive.onOver = e -> { onOverRoutines.map(fv -> fv()); };
		interactive.onOut = e ->
		{
			if (selectedWorldAsset.value == null || selectedWorldAsset.value.instance == null || selectedWorldAsset.value.instance != instance)
			{
				onOutRoutines.map(fv -> fv());
			}
		};
		selectedWorldAsset.bind(v -> if (v == null || v.instance == null || v.instance != instance) onOutRoutines.map(fv -> fv()));

		if (previewInstance != null)
		{
			interactive.visible = false;
			interactive.cancelEvents = true;
		}

		world.addToWorldPoint(instance, x, y, z, scale, rotation);

		if (isLevelLoaded) logAction({ actionType: EditorActionType.Create, target: instance });
	}

	function createUnit(config:AssetConfig, x, y, z, scale, rotation, owner)
	{
		createAsset(config, x, y, z, scale, rotation, owner);
	}

	function onKeyEvent(e:Event)
	{
		var selectedInstance = selectedWorldAsset.value != null ? selectedWorldAsset.value.instance : null;
		var selectedConfig = selectedWorldAsset.value != null ? selectedWorldAsset.value.config : null;

		if (e.kind == EKeyDown)
			switch (e.keyCode)
			{
				case Key.Z if (Key.isDown(Key.CTRL)):
					hadActiveCommandWithCtrl = true;
					undo();

				case Key.Y if (Key.isDown(Key.CTRL)):
					hadActiveCommandWithCtrl = true;
					redo();

				case _  if (Key.isDown(Key.CTRL)): hadActiveCommandWithCtrl = true;
				case _:
			}

		if (e.kind == EKeyUp)
			switch (e.keyCode)
			{
				case Key.CTRL:
					if (hadActiveCommandWithCtrl)
					{
						hadActiveCommandWithCtrl = false;
						return;
					}

				case Key.UP | Key.W if (previewInstance != null):
					previewInstance.scale(1.1);
				case Key.DOWN | Key.S if (previewInstance != null):
					previewInstance.scale(0.9);

				case Key.UP | Key.W if (selectedInstance != null):
					logAction(
					{
						actionType: EditorActionType.Scale,
						target: selectedInstance,
						oldValueFloat: selectedInstance.scaleX,
						newValueFloat: selectedInstance.scaleX * 0.9
					});
					selectedInstance.scale(1.1);
				case Key.DOWN | Key.S if (selectedInstance != null):
					logAction(
					{
						actionType: EditorActionType.Scale,
						target: selectedInstance,
						oldValueFloat: selectedInstance.scaleX,
						newValueFloat: selectedInstance.scaleX * 1.1
					});
					selectedInstance.scale(0.9);

				case Key.LEFT | Key.A if (previewInstance != null):
					previewInstance.rotate(0, 0, Math.PI / 8);
				case Key.RIGHT | Key.D if (!hadActiveCommandWithCtrl && previewInstance != null):
					previewInstance.rotate(0, 0, -Math.PI / 8);

				case Key.LEFT | Key.A if (selectedInstance != null):
					var prevQ = selectedInstance.getRotationQuat().clone();
					selectedInstance.rotate(0, 0, Math.PI / 8);
					logAction(
					{
						actionType: EditorActionType.Rotate,
						target: selectedInstance,
						oldValueQuat: prevQ,
						newValueQuat: selectedInstance.getRotationQuat().clone()
					});

				case Key.RIGHT | Key.D if (!hadActiveCommandWithCtrl && selectedInstance != null):
					var prevQ = selectedInstance.getRotationQuat().clone();
					selectedInstance.rotate(0, 0, -Math.PI / 8);
					logAction(
					{
						actionType: EditorActionType.Rotate,
						target: selectedInstance,
						oldValueQuat: prevQ,
						newValueQuat: selectedInstance.getRotationQuat().clone()
					});

				/*case Key.UP | Key.W:
					cameraObject.x += 5 * Math.sin(camRotation);
					cameraObject.y += 5 * Math.cos(camRotation);

				case Key.DOWN | Key.S:
					cameraObject.x -= 5 * Math.sin(camRotation);
					cameraObject.y -= 5 * Math.cos(camRotation);

				case Key.LEFT | Key.A:
					cameraObject.x += 5 * Math.sin(camRotation + Math.PI / 2);
					cameraObject.y += 5 * Math.cos(camRotation + Math.PI / 2);

				case Key.RIGHT | Key.D:
					cameraObject.x += 5 * Math.sin(camRotation - Math.PI / 2);
					cameraObject.y += 5 * Math.cos(camRotation - Math.PI / 2);*/

				case Key.SPACE if (previewInstance != null):
					var libraryModule = cast(model.getModule(EditorModuleId.MEditorLibrary).instance, EditorLibraryModule);
					libraryModule.removeSelection();

				case Key.ESCAPE if (selectedWorldAsset.value != null): selectedWorldAsset.set(null);

				case Key.ESCAPE if (previewInstance != null):
					var now = Date.now().getTime();
					if (now - lastEscPressTime < 500)
					{
						var libraryModule = cast(model.getModule(EditorModuleId.MEditorLibrary).instance, EditorLibraryModule);
						libraryModule.removeSelection();
						return;
					}
					lastEscPressTime = now;

					previewInstance.setScale(selectedAssetConfig.modelScale);
					previewInstance.setRotation(0, 0, 0);

				case Key.ESCAPE if (previewInstance == null):
					var now = Date.now().getTime();
					if (now - lastEscPressTime < 500)
					{
						camera.camDistance = 30;
						camAngle = Math.PI - Math.PI / 4;
						camRotation = Math.PI / 2;
						return;
					}
					lastEscPressTime = now;

				case Key.C if (selectedWorldAsset.value != null):
					createPreview(selectedWorldAsset.value.config);
					previewInstance.setScale(selectedWorldAsset.value.instance.scaleX);
					previewInstance.setRotationQuat(selectedWorldAsset.value.instance.getRotationQuat().clone());

				case Key.DELETE if (selectedWorldAsset.value != null):
					for (obj in model.staticObjects)
					{
						if (obj.instance == selectedWorldAsset.value.instance)
						{
							model.staticObjects.remove(obj);
							obj.instance.remove();
							selectedWorldAsset.set(null);
							return;
						}
					}
					for (unit in model.units)
					{
						if (unit.instance == selectedWorldAsset.value.instance)
						{
							model.units.remove(unit);
							unit.instance.remove();
							selectedWorldAsset.set(null);
							return;
						}
					}
					if (draggedInstance != null) draggedInstance = null;

				case Key.N if (!Key.isDown(Key.CTRL)): editorUi.increaseSnap();
				case Key.G if (!Key.isDown(Key.CTRL)): model.showGrid = !model.showGrid;
			}
	}

	function disableAssetInteractives(except = null)
	{
		for (i in worldInstances)
		{
			if (i.interactive != except)
			{
				i.interactive.visible = false;
				i.interactive.cancelEvents = true;
			}
		}
	}

	function enableAssetInteractives()
	{
		for (i in worldInstances)
		{
			i.interactive.visible = true;
			i.interactive.cancelEvents = false;
		}
	}

	function createPreview(asset:AssetConfig)
	{
		selectedAssetConfig = asset;

		if (previewInstance != null)
		{
			previewInstance.remove();
			previewInstance = null;
			enableAssetInteractives();
		}

		if (selectedAssetConfig != null)
		{
			var modelName = selectedAssetConfig.assetGroup + (selectedAssetConfig.race == null ? "" : ".idle");
			var addPreviewToWorld = () -> {
				previewInstance = AssetCache.instance.getModel(modelName);
				if (asset.hasTransparentTexture != null && asset.hasTransparentTexture) for (m in previewInstance.getMaterials()) m.textureShader.killAlpha = true;
				if (selectedAssetConfig.race != null) previewInstance.playAnimation(AssetCache.instance.getAnimation(modelName));
				previewInstance.setScale(selectedAssetConfig.modelScale);
				previewInstance.setRotation(0, 0, 0);
				if (selectedAssetConfig.zOffset != null) previewInstance.z = selectedAssetConfig.zOffset;

				s3d.addChild(previewInstance);
				disableAssetInteractives();
			}

			if (AssetCache.instance.hasModelCache(modelName)) addPreviewToWorld();
			else AssetCache.instance.loadModelGroups([selectedAssetConfig.assetGroup]).handle(addPreviewToWorld);
		}

		Browser.document.getElementById("webgl").focus();
	}

	function logAction(a:EditorAction)
	{
		if (actionIndex < actionHistory.length - 1)
		{
			actionHistory = actionHistory.slice(0, actionIndex);
		}

		actionHistory.push(a);
		actionIndex = actionHistory.length;
	}

	function undo()
	{
		if (actionIndex == 0 || draggedInstance != null) return;
		actionIndex--;
		reprocessAction(actionHistory[actionIndex], false);
	}

	function redo()
	{
		if (actionIndex == actionHistory.length || draggedInstance != null) return;
		reprocessAction(actionHistory[actionIndex], true);
		actionIndex++;
	}

	function reprocessAction(a, useNewValue)
	{
		switch (a.actionType)
		{
			case EditorActionType.Scale:
				a.target.setScale(useNewValue ? a.newValueFloat : a.oldValueFloat);
				calculatePathMap();

			case EditorActionType.Rotate:
				a.target.setRotationQuat(useNewValue ? a.newValueQuat : a.oldValueQuat);
				calculatePathMap();

			case EditorActionType.Move:
				a.target.setPosition(
					useNewValue ? a.newValueSimplePoint.x : a.oldValueSimplePoint.x,
					useNewValue ? a.newValueSimplePoint.y : a.oldValueSimplePoint.y,
					a.target.z
				);
				calculatePathMap();

			case _:
		}
	}

	function createGrid()
	{
		grid = new Grid(cast adventureConfig.size.y, cast adventureConfig.size.x);
		grid.addTangents();

		gridMesh = new Mesh(grid, Material.create(Texture.fromColor(0x999900, 0.1)), s3d);
		gridMesh.material.mainPass.wireframe = true;
		gridMesh.material.castShadows = false;
		gridMesh.material.receiveShadows = false;
	}

	function updateGrid()
	{
		if (gridMesh.visible)
		{
			grid.buffer = null;

			for (i in 0...grid.points.length)
			{
				grid.points[i].z = world.heightGridCache[i];
			}
		}
	}

	function hideGrid() gridMesh.visible = false;

	function showGrid()
	{
		updateGrid();
		gridMesh.visible = true;
	}

	function getZFromPoint(targetX, targetY)
	{
		var targetGrid:Grid = cast world.terrainLayers[0].primitive;

		for (p in targetGrid.points) if (targetX == p.x && targetY == p.y) return p.z;

		return 0;
	}

	function drawPathFindingLayer():Void
	{
		calculatePathMap();
/*
		pathFindingLayer.clear();
		pathFindingLayer.lineStyle(4, 0x000000, 0.1);

		for (i in 0...world.graph.grid.length)
		{
			for (j in 0...world.graph.grid[i].length)
			{
				if (world.graph.grid[i][j].weight == 0)
				{
					pathFindingLayer.moveTo(i, j, getZFromPoint(i, j));
					pathFindingLayer.lineTo(i + 1, j, getZFromPoint(i + 1, j));
					pathFindingLayer.lineTo(i + 1, j + 1, getZFromPoint(i + 1, j + 1));
					pathFindingLayer.lineTo(i, j + 1, getZFromPoint(i, j + 1));
					pathFindingLayer.lineTo(i, j, getZFromPoint(i, j));
				}
			}
		}*/
	}

	function calculatePathMap()
	{
		for (g in world.graph.grid) for (e in g) e.weight = 1;

		for (i in 0...world.graph.grid.length)
		{
			var row = world.graph.grid[i];

			for (j in 0...row.length)
			{
				var gridIndex = j * (row.length + 1) + i;
				var current = world.heightGridCache[gridIndex];
				var up = world.heightGridCache[i > 0 ? gridIndex - (row.length + 1) : gridIndex];
				var down = world.heightGridCache[i < world.graph.grid.length - 1 ? gridIndex + (row.length + 1) : gridIndex];
				var left = world.heightGridCache[j > 0 ? gridIndex - 1 : gridIndex];
				var right = world.heightGridCache[j < row.length - 2 ? gridIndex + 1 : gridIndex];

				row[j].weight = (
					Math.abs(current - up) > 1.5
					|| Math.abs(current - down) > 1.5
					|| Math.abs(current - left) > 1.5
					|| Math.abs(current - right) > 1.5
				) ? 0 : row[j].weight;
			}
		}

		for (o in model.staticObjects)
		{
			if (o.isPathBlocker)
			{
				var b = o.instance.getBounds().getSize();
				var xMin:Int = cast Math.max(Math.round(o.instance.x - b.x / 2), 0);
				var xMax:Int = cast Math.min(xMin + Math.round(b.x), world.size.x);
				var yMin:Int = cast Math.max(Math.round(o.instance.y - b.y / 2), 0);
				var yMax:Int = cast Math.min(yMin + Math.round(b.y), world.size.x);

				// TODO why is it wrong in the first time?
				if (xMax - xMin > 50) continue;

				for (x in xMin...xMax)
				{
					for (y in yMin...yMax)
					{
						world.graph.grid[x][y].weight = 0;
					}
				}
			}
		}
	}

	function drawDebugRegions():Void
	{
		debugRegions.clear();

		for (r in adventureConfig.worldConfig.regions)
		{
			debugRegions.lineStyle(5, 0x5555AA);

			debugRegions.moveTo(r.x, r.y, 0);
			debugRegions.lineTo(r.x + r.width, r.y, 0);
			debugRegions.lineTo(r.x + r.width, r.y + r.height, 0);
			debugRegions.lineTo(r.x, r.y + r.height, 0);
			debugRegions.lineTo(r.x, r.y, 0);
		}
	}

	function drawDebugInteractionRadius():Void
	{
		debugDetectionRadius.clear();

		for (u in world.units)
		{
			debugDetectionRadius.lineStyle(2, 0xFF0000);
			debugDetectionRadius.moveTo(u.view.x + u.config.attackRange, u.view.y, 0);
			for (i in 0...19) debugDetectionRadius.lineTo(
					u.view.x + u.config.attackRange * Math.cos(i * 20 * (Math.PI / 180)),
					u.view.y + u.config.attackRange * Math.sin(i * 20 * (Math.PI / 180)),
					0
				);

			debugDetectionRadius.lineStyle(2, 0x0000FF);
			debugDetectionRadius.moveTo(u.view.x + u.config.unitSize, u.view.y, 0);
			for (i in 0...19) debugDetectionRadius.lineTo(
					u.view.x + u.config.unitSize * Math.cos(i * 20 * (Math.PI / 180)),
					u.view.y + u.config.unitSize * Math.sin(i * 20 * (Math.PI / 180)),
					0
				);

			debugDetectionRadius.lineStyle(2, 0x00FF00);
			debugDetectionRadius.moveTo(u.view.x + u.config.detectionRange, u.view.y, 0);
			for (i in 0...19) debugDetectionRadius.lineTo(
					u.view.x + u.config.detectionRange * Math.cos(i * 20 * (Math.PI / 180)),
					u.view.y + u.config.detectionRange * Math.sin(i * 20 * (Math.PI / 180)),
					0
				);
		}
	}

	override function update(d:Float)
	{
		if (world == null) return;

		var now = Date.now().getTime();

		world.update(d);
		camera.update(d);
		if (isDisposed) return;

		/*
		drawDebugRegions();
		drawDebugInteractionRadius();*/

		for (i in worldInstances) i.instance.z = GeomUtil3D.getHeightByPosition(world.heightGrid, i.instance.x, i.instance.y);
		/*for (m in modules) if (m.update != null) m.update(d);*/

		//updateCamera(d);

		if (isPathFindingLayerDirty && now - lastPathRenderTime > 100)
		{
			lastPathRenderTime = now;
			isPathFindingLayerDirty = false;
			drawPathFindingLayer();
		}

		//grid.visible = model.showGrid && camDistance < 90;
	}

	function snapPosition(p:Float)
	{
		var pos = model.currentSnap == 0 ? p : Math.round(p / model.currentSnap) * model.currentSnap;
		return Math.max(1, pos);
	}

	public function createNewAdventure(data:InitialAdventureData)
	{
		var result = createNewAdventureRawData(data);

		var savedMaps = SaveUtil.editorData.customAdventures;
		if (savedMaps.length > 0) SaveUtil.editorData.customAdventures[0] = result;
		else SaveUtil.editorData.customAdventures.push(result);

		SaveUtil.editorData.showGrid = model.showGrid;
		SaveUtil.save();

		HppG.changeState(EditorState, [stage, s3d, result, cf]);
	}

	function createNewAdventureRawData(data:InitialAdventureData)
	{
		var result = Json.stringify(
		{
			id: "Local-" + Date.now().getTime(),
			title: "A Great New Adventure",
			subTitle: "",
			description: "",
			editorVersion: Main.editorVersion,
			size: data.size,
			worldConfig: compressor.compressToEncodedURIComponent(Json.stringify(AdventureParser.createDefaultWorld(data)))
		});

		return result;
	}

	public function save()
	{
		var worldSettingsModule = cast(model.getModule(EditorModuleId.MWorldSettings).instance, WorldSettingsModule);
		var skyboxModule = cast(model.getModule(EditorModuleId.MSkybox).instance, SkyboxModule);
		var lightModule = cast(model.getModule(EditorModuleId.MLight).instance, LightModule);
		var terrainModule = cast(model.getModule(EditorModuleId.MTerrain).instance, TerrainModule);
		var cameraModule = cast(model.getModule(EditorModuleId.MCamera).instance, CameraModule);
		var watherModule = cast(model.getModule(EditorModuleId.MWeather).instance, WeatherModule);
		var scriptModule = cast(model.getModule(EditorModuleId.MScript).instance, ScriptModule);

		var terrainLayers = [];

		for (i in 0...world.terrainLayers.length)
		{
			var l = world.terrainLayers[i];
			var shader = l.material.mainPass.getShader(AlphaMap);

			terrainLayers.push(
			{
				textureId: terrainModule.model.layers.toArray()[i].terrainId.value,
				texture: shader != null ? Base64.encode(shader.texture.capturePixels().bytes) : null,
				uvScale: terrainModule.model.layers.toArray()[i].uvScale.value
			});
		}

		var units = [for (u in model.units)
		{
			owner: u.owner,
				   id: u.id,
				   name: u.name,
				   x: u.instance.x,
				   y: u.instance.y,
				   z: u.instance.z,
				   scale: u.instance.scaleX,
				   rotation: u.instance.getRotationQuat().clone(),
				   zOffset: u.zOffset,
		}];

		var staticObjects = [for (o in model.staticObjects)
		{
			id: o.id,
			name: o.name,
			x: o.instance.x,
			y: o.instance.y,
			z: o.instance.z,
			scale: o.instance.scaleX,
			rotation: o.instance.getRotationQuat().clone(),
			zOffset: o.zOffset,
			isPathBlocker: o.isPathBlocker
		}];

		var worldConfig:WorldConfig =
		{
			general: worldSettingsModule.getData(),
			skybox: skyboxModule.getData(),
			light: lightModule.getData(),
			globalWeather: watherModule.getGlobalWeather(),
			regions: model.regions,
			cameras: cameraModule.getCameras(),
			triggers: scriptModule.getScripts(),
			units: units,
			staticObjects: staticObjects,
			terrainLayers: terrainLayers,
			heightMap: Base64.encode(world.heightMap.getPixels().bytes),
			editorLastCamPosition: new Vector(cameraObject.x, cameraObject.y, camera.currentCamDistance)
		};
		var result = Json.stringify(
		{
			id: model.id,
			title: model.title,
			subTitle: model.subTitle,
			description: model.description,
			preloaderImage: model.preloaderImage,
			editorVersion: Main.editorVersion,
			size: model.size,
			worldConfig: compressor.compressToEncodedURIComponent(Json.stringify(worldConfig))
		});

		var savedMaps = SaveUtil.editorData.customAdventures;
		var isNewMap:Bool = true;
		for (i in 0...savedMaps.length)
		{
			if (savedMaps[i].indexOf('"id":"' + model.id + '"') != -1)
			{
				SaveUtil.editorData.customAdventures[i] = result;
				isNewMap = false;
				break;
			}
		}
		if (isNewMap) SaveUtil.editorData.customAdventures.push(result);

		SaveUtil.editorData.showGrid = model.showGrid;
		SaveUtil.save();
		trace(result);

		return result;
	}

	override public function dispose():Void
	{
		super.dispose();

		world.onWorldClick = null;
		world.onWorldMouseDown = null;
		world.onWorldMouseUp = null;
		world.onWorldMouseMove = null;
		world.onWorldWheel = null;
		world.remove();
		world.dispose();
		world = null;

		s2d.removeChildren();
		s3d.removeChildren();

		cf.layout.removeView(LayoutId.EditorUi);

		Actuate.reset();

		isDisposed = true;
	}
}

typedef AssetItem =
{
	var instance:Object;
	var config:AssetConfig;
}

typedef AssetWorldInstance =
{
	var instance(default, never):Object;
	var config:AssetConfig;
	var interactive(default, never):Interactive;
}

typedef EditorAction =
{
	var actionType:EditorActionType;
	@:optional var target:Dynamic;
	@:optional var oldValueFloat:Float;
	@:optional var oldValueQuat:Quat;
	@:optional var oldValueSimplePoint:SimplePoint;
	@:optional var newValueFloat:Float;
	@:optional var newValueQuat:Quat;
	@:optional var newValueSimplePoint:SimplePoint;
	@:optional var oldValueString:String;
	@:optional var newValueString:String;
}

enum EditorActionType
{
	Create;
	Delete;
	Move;
	Rotate;
	Scale;
}

typedef EditorCore =
{
	public var moduleSelector:ModuleSelector;
	public var adventureConfig:AdventureConfig;
	public var snapPosition:Float->Float;
	public var model:EditorModel;
	public var s2d:h2d.Scene;
	public var s3d:h3d.scene.Scene;
	public var world:GameWorld;
	public var logAction:EditorAction->Void;
	public var dialogManager:EditorDialogManager;
	public var updateGrid:Void->Void;
	public var isPathFindingLayerDirty:Bool;
	public var jumpCamera:Float->Float->Float->Void;
	public var camera:ActionCamera;
	public var camAngle:Float;
	public var camRotation:Float;
}

typedef InitialAdventureData =
{
	var size:SimplePoint;
	var defaultTerrainTextureId:String;
}