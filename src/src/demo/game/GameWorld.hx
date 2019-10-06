package demo.game;

import demo.game.js.Graph;
import h3d.mat.Data.Wrap;
import h3d.mat.Material;
import h3d.prim.Cube;
import h3d.prim.ModelCache;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.scene.World;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameWorld extends World
{
	public static var instance:GameWorld;

	public var graph:Graph;

	public var blockSize:Float;
	public var size:SimplePoint;

	public var onWorldClick:Event->Void;

	public function new(parent, size:SimplePoint, blockSize:Float, chunkSize:Int, worldSize:Int, ?parent, ?autoCollect = true)
	{
		super(chunkSize, worldSize, parent, autoCollect);

		this.size = size;
		instance = this;

		this.blockSize = blockSize;

		var c = new Cube(size.y, size.x, 0.5);
		c.addNormals();
		c.addUVs();
		c.uvScale(6, 4);

		var m = new Mesh(c, Material.create(Res.texture.ground.toTexture()), parent);
		m.x = 0;
		m.y = 0;
		m.z = -0.51;
		m.material.texture.wrap = Wrap.Repeat;

		var interact = new h3d.scene.Interactive(m.getCollider(), parent);
		interact.onClick = function (e) { onWorldClick(e); };
	}

	public function generateRandomMap():Void
	{
		var graphArray = [];

		var cache:ModelCache = new ModelCache();

		for (i in 0...cast size.y)
		{
			graphArray.push([]);
			for (j in 0...cast size.x)
			{
				var isWalkable:Bool = !(i == 0 || j == 0 || i == size.y - 1 || j == size.x - 1);
				graphArray[i].push(isWalkable ? 1 : 0);

				if (!isWalkable)
				{
					var tree:Object = cache.loadModel(Res.model.environment.tree.tree);
					addToWorldPoint(tree, i, j, 0, 0.9 + Math.random() * 0.5, Math.random() * Math.PI * 2);
				}
			}
		}

		graph = new Graph(graphArray, { diagonal: true });
	}

	public function addToWorldPoint(model:Object, x:Float, y:Float, z:Float = 1, scale = 1., rotation = 0.):Void
	{
		model.setPosition(x, y, z);
		model.setScale(scale);
		model.setRotation(0, 0, rotation);
		addChild(model);
	}

	public function getRandomWalkablePoint():SimplePoint
	{
		var getRandomPoint = function () return { x: Math.floor(Math.random() * graph.grid.length), y: Math.floor(Math.random() * graph.grid[0].length) };

		var result = getRandomPoint();
		while (graph.grid[cast result.x][cast result.y].weight != 0)
		{
			result = getRandomPoint();
		}

		return cast result;
	}
}