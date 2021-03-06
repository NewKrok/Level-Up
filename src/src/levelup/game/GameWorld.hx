package levelup.game;

import h2d.Anim;
import h2d.Bitmap;
import h2d.Tile;
import h3d.Matrix;
import h3d.Quat;
import h3d.Vector;
import h3d.col.Bounds;
import h3d.col.Point;
import h3d.mat.BlendMode;
import h3d.mat.Data.MipMap;
import h3d.mat.Data.TextureFlags;
import h3d.mat.Data.TextureFormat;
import h3d.mat.Data.Wrap;
import h3d.mat.Material;
import h3d.mat.Texture;
import h3d.parts.GpuParticles;
import h3d.pass.DefaultShadowMap;
import h3d.prim.Cube;
import h3d.prim.Cylinder;
import h3d.prim.Grid;
import h3d.prim.Sphere;
import h3d.scene.Box;
import h3d.scene.Interactive;
import h3d.scene.Mesh;
import h3d.scene.Object;
import h3d.scene.Scene;
import h3d.scene.World;
import h3d.scene.fwd.DirLight;
import h3d.shader.AlphaMap;
import h3d.shader.AnimatedTexture;
import h3d.shader.ColorKey;
import h3d.shader.CubeMap;
import h3d.shader.NormalMap;
import haxe.crypto.Base64;
import hpp.heaps.HppG;
import hpp.util.GeomUtil;
import hpp.util.GeomUtil.SimplePoint;
import hxd.BitmapData;
import hxd.Event;
import hxd.Key;
import hxd.PixelFormat;
import hxd.Pixels;
import hxd.Res;
import js.Browser;
import levelup.TerrainAssets.TerrainConfig;
import levelup.TerrainAssets.TerrainEffect;
import levelup.game.GameState.WorldConfig;
import levelup.game.Projectile.ProjectileState;
import levelup.game.js.AStar.GridNode;
import levelup.game.js.Graph;
import levelup.game.unit.BaseUnit;
import levelup.heaps.component.car.Car;
import levelup.heaps.component.car.CarController;
import levelup.shader.ForcedZIndex;
import levelup.shader.Hovering;
import levelup.shader.KillColor;
import levelup.shader.TerrainShader;
import levelup.shader.Wave;
import levelup.util.GeomUtil3D;
import lzstring.LZString;
import levelup.extern.Cannon.CannonWorld;
import levelup.extern.Cannon.CannonSAPBroadphase;
import levelup.extern.Cannon.CannonMaterial;
import levelup.extern.Cannon.CannonContactMaterial;
import levelup.extern.Cannon.CannonBox;
import levelup.extern.Cannon.CannonBody;
import levelup.extern.Cannon.CannonVec3;
import levelup.extern.Cannon.CannonHeightfield;

