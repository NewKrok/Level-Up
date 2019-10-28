package demo.game;

import demo.AsyncUtil.Result;
import demo.game.GameModel.PlayState;
import demo.game.unit.BaseUnit;
import demo.game.unit.orc.Grunt;
import demo.game.unit.orc.Berserker;
import demo.game.ui.LifeBar;
import demo.game.unit.orc.Minion;
import demo.game.unit.orc.PlayerGrunt;
import h2d.Object;
import h2d.Scene;
import h3d.Vector;
import h3d.mat.Data.Wrap;
import h3d.mat.Material;
import h3d.pass.DefaultShadowMap;
import h3d.prim.Cube;
import h3d.prim.Cylinder;
import h3d.scene.Graphics;
import h3d.scene.Mesh;
import h3d.scene.fwd.DirLight;
import h3d.scene.fwd.PointLight;
import haxe.Json;
import haxe.Timer;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.heaps.HppG;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import hxd.Res;
import motion.Actuate;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.IEasing;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameState extends Base2dState
{
	var world:GameWorld;
	var mapConfig:WorldConfig;
	var model:GameModel;

	var s2d:h2d.Scene;
	var s3d:h3d.scene.Scene;

	var debugMapBlocks:Graphics;
	var debugUnitPath:Graphics;
	var debugDetectionRadius:Graphics;
	var g:Graphics;

	var camPosition:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var camAnimationPosition:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var cameraSpeed:SimplePoint = { x: 10, y: 10 };
	var hasCameraAnimation:Bool = false;
	var camAnimationResult:Result;
	var camAnimationResultHandler:Void->Void;
	var cameraTarget:BaseUnit;

	var isMoveTriggerOn:Bool = false;
	var lastMovePosition:SimplePoint = { x: 0, y: 0 };

	var playerCharacter:BaseUnit;
	var targetMarker:Mesh;
	var isControlEnabled:Bool = false;

	public function new(stage:Base2dStage, s2d:h2d.Scene, s3d:h3d.scene.Scene)
	{
		super(stage);

		this.s3d = s3d;
		this.s2d = s2d;

		camAnimationResult = { handle: function(handler:Void->Void) { camAnimationResultHandler = handler; } };

		model = new GameModel();
		model.observables.state.bind(function(v)
		{
			switch (v)
			{
				case PlayState.GameStarted: isControlEnabled = true;
				case _: isControlEnabled = false;
			}
		});

		mapConfig = Json.parse(Res.data.level_1.entry.getText());

		debugMapBlocks = new Graphics(s3d);
		debugMapBlocks.z = 0.2;
		debugUnitPath = new Graphics(s3d);
		debugUnitPath.z = 0.2;
		debugDetectionRadius = new Graphics(s3d);
		debugDetectionRadius.z = 0.2;
		g = new Graphics(s3d);

		world = new GameWorld(s3d, mapConfig, 1, 64, 64, s3d);
		world.done();

		var startPoint:SimplePoint = { x: 10, y: 5 };

		playerCharacter = new PlayerGrunt(s2d, Player.User);
		setCameraTarget(playerCharacter);
		playerCharacter.view.x = startPoint.y * world.blockSize + world.blockSize / 2;
		playerCharacter.view.y = startPoint.x * world.blockSize + world.blockSize / 2;
		world.addEntity(playerCharacter);

		for (i in 0...10)
		{
			var startPoint:SimplePoint = world.getRandomWalkablePoint();
			var character = switch(Math.floor(Math.random() * 3)) {
				case 0: new Minion(s2d, Player.Enemy);
				case 1: new Grunt(s2d, Player.Enemy);
				case 2: new Berserker(s2d, Player.Enemy);
				case _: null;
			}
			character.view.x = startPoint.y;
			character.view.y = startPoint.x;
			world.addEntity(character);
		}


		/*var enemyPoints = [
			{ x: 5, y: 5 },
			{ x: 2, y: 5 },
			{ x: 15, y: 5 },
		];
		for (p in enemyPoints)
		{
			var character = new Warrior(s2d, Player.Enemy);
			character.view.x = p.y * world.blockSize + world.blockSize / 2;
			character.view.y = p.x * world.blockSize + world.blockSize / 2;
			world.addEntity(character);
		}*/

		var dirLight = new DirLight(null, s3d);
		dirLight.setDirection(new Vector(2, 0, -2));
		dirLight.color = new Vector(0.9, 0.9, 0.9);

		var pLight = new PointLight(s3d);
		pLight.setPosition(20, 10, 15);
		pLight.color = new Vector(200, 200, 200);

		s3d.lightSystem.ambientLight.setColor(0x333333);

		var shadow:h3d.pass.DefaultShadowMap = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.power = 100;
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
		targetMarker = new Mesh(c, null, s3d);
		targetMarker.z = -0.8;
		targetMarker.material.color.setColor(0xFFFF00);
		targetMarker.material.shadows = false;

		world.onWorldClick = function(e:Event)
		{
			if (isControlEnabled && playerCharacter != null && playerCharacter.state != Dead)
			{
				lastMovePosition.x = Math.floor(e.relY / world.blockSize);
				lastMovePosition.y = Math.floor(e.relX / world.blockSize);
				playerCharacter.moveTo({ x: lastMovePosition.x, y: lastMovePosition.y }).handle(function () { trace("MOVE FINISHED"); });
			}
		}
		world.onWorldMouseDown = function(e:Event) isMoveTriggerOn = true;
		world.onWorldMouseUp = function(e:Event) isMoveTriggerOn = false;
		world.onWorldMouseMove = function(e:Event)
		{
			if (playerCharacter != null && isMoveTriggerOn)
			{
				lastMovePosition.x = Math.floor(e.relY / world.blockSize);
				lastMovePosition.y = Math.floor(e.relX / world.blockSize);
				playerCharacter.moveTo({ x: lastMovePosition.x, y: lastMovePosition.y }).handle(function () { trace("MOVE FINISHED"); });
			}
		}

		model.initGame();

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
		jumpCamera(10, 10, 20);
		model.startGame();


		var lifeUi = new LifeBar(s2d, playerCharacter.life, playerCharacter.config.maxLife);
		lifeUi.x = 20;
		lifeUi.y = 20;
	}

	/*function moveToRandomPoint(c)
	{
		var p = world.getRandomWalkablePoint();
		if (p != null)
		{
			c.moveTo({ x: p.y, y: p.x }).handle(function () { moveToRandomPoint(c); });
		}
		else
		{
			Timer.delay(moveToRandomPoint.bind(c), 1000);
		}
	}*/

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
		world.update(d);
		updateCamera(d);

		if (playerCharacter != null && playerCharacter.nearestTarget != null)
		{
			targetMarker.visible = true;
			targetMarker.x = playerCharacter.nearestTarget.getPosition().x - 0.5;
			targetMarker.y = playerCharacter.nearestTarget.getPosition().y - 0.5;
		}

		drawDebugMapBlocks();
		drawDebugPath();
		drawDebugInteractionRadius();
	}

	function updateCamera(d:Float)
	{
		if (hasCameraAnimation)
		{
			camPosition.x = camAnimationPosition.x;
			camPosition.y = camAnimationPosition.y;
			camPosition.z = camAnimationPosition.z;
		}
		else
		{
			var targetPoint = cameraTarget.getPosition();

			camPosition.x += (targetPoint.x - camPosition.x) / cameraSpeed.x * d * 30;
			camPosition.y += (targetPoint.y - camPosition.y) / cameraSpeed.y * d * 30;
		}

		camPosition.x = Math.max(camPosition.x, 9);
		camPosition.x = Math.min(camPosition.x, 38);

		camPosition.y = Math.max(camPosition.y, 4);
		camPosition.y = Math.min(camPosition.y, 16);

		s3d.camera.pos.set(camPosition.x - 20, camPosition.y, camPosition.z);
		s3d.camera.target.set(camPosition.x + 2, camPosition.y);
	}

	function moveCamera(x:Float, y:Float, z:Float, time:Float, ease:IEasing = null)
	{
		camAnimationResultHandler = null;
		hasCameraAnimation = true;
		camAnimationPosition.x = camPosition.x;
		camAnimationPosition.y = camPosition.y;
		camAnimationPosition.z = camPosition.z;

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

	function jumpCamera(x:Float, y:Float, z:Float)
	{
		camPosition.x = x;
		camPosition.y = y;
		camPosition.z = z;
		camAnimationPosition.x = camPosition.x;
		camAnimationPosition.y = camPosition.y;
		camAnimationPosition.z = camPosition.z;

		updateCamera(0);
	}

	function setCameraTarget(target)
	{
		cameraTarget = target;
	}
}

typedef WorldConfig =
{
	var map(default, never):Array<Array<WorldEntity>>;
	var staticObjects(default, never):Array<StaticObjectConfig>;
}

typedef StaticObjectConfig =
{
	var name(default, never):String;
	var x(default, never):Float;
	var y(default, never):Float;
	var z(default, never):Float;
	var scale(default, never):Float;
	var rotation(default, never):Float;
}

@:enum abstract WorldEntity(Int) from Int to Int {
	var Nothing = 0;
	var SimpleUnwalkable = 1;
	var Tree = 2;
}

enum Player {
	User;
	Enemy;
}