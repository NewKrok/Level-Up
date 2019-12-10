package levelup.editor;

import coconut.ui.RenderResult;
import h2d.Scene;
import h3d.Quat;
import h3d.Vector;
import h3d.mat.BlendMode;
import h3d.mat.Data.Face;
import h3d.pass.DefaultShadowMap;
import h3d.prim.Grid;
import h3d.prim.ModelCache;
import h3d.scene.Graphics;
import h3d.scene.Interactive;
import h3d.scene.Object;
import h3d.scene.fwd.DirLight;
import h3d.shader.ColorMult;
import haxe.Json;
import haxe.crypto.Base64;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import hxd.Key;
import hxd.Window;
import hxd.clipper.Rect;
import js.Browser;
import levelup.Asset;
import levelup.editor.EditorModel.ToolState;
import levelup.editor.dialog.EditorDialogManager;
import levelup.editor.html.EditorUi;
import levelup.editor.module.heightmap.HeightMapModule;
import levelup.editor.module.terrain.TerrainModule;
import levelup.game.GameState;
import levelup.game.GameState.StaticObjectConfig;
import levelup.game.GameState.WorldConfig;
import levelup.game.GameState.WorldEntity;
import levelup.game.GameWorld;
import levelup.game.GameWorld.Region;
import levelup.game.unit.BaseUnit;
import levelup.shader.AlphaMask;
import levelup.shader.Opacity;
import levelup.shader.TopLayer;
import levelup.util.AdventureParser;
import levelup.util.GeomUtil3D;
import levelup.util.SaveUtil;
import motion.Actuate;
import react.ReactDOM;
import tink.pure.List;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorState extends Base2dState
{
	public var id(default, never):UInt = Math.floor(Math.random() * 1000);

	var world:GameWorld;
	var mapConfig:WorldConfig;
	var model:EditorModel;

	var s2d:h2d.Scene;
	var s3d:h3d.scene.Scene;

	var editorUi:EditorUi;
	var dialogManager:EditorDialogManager;
	var views:Map<EditorViewId, RenderResult> = [];
	var modules:Array<EditorModule> = [];

	var gridParts:Array<Graphics> = [];
	var gridBlockCount = 5;

	var pathFindingLayer:Graphics;

	var debugRegions:Graphics;
	var debugUnitPath:Graphics;
	var debugDetectionRadius:Graphics;

	var selectionCircle:Graphics;
	var isDisposed:Bool = false;

	var isMapDragActive:Bool = false;
	var isMouseDrawActive:Bool = false;
	var cameraDragStartPoint:SimplePoint = { x: 0, y: 0 };
	var dragStartObjectPoint:SimplePoint = { x: 0, y: 0 };

	var cameraObject:Object = new Object();
	var currentCameraPoint:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var currentCamDistance:Float = 0;
	var cameraSpeed:Vector = new Vector(10, 10, 5);
	var camAngle:Float = Math.PI - Math.PI / 4;
	var camDistance:Float = 30;

	var cache:ModelCache = new ModelCache();
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

	public function new(stage:Base2dStage, s2d:h2d.Scene, s3d:h3d.scene.Scene, rawMap:String)
	{
		super(stage);

		this.s3d = s3d;
		this.s2d = s2d;
		mapConfig = AdventureParser.loadLevel(rawMap);

		model = new EditorModel(
		{
			name: mapConfig.name,
			size: mapConfig.size,
			baseTerrainId: mapConfig.baseTerrainId,
			pathFindingMap: mapConfig.pathFindingMap,
			regions: mapConfig.regions,
			triggers: mapConfig.triggers,
			units: [],
			staticObjects: [],
		});

		model.observables.baseTerrainId.bind(id -> world.changeBaseTerrain(id));
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
		pathFindingLayer.z = 0.11;

		debugRegions = new Graphics(s3d);
		debugRegions.z = 0.2;
		debugUnitPath = new Graphics(s3d);
		debugUnitPath.z = 0.2;
		debugDetectionRadius = new Graphics(s3d);
		debugDetectionRadius.z = 0.2;

		world = new GameWorld(s3d, mapConfig, 1, 64, 64, s3d);
		world.done();

		var dirLight = new DirLight(null, s3d);
		dirLight.setDirection(new Vector(3, 1, -2));
		dirLight.color = new Vector(0.9, 0.9, 0.9);

		s3d.lightSystem.ambientLight.setColor(0x444444);

		var shadow:h3d.pass.DefaultShadowMap = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.power = 20;
		shadow.blur.radius = 5;
		shadow.bias *= 0.1;
		shadow.color.set(0.4, 0.4, 0.4);

		world.onWorldClick = e ->
		{
			for (m in modules) m.onWorldClick(e);
		}
		world.onWorldMouseDown = e ->
		{
			for (m in modules) m.onWorldMouseDown(e);

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
			for (m in modules) m.onWorldMouseUp(e);

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
					updateSelectionCircle();
				}
				else if (GeomUtil.getDistance({ x: e.relX, y: e.relY }, cameraDragStartPoint) < 0.2)
				{
					selectedWorldAsset.set(null);
					updateSelectionCircle();
				}

				if (draggedInstance != null)
				{
					logAction({
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
			for (m in modules) m.onWorldMouseMove(e);

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

				updateSelectionCircle();
			}
			else if (isMapDragActive)
			{
				cameraObject.x = dragStartObjectPoint.x + (cameraDragStartPoint.x - e.relX) * 2;
				cameraObject.y = dragStartObjectPoint.y + (cameraDragStartPoint.y - e.relY) * 2;
			}
			else if (isMouseDrawActive)
			{

			}

			if (previewInstance != null || draggedInstance != null) drawPathFindingLayer();
		}
		world.onWorldWheel = e ->
		{
			for (m in modules) m.onWorldWheel(e);

			camDistance += e.wheelDelta * 8;
		}

		for (o in mapConfig.staticObjects.concat([]))
		{
			var config = Asset.getAsset(o.id);
			if (config != null) createAsset(Asset.getAsset(o.id), o.x, o.y, o.z, o.scale == null ? config.scale : o.scale, o.rotation);
			else trace("Couldn't create asset with id: " + o.id);
		}

		for (o in mapConfig.units.concat([]))
		{
			var config = Asset.getAsset(o.id);
			if (config != null) createUnit(Asset.getAsset(o.id), o.x, o.y, o.z, o.scale == null ? config.scale : o.scale, o.rotation, o.owner);
			else trace("Couldn't create unit with id: " + o.id);
		}

		s3d.addChild(cameraObject);
		s3d.camera.target.x = s3d.camera.pos.x;
		s3d.camera.target.y = s3d.camera.pos.y;

		if (mapConfig.editorLastCamPosition == null) jumpCamera(10, 10);
		else
		{
			camDistance = mapConfig.editorLastCamPosition.z;
			jumpCamera(mapConfig.editorLastCamPosition.x, mapConfig.editorLastCamPosition.y);
		}

		editorUi = new EditorUi({
			backToLobby: () -> HppG.changeState(GameState, [stage, s3d, MapData.getRawMap("lobby")]),
			save: () -> save(),
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
		ReactDOM.render(editorUi.reactify(), Browser.document.getElementById("native-ui"));

		modules.push(cast new TerrainModule(cast this));
		modules.push(cast new HeightMapModule(cast this));

		selectionCircle = new Graphics(world);

		createGrid();

		Window.getInstance().addEventTarget(onKeyEvent);
		isLevelLoaded = true;
	}

	function updateSelectionCircle()
	{
		if (selectedWorldAsset == null)
		{
			selectionCircle.visible = false;
		}
		else
		{
			selectionCircle.visible = true;
			selectionCircle.clear();
			selectionCircle.lineStyle(4, 0xFFFFFF);
			var angle = 0.0;
			var b = selectedWorldAsset.value.instance.getMeshes()[0].getBounds();
			var size = (b.xMax > b.yMax ? b.xMax : b.yMax) / 25;
			var piece = Std.int(12 + size / 10 * 10);

			trace("TODO: WHAT IS THE PROBLEM WITH THE SIZE?!");

			for (i in 0...piece)
			{
				angle += Math.PI * 2 / (piece - 1);
				var xPos = selectedWorldAsset.value.instance.x + Math.cos(angle) * size / 2;
				var yPos = selectedWorldAsset.value.instance.y + Math.sin(angle) * size / 2;
				var zPos = 0.1 + GeomUtil3D.getHeightByPosition(world.heightGrid, xPos, yPos);

				if (i == 0) selectionCircle.moveTo(xPos, yPos, zPos);
				else selectionCircle.lineTo(xPos, yPos, zPos);
			}
		}
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
		var instance:Object = cache.loadModel(config.model);
		if (config.hasTransparentTexture != null && config.hasTransparentTexture) for (m in instance.getMaterials()) m.textureShader.killAlpha = true;

		var interactive = new Interactive(instance.getCollider(), world);

		if (config.race == null)
		{
			model.staticObjects.push({
				id: config.id,
				name: config.name,
				x: x,
				y: y,
				z: z,
				zOffset: config.zOffset,
				scale: scale,
				rotation: rotation
			});

			world.graph.grid[Math.floor(x)][Math.floor(y)].weight = 0;
			drawPathFindingLayer();
		}
		else
		{
			model.units.push({
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

		worldInstances.push({
			instance: instance,
			config: config,
			interactive: interactive
		});

		if (config.hasAnimation != null && config.hasAnimation)
		{
			instance.playAnimation(cache.loadAnimation(config.model));
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

		var colorShader = new ColorMult();
		colorShader.color = new Vector(1, 1, 0, 0.2);

		interactive.onOver = e -> for (m in instance.getMaterials()) m.mainPass.addShader(colorShader);
		interactive.onOut = e -> for (m in instance.getMaterials()) m.mainPass.removeShader(colorShader);

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
					model.isXDragLocked = !model.isXDragLocked;
					if (draggedInstance != null) dragInstanceWorldStartPoint = null;

				case Key.SHIFT:
					model.isYDragLocked = !model.isYDragLocked;
					if (draggedInstance != null) dragInstanceWorldStartPoint = null;

				case Key.UP | Key.W if (previewInstance != null):
					previewInstance.scale(1.1);
				case Key.DOWN | Key.S if (previewInstance != null):
					previewInstance.scale(0.9);

				case Key.UP | Key.W if (selectedInstance != null):
					logAction({
						actionType: EditorActionType.Scale,
						target: selectedInstance,
						oldValueFloat: selectedInstance.scaleX,
						newValueFloat: selectedInstance.scaleX * 0.9
					});
					selectedInstance.scale(1.1);
					editorUi.forceUpdateSelectedUser();
				case Key.DOWN | Key.S if (selectedInstance != null):
					logAction({
						actionType: EditorActionType.Scale,
						target: selectedInstance,
						oldValueFloat: selectedInstance.scaleX,
						newValueFloat: selectedInstance.scaleX * 1.1
					});
					selectedInstance.scale(0.9);
					editorUi.forceUpdateSelectedUser();

				case Key.LEFT | Key.A if (previewInstance != null):
					previewInstance.rotate(0, 0, Math.PI / 8);
				case Key.RIGHT | Key.D if (!hadActiveCommandWithCtrl && previewInstance != null):
					previewInstance.rotate(0, 0, -Math.PI / 8);

				case Key.LEFT | Key.A if (selectedInstance != null):
					var prevQ = selectedInstance.getRotationQuat().clone();
					selectedInstance.rotate(0, 0, Math.PI / 8);
					logAction({
						actionType: EditorActionType.Rotate,
						target: selectedInstance,
						oldValueQuat: prevQ,
						newValueQuat: selectedInstance.getRotationQuat().clone()
					});
					editorUi.forceUpdateSelectedUser();

				case Key.RIGHT | Key.D if (!hadActiveCommandWithCtrl && selectedInstance != null):
					var prevQ = selectedInstance.getRotationQuat().clone();
					selectedInstance.rotate(0, 0, -Math.PI / 8);
					logAction({
						actionType: EditorActionType.Rotate,
						target: selectedInstance,
						oldValueQuat: prevQ,
						newValueQuat: selectedInstance.getRotationQuat().clone()
					});
					editorUi.forceUpdateSelectedUser();

				case Key.UP | Key.W: cameraObject.x += 5;
				case Key.DOWN | Key.S: cameraObject.x -= 5;
				case Key.LEFT | Key.A: cameraObject.y -= 5;
				case Key.RIGHT | Key.D: cameraObject.y += 5;

				case Key.SPACE if (previewInstance != null): editorUi.removeSelection();
				case Key.ESCAPE if (previewInstance != null):
					var now = Date.now().getTime();
					if (now - lastEscPressTime < 500)
					{
						editorUi.removeSelection();
						return;
					}
					lastEscPressTime = now;

					previewInstance.setScale(selectedAssetConfig.scale);
					previewInstance.setRotation(0, 0, 0);

				case Key.ESCAPE if (selectedWorldAsset.value != null): selectedWorldAsset.set(null);

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
			previewInstance = cache.loadModel(selectedAssetConfig.model);
			if (asset.hasTransparentTexture != null && asset.hasTransparentTexture) for (m in previewInstance.getMaterials()) m.textureShader.killAlpha = true;

			if (selectedAssetConfig.hasAnimation != null && selectedAssetConfig.hasAnimation)
			{
				previewInstance.playAnimation(cache.loadAnimation(selectedAssetConfig.model));
			}
			previewInstance.setScale(selectedAssetConfig.scale);
			previewInstance.setRotation(0, 0, 0);
			if (selectedAssetConfig.zOffset != null) previewInstance.z = selectedAssetConfig.zOffset;

			s3d.addChild(previewInstance);
			disableAssetInteractives();
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
		switch(a.actionType)
		{
			case EditorActionType.Scale:
				a.target.setScale(useNewValue ? a.newValueFloat : a.oldValueFloat);

			case EditorActionType.Rotate:
				a.target.setRotationQuat(useNewValue ? a.newValueQuat : a.oldValueQuat);

			case EditorActionType.Move:
				a.target.setPosition(
					useNewValue ? a.newValueSimplePoint.x : a.oldValueSimplePoint.x,
					useNewValue ? a.newValueSimplePoint.y : a.oldValueSimplePoint.y,
					a.target.z
				);

			case EditorActionType.ChangeBaseTerrain:
				model.baseTerrainId = useNewValue ? a.newValueString : a.oldValueString;

			case _:
		}
	}

	function updateGrid(r:Rect)
	{
		var w = Math.floor(mapConfig.size.y / gridBlockCount);
		var h = Math.floor(mapConfig.size.x / gridBlockCount);
		var x = Math.floor(r.left / h);
		var y = Math.floor(r.bottom / w);

		if (Math.floor(y * gridBlockCount + x) >= gridParts.length) x--;

		var indexes = [];

		var indexLT = Math.floor(y * gridBlockCount + x);
		if (indexLT > -1 && indexLT < gridParts.length) indexes.push(indexLT);

		var indexRT = Math.floor(y * gridBlockCount + x + 1);
		if (indexRT > -1 && indexRT < gridParts.length && indexRT != indexLT) indexes.push(indexRT);

		var indexLB = Math.floor((y - 1) * gridBlockCount + x);
		if (indexLB > -1 && indexLB != indexLT) indexes.push(indexLB);

		var indexRB = Math.floor((y - 1) * gridBlockCount + x + 1);
		if (indexRB > -1 && indexRB < gridParts.length && indexRB != indexLB && indexRB != indexLT) indexes.push(indexRB);

		for (index in indexes)
		{
			var g = gridParts[index];
			g.clear();
			g.lineStyle(2, 0x999900, 1);

			for (i in 0...w)
			{
				for (j in 0...h)
				{
					g.moveTo(i, j, getZFromPoint(g.x + i, g.y + j));
					g.lineTo(i, j + 1, getZFromPoint(g.x + i, g.y + j + 1));

					g.moveTo(i, j, getZFromPoint(g.x + i, g.y + j));
					g.lineTo(i + 1, j, getZFromPoint(g.x + i + 1, g.y + j));
				}
			}
		}
	}

	function createGrid()
	{
		for (i in 0...gridBlockCount * gridBlockCount)
		{
			var grid = new Graphics(s3d);
			grid.material.mainPass.addShader(new TopLayer());
			gridParts.push(grid);
		}

		var w = Math.floor(mapConfig.size.x / gridBlockCount);
		var h = Math.floor(mapConfig.size.y / gridBlockCount);
		var x = 0;
		var y = 0;
		for (g in gridParts)
		{
			g.clear();
			g.lineStyle(2, 0x999900, 1);
			g.x = x * w;
			g.y = y * h;

			for (i in 0...w)
			{
				for (j in 0...h)
				{
					g.moveTo(i, j, getZFromPoint(g.x + i, g.y + j));
					g.lineTo(i, j + 1, getZFromPoint(g.x + i, g.y + j + 1));

					g.moveTo(i, j, getZFromPoint(g.x + i, g.y + j));
					g.lineTo(i + 1, j, getZFromPoint(g.x + i + 1, g.y + j));
				}
			}

			x++;
			if (x == gridBlockCount)
			{
				y++;
				x = 0;
			}
		}
	}

	function getZFromPoint(targetX, targetY)
	{
		var targetGrid:Grid = cast world.terrainLayers[0].primitive;

		for (p in targetGrid.points) if (targetX == p.x && targetY == p.y) return p.z;

		return 0;
	}

	function showGrid() for (g in gridParts) g.visible = true;
	function hideGrid() for (g in gridParts) g.visible = false;

	function drawPathFindingLayer():Void
	{
		pathFindingLayer.clear();
		pathFindingLayer.lineStyle(4, 0x000000, 0.1);

		for (i in 0...world.graph.grid.length)
		{
			for (j in 0...world.graph.grid[i].length)
			{
				if (world.graph.grid[i][j].weight == 0)
				{
					pathFindingLayer.moveTo(i, j, 0);
					pathFindingLayer.lineTo(i + 1, j, 0);
					pathFindingLayer.lineTo(i + 1, j + 1, 0);
					pathFindingLayer.lineTo(i, j + 1, 0);
					pathFindingLayer.lineTo(i, j, 0);
				}
			}
		}
	}

	function drawDebugRegions():Void
	{
		debugRegions.clear();

		for (r in mapConfig.regions)
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

		world.update(d);
		if (isDisposed) return;

		/*
		drawDebugRegions();
		drawDebugInteractionRadius();*/

		for (i in worldInstances) i.instance.z = GeomUtil3D.getHeightByPosition(world.heightGrid, i.instance.x, i.instance.y);
		for (m in modules) m.update(d);

		updateCamera(d);

		//grid.visible = model.showGrid && camDistance < 90;
	}

	function updateCamera(d:Float)
	{
		camDistance = Math.max(10, camDistance);
		camDistance = Math.min(300, camDistance);

		cameraObject.x = Math.min(Math.max(cameraObject.x, 0), mapConfig.size.x);
		currentCameraPoint.x += (cameraObject.x - currentCameraPoint.x) / cameraSpeed.x * d * 30;

		cameraObject.y = Math.min(Math.max(cameraObject.y, 0), mapConfig.size.y);
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

	public function save()
	{
		var terrainLayers = [];
		var terrainModule = cast(getModule(TerrainModule), TerrainModule);
		for (i in 1...world.terrainLayers.length)
		{
			var l = world.terrainLayers[i];
			var shader = l.material.mainPass.getShader(AlphaMask);

			if (shader != null) terrainLayers.push({
				textureId: terrainModule.model.layers.toArray()[i].terrainId.value,
				texture: Base64.encode(shader.texture.capturePixels().bytes)
			});
		}

		var units = [for (u in model.units) {
			owner: u.owner,
			id: u.id,
			name: u.name,
			x: u.instance.x,
			y: u.instance.y,
			z: u.instance.z,
			zOffset: u.zOffset,
			scale: u.instance.scaleX,
			rotation: u.instance.getRotationQuat().clone(),
		}];

		var worldConfig:WorldConfig = {
			name: model.name,
			size: model.size,
			baseTerrainId: model.baseTerrainId,
			pathFindingMap: model.pathFindingMap,
			regions: model.regions,
			triggers: model.triggers,
			units: units,
			staticObjects: model.staticObjects,
			terrainLayers: terrainLayers,
			heightMap: Base64.encode(world.heightMap.getPixels().bytes),
			editorLastCamPosition: new Vector(cameraObject.x, cameraObject.y, currentCamDistance)
		};
		var result = Json.stringify(worldConfig);

		var savedMaps = SaveUtil.editorData.customMaps;
		var isNewMap:Bool = true;
		for (i in 0...savedMaps.length)
		{
			if (savedMaps[i].indexOf('"name":"' + worldConfig.name + '"') != -1)
			{
				SaveUtil.editorData.customMaps[i] = result;
				isNewMap = false;
				break;
			}
		}

		if (isNewMap) SaveUtil.editorData.customMaps.push(result);

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

enum EditorActionType {
	Create;
	Delete;
	Move;
	Rotate;
	Scale;
	ChangeBaseTerrain;
}

enum EditorViewId {
	VDialogManager;
	VTerrainModule;
	VHeightMapModule;
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
	public var updateGrid:Rect->Void;
}