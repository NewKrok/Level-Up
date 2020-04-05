package levelup;

import h3d.prim.Cube;
import h3d.prim.ModelCache;
import haxe.ds.Map;
import h3d.scene.Mesh;
import hxd.BitmapData;
import hxd.net.BinaryLoader;
import hxd.res.Model;
import tink.CoreApi.Future;
import tink.CoreApi.FutureTrigger;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;
import h3d.mat.Material;
import h3d.mat.Texture;
import h3d.prim.Sphere;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AssetCache
{
	private static var rawCache:RawModelCache = { groups: [] };
	private static var modelCache:ModelCache = new ModelCache();
	private static var modelDirectory:Map<String, Model> = new Map<String, Model>();
	private static var loadedModelTextureCount:Int;
	private static var loadedModelCount:Int;

	private static var textureDirectory:Map<String, Dynamic> = new Map<String, Dynamic>();
	private static var loadedTextureCount:Int;

	private static var isLoadingInProgress:Bool;

	public static function addData(rawData:Dynamic) AssetCache.rawCache.groups = AssetCache.rawCache.groups.concat(rawData.groups);

	public static function load(modelGroupList:Array<String>, textureList:Array<String>):Future<Outcome<Noise, String>>
	{
		var result:FutureTrigger<Outcome<Noise, String>> = Future.trigger();

		loadModelGroups(modelGroupList).handle(function (o):Void switch(o)
		{
			case Success(_):
				loadTextures(textureList).handle(o -> switch(o)
				{
					case Success(_): result.trigger(Success(Noise));
					case Failure(e): result.trigger(Failure(e));
				});

			case Failure(e): result.trigger(Failure(e));
		});

		return result;
	}

	public static function loadModelGroups(modelGroupList:Array<String>):Future<Outcome<Noise, String>>
	{
		var result:FutureTrigger<Outcome<Noise, String>> = Future.trigger();

		isLoadingInProgress = true;

		var collectedModelDatas:Array<RawModelData> = [];
		var collectedModelTextures:Array<TextureDataWithModelReferences> = [];

		for (group in modelGroupList)
		{
			var selectedGroup:RawModelGroupData = rawCache.groups.filter(data -> return data.id == group)[0];
			collectedModelDatas = collectedModelDatas.concat(selectedGroup.models);

			for (texture in selectedGroup.textures)
				if (collectedModelTextures.filter(t -> return t.data.id == texture.id).length == 0)
					collectedModelTextures.push({data: texture, modelReferences: []});

			for (texture in collectedModelTextures)
				for (model in selectedGroup.models)
					texture.modelReferences.push(model.url);
		}

		loadModelTextures(collectedModelTextures).handle(function (o):Void { switch(o)
		{
			case Success(_):
				loadModels(collectedModelDatas).handle(result.trigger);

			case Failure(e): result.trigger(o);
		}});

		return result;
	}

	private static function loadModelTextures(list:Array<TextureDataWithModelReferences>):Future<Outcome<Noise, String>>
	{
		var result = Future.trigger();
		loadedModelTextureCount = 0;

		var onLoaded = (data, t:TextureDataWithModelReferences) ->
		{
			var texture = hxd.res.Any.fromBytes(t.data.url, data).toTexture();
			for (modelRef in t.modelReferences)
				modelCache.textures.set(modelRef + "@" + t.data.id, texture);

			loadedModelTextureCount++;
			if (loadedModelTextureCount == list.length) result.trigger(Success(Noise));
		}

		var loadRoutine = t ->
		{
			var loader = new BinaryLoader(t.data.url);
			loader.onError = e -> result.trigger(Failure(e));
			loader.load();
			loader.onLoaded = data -> onLoaded(data, t);
		}

		for (t in list) loadRoutine(t);

		return result;
	}

	private static function loadModels(list:Array<RawModelData>):Future<Outcome<Noise, String>>
	{
		var result = Future.trigger();
		loadedModelCount = 0;

		var onLoaded = (data, m) ->
		{
			modelDirectory.set(m.id, hxd.res.Any.fromBytes(m.url, data).toModel());

			loadedModelCount++;
			if (loadedModelCount == list.length) result.trigger(Success(Noise));
		}

		var loadRoutine = m ->
		{
			var loader = new BinaryLoader(m.url);
			loader.onError = e -> result.trigger(Failure(e));
			loader.load();
			loader.onLoaded = data -> onLoaded(data, m);
		}

		for (m in list) loadRoutine(m);

		return result;
	}

	public static function getUndefinedModel()
	{
		var primtive = new Cube(1, 1, 1);
		primtive.addNormals();
		primtive.addUVs();
		primtive.addTangents();

		if (textureDirectory.get("undefinedModel") == null)
		{
			var texBmp = new BitmapData(20, 20);
			texBmp.fill(0, 0, 5, 5, 0xFF000000);
			for (i in 0...5)
				for (j in 0...5)
					if ((j % 2 == 0 && i % 2 != 0) || (j % 2 != 0 && i % 2 == 0))
						texBmp.fill(i * 4, j * 4, 4, 4, 0xFFFF0000);

			textureDirectory.set("undefinedModel", Texture.fromBitmap(texBmp));
		}

		var undefinedModel = new Mesh(primtive, Material.create(textureDirectory.get("undefinedModel")));
		undefinedModel.material.castShadows = false;
		undefinedModel.material.receiveShadows = false;
		undefinedModel.material.mainPass.isStatic = true;

		return undefinedModel;
	}

	public static function getModel(modelId:String) return modelCache.loadModel(modelDirectory.get(modelId));

	public static function getAnimation(modelId:String) return modelCache.loadAnimation(modelDirectory.get(modelId));

	public static function loadTextures(list:Array<String>):Future<Outcome<Noise, String>>
	{
		var result = Future.trigger();
		loadedTextureCount = 0;

		var onLoaded = (data, url) ->
		{
			var texture = hxd.res.Any.fromBytes(url, data).toTexture();
			textureDirectory.set(url, texture);

			loadedTextureCount++;
			if (loadedTextureCount == list.length) result.trigger(Success(Noise));
		}

		var loadRoutine = t ->
		{
			var loader = new BinaryLoader(t);
			loader.onError = e -> result.trigger(Failure(e));
			loader.load();
			loader.onLoaded = data -> onLoaded(data, t);
		}

		for (t in list) loadRoutine(t);

		return result;
	}

	public static function getTexture(url:String) return textureDirectory.get(url);
}

typedef RawModelCache =
{
	var groups:Array<RawModelGroupData>;
}

typedef RawModelGroupData =
{
	var id:String;
	var models:Array<RawModelData>;
	var textures:Array<RawTextureData>;
}

typedef RawModelData =
{
	var id:String;
	var url:String;
}

typedef RawTextureData =
{
	var id:String;
	var url:String;
}

typedef TextureDataWithModelReferences =
{
	var data:RawTextureData;
	var modelReferences:Array<String>;
}