package levelup.game;

import h3d.Vector;
import h3d.col.Point;
import h3d.mat.BlendMode;
import h3d.mat.Texture;
import h3d.prim.Grid;
import h3d.prim.Plane2D;
import h3d.prim.Polygon;
import h3d.prim.UV;
import h3d.shader.Displacement;
import h3d.shader.NormalMap;
import haxe.crypto.Base64;
import hxd.BitmapData;
import hxd.PixelFormat;
import hxd.Pixels;
import hxd.fmt.fbx.Geometry;
import levelup.TerrainAssets.TerrainConfig;
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
import levelup.shader.AlphaMask;
import levelup.util.GeomUtil3D;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameWorld extends World
{
	public var id(default, never):UInt = Math.floor(Math.random() * 1000);

	public static var instance:GameWorld;

	public var graph:Graph;
	public var heightMap:BitmapData;
	public var heightGrid:Array<Point>;
	public var terrainLayers:Array<Mesh> = [];

	public var blockSize:Float;

	public var onClickOnUnit:BaseUnit->Void;

	public var onWorldClick:Event->Void;
	public var onWorldMouseDown:Event->Void;
	public var onWorldMouseUp:Event->Void;
	public var onWorldMouseMove:Event->Void;
	public var onWorldWheel:Event->Void;

	public var units(default, null):Array<BaseUnit> = [];
	public var regionDatas(default, null):Array<RegionData> = [];

	public var onUnitEntersToRegion:Region->BaseUnit->Void = null;
	public var onUnitLeavesFromRegion:Region->BaseUnit->Void = null;

	public var worldConfig(default, null):WorldConfig;

	var interact:Interactive;
	var isWorldGraphDirty:Bool = false;
	var lastRerouteTime:Float = 0;
	var lastUpdateTime:Float = 0;
	var heightPositionFrequency = 20;

	public function new(parent, worldConfig:WorldConfig, blockSize:Float, chunkSize:Int, worldSize:Int, ?parent, ?autoCollect = true)
	{
		super(chunkSize, worldSize, parent, autoCollect);
		this.worldConfig = worldConfig;
		this.blockSize = blockSize;

		instance = this;

		/*heightMap = new BitmapData(cast worldConfig.size.y * 2, cast worldConfig.size.x * 2);
		heightMap.fill(0, 0, bmp.width, bmp.height, 0x00000000);*/
		heightMap = Res.texture.hm.toBitmap();
		heightMap.lock();

		addStaticTerrainLayer(TerrainAssets.getTerrain(worldConfig.baseTerrainId));

		if (worldConfig.terrainLayers != null)
		{
			for (l in worldConfig.terrainLayers)
			{
				addTerrainLayer(TerrainAssets.getTerrain(l.textureId), l.texture);
			}
		}

		//updateTerrainByHeightMap();

		generateMap();

		interact = new Interactive(terrainLayers[0].getCollider(), parent);
		interact.enableRightButton = true;
		interact.onClick = function (e) { onWorldClick(e); };
		interact.onPush = function (e) { onWorldMouseDown(e); };
		interact.onRelease = function (e) { onWorldMouseUp(e); };
		interact.onMove = function (e) { onWorldMouseMove(e); };
		interact.onWheel = function (e) { onWorldWheel(e); };

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

	private function addStaticTerrainLayer(terrainConfig:TerrainConfig)
	{
		var layer = new Grid(cast worldConfig.size.y, cast worldConfig.size.x);
		layer.addNormals();
		layer.addUVs();
		layer.uvScale(30, 30);

		heightGrid = layer.points;
		setGridByHeightMap(layer);

		var mesh = new Mesh(layer, Material.create(terrainConfig.texture), parent);
		mesh.material.texture.wrap = Wrap.Repeat;

		terrainLayers.push(mesh);
	}

	public function addTerrainLayer(terrainConfig:TerrainConfig, alphaMap:String = null)
	{
		var layer = new Grid(cast worldConfig.size.y, cast worldConfig.size.x);
		layer.addNormals();
		layer.addUVs();
		layer.uvScale(30, 30);

		setGridByHeightMap(layer);

		var bmp = new BitmapData(cast worldConfig.size.y * 2, cast worldConfig.size.x * 2);
		bmp.fill(0, 0, bmp.width, bmp.height, 0x00000000);

		if (alphaMap != null)
			bmp.setPixels(new Pixels(bmp.width, bmp.height, Base64.decode(alphaMap), PixelFormat.RGBA));

		var alphaMask = new AlphaMask(Texture.fromBitmap(bmp));
		alphaMask.uvScale.set(0.03333, 0.03333);

		var mesh = new Mesh(layer, Material.create(terrainConfig.texture), parent);
		mesh.material.mainPass.addShader(alphaMask);
		mesh.material.texture.wrap = Wrap.Repeat;
		mesh.material.blendMode = BlendMode.Alpha;
		mesh.z = 0.05 * terrainLayers.length;

		terrainLayers.push(mesh);
	}

	function setGridByHeightMap(g:Grid)
	{
		for (n in g.points)
		{
			var pixelIntensity = (heightMap.getPixel(cast n.x, cast n.y) >> 16) & 0xFF;
			n.z = pixelIntensity / 255 * 5;
		}
	}

	public function changeBaseTerrain(terrainId:String)
	{
		var terrainConfig = TerrainAssets.getTerrain(terrainId);

		var baseLayer = terrainLayers[0];
		baseLayer.material.texture = terrainConfig.texture;
		baseLayer.material.texture.wrap = Wrap.Repeat;
	}

	public function generateMap():Void
	{
		var graphArray = [];

		var cache:ModelCache = new ModelCache();

		for (i in 0...cast worldConfig.size.y)
		{
			graphArray.push([]);
			for (j in 0...cast worldConfig.size.x)
			{
				graphArray[i].push(worldConfig.pathFindingMap[i][j] == 1 || worldConfig.pathFindingMap[i][j] == 2 ? 0 : 1);
			}
		}

		for (o in worldConfig.staticObjects)
		{
			var instance:Object = cache.loadModel(Asset.getAsset(o.id).model);
			addToWorldPoint(instance, o.x, o.y, o.z, o.scale, o.rotation);
		}

		graph = new Graph(graphArray, { diagonal: true });
	}

	public function resetWorldWeight()
	{
		var indexI = worldConfig.pathFindingMap.length - 1;
		for (i in 0...worldConfig.pathFindingMap.length)
		{
			var indexJ = worldConfig.pathFindingMap[0].length - 1;
			for (j in 0...worldConfig.pathFindingMap[0].length)
			{
				graph.grid[i][j].weight = worldConfig.pathFindingMap[indexI][j] == 1 || worldConfig.pathFindingMap[indexI][j] == 2 ? 0 : 1;
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

		if (now - lastUpdateTime >= heightPositionFrequency)
		{
			lastUpdateTime = now;
			for (c in children) c.z = GeomUtil3D.getHeightByPosition(heightGrid, c.x, c.y);
		}

		//resetWorldWeight();
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

					if (
						distance < uA.config.unitSize + uB.config.unitSize
						&& (
							(!uA.config.isFlyingUnit && !uB.config.isFlyingUnit)
							|| (uA.config.isFlyingUnit && uB.config.isFlyingUnit)
						)
					){
						var angle = GeomUtil.getAngle(uA.getPosition(), uB.getPosition());
						var cosAngle = Math.cos(angle);
						var sinAngle = Math.sin(angle);
						var uAPower = 1 * (uA.config.unitSize / uB.config.unitSize);
						var uBPower = 1 * (uA.config.unitSize / uB.config.unitSize);

						switch ([uA.state.value, uB.state.value])
						{
							case [UnitState.MoveTo | UnitState.AttackMoveTo | UnitState.AttackRequested, UnitState.Idle]: uAPower = 2; uBPower = 0;
							case [UnitState.Idle, UnitState.MoveTo | UnitState.AttackMoveTo | UnitState.AttackRequested]: uAPower = 0; uBPower = 2;

							case [UnitState.MoveTo | UnitState.AttackMoveTo | UnitState.AttackRequested, UnitState.AttackTriggered]: uAPower = 1; uBPower = 0;
							case [UnitState.AttackTriggered, UnitState.MoveTo | UnitState.AttackMoveTo | UnitState.AttackRequested]: uAPower = 0; uBPower = 1;

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