using Lambda;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameWorld extends World
{
	public var id(default, never):UInt = Math.floor(Math.random() * 1000);

	public static var instance:GameWorld;

	public var s3d:Scene;

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
	public var projectiles(default, null):Array<Projectile> = [];
	public var staticObjects(default, null):Array<StaticObject> = [];
	public var regionDatas(default, null):Array<RegionData> = [];

	public var onUnitEntersToRegion:Region->BaseUnit->Void = null;
	public var onUnitLeavesFromRegion:Region->BaseUnit->Void = null;

	public var size(default, null):SimplePoint;
	public var worldConfig(default, null):WorldConfig;

	var interact:Interactive;
	var isWorldGraphDirty:Bool = false;
	var lastRerouteTime:Float = 0;
	var pathBlocksByUnits:Array<GridNode> = [];

	public var skybox:Mesh;

	var shadow:DefaultShadowMap;
	var shadowColor:Vector = new Vector(0.6, 0.6, 0.6);
	var shadowPowerPercent:Float = 1;
	var sunAndMoon:DirLight;
	var moonLight:DirLight;
	var sunObj:Mesh;
	var moonObj:Mesh;
	var sunAngle = Math.PI;
	var sunAndMoonOffset:Float = 0.0;
	var dayColor:Vector = new Vector();
	var nightColor:Vector = new Vector();
	var sunsetColor:Vector = new Vector();
	var dawnColor:Vector = new Vector();
	var dayTimeSpeed:Float = Math.PI / 200;
	var isDayTimeEnabled:Bool = true;

	var globalWeather:GpuParticles;
	var fadeFilter:h2d.Object;

	public function new(s3d:Scene, size:SimplePoint, worldConfig:WorldConfig, blockSize:Float, chunkSize:Int, worldSize:Int, ?autoCollect = true)
	{
		this.s3d = s3d;
		super(chunkSize, worldSize, s3d, autoCollect);
		this.size = size;
		this.worldConfig = worldConfig;
		this.blockSize = blockSize;

		createSkybox(worldConfig.skybox.id);

		instance = this;

		heightMap = new BitmapData(cast size.y, cast size.x);
		heightMap.fill(0, 0, heightMap.width, heightMap.height, 0xFFFFFF);

		if (worldConfig.heightMap != null)
		{
			heightMap.setPixels(new Pixels(heightMap.width, heightMap.height, Base64.decode(worldConfig.heightMap), PixelFormat.RGBA));
		}

		if (worldConfig.terrainLayers != null)
		{
			var index = 0;
			for (l in worldConfig.terrainLayers)
			{
				if (index == 0) addStaticTerrainLayer(TerrainAssets.getTerrain(l.textureId), l.uvScale);
				else addTerrainLayer(TerrainAssets.getTerrain(l.textureId), l.uvScale, l.texture);
				index++;
			}
		}

		var graphArray = [for (i in 0...cast size.x) [for (j in 0...cast size.y) 1]];
		graph = new Graph(graphArray, { diagonal: true });

		interact = new Interactive(terrainLayers[0].getCollider(), s3d);
		interact.enableRightButton = true;
		interact.onClick = e -> if (onWorldClick != null) onWorldClick(e);
		interact.onPush = e -> if (onWorldMouseDown != null) onWorldMouseDown(e);
		interact.onRelease = e -> if (onWorldMouseUp != null) onWorldMouseUp(e);
		interact.onMove = e -> if (onWorldMouseMove != null) onWorldMouseMove(e);
		interact.onWheel = e -> if (onWorldWheel != null) onWorldWheel(e);

		for (r in worldConfig.regions)
		{
			var rData = new RegionData(
				r,
				u -> if (onUnitEntersToRegion != null) onUnitEntersToRegion(r, u),
				u -> if (onUnitLeavesFromRegion != null) onUnitLeavesFromRegion(r, u)
				);
			regionDatas.push(rData);
		}

		shadow = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.bias *= 0.1;
		shadow.color = shadowColor;

		sunAndMoon = new DirLight(null, s3d);
		var s = new Sphere();
		s.addNormals();
		s.addUVs();
		sunObj = new Mesh(s, Material.create(Texture.fromColor(0xFFFF00)), s3d);
		sunObj.material.castShadows = false;
		sunObj.material.receiveShadows = false;

		// Why can't have 2 dirlights in the same time?
		//moonLight = new DirLight(null, s3d);
		var s = new Sphere();
		s.addNormals();
		s.addUVs();
		moonObj = new Mesh(s, Material.create(Texture.fromColor(0x0000FF)), s3d);
		moonObj.material.castShadows = false;
		moonObj.material.receiveShadows = false;

		setTime(worldConfig.general.startingTime);
		setSunAndMoonOffsetPercent(worldConfig.light.sunAndMoonOffsetPercent);
		setShadowPowerPercent(worldConfig.light.shadowPower);
		setDayColor(worldConfig.light.dayColor);
		setNightColor(worldConfig.light.nightColor);
		setSunsetColor(worldConfig.light.sunsetColor);
		setDawnColor(worldConfig.light.dawnColor);

		addWeatherEffects();

		physicsWorld = new CannonWorld();
		physicsWorld.broadphase = new CannonSAPBroadphase(physicsWorld);
		physicsWorld.gravity.set(0, 0, -10);
		physicsWorld.defaultContactMaterial.friction = 0;

		car = new Car(s3d, physicsWorld, CarData.getConfig("car.monstertruck11a"));
		car.setPosition(15, 20, 5);
		carController = new CarController();
		carController.setTarget(car);

		var matrix = [];
		var gridIndex = 0;
		for (i in 0...Math.floor(size.x))
		{
			matrix.push([]);
			for (j in 0...Math.floor(size.y))
			{
				matrix[i].push(0.0);
			}
		}

		for (i in 0...Math.floor(size.x))
		{
			for (j in 0...Math.floor(size.y))
			{
				matrix[j][i] = Math.max(0, heightGridCache[gridIndex++]);
			}
		}

		var hfShape = new CannonHeightfield(matrix, {
			elementSize: 1
		});
		var hfBody = new CannonBody({ mass: 0 });
		hfBody.addShape(hfShape);
		physicsWorld.addBody(hfBody);
	}

	var physicsWorld:CannonWorld;
	public var car:Car;
	public var carController:CarController;

	public function setSunAndMoonOffsetPercent(value:Float):Void sunAndMoonOffset = -100 + (size.x + 200) * (value / 100);
	public function setShadowPowerPercent(value:Float):Void shadowPowerPercent = value;
	public function setDayColor(c:String) dayColor.setColor(Std.parseInt("0x" + c.substr(1)));
	public function setNightColor(c:String) nightColor.setColor(Std.parseInt("0x" + c.substr(1)));
	public function setSunsetColor(c:String) sunsetColor.setColor(Std.parseInt("0x" + c.substr(1)));
	public function setDawnColor(c:String) dawnColor.setColor(Std.parseInt("0x" + c.substr(1)));

	public function createSkybox(skyboxId)
	{
		disposeSkybox();

		var skyboxOrder = [3, 0, 4, 5, 2, 1];
		var skyTexture = new h3d.mat.Texture(512, 512, [Cube, MipMapped]);
		var arr = SkyboxData.getConfig(skyboxId).assets;
		for (i in 0...arr.length)
		{
			skyTexture.uploadPixels(AssetCache.instance.getImage(arr[i]).getPixels(), 0, skyboxOrder[i]);
		}
		skyTexture.mipMap = Linear;

		var sky = new h3d.prim.Sphere(size.x > size.y ? size.x * 2 : size.y * 2, 64, 64);
		sky.addNormals();

		skybox = new Mesh(sky, s3d);
		skybox.defaultTransform = new Matrix();
		skybox.defaultTransform.initRotation(Math.PI / 2, Math.PI / 2, Math.PI / 2);
		skybox.material.mainPass.culling = Front;
		skybox.material.mainPass.addShader(new CubeMap(skyTexture));
		skybox.material.shadows = false;
		skybox.x = size.x / 2;
		skybox.y = size.y / 2;
	}

	private function addStaticTerrainLayer(terrainConfig:TerrainConfig, uvScale:Float)
	{
		if (uvScale == null) uvScale = 1;

		var layer = new Grid(cast size.y, cast size.x);
		layer.addTangents();
		layer.uvScale(30 / uvScale, 30 / uvScale);

		heightGrid = layer.points;
		setGridByHeightMap(layer);

		var mesh = new Mesh(layer, Material.create(AssetCache.instance.getTexture(terrainConfig.textureUrl)), s3d);
		mesh.material.mainPass.addShader(new ForcedZIndex(0));
		mesh.material.mainPass.isStatic = true;
		mesh.material.texture.wrap = Wrap.Repeat;

		if (terrainConfig.normalMapUrl != null)
		{
			var normalMap = AssetCache.instance.getTexture(terrainConfig.normalMapUrl);
			normalMap.wrap = Wrap.Repeat;
			mesh.material.mainPass.addShader(new NormalMap(normalMap));
		}

		terrainLayers.push(mesh);
	}

	public function removeTerrainLayer(index:Int)
	{
		var l = terrainLayers[index];
		l.remove();

		terrainLayers.remove(l);
	}

	public function addTerrainLayer(terrainConfig:TerrainConfig, uvScale:Float, alphaMap:String = null)
	{
		if (uvScale == null) uvScale = 1;

		var layer = new Grid(cast size.y, cast size.x);
		layer.addTangents();
		layer.uvScale(30 / uvScale, 30 / uvScale);

		setGridByHeightMap(layer);

		var bmp = new BitmapData(cast size.y * 2, cast size.x * 2);
		bmp.fill(0, 0, bmp.width, bmp.height, 0x00000000);

		if (alphaMap != null)
			bmp.setPixels(new Pixels(bmp.width, bmp.height, Base64.decode(alphaMap), PixelFormat.RGBA));

		var alphaMask = new AlphaMap(Texture.fromBitmap(bmp));
		alphaMask.uvScale.set(0.03333 * uvScale, 0.03333 * uvScale);

		var mesh = new Mesh(layer, Material.create(AssetCache.instance.getTexture(terrainConfig.textureUrl)), s3d);
		mesh.material.mainPass.addShader(alphaMask);
		mesh.material.mainPass.addShader(new TerrainShader());
		mesh.material.mainPass.isStatic = true;
		mesh.material.texture.wrap = Wrap.Repeat;
		mesh.material.blendMode = BlendMode.Alpha;
		mesh.z = terrainLayers.length * 0.05;

		if (terrainConfig.normalMapUrl != null)
		{
			var normalMap = AssetCache.instance.getTexture(terrainConfig.normalMapUrl);
			normalMap.wrap = Wrap.Repeat;
			mesh.material.mainPass.addShader(new NormalMap(normalMap));
		}

		if (terrainConfig.effects != null)
		{
			for (e in terrainConfig.effects)
			{
				switch (e)
				{
					case TerrainEffect.Wave: mesh.material.mainPass.addShader(new Wave());
					case TerrainEffect.Reflection:
				}
			}
		}

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

		var maxColor = 65793;
		var minColor = 16711423;
		var maxDiff = minColor - maxColor;
		for (i in 0...g.points.length)
		{
			var point = g.points[i];
			if (hasCache) point.z = heightGridCache[i];
			else
			{
				var pixelIntensity:Float = heightMap.getPixel(cast point.x, cast point.y) | 0xFF000000;
				var calculatedZ:Float = 15 + ((pixelIntensity - maxColor) / (maxDiff)) * 20;
				calculatedZ = 2 + 3 * Math.sin(i * 0.001);
				heightGridCache.push(calculatedZ);
				point.z = calculatedZ;
			}
		}

		if (!hasCache)
		{
			heightMap.unlock();
		}
	}

	public function updateHeightMap():Void
	{
		heightGridCache = null;

		for (l in terrainLayers)
		{
			var g:Grid = cast l.primitive;
			g.buffer = null;
			setGridByHeightMap(g);
		}
		heightGrid = cast(terrainLayers[0].primitive, Grid).points;

		interact.shape = terrainLayers[0].getCollider();
	}

	public function changeBaseTerrain(terrainId:String):Void
	{
		var terrainConfig = TerrainAssets.getTerrain(terrainId);

		var baseLayer = terrainLayers[0];
		baseLayer.material.texture = AssetCache.instance.getTexture(terrainConfig.textureUrl);
		baseLayer.material.texture.wrap = Wrap.Repeat;
	}

	public function addWeatherEffects()
	{
		if (worldConfig.globalWeather != 0) setGlobalWeatherEffect(worldConfig.globalWeather);

		//addSnow();
		//addRain();
	}

	public function setGlobalWeatherEffect(v)
	{
		if (globalWeather != null)
		{
			globalWeather.removeGroup(globalWeather.getGroup("base"));
			globalWeather.remove();
			globalWeather = null;
		}

		switch (v)
		{
			case 1: globalWeather = addGlobalSnow();
			//case 2: globalWeather = addGlobalRain();

			case _:
		}
	}

	function addGlobalSnow()
	{
		var parts = new GpuParticles(s3d);
		parts.volumeBounds = Bounds.fromValues( -10, -10, 15, 20, 20, 20);

		var g = parts.addGroup();
		g.name = "base";
		g.size = 0.2;
		g.gravity = 1;
		g.life = 10;
		g.nparts = 5000;
		g.emitMode = CameraBounds;

		return parts;
	}

	function addGlobalRain()
	{
		// TODO improve it
		/*var t = Res.raindrop.toTexture();

		var parts = new GpuParticles(s3d);
		parts.volumeBounds = Bounds.fromValues(-10, -10, 15, 20, 20, 20);
		parts.material.mainPass.depthWrite = false;

		var g = parts.addGroup();
		g.texture = t;
		g.size = 3;
		g.gravity = 30;
		g.speed = 0;
		g.life = 2;
		g.nparts = 1000;
		g.emitMode = CameraBounds;

		return parts;*/
	}

	public function setTime(time:Float):Void
	{
		sunAngle = Math.PI * 2 * (time / 24) - Math.PI / 2;
		if (sunAngle < 0) sunAngle = Math.PI * 2 + sunAngle;
		if (sunAngle > Math.PI * 2) sunAngle -= Math.PI * 2;
		updateDayTime(0);
	}

	public function disableDayTime():Void isDayTimeEnabled = false;

	public function resetWorldWeight()
	{
		for (r in pathBlocksByUnits) r.weight = 1;
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

		physicsWorld.step(1.0 / 60.0, d, 3);
		car.update(d);
		carController.update(d);

		if (!worldConfig.general.hasFixedWorldTime || !isDayTimeEnabled) updateDayTime(d);

		var isRerouteNeeded = isWorldGraphDirty && now - lastRerouteTime >= 3000;
		if (isRerouteNeeded) lastRerouteTime = now;

		for (u in units)
		{
			if (isRerouteNeeded && !u.config.isBuilding) u.reroute();
			u.view.z = GeomUtil3D.getHeightByPosition(heightGrid, u.view.x, u.view.y) + u.config.zOffset;
			u.update(d);
		}

		for (p in projectiles) p.update(d);
		for (o in staticObjects) o.instance.z = GeomUtil3D.getHeightByPosition(heightGrid, o.instance.x, o.instance.y) + o.zOffset;

		if (fadeFilter != null)
		{
			var fadeBmp:Bitmap = cast fadeFilter.getChildAt(0);
			if (fadeBmp.width != HppG.stage2d.width || fadeBmp.height != HppG.stage2d.height)
			{
				fadeBmp.width = HppG.stage2d.width;
				fadeBmp.height = HppG.stage2d.height;
			}
		}

		resetWorldWeight();
		calculateUnitInteractions(d);
		checkRegionDatas();
	}

	function updateDayTime(d:Float)
	{
		var isDayTime = sunAngle > 0 && sunAngle < Math.PI;
		var isInTransitionStartState:Bool = false;
		var isInTransitionFinishState:Bool = false;

		var sunAndMoonAngle = isDayTime ? sunAngle + Math.PI : sunAngle;
		// Revert it when moon light will be fixed
		//var sunAndMoonAngle = sunAngle + Math.PI;
		var sunAndMoonX = -sunAndMoonOffset;
		var sunAndMoonY = size.y * 0.6 * Math.cos(sunAndMoonAngle);
		var sunAndMoonZ = size.y * 0.6 * Math.sin(sunAndMoonAngle);
		sunAndMoon.setDirection(new Vector(sunAndMoonX, sunAndMoonY, sunAndMoonZ));

		/*var moonAngle = sunAndMoonAngle + Math.PI;
		var moonX = -sunAndMoonOffset;
		var moonY = size.y * 0.6 * Math.cos(moonAngle);
		var moonZ = size.y * 0.6 * Math.sin(moonAngle);
		moonLight.setDirection(new Vector(moonX, moonY, moonZ));*/

		var dayTimeColorPercent = 1.0;
		var ambientRed = isDayTime ? dayColor.x : nightColor.x;
		var ambientGreen = isDayTime ? dayColor.y : nightColor.y;
		var ambientBlue = isDayTime ? dayColor.z : nightColor.z;
		var transitionAngle = Math.PI / 6;

		if (sunAngle <= transitionAngle)
		{
			isInTransitionFinishState = true;
			dayTimeColorPercent = Math.min(sunAngle / transitionAngle, 1);
			ambientRed = dawnColor.x + dayTimeColorPercent * (dayColor.x - dawnColor.x);
			ambientGreen = dawnColor.y + dayTimeColorPercent * (dayColor.y - dawnColor.y);
			ambientBlue = dawnColor.z + dayTimeColorPercent * (dayColor.z - dawnColor.z);
		}
		else if (sunAngle > Math.PI - transitionAngle && sunAngle <= Math.PI)
		{
			isInTransitionStartState = true;
			dayTimeColorPercent = Math.min((sunAngle - (Math.PI - transitionAngle)) / transitionAngle, 1);
			ambientRed = dayColor.x + dayTimeColorPercent * (sunsetColor.x - dayColor.x);
			ambientGreen = dayColor.y + dayTimeColorPercent * (sunsetColor.y - dayColor.y);
			ambientBlue = dayColor.z + dayTimeColorPercent * (sunsetColor.z - dayColor.z);
		}
		else if (sunAngle > Math.PI && sunAngle <= Math.PI + transitionAngle)
		{
			isInTransitionFinishState = true;
			dayTimeColorPercent = Math.min((sunAngle - Math.PI) / transitionAngle, 1);
			ambientRed = sunsetColor.x + dayTimeColorPercent * (nightColor.x - sunsetColor.x);
			ambientGreen = sunsetColor.y + dayTimeColorPercent * (nightColor.y - sunsetColor.y);
			ambientBlue = sunsetColor.z + dayTimeColorPercent * (nightColor.z - sunsetColor.z);
		}
		else if (sunAngle >= Math.PI * 2 - transitionAngle)
		{
			isInTransitionStartState = true;
			dayTimeColorPercent = Math.min((sunAngle - (Math.PI * 2 - transitionAngle)) / transitionAngle, 1);
			ambientRed = nightColor.x + dayTimeColorPercent * (dawnColor.x - nightColor.x);
			ambientGreen = nightColor.y + dayTimeColorPercent * (dawnColor.y - nightColor.y);
			ambientBlue = nightColor.z + dayTimeColorPercent * (dawnColor.z - nightColor.z);
		}

		s3d.lightSystem.ambientLight.set(ambientRed, ambientGreen, ambientBlue);
		sunAndMoon.color.set(ambientRed, ambientGreen, ambientBlue);

		var sunObjAngle = sunAngle;
		sunObj.x = sunAndMoonOffset;
		sunObj.y = size.x / 2 + size.y * 0.6 * Math.cos(sunObjAngle);
		sunObj.z = size.y * 0.6 * Math.sin(sunObjAngle);

		var moonObjAngle = sunAngle + Math.PI;
		moonObj.x = sunObj.x;
		moonObj.y = size.x / 2 + size.y * 0.6 * Math.cos(moonObjAngle);
		moonObj.z = size.y * 0.6 * Math.sin(moonObjAngle);

		if (isDayTimeEnabled && !worldConfig.general.hasFixedWorldTime)
		{
			sunAngle += d * dayTimeSpeed;
			if (sunAngle > Math.PI * 2) sunAngle -= Math.PI * 2;
		}

		shadow.power = shadowPowerPercent * 25 * (
						   isInTransitionStartState
						   ? 1 - dayTimeColorPercent
						   : isInTransitionFinishState
						   ? dayTimeColorPercent
						   : 1
					   );
		shadow.blur.radius = isDayTime ? 5 : 25;
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
				)
				{
					collidedUnits.push(u);
				}
			}

			r.updateCollidedUnits(collidedUnits);
		}
	}

	function calculateUnitInteractions(d:Float)
	{
		pathBlocksByUnits = [];
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
							pathBlocksByUnits.push(graph.grid[cast p.y + i][cast p.x + j]);
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
					else if (uA.target == null && uB.target != null && uA.owner == uB.owner && distance <= uA.config.detectionRange)
					{
						bestUnit = uB.target;
					}

					if (
						distance < uA.config.unitSize + uB.config.unitSize
						&& !uA.config.isBuilding
						&& !uB.config.isBuilding
						&& (
							(!uA.config.isFlyingUnit && !uB.config.isFlyingUnit)
							|| (uA.config.isFlyingUnit && uB.config.isFlyingUnit)
						)
					)
					{
						var angle = GeomUtil.getAngle(uA.getPosition(), uB.getPosition());
						var cosAngle = Math.cos(angle);
						var sinAngle = Math.sin(angle);
						var uAPower = 1 * (uA.config.unitSize / uB.config.unitSize);
						var uBPower = 1 * (uA.config.unitSize / uB.config.unitSize);

						switch ([uA.state.value, uB.state.value])
						{
							case [UnitState.MoveTo | UnitState.AttackRequested, UnitState.Idle]: uAPower = 1; uBPower = 0;
							case [UnitState.Idle, UnitState.MoveTo | UnitState.AttackRequested]: uAPower = 0; uBPower = 1;

							case [UnitState.MoveTo | UnitState.AttackRequested, UnitState.AttackTriggered]: uAPower = 0.5; uBPower = 0;
							case [UnitState.AttackTriggered, UnitState.MoveTo | UnitState.AttackRequested]: uAPower = 0; uBPower = 0.5;

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
			u.state.bind(v ->
			{
				if (v == Rotten)
				{
					units.remove(u);
					u.dispose();
				}
			});
			units.push(u);
		}
		else if (Std.is(o, Projectile))
		{
			var p:Projectile = cast o;
			p.state.bind(v ->
			{
				switch (v)
				{
					case ProjectileState.Disappeared:
						projectiles.remove(p);
						p.dispose();

					case _:
				}
			});

			projectiles.push(p);
		}
	}

	public function addFadeFilter(fadeFilter)
	{
		disposeFadeFilter();

		this.fadeFilter = fadeFilter;
	}

	public function disposeFadeFilter()
	{
		if (fadeFilter != null)
		{
			fadeFilter.remove();
			fadeFilter = null;
		}
	}

	function disposeSkybox()
	{
		if (skybox != null)
		{
			skybox.material.mainPass.getShader(CubeMap).texture.dispose();
			skybox.remove();
			skybox = null;
		}
	}

	override public function dispose()
	{
		super.dispose();

		disposeFadeFilter();
		disposeSkybox();

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
	var id(default, never):String;
	var name(default, never):String;
	var x(default, never):Int;
	var y(default, never):Int;
	var width(default, never):Int;
	var height(default, never):Int;

	@:optional var instance:Mesh;
}

typedef StaticObject =
{
	var instance:Object;
	var zOffset:Float;
}

typedef SkyboxConfig =
{
	var id(default, never):String;
	var zOffset(default, never):Float;
	var rotation(default, never):Float;
	var scale(default, never):Float;
}