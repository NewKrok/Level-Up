package demo.game;

import h2d.Scene;
import h2d.col.Point;
import h3d.Vector;
import h3d.mat.Data.Wrap;
import h3d.mat.Material;
import h3d.pass.DefaultShadowMap;
import h3d.prim.Cube;
import h3d.scene.CameraController;
import h3d.scene.Graphics;
import demo.game.character.BaseCharacter;
import h3d.scene.Mesh;
import h3d.scene.fwd.DirLight;
import hpp.heaps.Base2dStage;
import hpp.heaps.Base2dState;
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

	var characters:Array<BaseCharacter>;

	public function new(stage:Base2dStage, s2d:h2d.Scene, s3d:h3d.scene.Scene)
	{
		super(stage);

		this.s3d = s3d;
		this.s2d = s2d;

		s2d.visible = false;

		debugMapBlocks = new Graphics(s3d);
		g = new Graphics(s3d);

		world = new GameWorld(s3d, {x: 20, y: 40 }, 1, 64, 64, s3d);
		world.generateRandomMap();
		world.done();

		characters = [];
		for (i in 0...1)
		{
			var startPoint:SimplePoint = { x: 10, y: 5 };
			var character = new BaseCharacter();
			characters.push(character);
			character.view.x = startPoint.y * world.blockSize + world.blockSize / 2;
			character.view.y = startPoint.x * world.blockSize + world.blockSize / 2;
			world.addChild(character.view);
		}

		new DirLight(new h3d.Vector( 0.3, -0.4, -0.9), s3d);
		s3d.lightSystem.ambientLight.setColor(0x909090);

		var shadow:h3d.pass.DefaultShadowMap = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.power = 200;
		shadow.blur.radius= 0;
		shadow.bias *= 0.1;
		shadow.color.set(0.7, 0.7, 0.7);

		new CameraController(s3d).loadFromCamera();



		var c = new Cube(80, 80, 1);
		c.addNormals();
		c.addUVs();
		var m = new Mesh(c, Material.create(Res.texture.sky.toTexture()), s3d);
		m.x = -10;
		m.y = -30;
		m.z = -10;
		//m.material.color.setColor(0xFFFF00);
		m.material.texture.wrap = Wrap.Repeat;
		m.material.shadows = false;



		//drawDebugMapBlocks();
		drawDebugPath();

		world.onWorldClick = function(e:Event)
		{
			characters[0].moveTo({ x: Math.floor(e.relY / world.blockSize), y: Math.floor(e.relX / world.blockSize) }).handle(function () { trace("MOVE FINISHED"); });
			drawDebugPath();
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
		s3d.camera.pos.set(charPosition.x - 20, charPosition.y, 20);
		s3d.camera.target.set(charPosition.x + 2, charPosition.y);
	}
}