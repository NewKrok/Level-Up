package demo.game;

import demo.AsyncUtil.Result;
import demo.game.GameModel.PlayState;
import demo.game.character.BaseCharacter;
import demo.game.character.Skeleton;
import demo.game.character.Warrior;
import demo.game.ui.LifeBar;
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
	var g:Graphics;

	var camPosition:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var camAnimationPosition:{ x:Float, y:Float, z:Float } = { x: 0, y: 0, z: 0 };
	var cameraSpeed:SimplePoint = { x: 10, y: 10 };
	var hasCameraAnimation:Bool = false;
	var camAnimationResult:Result;
	var camAnimationResultHandler:Void->Void;
	var cameraTarget:BaseCharacter;

	var isMoveTriggerOn:Bool = false;
	var lastMovePosition:SimplePoint = { x: 0, y: 0 };

	var characters:Array<BaseCharacter>;
	var playerCharacter:BaseCharacter;
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
		g = new Graphics(s3d);

		world = new GameWorld(s3d, mapConfig, 1, 64, 64, s3d);
		world.done();

		characters = [];

		var startPoint:SimplePoint = { x: 10, y: 2 };

		playerCharacter = new Skeleton(Player.User);
		characters.push(playerCharacter);
		setCameraTarget(playerCharacter);
		playerCharacter.view.x = startPoint.y * world.blockSize + world.blockSize / 2;
		playerCharacter.view.y = startPoint.x * world.blockSize + world.blockSize / 2;
		world.addChild(playerCharacter.view);

		for (i in 0...10)
		{
			var startPoint:SimplePoint = world.getRandomWalkablePoint();
			var character = new Warrior(Player.Enemy);
			characters.push(character);
			character.view.x = startPoint.x;
			character.view.y = startPoint.y;
			world.addChild(character.view);
			//moveToRandomPoint(character);
		}

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
			if (isControlEnabled)
			{
				lastMovePosition.x = Math.floor(e.relY / world.blockSize);
				lastMovePosition.y = Math.floor(e.relX / world.blockSize);
				characters[0].moveTo({ x: lastMovePosition.x, y: lastMovePosition.y }).handle(function () { trace("MOVE FINISHED"); });
			}
		}
		world.onWorldMouseDown = function(e:Event) isMoveTriggerOn = true;
		world.onWorldMouseUp = function(e:Event) isMoveTriggerOn = false;

		hasCameraAnimation = true;
		jumpCamera(40, 10, 20);
		model.initGame();
		Timer.delay(function() {
			moveCamera(10, 10, 15, 4).handle(model.startGame);
		}, 1000);
		Timer.delay(function() {
			playerCharacter.moveTo({ x: 10, y: 10 });
		}, 3500);

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
		var i = 0;
		for (row in world.graph.grid)
		{
			var j = 0;
			for (col in row)
			{
				if (col.weight != 0)
				{
					debugMapBlocks.lineStyle(1, 0x000000);

					debugMapBlocks.moveTo(i * world.blockSize, j * world.blockSize, 0);
					debugMapBlocks.lineTo(i * world.blockSize + world.blockSize, j * world.blockSize, 0);
					debugMapBlocks.lineTo(i * world.blockSize + world.blockSize, j * world.blockSize + world.blockSize, 0);
					debugMapBlocks.lineTo(i * world.blockSize, j * world.blockSize + world.blockSize, 0);
				}
				else
				{
					debugMapBlocks.lineStyle(1, 0x0000FF);

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
		g.clear();

		for (c in characters)
		{
			g.lineStyle(2, 0xFFFFFF, 1);
			g.moveTo(c.getPosition().x, c.getPosition().y, 0);

			if (c.path != null)
			{
				for (i in 0...c.path.length)
				{
					var path = c.path[i];
					g.lineTo(path.y * world.blockSize + world.blockSize / 2, path.x * world.blockSize + world.blockSize / 2, 0);
				}
			}
		}
	}

	override function update(d:Float)
	{
		for (c in characters) c.update(d);

		updateCamera(d);

		if (isMoveTriggerOn)
		{
			// TODO How to handle hm...
			/*lastMovePosition.x = Math.floor(e.relY / world.blockSize);
			lastMovePosition.y = Math.floor(e.relX / world.blockSize);
			characters[0].moveTo({ x: lastMovePosition.x, y: lastMovePosition.y }).handle(function () { trace("MOVE FINISHED"); });*/
		}

		calculateTargets();
		if (playerCharacter != null && playerCharacter.target != null)
		{
			targetMarker.visible = true;
			targetMarker.x = playerCharacter.target.getPosition().x;
			targetMarker.y = playerCharacter.target.getPosition().y;
		}
		else
		{
			targetMarker.visible = false;
		}
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

	function calculateTargets()
	{
		for (cA in characters)
		{
			var bestDistance = 999999.;
			var bestChar = null;
			for (cB in characters)
			{
				if (cA != cB && cA.owner != cB.owner)
				{
					var distance = GeomUtil.getDistance(cA.getPosition(), cB.getPosition());
					if (distance < bestDistance)
					{
						bestDistance = distance;
						bestChar = cB;
					}
				}
			}
			if (bestChar != null) cA.setNearestTarget(bestChar);
		}
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