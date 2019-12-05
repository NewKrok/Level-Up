package levelup.game;

import coconut.ui.RenderResult;
import h2d.Flow;
import h2d.Scene;
import h3d.Vector;
import h3d.pass.DefaultShadowMap;
import h3d.prim.Cube;
import h3d.scene.Graphics;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.scene.fwd.DirLight;
import haxe.Json;
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
import levelup.game.unit.elf.BattleOwl;
import levelup.game.unit.elf.DemonHunter;
import levelup.game.unit.elf.Druid;
import levelup.game.unit.elf.Dryad;
import levelup.game.unit.elf.Ranger;
import levelup.game.unit.elf.RockGolem;
import levelup.game.unit.elf.Treeant;
import levelup.game.unit.human.Archer;
import levelup.game.unit.human.Footman;
import levelup.game.unit.orc.BandWagon;
import levelup.game.unit.orc.Berserker;
import levelup.game.unit.orc.Drake;
import levelup.game.unit.orc.Grunt;
import levelup.game.unit.elf.Knome;
import levelup.game.unit.orc.Minion;
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
	var mapConfig:WorldConfig;
	var model:GameModel;

	var s2d:h2d.Scene;
	var s3d:h3d.scene.Scene;

	var debugMapBlocks:Graphics;
	var debugRegions:Graphics;
	var debugUnitPath:Graphics;
	var debugDetectionRadius:Graphics;

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
	var targetMarker:Mesh;
	var isControlEnabled:Bool = false;
	var isDisposed:Bool = false;

	public function new(stage:Base2dStage, s2d:h2d.Scene, s3d:h3d.scene.Scene, rawMap:String, stateConfigParam:GameStateConfig = null)
	{
		super(stage);

		this.s3d = s3d;
		this.s2d = s2d;
		this.stateConfig = stateConfigParam == null ? { isTestRun: false } : stateConfigParam;
		mapConfig = loadLevel(rawMap);

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
		dirLight.setDirection(new Vector(3, 1, -2));
		dirLight.color = new Vector(0.9, 0.9, 0.9);

		s3d.lightSystem.ambientLight.setColor(0x444444);

		var shadow:h3d.pass.DefaultShadowMap = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.power = 20;
		shadow.blur.radius = 5;
		shadow.bias *= 0.1;
		shadow.color.set(0.4, 0.4, 0.4);

		var c = new Cube(1, 1, 1);
		c.addNormals();
		c.addUVs();
		targetMarker = new Mesh(c, null, s3d);
		targetMarker.z = -0.8;
		targetMarker.material.color.setColor(0xFFFF00);
		targetMarker.material.shadows = false;

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
			for (t in mapConfig.triggers)
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

		for (u in mapConfig.units) createUnit(u.id, u.owner, u.x, u.y, u.scale, u.rotation);

		model.initGame();

		for (t in mapConfig.triggers)
		{
			switch(t.event)
			{
				case TimeElapsed(time) if (t.isEnabled): Actuate.timer(time).onComplete(runTrigger.bind(t));
				case _:
			}
		}

		// With intro
		/*hasCameraAnimation = true;
		jumpCamera(40, 10, 20);
		Timer.delay(function() {
			moveCamera(10, 10, 15, 4).handle(model.startGame);
		}, 1000);
		Timer.delay(function() {
			playerCharacter.moveTo({ x: 10, y: 10 });
		}, 3500);*/

		// Without intro
		jumpCamera(10, 10, camDistance);
		model.startGame();

		if (mapConfig.name == "Lobby" && !stateConfig.isTestRun)
		{
			var ui:RenderResult = LobbyUi.fromHxx({
				isTestRun: stateConfig.isTestRun,
				openEditor: () -> HppG.changeState(
					EditorState,
					[stage, s3d, SaveUtil.editorData.customMaps.length == 0 ? MapData.getRawMap("lobby") : SaveUtil.editorData.customMaps[0]]
				),
				closeTestRun: () -> HppG.changeState(EditorState, [stage, s3d, rawMap])
			});
			ReactDOM.render(ui, Browser.document.getElementById("native-ui"));
		}
		else
		{
			var ui:RenderResult = GameUi.fromHxx({
				isTestRun: stateConfig.isTestRun,
				openLobby: () -> HppG.changeState(GameState, [stage, s3d, MapData.getRawMap("lobby")]),
				closeTestRun: () -> HppG.changeState(EditorState, [stage, s3d, rawMap])
			});
			ReactDOM.render(ui, Browser.document.getElementById("native-ui"));
		}
	}

	function loadLevel(rawDataStr:String)
	{
		var rawData = Json.parse(rawDataStr);

		var pathFindingMap:Array<Array<WorldEntity>> = rawData.pathFindingMap;
		var staticObjects:Array<StaticObjectConfig> = rawData.staticObjects;

		var regions:Array<Region> = [for (r in cast(rawData.regions, Array<Dynamic>)) {
			id: r.id,
			x: r.x,
			y: r.y,
			width: r.width,
			height: r.height
		}];

		var triggers:Array<Trigger> = [for (t in cast(rawData.triggers, Array<Dynamic>)) {
			id: t.id != null ? t.id.toLowerCase() : Std.string(Math.random() * 9999999),
			isEnabled: t.isEnabled != null ? t.isEnabled : true,
			event: switch (t.event.toLowerCase().split(" ")) {
				case [event, regionName] if (event.toLowerCase() == "enterregion"): EnterRegion(getRegion(regions, regionName));
				case [event, time] if (event.toLowerCase() == "timeelapsed"): TimeElapsed(time);
				case [event, time] if (event.toLowerCase() == "timeperiodic"): TimePeriodic(time);
				case _: null;
			},
			condition: t.condition == null ? null : switch (t.condition.toLowerCase().split(" ")) {
				case [condition, unitDefinition, expectedPlayer] if (condition.toLowerCase() == "ownerof"):
					OwnerOf(switch(unitDefinition.toLowerCase())
					{
						case "triggeringunit": TriggeringUnit;
						case _: null;
					}, expectedPlayer);
				case _: null;
			},
			actions: [for(actionEntry in cast(t.actions, Array<Dynamic>)) switch (actionEntry.toLowerCase().split(" ")) {
				case [action, message] if (action.toLowerCase() == "log"): Log(message);
				case [action, levelName] if (action.toLowerCase() == "loadlevel"): LoadLevel(levelName);
				case [action, triggerId] if (action.toLowerCase() == "enabletrigger"): EnableTrigger(triggerId);
				case [action, unitId, owner] if (action.toLowerCase() == "createunit"): CreateUnit(unitId, owner);
				case _: null;
			}],
		}];

		return {
			name: rawData.name,
			size: rawData.size,
			baseTerrainId: rawData.baseTerrainId,
			pathFindingMap: pathFindingMap,
			regions: regions,
			triggers: triggers,
			units: rawData.units,
			staticObjects: staticObjects,
			terrainLayers: rawData.terrainLayers,
			heightMap: rawData.heightMap
		};
	}

	function getRegion(regions:Array<Region>, id:String) return regions.filter(function (r) { return r.id == id; })[0];

	function createUnit(id:String, owner:PlayerId, posX:Float, posY:Float, scale:Float, rotation:Float)
	{
		var unit = switch (id) {
			// orc
			case "bandwagon": new BandWagon(s2d, world, owner);
			case "berserker": new Berserker(s2d, world, owner);
			case "drake": new Drake(s2d, world, owner);
			case "minion": new Minion(s2d, world, owner);
			case "grunt": new Grunt(s2d, world, owner);
			// human
			case "archer": new Archer(s2d, world, owner);
			case "footman": new Footman(s2d, world, owner);
			// elf
			case "knome": new Knome(s2d, world, owner);
			case "demonhunter": new DemonHunter(s2d, world, owner);
			case "druid": new Druid(s2d, world, owner);
			case "dryad": new Dryad(s2d, world, owner);
			case "ranger": new Ranger(s2d, world, owner);
			case "rockgolem": new RockGolem(s2d, world, owner);
			case "treeant": new Treeant(s2d, world, owner);
			case "battleowl": new BattleOwl(s2d, world, owner);

			case _: null;
		};
		unit.view.x = posX * world.blockSize + world.blockSize / 2;
		unit.view.y = posY * world.blockSize + world.blockSize / 2;
		unit.view.setScale(scale);
		unit.view.setRotation(0, 0, scale);

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

	function selectUnit(u)
	{
		selectedUnit.set(u);
		setCameraTarget(selectedUnit.value);
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

		updateCamera(d);

		if (selectedUnit.value != null && selectedUnit.value.nearestTarget != null)
		{
			targetMarker.visible = true;
			targetMarker.x = selectedUnit.value.nearestTarget.getPosition().x - 0.5;
			targetMarker.y = selectedUnit.value.nearestTarget.getPosition().y - 0.5;
		}

		/*drawDebugMapBlocks();
		drawDebugRegions();
		drawDebugPath();
		drawDebugInteractionRadius();*/
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
		for (a in actions)
		{
			if (a != null)
			{
				switch(a)
				{
					case Log(message): trace(message);
					case LoadLevel(levelName): HppG.changeState(GameState, [s2d, s3d, MapData.getRawMap(levelName)]);
					case EnableTrigger(id): for (t in mapConfig.triggers) if (t.id == id) enableTrigger(t);
					case CreateUnit(unitId, owner): createUnit(unitId, owner, Math.floor(Math.random() * 5 + 5), Math.floor(Math.random() * 10 + 5), 1, 0);

					case _: trace("Unknown action in action list: " + actions);
				}
			}
			else trace("Unknown action in action list: " + actions);
		}
	}

	function enableTrigger(t:Trigger)
	{
		t.isEnabled = true;

		switch(t.event)
		{
			case TimePeriodic(time): Actuate.timer(time).repeat().onRepeat(runTrigger.bind(t));
			case _:
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

typedef WorldConfig =
{
	var name(default, never):String;
	var size(default, never):SimplePoint;
	var baseTerrainId(default, never):String;
	var pathFindingMap(default, never):Array<Array<WorldEntity>>;
	@:optional var regions(default, never):Array<Region>;
	@:optional var triggers(default, never):Array<Trigger>;
	@:optional var units(default, never):Array<InitialUnitData>;
	@:optional var staticObjects(default, never):Array<StaticObjectConfig>;
	@:optional var terrainLayers(default, never):Array<TerrainLayerInfo>;
	@:optional var heightMap(default, never):String;
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
	var rotation(default, never):Float;
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
}

typedef TerrainLayerInfo =
{
	var textureId:String;
	var texture:String;
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

@:enum abstract RaceId(Int) from Int to Int {
	var Human = 0;
	var Orc = 1;
	var Elf = 2;
	var Undead = 3;
}

enum TriggerAction {
	Log(message:String);
	LoadLevel(levelName:String);
	EnableTrigger(id:String);
	CreateUnit(unitId:String, owner:PlayerId);
}

@:enum abstract WorldEntity(Int) from Int to Int {
	var Nothing = 0;
	var SimpleUnwalkable = 1;
	var Tree = 2;
}