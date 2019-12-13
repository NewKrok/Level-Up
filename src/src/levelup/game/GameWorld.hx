package levelup.game;

import h3d.Quat;
import h3d.Vector;
import h3d.col.Point;
import h3d.mat.BlendMode;
import h3d.mat.Data.Wrap;
import h3d.mat.Material;
import h3d.mat.Texture;
import h3d.prim.Grid;
import h3d.prim.ModelCache;
import h3d.prim.Sphere;
import h3d.scene.Interactive;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.scene.Scene;
import h3d.scene.World;
import h3d.scene.fwd.DirLight;
import haxe.crypto.Base64;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.BitmapData;
import hxd.Event;
import hxd.PixelFormat;
import hxd.Pixels;
import hxd.res.Model;
import levelup.Asset.AssetConfig;
import levelup.TerrainAssets.TerrainConfig;
import levelup.game.GameState.WorldConfig;
import levelup.game.js.Graph;
import levelup.game.unit.BaseUnit;
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
	public var heightGridCache:Array<Float> = null;
	public var terrainLayers:Array<Mesh> = [];

	public var blockSize:Float;

	public var onClickOnUnit:BaseUnit->Void;

	public var onWorldClick:Event->Void;
	public var onWorldMouseDown:Event->Void;
	public var onWorldMouseUp:Event->Void;
	public var onWorldMouseMove:Event->Void;
	public var onWorldWheel:Event->Void;

	public var units(default, null):Array<BaseUnit> = [];
	public var staticObjects(default, null):Array<StaticObject> = [];
	public var regionDatas(default, null):Array<RegionData> = [];

	public var onUnitEntersToRegion:Region->BaseUnit->Void = null;
	public var onUnitLeavesFromRegion:Region->BaseUnit->Void = null;

	public var worldConfig(default, null):WorldConfig;

	var interact:Interactive;
	var isWorldGraphDirty:Bool = false;
	var lastRerouteTime:Float = 0;

	var sunAndMoon:DirLight;
	var sunObj:Mesh;
	var moonObj:Mesh;
	var sunAngle = Math.PI;
	var sunAndMoonOffset = -50;
	var dayColor:Vector = new Vector(1, 1, 1, 1);
	var NightColor:Vector = new Vector(0.2, 0.2, 0.6, 1);
	var DawnColor:Vector = new Vector(0.5, 0.5, 0.5, 1);
	var SunsetColor:Vector = new Vector(1, 0.8, 0.2, 1);
	var dayTimeSpeed:Float = Math.PI / 1000;

	public function new(parent, worldConfig:WorldConfig, blockSize:Float, chunkSize:Int, worldSize:Int, ?parent, ?autoCollect = true)
	{
		super(chunkSize, worldSize, parent, autoCollect);
		this.worldConfig = worldConfig;
		this.blockSize = blockSize;

		instance = this;

		heightMap = new BitmapData(cast worldConfig.size.y * 2, cast worldConfig.size.x * 2);
		heightMap.fill(0, 0, heightMap.width, heightMap.height, 0x333333);

		if (worldConfig.heightMap != null)
		{
			heightMap.setPixels(new Pixels(heightMap.width, heightMap.height, Base64.decode(worldConfig.heightMap), PixelFormat.RGBA));
		}

		addStaticTerrainLayer(TerrainAssets.getTerrain(worldConfig.baseTerrainId));

		if (worldConfig.terrainLayers != null)
		{
			for (l in worldConfig.terrainLayers)
			{
				addTerrainLayer(TerrainAssets.getTerrain(l.textureId), l.texture);
			}
		}

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

		sunAndMoon = new DirLight(null, parent);
		sunAndMoon.color = new Vector(0.9, 0.9, 0.9);
		var s = new Sphere();
		s.addNormals();
		s.addUVs();
		sunObj = new Mesh(s, Material.create(Texture.fromColor(0xFFFF00)), parent);
		sunObj.material.castShadows = false;
		sunObj.material.receiveShadows = false;

		var s = new Sphere();
		s.addNormals();
		s.addUVs();
		moonObj = new Mesh(s, Material.create(Texture.fromColor(0x0000FF)), parent);
		moonObj.material.castShadows = false;
		moonObj.material.receiveShadows = false;
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
		mesh.material.castShadows = false;
		//mesh.z = terrainLayers.length * 0.000001;
		mesh.z = terrainLayers.length * 0.05;
		terrainLayers.push(mesh);
	}

	function setGridByHeightMap(g:Grid)
	{
		var hasCache = heightGridCache != null;
		if (!hasCache)
		{
			heightGridCache = [];
			heightMap.lock();
		}

		for (i in 0...g.points.length)
		{
			var point = g.points[i];
			if (hasCache) point.z = heightGridCache[i];
			else
			{
				var pixelIntensity = (heightMap.getPixel(cast point.x, cast point.y) >> 16) & 0xFF;
				var calculatedZ = pixelIntensity / 255 * 10;
				heightGridCache.push(calculatedZ);
				point.z = calculatedZ;
			}
		}

		if (!hasCache) heightMap.unlock();
	}

	public function updateHeightMap()
	{
		heightGridCache = null;

		for (l in terrainLayers)
		{
			var g:Grid = cast l.primitive;
			g.buffer = null;
			setGridByHeightMap(g);
		}
		heightGrid = cast(terrainLayers[0].primitive, Grid).points;
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

		/*for (o in worldConfig.staticObjects)
		{
			staticObjects.push({
				instance: instance,
				zOffset: o.zOffset
			});
		}*/

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

	public function addToWorldPoint(model:Object, x:Float, y:Float, z:Float = 1, scale = 1., rotation:Quat = null):Void
	{
		model.setPosition(x, y, z);
		model.setScale(scale);
		if (rotation != null) model.setRotationQuat(rotation);
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

		updateDayTime();

		var isRerouteNeeded = isWorldGraphDirty && now - lastRerouteTime >= 3000;
		if (isRerouteNeeded) lastRerouteTime = now;

		for (u in units)
		{
			if (isRerouteNeeded) u.reroute();
			u.view.z = GeomUtil3D.getHeightByPosition(heightGrid, u.view.x, u.view.y) + u.config.zOffset;
			u.update(d);
		}

		for (o in staticObjects) o.instance.z = GeomUtil3D.getHeightByPosition(heightGrid, o.instance.x, o.instance.y) + o.zOffset;

		resetWorldWeight();
		calculateUnitInteractions(d);
		checkRegionDatas();
	}

	function updateDayTime()
	{
		var isDayTime = sunAngle > 0 && sunAngle < Math.PI;

		var sunAndMoonAngle = isDayTime ? sunAngle + Math.PI : sunAngle;
		var sunAndMoonX = -sunAndMoonOffset;
		var sunAndMoonY = worldConfig.size.y * 0.6 * Math.cos(sunAndMoonAngle);
		var sunAndMoonZ = worldConfig.size.y * 0.6 * Math.sin(sunAndMoonAngle);
		sunAndMoon.setDirection(new Vector(sunAndMoonX, sunAndMoonY, sunAndMoonZ));

		var dayTimeColorPercent = 1.0;
		var ambientRed = isDayTime ? dayColor.x : NightColor.x;
		var ambientGreen = isDayTime ? dayColor.y : NightColor.y;
		var ambientBlue = isDayTime ? dayColor.z : NightColor.z;
		var transitionAngle = Math.PI / 6;

		if (sunAngle < transitionAngle)
		{
			dayTimeColorPercent = Math.min(sunAngle / transitionAngle, 1);
			ambientRed = DawnColor.x + dayTimeColorPercent * (dayColor.x - DawnColor.x);
			ambientGreen = DawnColor.y + dayTimeColorPercent * (dayColor.y - DawnColor.y);
			ambientBlue = DawnColor.z + dayTimeColorPercent * (dayColor.z - DawnColor.z);
		}
		else if (sunAngle > Math.PI - transitionAngle && sunAngle < Math.PI)
		{
			dayTimeColorPercent = Math.min((sunAngle - (Math.PI - transitionAngle)) / transitionAngle, 1);
			ambientRed = dayColor.x + dayTimeColorPercent * (SunsetColor.x - dayColor.x);
			ambientGreen = dayColor.y + dayTimeColorPercent * (SunsetColor.y - dayColor.y);
			ambientBlue = dayColor.z + dayTimeColorPercent * (SunsetColor.z - dayColor.z);
		}
		else if (sunAngle > Math.PI && sunAngle < Math.PI + transitionAngle)
		{
			dayTimeColorPercent = Math.min((sunAngle - Math.PI) / transitionAngle, 1);
			ambientRed = SunsetColor.x + dayTimeColorPercent * (NightColor.x - SunsetColor.x);
			ambientGreen = SunsetColor.y + dayTimeColorPercent * (NightColor.y - SunsetColor.y);
			ambientBlue = SunsetColor.z + dayTimeColorPercent * (NightColor.z - SunsetColor.z);
		}
		else if (sunAngle > Math.PI * 2 - transitionAngle)
		{
			dayTimeColorPercent = Math.min((sunAngle - (Math.PI * 2 - transitionAngle)) / transitionAngle, 1);
			ambientRed = NightColor.x + dayTimeColorPercent * (DawnColor.x - NightColor.x);
			ambientGreen = NightColor.y + dayTimeColorPercent * (DawnColor.y - NightColor.y);
			ambientBlue = NightColor.z + dayTimeColorPercent * (DawnColor.z - NightColor.z);
		}

		cast(parent, Scene).lightSystem.ambientLight.set(ambientRed, ambientGreen, ambientBlue, 1);
		sunAndMoon.color.set(ambientRed, ambientGreen, ambientBlue, 1);

		var sunObjAngle = sunAngle;
		sunObj.x = worldConfig.size.x / 2 + sunAndMoonOffset;
		sunObj.y = worldConfig.size.x / 2 + worldConfig.size.y * 0.6 * Math.cos(sunObjAngle);
		sunObj.z = worldConfig.size.y * 0.6 * Math.sin(sunObjAngle);

		var moonObjAngle = sunAngle + Math.PI;
		moonObj.x = sunObj.x;
		moonObj.y = worldConfig.size.x / 2 + worldConfig.size.y * 0.6 * Math.cos(moonObjAngle);
		moonObj.z = worldConfig.size.y * 0.6 * Math.sin(moonObjAngle);

		sunAngle += dayTimeSpeed;

		if (sunAngle > Math.PI * 2) sunAngle -= Math.PI * 2;
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

typedef StaticObject =
{
	var instance:Object;
	var zOffset:Float;
}