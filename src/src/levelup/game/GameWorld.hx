package levelup.game;

import levelup.game.GameState.WorldConfig;
import levelup.game.unit.BaseUnit;
import levelup.game.js.Graph;
import h2d.Scene;
import h3d.col.Bounds;
import h3d.mat.Data.Wrap;
import h3d.mat.Material;
import h3d.prim.Cube;
import h3d.prim.ModelCache;
import h3d.scene.Interactive;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.scene.World;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameWorld extends World
{
	public var id(default, never):UInt = Math.floor(Math.random() * 1000);

	public static var instance:GameWorld;

	public var graph:Graph;

	public var blockSize:Float;

	public var onClickOnUnit:BaseUnit->Void;

	public var onWorldClick:Event->Void;
	public var onWorldMouseDown:Event->Void;
	public var onWorldMouseUp:Event->Void;
	public var onWorldMouseMove:Event->Void;

	public var units(default, null):Array<BaseUnit> = [];
	public var regionDatas(default, null):Array<RegionData> = [];

	public var onUnitEntersToRegion:Region->BaseUnit->Void = null;
	public var onUnitLeavesFromRegion:Region->BaseUnit->Void = null;

	var worldConfig:WorldConfig;
	var interact:Interactive;
	var isWorldGraphDirty:Bool = false;
	var lastRerouteTime:Float = 0;

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
		interact.onMove = function (e) { onWorldMouseMove(e); };

		for (r in worldConfig.regions)
		{
			var rData = new RegionData(
				r,
				u -> if (onUnitEntersToRegion != null) onUnitEntersToRegion(r, u),
				u -> if (onUnitLeavesFromRegion != null) onUnitLeavesFromRegion(r, u)
			);
			regionDatas.push(rData);
		}
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

	public function resetWorldWeight()
	{
		var indexI = worldConfig.map.length - 1;
		for (i in 0...worldConfig.map.length)
		{
			var indexJ = worldConfig.map[0].length - 1;
			for (j in 0...worldConfig.map[0].length)
			{
				graph.grid[i][j].weight = worldConfig.map[indexI][indexJ] == 1 || worldConfig.map[indexI][indexJ] == 2 ? 0 : 1;
				indexJ--;
			}
			indexI--;
		}
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
		var getRandomPoint = function () return { x: Math.floor(Math.random() * graph.grid[0].length), y: Math.floor(Math.random() * graph.grid.length) };

		var result = getRandomPoint();
		while (graph.grid[cast result.y][cast result.x].weight != 1) result = getRandomPoint();

		return cast result;
	}

	public function update(d:Float)
	{
		var now = Date.now().getTime();

		var isRerouteNeeded = isWorldGraphDirty && now - lastRerouteTime >= 3000;
		if (isRerouteNeeded) lastRerouteTime = now;

		for (u in units)
		{
			if (isRerouteNeeded) u.reroute();
			u.update(d);
		}

		resetWorldWeight();
		calculateUnitInteractions(d);
		checkRegionDatas();
	}

	function checkRegionDatas()
	{
		for (r in regionDatas)
		{
			var collidedUnits = [];
			for (u in units)
			{
				var p = u.getPosition();
				if (
					p.x + u.config.unitSize > r.data.x && p.x - u.config.unitSize < r.data.x + r.data.width
					&& p.y + u.config.unitSize > r.data.y && p.y - u.config.unitSize < r.data.y + r.data.height
				){
					collidedUnits.push(u);
				}
			}

			r.updateCollidedUnits(collidedUnits);
		}
	}

	function calculateUnitInteractions(d:Float)
	{
		for (uA in units)
		{
			var p = uA.getWorldPoint();
			if (graph.grid[cast p.y][cast p.x].weight != 0)
			{
				var indexesY = [0];
				var indexesX = [0];
				for (i in indexesY)
				{
					for (j in indexesX)
					{
						if (p.x + j > 0 && p.x + j < graph.grid[0].length && p.y + i > 0 && p.y + i < graph.grid.length)
						{
							graph.grid[cast p.y + i][cast p.x + j].weight = 0;
						}
					}
				}
				isWorldGraphDirty = true;
			}

			var bestDistance = 999999.;
			var bestUnit = null;

			for (uB in units)
			{
				if (uA != uB && uA.state != Dead && uB.state != Dead)
				{
					var distance = GeomUtil.getDistance(uA.getPosition(), uB.getPosition());

					if (uA.owner != uB.owner && distance < bestDistance && distance <= uA.config.detectionRange)
					{
						bestDistance = distance;
						bestUnit = uB;
					}

					if (distance < uA.config.unitSize + uB.config.unitSize)
					{
						var angle = GeomUtil.getAngle(uA.getPosition(), uB.getPosition());
						var cosAngle = Math.cos(angle);
						var sinAngle = Math.sin(angle);
						var uAPower = 2 * (uB.config.unitSize / uA.config.unitSize);
						var uBPower = 2 * (uB.config.unitSize / uA.config.unitSize);

						switch ([uA.state.value, uB.state.value])
						{
							case [UnitState.MoveTo | UnitState.AttackMoveTo | UnitState.AttackRequested, UnitState.Idle]: uAPower = 4; uBPower = -1;
							case [UnitState.Idle, UnitState.MoveTo | UnitState.AttackMoveTo | UnitState.AttackRequested]: uAPower = -1; uBPower = 4;

							case [UnitState.MoveTo | UnitState.AttackMoveTo | UnitState.AttackRequested, UnitState.AttackTriggered]: uAPower = 3; uBPower = -1;
							case [UnitState.AttackTriggered, UnitState.MoveTo | UnitState.AttackMoveTo | UnitState.AttackRequested]: uAPower = -1; uBPower = 3;

							case _:
						}

						uA.view.x -= uBPower * d * cosAngle;
						uA.view.y -= uBPower * d * sinAngle;
						uB.view.x += uAPower * d * cosAngle;
						uB.view.y += uAPower * d * sinAngle;
						uA.restartMoveRoutine();
						uB.restartMoveRoutine();
					}
				}
			}

			if (bestUnit != null) uA.setNearestTarget(bestUnit);
		}
	}

	public function posToWorldPoint (pos:SimplePoint):SimplePoint
	{
		return { x: Math.floor(pos.x / blockSize), y: Math.floor(pos.y / blockSize) };
	}

	public function addEntity(o:Dynamic)
	{
		if (Std.is(o, BaseUnit))
		{
			var u:BaseUnit = cast o;
			u.onClick = onClickOnUnit;
			units.push(u);
		}
	}

	override public function dispose()
	{
		super.dispose();

		for (i in 0...units.length)
		{
			units[i].dispose();
			units[i] = null;
		}
		units = null;

		for (i in 0...regionDatas.length)
		{
			regionDatas[i] = null;
		}
		regionDatas = null;

		interact.removeChildren();
		interact.onClick = null;
		interact.onPush = null;
		interact.onRelease = null;
		interact.onMove = null;
		interact.remove();
		interact = null;
	}
}

typedef Region =
{
	var id:String;
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
}