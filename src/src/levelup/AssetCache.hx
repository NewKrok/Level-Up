package levelup;

import h3d.prim.ModelCache;
import haxe.ds.Map;
import hxd.net.BinaryLoader;
import hxd.res.Model;
import tink.CoreApi.Future;
import tink.CoreApi.FutureTrigger;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AssetCache
{
	private static var rawCache:RawCache;
	private static var cache:ModelCache = new ModelCache();
	private static var modelDirectory:Map<String, Model> = new Map<String, Model>();

	private static var isLoadingInProgress:Bool;
	private static var loadedTextureCount:Int;
	private static var loadedModelCount:Int;

	public static function init(rawData:Dynamic) AssetCache.rawCache = rawData;

	public static function loadModelGroups(modelGroupList:Array<ModelGroup>):Future<Outcome<Noise, String>>
	{
		var result:FutureTrigger<Outcome<Noise, String>> = Future.trigger();

		isLoadingInProgress = true;

		var collectedModelDatas:Array<RawModelData> = [];
		var collectedModelTextures:Array<TextureDataWithModelReferences> = [];

		for (group in modelGroupList)
		{
			var selectedModels = rawCache.models.filter(data -> return data.modelGroup == group);
			collectedModelDatas = collectedModelDatas.concat(selectedModels);

			for (model in selectedModels)
				for (texture in model.textures)
					if (collectedModelTextures.filter(t -> return t.data.id == texture.id).length == 0)
						collectedModelTextures.push({data: texture, modelReferences: []});

			for (texture in collectedModelTextures)
				for (model in selectedModels)
					if (model.textures.filter(t -> return t.id == texture.data.id).length > 0)
						texture.modelReferences.push(model.url);
		}

		loadTextures(collectedModelTextures).handle(function (o):Void { switch(o)
		{
			case Success(_):
				loadModels(collectedModelDatas).handle(result.trigger);

			case Failure(e): result.trigger(o);
		}});

		return result;
	}

	private static function loadTextures(list:Array<TextureDataWithModelReferences>):Future<Outcome<Noise, String>>
	{
		var result = Future.trigger();
		loadedTextureCount = 0;

		var onLoaded = (data, t:TextureDataWithModelReferences) ->
		{
			var texture = hxd.res.Any.fromBytes(t.data.url, data).toTexture();
			for (modelRef in t.modelReferences)
				cache.textures.set(modelRef + "@" + t.data.id, texture);

			loadedTextureCount++;
			if (loadedTextureCount == list.length) result.trigger(Success(Noise));
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

	public static function getModel(modelId:String) return cache.loadModel(modelDirectory.get(modelId));

	public static function getAnimation(modelId:String) return cache.loadAnimation(modelDirectory.get(modelId));
}

typedef RawCache =
{
	var models:Array<RawModelData>;
}

typedef RawModelData =
{
	var modelGroup:ModelGroup;
	var id:String;
	var url:String;
	var textures:Array<RawTextureData>;
}

@:enum abstract ModelGroup(String) from String to String
{
	var ElfUnitKnome = "elf.unit.knome";
	var ElfUnitBattleOwl = "elf.unit.battleowl";
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