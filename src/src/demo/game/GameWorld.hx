package demo.game;

import demo.game.GameState.WorldConfig;
import demo.game.js.Graph;
import h3d.mat.Data.Wrap;
import h3d.mat.Material;
import h3d.prim.Cube;
import h3d.prim.ModelCache;
import h3d.scene.Interactive;
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

	public var onWorldClick:Event->Void;
	public var onWorldMouseDown:Event->Void;
	public var onWorldMouseUp:Event->Void;

	var worldConfig:WorldConfig;
	var interact:Interactive;

	public function new(parent, worldConfig:WorldConfig, blockSize:Float, chunkSize:Int, worldSize:Int, ?parent, ?autoCollect = true)
	{
		super(chunkSize, worldSize, parent, autoCollect);
		this.worldConfig = worldConfig;
		this.blockSize = blockSize;

		instance = this;

		generateMap();

		var c = new Cube(worldConfig.map.length, worldConfig.map[0].length, 1);

		interact = new Interactive(c.getCollider(), parent);
		interact.onClick = function (e) { onWorldClick(e); };
		interact.onPush = function (e) { onWorldMouseDown(e); };
		interact.onRelease = function (e) { onWorldMouseUp(e); };
	}

	public function generateMap():Void
	{
		var graphArray = [];

		var cache:ModelCache = new ModelCache();

		var indexI = worldConfig.map.length - 1;
		for (i in 0...worldConfig.map.length)
		{
			var indexJ = worldConfig.map[0].length - 1;
			graphArray.push([]);
			for (j in 0...worldConfig.map[0].length)
			{
				switch(worldConfig.map[indexI][indexJ])
				{
					case 2:
						var tree:Object = cache.loadModel(Res.model.environment.tree.tree);
						addToWorldPoint(tree, i, indexJ, 0, 0.9 + Math.random() * 0.5, Math.random() * Math.PI * 2);

					case _:
				}

				graphArray[i].push(worldConfig.map[indexI][indexJ] == 1 || worldConfig.map[indexI][indexJ] == 2 ? 0 : 1);
				indexJ--;
			}
			indexI--;
		}

		for (o in worldConfig.staticObjects)
		{
			var instance:Object = cache.loadModel(Asset.getStaticObject(o.name));
			addToWorldPoint(instance, o.x, o.y, o.z, o.scale, o.rotation);
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
		while (graph.grid[cast result.x][cast result.y].weight != 1)
		{
			result = getRandomPoint();
		}

		return cast result;
	}
}