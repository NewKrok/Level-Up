package levelup.editor;

import Main.CoreFeatures;
import coconut.ui.RenderResult;
import format.jpg.Data;
import format.jpg.Writer;
import h2d.Scene;
import h3d.Quat;
import h3d.Vector;
import h3d.mat.BlendMode;
import h3d.mat.Data.Face;
import h3d.mat.Material;
import h3d.mat.Pass;
import h3d.mat.Texture;
import h3d.pass.DefaultShadowMap;
import h3d.prim.Grid;
import h3d.scene.Graphics;
import h3d.scene.Interactive;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.shader.AlphaMap;
import h3d.shader.ColorMult;
import h3d.shader.FixedColor;
import haxe.Json;
import haxe.crypto.Base64;
import haxe.io.BytesOutput;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.BitmapData;
import hxd.Event;
import hxd.Key;
import hxd.Window;
import hxd.clipper.Rect;
import js.Browser;
import levelup.Asset;
import levelup.UnitData;
import levelup.component.layout.LayoutView.LayoutId;
import levelup.editor.EditorModel.ToolState;
import levelup.editor.dialog.EditorDialogManager;
import levelup.editor.html.EditorUi;
import levelup.editor.html.NewAdventureDialog;
import levelup.editor.module.camera.CameraModule;
import levelup.editor.module.dayandnight.DayAndNightModule;
import levelup.editor.module.heightmap.HeightMapModule;
import levelup.editor.module.region.RegionModule;
import levelup.editor.module.script.ScriptModule;
import levelup.editor.module.terrain.TerrainChooser;
import levelup.editor.module.terrain.TerrainModule;
import levelup.game.GameState;
import levelup.game.GameState.StaticObjectConfig;
import levelup.game.GameState.WorldConfig;
import levelup.game.GameWorld;
import levelup.game.GameWorld.Region;
import levelup.game.unit.BaseUnit;
import levelup.shader.Opacity;
import levelup.shader.ForcedZIndex;
import levelup.util.AdventureParser;
import levelup.util.GeomUtil3D;
import levelup.util.SaveUtil;
import motion.Actuate;
import tink.pure.List;
import tink.state.State;
import lzstring.LZString;

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

	var editorUi:EditorUi;
	var dialogManager:EditorDialogManager;
	var views:Map<EditorViewId, RenderResult> = [];
	var modules:Array<EditorModule> = [];

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

	var cameraObject:Object = new Object();
	var currentCameraPoint: { x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var currentCamDistance:Float = 0;
	var cameraSpeed:Vector = new Vector(10, 10, 5);
	var camAngle:Float = Math.PI - Math.PI / 4;
	var camDistance:Float = 30;

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

		cf.adventureLoader.load(rawMap, true).handle(o -> switch (o)
		{
			case Success(result):
				adventureConfig = result.config;
				onLoaded(rawMap);

			case Failure(e):
		});
	}

	function onLoaded(rawMap)
	{
		model = new EditorModel(
		{
			title: adventureConfig.title,
			subTitle: adventureConfig.subTitle,
			description: adventureConfig.description,
			size: adventureConfig.size,
			startingTime: adventureConfig.worldConfig.startingTime,
			sunAndMoonOffsetPercent: adventureConfig.worldConfig.sunAndMoonOffsetPercent,
			dayColor: adventureConfig.worldConfig.dayColor,
			nightColor: adventureConfig.worldConfig.nightColor,
			sunsetColor: adventureConfig.worldConfig.sunsetColor,
			dawnColor: adventureConfig.worldConfig.dawnColor,
			regions: adventureConfig.worldConfig.regions,
			triggers: adventureConfig.worldConfig.triggers,
			units: [],
			staticObjects: [],
			showGrid: SaveUtil.editorData.showGrid,
			defaultTerrainIdForNewAdventure: TerrainAssets.terrains[0].id
		});

		model.observables.startingTime.bind(v -> world.setTime(v));
		model.observables.sunAndMoonOffsetPercent.bind(v -> world.setSunAndMoonOffsetPercent(v));
		model.observables.dayColor.bind(v -> world.setDayColor(v));
		model.observables.nightColor.bind(v -> world.setNightColor(v));
		model.observables.sunsetColor.bind(v -> world.setSunsetColor(v));
		model.observables.dawnColor.bind(v -> world.setDawnColor(v));
		model.observables.showGrid.bind(v -> v ? showGrid() : hideGrid());
		model.observables.toolState.bind(v ->
		{
			if (v == ToolState.Library) enableAssetInteractives();
			else
			{
				disableAssetInteractives();
				createPreview(null);
			}
		});

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
			for (m in modules) if (m.onWorldClick != null) m.onWorldClick(e);
		}
		world.onWorldMouseDown = e ->
		{
			for (m in modules) if (m.onWorldMouseDown != null) m.onWorldMouseDown(e);

			if (e.button == 0)
			{
				dragStartObjectPoint.x = cameraObject.x;
				dragStartObjectPoint.y = cameraObject.y;
				isMouseDrawActive = true;
			}
			else if (e.button == 1)
			{
				isMapDragActive = true;
				cameraDragStartPoint.x = e.relX;
				cameraDragStartPoint.y = e.relY;
				dragStartObjectPoint.x = cameraObject.x;
				dragStartObjectPoint.y = cameraObject.y;
			}
		}
		world.onWorldMouseUp = e ->
		{
			for (m in modules) if (m.onWorldMouseUp != null) m.onWorldMouseUp(e);

			if (e.button == 0)
			{
				if (model.toolState == ToolState.Library && previewInstance == null) enableAssetInteractives();

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
			}
		}
		world.onWorldMouseMove = e ->
		{
			for (m in modules) if (m.onWorldMouseMove != null) m.onWorldMouseMove(e);

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
				cameraObject.x = dragStartObjectPoint.x + (cameraDragStartPoint.x - e.relX) * 2;
				cameraObject.y = dragStartObjectPoint.y + (cameraDragStartPoint.y - e.relY) * 2;
			}
			else if (isMouseDrawActive)
			{

			}

			if (previewInstance != null || draggedInstance != null) isPathFindingLayerDirty = true;
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
					camAngle += e.wheelDelta < 0 ? camStep : -camStep;
					camAngle = Math.max(camAngle, camStep * 32);
					camAngle = Math.min(camAngle, camStep * 62);
				}
			}
			else
			{
				for (m in modules) if (m.onWorldWheel != null) m.onWorldWheel(e);

				camDistance += e.wheelDelta * 8;
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

		if (adventureConfig.worldConfig.editorLastCamPosition == null) jumpCamera(10, 10);
		else
		{
			camDistance = adventureConfig.worldConfig.editorLastCamPosition.z;
			jumpCamera(adventureConfig.worldConfig.editorLastCamPosition.x, adventureConfig.worldConfig.editorLastCamPosition.y);
		}

		editorUi = new EditorUi(
		{
			backToLobby: () -> HppG.changeState(GameState, [stage, s3d, MapData.getRawMap("lobby")]),
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
			testRun: () -> HppG.changeState(GameState, [stage, s3d, save(), { isTestRun: true }]),
			previewRequest: createPreview,
			environmentsList: List.fromArray(Asset.environment),
			propsList: List.fromArray(Asset.props),
			buildingList: List.fromArray(Asset.buildings),
			unitsList: List.fromArray(Asset.units),
			selectedWorldAsset: selectedWorldAsset,
			model: model,
			getModuleView: getModuleView
		});
		cf.layout.registerView(LayoutId.EditorUi, editorUi.reactify());

		modules.push(cast new TerrainModule(cast this));
		modules.push(cast new HeightMapModule(cast this));
		modules.push(cast new DayAndNightModule(cast this));
		modules.push(cast new RegionModule(cast this));
		modules.push(cast new ScriptModule(cast this));
		modules.push(cast new CameraModule(cast this));

		createGrid();

		Window.getInstance().addEventTarget(onKeyEvent);
		isLevelLoaded = true;
	}

	function getModule(c) return modules.filter(m ->Std.is(m, c))[0];

	public function registerView(id:EditorViewId, view:RenderResult)
	{
		views.set(id, view);
	}

	function getModuleView(id:EditorViewId)
	{
		return views.get(id);
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

				case Key.UP | Key.W: cameraObject.x += 5;
				case Key.DOWN | Key.S: cameraObject.x -= 5;
				case Key.LEFT | Key.A: cameraObject.y -= 5;
				case Key.RIGHT | Key.D: cameraObject.y += 5;

				case Key.SPACE if (previewInstance != null): editorUi.removeSelection();

				case Key.ESCAPE if (selectedWorldAsset.value != null): selectedWorldAsset.set(null);

				case Key.ESCAPE if (previewInstance != null):
					var now = Date.now().getTime();
					if (now - lastEscPressTime < 500)
					{
						editorUi.removeSelection();
						return;
					}
					lastEscPressTime = now;

					previewInstance.setScale(selectedAssetConfig.modelScale);
					previewInstance.setRotation(0, 0, 0);

				case Key.ESCAPE if (previewInstance == null):
					var now = Date.now().getTime();
					if (now - lastEscPressTime < 500)
					{
						camDistance = 30;
						camAngle = Math.PI - Math.PI / 4;
						return;
					}
					lastEscPressTime = now;

				case Key.C if (selectedWorldAsset.value != null):
					createPreview(selectedWorldAsset.value.config);
					previewInstance.setScale(selectedWorldAsset.value.instance.scaleX);
					previewInstance.setRotationQuat(selectedWorldAsset.value.instance.getRotationQuat().clone());

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

		/*pathFindingLayer.clear();
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
				var current = world.levellingHeightGridCache[gridIndex];
				var up = world.levellingHeightGridCache[i > 0 ? gridIndex - (row.length + 1) : gridIndex];
				var down = world.levellingHeightGridCache[i < world.graph.grid.length - 1 ? gridIndex + (row.length + 1) : gridIndex];
				var left = world.levellingHeightGridCache[j > 0 ? gridIndex - 1 : gridIndex];
				var right = world.levellingHeightGridCache[j < row.length - 2 ? gridIndex + 1 : gridIndex];

				row[j].weight = (current - up != 0 || current - down != 0 || current - left != 0 || current - right != 0) ? 0 : row[j].weight;
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
		if (isDisposed) return;

		/*
		drawDebugRegions();
		drawDebugInteractionRadius();*/

		for (i in worldInstances) i.instance.z = GeomUtil3D.getHeightByPosition(world.heightGrid, i.instance.x, i.instance.y);
		for (m in modules) if (m.update != null) m.update(d);

		updateCamera(d);

		if (isPathFindingLayerDirty && now - lastPathRenderTime > 100)
		{
			lastPathRenderTime = now;
			isPathFindingLayerDirty = false;
			drawPathFindingLayer();
		}

		//grid.visible = model.showGrid && camDistance < 90;
	}

	function updateCamera(d:Float)
	{
		camDistance = Math.max(10, camDistance);
		camDistance = Math.min(300, camDistance);

		cameraObject.x = Math.min(Math.max(cameraObject.x, 0), adventureConfig.size.x);
		currentCameraPoint.x += (cameraObject.x - currentCameraPoint.x) / cameraSpeed.x * d * 30;

		cameraObject.y = Math.min(Math.max(cameraObject.y, 0), adventureConfig.size.y);
		currentCameraPoint.y += (cameraObject.y - currentCameraPoint.y) / cameraSpeed.y * d * 30;

		var distanceOffset = (camDistance - currentCamDistance) / cameraSpeed.z * d * 30;
		if (Math.abs(distanceOffset) < 0.001) currentCamDistance = camDistance;
		else currentCamDistance += distanceOffset;

		s3d.camera.target.set(currentCameraPoint.x, currentCameraPoint.y);

		s3d.camera.pos.set(
			currentCameraPoint.x + currentCamDistance * Math.cos(camAngle),
			currentCameraPoint.y,
			cameraObject.z + currentCamDistance * Math.sin(camAngle)
		);
	}

	function jumpCamera(x:Float, y:Float, z:Float = null)
	{
		cameraObject.x = x;
		cameraObject.y = y;

		currentCameraPoint.x = x;
		currentCameraPoint.y = y;
		if (z != null) currentCameraPoint.z = z;

		currentCamDistance = camDistance;

		updateCamera(0);
	}

	function snapPosition(p:Float)
	{
		var pos = model.currentSnap == 0 ? p : Math.round(p / model.currentSnap) * model.currentSnap;
		return Math.max(1, pos);
	}

	public function createNewAdventure(data:InitialAdventureData)
	{
		var rawHeightMap = new BitmapData(Std.int(data.size.x), Std.int(data.size.y));
		rawHeightMap.fill(0, 0, Std.int(data.size.x), Std.int(data.size.y), 0x888888);

		var worldConfig:WorldConfig =
		{
			regions: [],
			triggers: [],
			units: [],
			staticObjects: [],
			terrainLayers: [{ textureId: data.defaultTerrainTextureId, texture: null, uvScale: 1 }],
			heightMap: Base64.encode(rawHeightMap.getPixels().bytes),
			editorLastCamPosition: new Vector(data.size.x / 2, data.size.y / 2, data.size.y / 2)
		};
		var result = Json.stringify(
		{
			name: "A Great New Adventure",
			editorVersion: Main.editorVersion,
			size: data.size,
			worldConfig: compressor.compressToEncodedURIComponent(Json.stringify(worldConfig))
		});

		var savedMaps = SaveUtil.editorData.customMaps;
		if (savedMaps.length > 0) SaveUtil.editorData.customMaps[0] = result;
		else SaveUtil.editorData.customMaps.push(result);

		SaveUtil.editorData.showGrid = model.showGrid;
		SaveUtil.save();

		HppG.changeState(EditorState, [stage, s3d, result, cf]);
	}

	public function save()
	{
		var terrainLayers = [];
		var terrainModule = cast(getModule(TerrainModule), TerrainModule);
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

		var regions = [for (r in model.regions)
		{
			id: r.id,
			name: r.name,
			x: Math.floor(r.instance.x),
			y: Math.floor(r.instance.y),
			width: cast(r.instance.primitive, Grid).width,
			height: cast(r.instance.primitive, Grid).height
		}];

		var worldConfig:WorldConfig =
		{
			startingTime: model.startingTime,
			sunAndMoonOffsetPercent: model.sunAndMoonOffsetPercent,
			dayColor: model.dayColor,
			nightColor: model.nightColor,
			sunsetColor: model.sunsetColor,
			dawnColor: model.dawnColor,
			regions: regions,
			triggers: model.triggers,
			units: units,
			staticObjects: staticObjects,
			terrainLayers: terrainLayers,
			heightMap: Base64.encode(world.heightMap.getPixels().bytes),
			levellingHeightMap: Base64.encode(world.levellingHeightMap.getPixels().bytes),
			editorLastCamPosition: new Vector(cameraObject.x, cameraObject.y, currentCamDistance)
		};
		var result = Json.stringify(
		{
			title: model.title,
			subTitle: model.subTitle,
			description: model.description,
			editorVersion: Main.editorVersion,
			size: model.size,
			worldConfig: compressor.compressToEncodedURIComponent(Json.stringify(worldConfig))
		});

		var savedMaps = SaveUtil.editorData.customMaps;
		var isNewMap:Bool = true;
		for (i in 0...savedMaps.length)
		{
			if (savedMaps[i].indexOf('"title":"' + model.title + '"') != -1)
			{
				SaveUtil.editorData.customMaps[i] = result;
				isNewMap = false;
				break;
			}
		}
		trace(result);
		if (isNewMap) SaveUtil.editorData.customMaps.push(result);

		SaveUtil.editorData.showGrid = model.showGrid;
		SaveUtil.save();

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

typedef EditorModule =
{
	var onWorldClick:Event->Void;
	var onWorldMouseDown:Event->Void;
	var onWorldMouseUp:Event->Void;
	var onWorldMouseMove:Event->Void;
	var onWorldWheel:Event->Void;
	var update:Float->Void;
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

enum EditorViewId
{
	VDialogManager;
	VTerrainModule;
	VHeightMapModule;
	VDayAndNightModule;
	VRegionModule;
	VCameraModule;
	VWeatherModule;
	VScriptModule;
	VTeamModule;
}

typedef EditorCore =
{
	public var snapPosition:Float->Float;
	public var model:EditorModel;
	public var s2d:h2d.Scene;
	public var s3d:h3d.scene.Scene;
	public var world:GameWorld;
	public var logAction:EditorAction->Void;
	public var registerView:EditorViewId->RenderResult->Void;
	public var dialogManager:EditorDialogManager;
	public var updateGrid:Void->Void;
	public var isPathFindingLayerDirty:Bool;
}

typedef InitialAdventureData =
{
	var size:SimplePoint;
	var defaultTerrainTextureId:String;
}