package levelup.editor;

import coconut.ui.RenderResult;
import h2d.Flow;
import h2d.Scene;
import h3d.Camera;
import h3d.Vector;
import h3d.mat.BlendMode;
import h3d.pass.DefaultShadowMap;
import h3d.prim.Cube;
import h3d.prim.ModelCache;
import h3d.scene.Graphics;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.scene.fwd.DirLight;
import h3d.scene.fwd.PointLight;
import haxe.Json;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hpp.util.GeomUtil.SimplePoint;
import js.Browser;
import levelup.Asset;
import levelup.editor.EditorUi;
import levelup.editor.html.EditorHtmlUi;
import levelup.game.GameState;
import levelup.game.GameState.PlayerId;
import levelup.game.GameState.StaticObjectConfig;
import levelup.game.GameState.WorldConfig;
import levelup.game.GameState.WorldEntity;
import levelup.game.GameWorld;
import levelup.game.GameWorld.Region;
import levelup.game.ui.HeroUi;
import levelup.game.unit.BaseUnit;
import levelup.game.unit.orc.BandWagon;
import levelup.game.unit.orc.Berserker;
import levelup.game.unit.orc.Drake;
import levelup.game.unit.orc.Grunt;
import levelup.game.unit.orc.Minion;
import levelup.game.unit.orc.PlayerGrunt;
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

	var s2d:h2d.Scene;
	var s3d:h3d.scene.Scene;

	var debugMapBlocks:Graphics;
	var debugRegions:Graphics;
	var debugUnitPath:Graphics;
	var debugDetectionRadius:Graphics;

	var selectedUnit:State<BaseUnit> = new State<BaseUnit>(null);
	var isDisposed:Bool = false;

	var isMapDragActive:Bool = false;
	var dragStartPoint:SimplePoint = { x: 0, y: 0 };
	var dragStartObjectPoint:SimplePoint = { x: 0, y: 0 };

	var cameraObject:Object = new Object();
	var currentCameraPoint:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var currentCamDistance:Float = 0;
	var cameraSpeed:Vector = new Vector(10, 10, 5);
	var camAngle:Float = Math.PI - Math.PI / 4;
	var camDistance:Float = 30;

	var cache:ModelCache = new ModelCache();
	var previewInstance:Object;

	public function new(stage:Base2dStage, s2d:h2d.Scene, s3d:h3d.scene.Scene, rawMap:String)
	{
		super(stage);

		this.s3d = s3d;
		this.s2d = s2d;
		mapConfig = loadLevel(rawMap);

		debugMapBlocks = new Graphics(s3d);
		debugMapBlocks.z = 0.2;
		debugRegions = new Graphics(s3d);
		debugRegions.z = 0.2;
		debugUnitPath = new Graphics(s3d);
		debugUnitPath.z = 0.2;
		debugDetectionRadius = new Graphics(s3d);
		debugDetectionRadius.z = 0.2;

		world = new GameWorld(s3d, mapConfig, 1, 64, 64, s3d);
		world.done();

		var dirLight = new DirLight(null, s3d);
		dirLight.setDirection(new Vector(1, 0, -2));
		dirLight.color = new Vector(0.9, 0.9, 0.9);

		var pLight = new PointLight(s3d);
		pLight.setPosition(20, 10, 15);
		pLight.color = new Vector(200, 200, 200);

		s3d.lightSystem.ambientLight.setColor(0x000000);

		var shadow:h3d.pass.DefaultShadowMap = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.power = 20;
		shadow.blur.radius = 5;
		shadow.bias *= 0.1;
		shadow.color.set(0.4, 0.4, 0.4);

		var c = new Cube(90, 80, 1);
		c.addNormals();
		c.addUVs();
		var m = new Mesh(c, null, s3d);
		m.x = -10;
		m.y = -30;
		m.z = -10;
		m.material.color.setColor(0x000000);
		m.material.shadows = false;

		var c = new Cube(1, 1, 1);
		c.addNormals();
		c.addUVs();

		world.onWorldClick = e ->
		{

		}
		world.onWorldMouseDown = e ->
		{
			isMapDragActive = true;
			dragStartPoint.x = e.relX;
			dragStartPoint.y = e.relY;
			dragStartObjectPoint.x = cameraObject.x;
			dragStartObjectPoint.y = cameraObject.y;
		}
		world.onWorldMouseUp = e ->
		{
			isMapDragActive = false;
		}
		world.onWorldMouseMove = e ->
		{
			if (previewInstance != null)
			{
				previewInstance.x = e.relX;
				previewInstance.y = e.relY;
			}

			if (isMapDragActive)
			{
				cameraObject.x = dragStartObjectPoint.x + (dragStartPoint.x - e.relX) * 2;
				cameraObject.y = dragStartObjectPoint.y + (dragStartPoint.y - e.relY) * 2;
			}
		}
		world.onWorldWheel = e -> camDistance += e.wheelDelta * 8;
		world.onClickOnUnit = u -> if (u.owner == PlayerId.Player1) selectUnit(u);

		for (u in mapConfig.units) createUnit(u.id, u.owner, u.x, u.y);

		s3d.addChild(cameraObject);
		s3d.camera.pos.set(10 - 30, 10, 30);
		s3d.camera.target.x = s3d.camera.pos.x + 30;
		s3d.camera.target.y = s3d.camera.pos.y;
		jumpCamera(10, 10, 23);

		new EditorUi(s2d, s3d, world);

		var ui:RenderResult = EditorHtmlUi.fromHxx({
			backToLobby: () -> HppG.changeState(GameState, [stage, s3d, MapData.getRawMap("lobby")]),
			previewRequest: createPreview,
			environmentsList: List.fromArray(Asset.environment),
			propsList: List.fromArray(Asset.props),
			unitsList: List.fromArray([])
		});
		ReactDOM.render(ui, Browser.document.getElementById("native-ui"));
	}

	function jumpCamera(x:Float, y:Float, z:Float)
	{
		cameraObject.x = x;
		cameraObject.y = y;

		currentCameraPoint.x = x;
		currentCameraPoint.y = y;
		currentCameraPoint.z = z;

		currentCamDistance = camDistance;

		updateCamera(0);
	}

	function createPreview(asset:AssetItem)
	{
		if (previewInstance != null)
		{
			previewInstance.remove();
			previewInstance = null;
		}

		previewInstance = cache.loadModel(asset.model);
		previewInstance.scale(0.05);
		previewInstance.getMaterials()[0].blendMode = BlendMode.Screen;

		s3d.addChild(previewInstance);
	}

	function loadLevel(rawDataStr:String)
	{
		var rawData = Json.parse(rawDataStr);

		var map:Array<Array<WorldEntity>> = rawData.map;
		var staticObjects:Array<StaticObjectConfig> = rawData.staticObjects;

		var regions:Array<Region> = [for (r in cast(rawData.regions, Array<Dynamic>)) {
			id: r.id,
			x: r.x,
			y: r.y,
			width: r.width,
			height: r.height
		}];

		return {
			name: rawData.name,
			map: map,
			regions: regions,
			triggers: [],
			units: rawData.units,
			staticObjects: staticObjects
		};
	}

	function getRegion(regions:Array<Region>, id:String) return regions.filter(function (r) { return r.id == id; })[0];

	function createUnit(id:String, owner:PlayerId, posX:Int, posY:Int)
	{
		var unit = switch (id) {
			case "playergrunt": new PlayerGrunt(s2d, world, owner);
			case "bandwagon": new BandWagon(s2d, world, owner);
			case "berserker": new Berserker(s2d, world, owner);
			case "drake": new Drake(s2d, world, owner);
			case "minion": new Minion(s2d, world, owner);
			case "grunt": new Grunt(s2d, world, owner);
			case _: null;
		};
		unit.view.x = posY * world.blockSize + world.blockSize / 2;
		unit.view.y = posX * world.blockSize + world.blockSize / 2;
		world.addEntity(unit);
	}

	function selectUnit(u)
	{
		selectedUnit.set(u);
	}

	function drawDebugMapBlocks():Void
	{
		debugMapBlocks.clear();

		var i = 0;
		for (row in world.graph.grid)
		{
			var j = 0;
			for (col in row)
			{
				if (col.weight != 0)
				{
					/*debugMapBlocks.lineStyle(2, 0x000000);

					debugMapBlocks.moveTo(i * world.blockSize, j * world.blockSize, 0);
					debugMapBlocks.lineTo(i * world.blockSize + world.blockSize, j * world.blockSize, 0);
					debugMapBlocks.lineTo(i * world.blockSize + world.blockSize, j * world.blockSize + world.blockSize, 0);
					debugMapBlocks.lineTo(i * world.blockSize, j * world.blockSize + world.blockSize, 0);*/
				}
				else
				{
					debugMapBlocks.lineStyle(2, 0x0000FF);

					debugMapBlocks.moveTo(i * world.blockSize, j * world.blockSize + world.blockSize, 0);
					debugMapBlocks.lineTo(i * world.blockSize + world.blockSize, j * world.blockSize, 0);
					debugMapBlocks.moveTo(i * world.blockSize, j * world.blockSize, 0);
					debugMapBlocks.lineTo(i * world.blockSize + world.blockSize, j * world.blockSize + world.blockSize, 0);
				}
				j++;
			}
			i++;
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

	function drawDebugPath():Void
	{
		debugUnitPath.clear();

		for (u in world.units)
		{
			debugUnitPath.lineStyle(2, 0xFFFFFF);
			debugUnitPath.moveTo(u.getPosition().x, u.getPosition().y, 0);

			if (u.path != null)
			{
				for (i in 0...u.path.length)
				{
					var path = u.path[i];
					debugUnitPath.lineTo(path.y * world.blockSize + world.blockSize / 2, path.x * world.blockSize + world.blockSize / 2, 0);
				}
			}
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

		/*drawDebugMapBlocks();
		drawDebugRegions();
		drawDebugPath();
		drawDebugInteractionRadius();*/

		updateCamera(d);
	}

	function updateCamera(d:Float)
	{
		camDistance = Math.max(10, camDistance);
		camDistance = Math.min(100, camDistance);

		currentCameraPoint.x += (cameraObject.x - currentCameraPoint.x) / cameraSpeed.x * d * 30;
		currentCameraPoint.y += (cameraObject.y - currentCameraPoint.y) / cameraSpeed.y * d * 30;
		currentCamDistance += (camDistance - currentCamDistance) / cameraSpeed.z * d * 30;

		s3d.camera.target.set(currentCameraPoint.x, currentCameraPoint.y);

		s3d.camera.pos.set(
			currentCameraPoint.x + currentCamDistance * Math.cos(camAngle),
			currentCameraPoint.y,
			cameraObject.z + currentCamDistance * Math.sin(camAngle)
		);
	}

	override public function dispose():Void
	{
		super.dispose();

		world.onWorldClick = null;
		world.onWorldMouseDown = null;
		world.onWorldMouseUp = null;
		world.onWorldMouseMove = null;
		world.onUnitEntersToRegion = null;
		world.remove();
		world.dispose();
		world = null;

		s2d.removeChildren();
		s3d.removeChildren();

		Actuate.reset();

		isDisposed = true;
	}
}