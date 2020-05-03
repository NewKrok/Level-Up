package levelup.game;

import Main.CoreFeatures;
import coconut.ui.RenderResult;
import h2d.Flow;
import h2d.Scene;
import h3d.Quat;
import h3d.Vector;
import h3d.pass.DefaultShadowMap;
import h3d.prim.Cube;
import h3d.prim.ModelCache;
import h3d.scene.Graphics;
import h3d.scene.Mesh;
import h3d.scene.Object;
import haxe.Json;
import haxe.ds.Map;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hpp.util.GeomUtil.SimplePoint;
import js.Browser;
import levelup.AsyncUtil.Result;
import levelup.MapData;
import levelup.editor.EditorState;
import levelup.game.GameModel.PlayState;
import levelup.game.GameState.Trigger;
import levelup.game.GameWorld.Region;
import levelup.game.html.GameUi;
import levelup.game.html.LobbyUi;
import levelup.game.ui.HeroUi;
import levelup.game.unit.BaseUnit;
import levelup.game.unit.elf.DemonHunter;
import levelup.game.unit.elf.Druid;
import levelup.game.unit.elf.Dryad;
import levelup.game.unit.elf.Treeant;
import levelup.game.unit.human.Archer;
import levelup.game.unit.human.Footman;
import levelup.game.unit.orc.Berserker;
import levelup.game.unit.orc.Drake;
import levelup.game.unit.orc.Grunt;
import levelup.util.AdventureParser;
import levelup.util.SaveUtil;
import motion.Actuate;
import motion.easing.IEasing;
import motion.easing.Linear;
import react.ReactDOM;
import tink.state.State;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameState extends Base2dState
{
	public var id(default, never):UInt = Math.floor(Math.random() * 1000);

	var stateConfig:GameStateConfig;
	var world:GameWorld;
	var adventureConfig:AdventureConfig;
	var model:GameModel;

	var s2d:h2d.Scene;
	var s3d:h3d.scene.Scene;

	var debugUnitPath:Graphics;

	var heroUiContainer:Flow;

	var currentCameraPoint:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var camAnimationPosition:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var currentCamDistance:Float = 0;
	var cameraSpeed:Vector = new Vector(10, 10, 5);
	var camAngle:Float = Math.PI - Math.PI / 4;
	var camDistance:Float = 40;
	var hasCameraAnimation:Bool = false;
	var camAnimationResult:Result;
	var camAnimationResultHandler:Void->Void;
	var cameraTarget:BaseUnit;

	var isMoveTriggerOn:Bool = false;
	var lastMovePosition:SimplePoint = { x: 0, y: 0 };

	var selectedUnit:State<BaseUnit> = new State<BaseUnit>(null);
	var isControlEnabled:Bool = false;
	var isDisposed:Bool = false;

	public function new(stage:Base2dStage, s2d:h2d.Scene, s3d:h3d.scene.Scene, rawMap:String, cf:CoreFeatures, stateConfigParam:GameStateConfig = null)
	{
		super(stage);

		this.s3d = s3d;
		this.s2d = s2d;
		this.stateConfig = stateConfigParam == null ? { isTestRun: false } : stateConfigParam;
		adventureConfig = AdventureParser.loadLevel(rawMap);

		cf.adventureLoader.load(rawMap).handle(o -> switch(o)
		{
			case Success(result):
				adventureConfig = result.config;
				onLoaded(rawMap);

			case Failure(e):
		});
	}

	function onLoaded(rawMap)
	{
		heroUiContainer = new Flow(s2d);
		heroUiContainer.scale(0.5);
		heroUiContainer.layout = Vertical;
		heroUiContainer.verticalSpacing = 15;
		heroUiContainer.x = 10;
		heroUiContainer.y = 10;

		camAnimationResult = { handle: function(handler:Void->Void) { camAnimationResultHandler = handler; } };

		model = new GameModel();
		model.observables.gameState.bind(function(v)
		{
			switch (v)
			{
				case PlayState.GameStarted: isControlEnabled = true;
				case _: isControlEnabled = false;
			}
		});

		debugUnitPath = new Graphics(s3d);
		debugUnitPath.z = 0.2;

		world = new GameWorld(s3d, adventureConfig.size, adventureConfig.worldConfig, 1, 64, 64);
		world.done();

		var c = new Cube(1, 1, 1);
		c.addNormals();
		c.addUVs();

		world.onWorldClick = e ->
		{
			if (isControlEnabled && selectedUnit.value != null && selectedUnit.value.state != Dead)
			{
				lastMovePosition.x = e.relY / world.blockSize;
				lastMovePosition.y = e.relX / world.blockSize;
				selectedUnit.value.moveTo({ x: lastMovePosition.x, y: lastMovePosition.y }).handle(function () { trace("MOVE FINISHED"); });
			}
		}
		world.onWorldMouseDown = _ -> isMoveTriggerOn = true;
		world.onWorldMouseUp = _ -> isMoveTriggerOn = false;
		world.onWorldMouseMove = e ->
		{
			if (selectedUnit.value != null && isMoveTriggerOn)
			{
				lastMovePosition.x = e.relY / world.blockSize;
				lastMovePosition.y = e.relX / world.blockSize;
				selectedUnit.value.moveTo({ x: lastMovePosition.x, y: lastMovePosition.y }).handle(function () { trace("MOVE FINISHED"); });
			}
		}
		world.onUnitEntersToRegion = function(r, u)
		{
			for (t in adventureConfig.worldConfig.triggers)
			{
				switch(t.event)
				{
					case EnterRegion(region) if (r == region): runTrigger(t, { triggeringUnit: u });
					case _:
				}
			}
		}
		world.onWorldWheel = e -> camDistance += e.wheelDelta * 8;
		world.onClickOnUnit = u -> if (u.owner == PlayerId.Player1) selectUnit(u);

		for (u in adventureConfig.worldConfig.units) createUnit(u.id, u.owner, u.x, u.y, u.scale, u.rotation);

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

				if (current - up != 0 || current - down != 0 || current - left != 0 || current - right != 0) world.graph.grid[i][j].weight = 0;
			}
		}

		for (o in adventureConfig.worldConfig.staticObjects.concat([]))
		{
			var config = EnvironmentData.getEnvironmentConfig(o.id);
			var instance:Object = config == null ? AssetCache.instance.getUndefinedModel() : AssetCache.instance.getModel(config.assetGroup);

			if (config != null && config.hasTransparentTexture != null && config.hasTransparentTexture)
				for (m in instance.getMaterials()) m.textureShader.killAlpha = true;
			else if (config == null)
				trace('Warning! There is a static object in the world without proper config with this id: ${o.id}');

			world.addToWorldPoint(instance, o.x, o.y, o.z, config == null ? 1 : o.scale, o.rotation);

			if (o.isPathBlocker)
			{
				var b = instance.getBounds().getSize();
				var xMin:Int = cast Math.max(Math.round(instance.x - b.x / 2), 0);
				var xMax:Int = cast Math.min(xMin + Math.round(b.x), world.size.x);
				var yMin:Int = cast Math.max(Math.round(instance.y - b.y / 2), 0);
				var yMax:Int = cast Math.min(yMin + Math.round(b.y), world.size.y);

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

		model.initGame();
		jumpCamera(adventureConfig.size.x / 2, adventureConfig.size.y / 2);

		for (t in adventureConfig.worldConfig.triggers) initTrigger(t);

		model.startGame();

		if (adventureConfig.title == "Lobby" && !stateConfig.isTestRun)
		{
			var ui:RenderResult = LobbyUi.fromHxx({
				isTestRun: stateConfig.isTestRun,
				openEditor: () -> HppG.changeState(
					EditorState,
					[stage, s3d, SaveUtil.editorData.customMaps.length == 0 ? MapData.getRawMap("lobby") : SaveUtil.editorData.customMaps[0]]
				),
				closeTestRun: () -> HppG.changeState(EditorState, [stage, s3d, rawMap])
			});
			ReactDOM.render(ui, Browser.document.getElementById("lu_native_ui"));
		}
		else
		{
			var ui:RenderResult = GameUi.fromHxx({
				isTestRun: stateConfig.isTestRun,
				openLobby: () -> HppG.changeState(GameState, [stage, s3d, MapData.getRawMap("lobby")]),
				closeTestRun: () -> HppG.changeState(EditorState, [stage, s3d, rawMap])
			});
			ReactDOM.render(ui, Browser.document.getElementById("lu_native_ui"));
		}
	}

	function createUnit(id:String, owner:PlayerId, posX:Float, posY:Float, scale:Float = null, rotation:Quat = null)
	{
		var unit = new BaseUnit(s2d, world, owner, UnitData.getUnitConfig(id), createProjectile);

		unit.view.x = posX * world.blockSize + world.blockSize / 2;
		unit.view.y = posY * world.blockSize + world.blockSize / 2;
		if (scale != null) unit.view.setScale(scale);
		if (rotation != null) unit.view.setRotationQuat(rotation);

		world.addEntity(unit);

		if (owner == PlayerId.Player1)
		{
			var ui = new HeroUi(
				heroUiContainer,
				unit,
				selectUnit,
				selectedUnit.observe()
			);
		}
	}

	function createProjectile(d:ProjectileData)
	{
		world.addEntity(new Projectile(s3d, d));
	}

	function selectUnit(u)
	{
		selectedUnit.set(u);
		setCameraTarget(selectedUnit.value);
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

	override function update(d:Float)
	{
		if (world == null) return;

		world.update(d);
		if (isDisposed) return;

		updateCamera(d);
	}

	function updateCamera(d:Float)
	{
		if (hasCameraAnimation || cameraTarget == null)
		{
			currentCameraPoint.x = camAnimationPosition.x;
			currentCameraPoint.y = camAnimationPosition.y;
			currentCameraPoint.z = camDistance = camAnimationPosition.z;
		}
		else
		{
			var targetPoint = cameraTarget.getPosition();

			camDistance = Math.max(20, camDistance);
			camDistance = Math.min(60, camDistance);

			currentCameraPoint.x += (targetPoint.x - currentCameraPoint.x) / cameraSpeed.x * d * 30;
			currentCameraPoint.y += (targetPoint.y - currentCameraPoint.y) / cameraSpeed.y * d * 30;

			var distanceOffset = (camDistance - currentCamDistance) / cameraSpeed.z * d * 30;
			if (Math.abs(distanceOffset) < 0.001) currentCamDistance = camDistance;
			else currentCamDistance += distanceOffset;
		}

		s3d.camera.target.set(currentCameraPoint.x, currentCameraPoint.y);
		s3d.camera.pos.set(
			currentCameraPoint.x + currentCamDistance * Math.cos(camAngle),
			currentCameraPoint.y,
			(hasCameraAnimation || cameraTarget == null)
				? currentCamDistance * Math.sin(camAngle)
				: currentCamDistance * Math.sin(camAngle)
		);
	}

	function moveCamera(x:Float, y:Float, z:Float, time:Float, ease:IEasing = null)
	{
		camAnimationResultHandler = null;
		hasCameraAnimation = true;
		camAnimationPosition.x = currentCameraPoint.x;
		camAnimationPosition.y = currentCameraPoint.y;
		camAnimationPosition.z = currentCameraPoint.z;

		Actuate.tween(camAnimationPosition, time, { x: x, y: y, z: z })
			.ease(ease == null ? Linear.easeNone : ease)
			.onUpdate(function()
			{
				camAnimationPosition.x = camAnimationPosition.x;
				camAnimationPosition.y = camAnimationPosition.y;
				camAnimationPosition.z = camAnimationPosition.z;
			})
			.onComplete(function()
			{
				hasCameraAnimation = false;
				if (camAnimationResultHandler != null) camAnimationResultHandler();
			});

		return camAnimationResult;
	}

	function jumpCamera(x:Float, y:Float, z:Float = null)
	{
		currentCameraPoint.x = x;
		currentCameraPoint.y = y;
		if (z != null) currentCameraPoint.z = z;
		camAnimationPosition.x = currentCameraPoint.x;
		camAnimationPosition.y = currentCameraPoint.y;
		if (z != null) camAnimationPosition.z = currentCameraPoint.z;

		currentCamDistance = camDistance;

		updateCamera(0);
	}

	function setCameraTarget(target)
	{
		currentCamDistance = camDistance;
		cameraTarget = target;
	}

	function runTrigger(t:Trigger, p:TriggerParams = null)
	{
		if (!t.isEnabled) return;

		if (t.condition != null)
		{
			switch (t.condition)
			{
				case OwnerOf(unitDef, expectedPlayer) if (unitDef == TriggeringUnit && p.triggeringUnit.owner == expectedPlayer): runActions(t.actions, p);

				case _:
			}
		}
		else runActions(t.actions, p);
	}

	function runActions(actions:Array<TriggerAction>, p:TriggerParams)
	{
		var localVariables:Map<String, Dynamic> = [];

		for (a in actions)
		{
			if (a != null)
			{
				switch(a)
				{
					case Log(message): trace(message);
					case LoadLevel(levelName): HppG.changeState(GameState, [s2d, s3d, MapData.getRawMap(levelName)]);
					case EnableTrigger(id): for (t in adventureConfig.worldConfig.triggers) if (t.id == id) enableTrigger(t);
					case SetLocalVariable(name, value): localVariables.set(name, value);

					case JumpCameraToUnit(playerId, unitDefinition):
					{
						// TODO Define own player id, it could be different during multiplayer games
						if (playerId == PlayerId.Player1)
						{
							var unit:BaseUnit = resolveUnitByDefinition(unitDefinition, localVariables);
							jumpCamera(unit.view.x, unit.view.y);
						}
					}

					case SelectUnit(playerId, unitDefinition):
					{
						// TODO Define own player id, it could be different during multiplayer games
						if (playerId == PlayerId.Player1) selectUnit(resolveUnitByDefinition(unitDefinition, localVariables));
					}

					case CreateUnit(unitId, owner, positionDefinition):
						var position = resolvePositionByDefinition(positionDefinition);
						createUnit(unitId, owner, position.x, position.y);

					case AttackMoveToRegion(unitDefinition, positionDefinition):
						var position = resolvePositionByDefinition(positionDefinition);
						var unit:BaseUnit = resolveUnitByDefinition(unitDefinition, localVariables);
						if (unit != null)
						{
							unit.attackMoveTo({ y: position.x, x: position.y });
						}

					case _: trace("Unknown action in action list: " + actions);
				}
			}
			else trace("Unknown action in action list: " + actions);
		}
	}

	function resolveUnitByDefinition(unitDefinition, localVariables:Map<String, Dynamic>) return switch(unitDefinition)
	{
		case LastCreatedUnit: world.units[world.units.length - 1];
		case GetLocalVariable(name): resolveUnitByDefinition(localVariables.get(name), localVariables);

		case GetUnit(definition): switch(definition)
			{
				case UnitOfPlayer(playerId, filter): getUnitsOfPlayer(playerId)[switch(filter)
				{
					case Index(value): value;
					case _: 0;
				}];

				case _: null;
			}

		case _: null;
	}

	function getUnitsOfPlayer(playerId)
	{
		return world.units.filter(u -> return u.owner == playerId);
	}

	function resolvePositionByDefinition(positionDefinition):SimplePoint
	{
		switch(positionDefinition)
		{
			case PositionDefinition.RegionPosition(regionDefinition):
				switch (regionDefinition)
				{
					case RegionPositionDefinition.CenterOf(region):
						var region = resolveRegionByName(region);
						return { x: region.x + region.width / 2, y: region.y + region.height / 2 };

					case RegionPositionDefinition.RandomPointOf(region):
						var region = resolveRegionByName(region);
						return { x: region.x + region.width * Math.random(), y: region.y + region.height * Math.random() };
				}

			case PositionDefinition.WorldPoint(position): return { x: position.x, y: position.y };
		}

		return { x: 0, y: 0 };
	}

	function resolveRegionByName(name)
	{
		var raw = adventureConfig.worldConfig.regions.filter(r -> return r.name == name);

		return raw != null && raw.length > 0 ? raw[0] : null;
	}

	function enableTrigger(t:Trigger)
	{
		t.isEnabled = true;
		initTrigger(t);
	}

	function initTrigger(t:Trigger)
	{
		if (t.isEnabled)
		{
			switch(t.event)
			{
				case OnInit: runTrigger(t);
				case TimeElapsed(time): Actuate.timer(time).onComplete(runTrigger.bind(t));
				case TimePeriodic(time): Actuate.timer(time).repeat().onRepeat(runTrigger.bind(t));
				case _:
			}
		}
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

typedef GameStateConfig =
{
	var isTestRun:Bool;
}

typedef AdventureConfig =
{
	var preloaderImage(default, never):String;
	var title(default, never):String;
	var subTitle(default, never):String;
	var description(default, never):String;
	var editorVersion(default, never):String;
	var size(default, never):SimplePoint;
	var worldConfig:WorldConfig;
	var neededModelGroups:Array<String>;
	var neededTextures:Array<String>;
}

typedef WorldConfig =
{
	@:optional var regions(default, never):Array<Region>;
	@:optional var triggers(default, never):Array<Trigger>;
	@:optional var units(default, never):Array<InitialUnitData>;
	@:optional var staticObjects(default, never):Array<StaticObjectConfig>;
	@:optional var terrainLayers(default, never):Array<TerrainLayerInfo>;
	@:optional var heightMap(default, never):String;
	@:optional var levellingHeightMap(default, never):String;
	@:optional var editorLastCamPosition(default, never):Vector;
	@:optional var startingTime(default, never):Float;
	@:optional var sunAndMoonOffsetPercent(default, never):Float;
	@:optional var dayColor(default, never):String;
	@:optional var nightColor(default, never):String;
	@:optional var sunsetColor(default, never):String;
	@:optional var dawnColor(default, never):String;
}

typedef StaticObjectConfig =
{
	var id(default, never):String;
	var name(default, never):String;
	var x(default, never):Float;
	var y(default, never):Float;
	var z(default, never):Float;
	var zOffset(default, never):Float;
	var scale(default, never):Float;
	var rotation(default, never):Quat;
	@:optional var isPathBlocker(default, never):Bool;
	@:optional var instance(default, never):Object;
}

typedef InitialUnitData =
{
	> StaticObjectConfig,
	var owner:PlayerId;
}

typedef Trigger =
{
	var id:String;
	var isEnabled:Bool;
	var event:TriggerEvent;
	var condition:TriggerCondition;
	var actions:Array<TriggerAction>;
}

enum TriggerEvent {
	OnInit;
	EnterRegion(region:Region);
	TimeElapsed(time:Float);
	TimePeriodic(time:Float);
}

typedef TriggerParams =
{
	var triggeringUnit:BaseUnit;
}

enum TriggerCondition {
	OwnerOf(unit:UnitDefinition, player:PlayerId);
}

enum UnitDefinition {
	TriggeringUnit;
	LastCreatedUnit;
	GetUnit(definition:GetUnitDefinition);
	GetLocalVariable(name:String);
}

enum GetUnitDefinition {
	UnitOfPlayer(player:PlayerId, filter:Filter);
}

enum Filter {
	Index(value:Int);
}

typedef TerrainLayerInfo =
{
	var textureId:String;
	var texture:String;
	var uvScale:Float;
}

@:enum abstract PlayerId(Int) from Int to Int {
	var Player1 = 0;
	var Player2 = 1;
	var Player3 = 2;
	var Player4 = 3;
	var Player5 = 4;
	var Player6 = 5;
	var Player7 = 6;
	var Player8 = 7;
	var Player9 = 8;
	var Player10 = 9;
}

enum TriggerAction {
	Log(message:String);
	LoadLevel(levelName:String);
	EnableTrigger(id:String);
	SetLocalVariable(name:String, value:Dynamic);
	JumpCameraToUnit(player:PlayerId, unit:UnitDefinition);
	SelectUnit(player:PlayerId, unit:UnitDefinition);
	CreateUnit(unitId:String, owner:PlayerId, position:PositionDefinition);
	AttackMoveToRegion(unit:UnitDefinition, position:PositionDefinition);
}

enum PositionDefinition {
	RegionPosition(value:RegionPositionDefinition);
	WorldPoint(position:SimplePoint);
}

enum RegionPositionDefinition {
	CenterOf(regionId:String);
	RandomPointOf(regionId:String);
}