package demo.game;

import demo.game.character.BaseCharacter;
import demo.game.character.Skeleton;
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
import haxe.Json;
import haxe.Timer;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameState extends Base2dState
{
	var world:GameWorld;
	var s2d:h2d.Scene;
	var s3d:h3d.scene.Scene;

	var debugMapBlocks:Graphics;
	var g:Graphics;
	var camPosition:SimplePoint = { x: 0, y: 0 };
	var isMoveTriggerOn:Bool = false;
	var lastMovePosition:SimplePoint = { x: 0, y: 0 };

	var characters:Array<BaseCharacter>;
	var playerCharacter:BaseCharacter;
	var targetMarker:Mesh;

	public function new(stage:Base2dStage, s2d:h2d.Scene, s3d:h3d.scene.Scene)
	{
		super(stage);

		this.s3d = s3d;
		this.s2d = s2d;

		s2d.visible = false;

		debugMapBlocks = new Graphics(s3d);
		g = new Graphics(s3d);

		world = new GameWorld(s3d, Json.parse(Res.data.level_1.entry.getText()), 1, 64, 64, s3d);
		world.done();

		characters = [];

		var startPoint:SimplePoint = { x: 10, y: 5 };
		playerCharacter = new Skeleton();
		characters.push(playerCharacter);
		playerCharacter.view.x = startPoint.y * world.blockSize + world.blockSize / 2;
		playerCharacter.view.y = startPoint.x * world.blockSize + world.blockSize / 2;
		world.addChild(playerCharacter.view);

		for (i in 0...10)
		{
			var startPoint:SimplePoint = world.getRandomWalkablePoint();
			var character = new demo.game.character.Warrior();
			characters.push(character);
			character.view.x = startPoint.x;
			character.view.y = startPoint.y;
			world.addChild(character.view);
			moveToRandomPoint(character);
		}

		new DirLight(new h3d.Vector( 0.3, -0.4, -0.9), s3d);
		s3d.lightSystem.ambientLight.setColor(0x909090);

		var shadow:h3d.pass.DefaultShadowMap = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.power = 200;
		shadow.blur.radius= 0;
		shadow.bias *= 0.1;
		shadow.color.set(0.7, 0.7, 0.7);

		var c = new Cube(90, 80, 1);
		c.addNormals();
		c.addUVs();
		var m = new Mesh(c, Material.create(Res.texture.Ash.toTexture()), s3d);
		m.x = -10;
		m.y = -30;
		m.z = -10;
		//m.material.color.setColor(0xFFFF00);
		m.material.texture.wrap = Wrap.Repeat;
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
			lastMovePosition.x = Math.floor(e.relY / world.blockSize);
			lastMovePosition.y = Math.floor(e.relX / world.blockSize);
			characters[0].moveTo({ x: lastMovePosition.x, y: lastMovePosition.y }).handle(function () { trace("MOVE FINISHED"); });
		}
		world.onWorldMouseDown = function(e:Event) isMoveTriggerOn = true;
		world.onWorldMouseUp = function(e:Event) isMoveTriggerOn = false;
	}

	function moveToRandomPoint(c)
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
	}

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

		var charPosition = characters[0].getPosition();

		camPosition.x += (charPosition.x - camPosition.x) / 20 * d * 30;
		camPosition.y += (charPosition.y - camPosition.y) / 20 * d * 30;

		s3d.camera.pos.set(camPosition.x - 20, camPosition.y, 15);
		s3d.camera.target.set(camPosition.x + 2, camPosition.y);

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

	function calculateTargets()
	{
		for (cA in characters)
		{
			var bestDistance = 999999.;
			var bestChar = null;
			for (cB in characters)
			{
				if (cA != cB)
				{
					var distance = GeomUtil.getDistance(cA.getPosition(), cB.getPosition());
					if (distance < bestDistance)
					{
						bestDistance = distance;
						bestChar = cB;
					}
				}
			}
			if (bestChar != null) cA.setTarget(bestChar);
		}
	}
}