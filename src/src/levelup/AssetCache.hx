package levelup;

import h3d.prim.Cube;
import h3d.prim.ModelCache;
import haxe.ds.Map;
import h3d.scene.Mesh;
import hxd.BitmapData;
import hxd.Pixels;
import hxd.net.BinaryLoader;
import hxd.res.Image;
import hxd.res.Model;
import tink.CoreApi.Future;
import tink.CoreApi.FutureTrigger;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;
import h3d.mat.Material;
import h3d.mat.Texture;
import h3d.prim.Sphere;
import tink.state.State;

using StringTools;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AssetCache
{
	public static var instance:AssetCache;

	private var rawCache:RawModelCache = { groups: [] };
	private var modelCache:ModelCache = new ModelCache();
	private var modelDirectory:Map<String, Model> = new Map<String, Model>();
	private var textureDirectory:Map<String, Texture> = new Map<String, Texture>();
	private var imageDirectory:Map<String, Image> = new Map<String, Image>();

	private var textureQuality:Int = 1;

	private var isLoadingInProgress:Bool;

	private var totalAssetCount = 0;
	private var loadedModelTextureCount:Int = 0;
	private var loadedModelCount:Int = 0;
	private var loadedTextureCount:Int = 0;
	private var loadedImageCount:Int = 0;
	public var loadPercentage:State<Float> = new State<Float>(0);

	public function new() instance = this;

	public function setTextureQuality(q) textureQuality = Std.int(Math.min(Math.max(q, 0), 2));

	public function addData(rawData:Dynamic)
	{
		var newGroups = [];
		var castedRawData:Array<RawModelGroupData> = cast rawData.groups;

		for (d in castedRawData)
		{
			if (d.id.indexOf("{") == -1)
			{
				newGroups.push(d);
			}
			else
			{
				var assetFrom = Std.parseInt(d.id.substring(d.id.indexOf("{") + 1, d.id.indexOf("...")));
				var assetTo = Std.parseInt(d.id.substring(d.id.indexOf("...") + 3, d.id.indexOf("}"))) + 1;
				for (i in assetFrom...assetTo)
				{
					var pureId = d.id.substring(0, d.id.indexOf("{"));
					var countStr = i < 10 ? "0" + i : Std.string(i);

					var group = {
						id: pureId + countStr,
						models: [for (modelInfo in d.models) {{
							id: StringTools.replace(modelInfo.id, "{counter}", countStr),
							url: StringTools.replace(modelInfo.url, "{counter}", countStr)
						}}],
						textures: [for (textureInfo in d.textures) {{
							id: StringTools.replace(textureInfo.id, "{counter}", countStr),
							url: StringTools.replace(textureInfo.url, "{counter}", countStr)
						}}]
					}
					newGroups.push(group);
				}
			}
		}

		rawCache.groups = rawCache.groups.concat(newGroups);
	}

	public function load(modelGroupList:Array<String>, textureList:Array<String>, imageList:Array<String>):Future<Outcome<Noise, String>>
	{
		loadedModelTextureCount = 0;
		loadedModelCount = 0;
		loadedTextureCount = 0;
		loadedImageCount = 0;

		loadPercentage.set(0);

		totalAssetCount = textureList.length;
		totalAssetCount += imageList.length;

		var result:FutureTrigger<Outcome<Noise, String>> = Future.trigger();

		loadModelGroups(modelGroupList).handle(function (o):Void switch(o)
		{
			case Success(_):
				loadTextures(textureList).handle(function (o):Void switch(o)
				{
					case Success(_):
						loadImages(imageList).handle(o -> switch(o)
						{
							case Success(_): result.trigger(Success(Noise));
							case Failure(e): result.trigger(Failure(e));
						});

					case Failure(e): result.trigger(Failure(e));
				});

			case Failure(e): result.trigger(Failure(e));
		});

		return result;
	}

	public function loadModelGroups(modelGroupList:Array<String>):Future<Outcome<Noise, String>>
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

		totalAssetCount += collectedModelDatas.length;
		totalAssetCount += collectedModelTextures.length;

		loadModelTextures(collectedModelTextures).handle(function (o):Void { switch(o)
		{
			case Success(_):
				loadModels(collectedModelDatas).handle(result.trigger);

			case Failure(e): result.trigger(o);
		}});

		if (modelGroupList.length == 0) result.trigger(Success(Noise));

		return result;
	}

	private function loadModelTextures(list:Array<TextureDataWithModelReferences>):Future<Outcome<Noise, String>>
	{
		var result = Future.trigger();
		loadedModelTextureCount = 0;

		var onLoaded = (data, t:TextureDataWithModelReferences) ->
		{
			var texture = hxd.res.Any.fromBytes(t.data.url, data).toTexture();
			for (modelRef in t.modelReferences)
				modelCache.textures.set(modelRef + "@" + t.data.id, texture);

			loadedModelTextureCount++;
			updateLoadPercentage();
			if (loadedModelTextureCount == list.length) result.trigger(Success(Noise));
		}

		var loadRoutine = t ->
		{
			var url:String = t.data.url;
			var hasMultiplyTexture = url.indexOf("_q1") > -1;

			var loader = new BinaryLoader(hasMultiplyTexture ? url.replace("_q1", "_q" + textureQuality) : url);
			loader.onError = e -> result.trigger(Failure(e));
			loader.load();
			loader.onLoaded = data -> onLoaded(data, t);
		}

		for (t in list) loadRoutine(t);

		return result;
	}

	private function loadModels(list:Array<RawModelData>):Future<Outcome<Noise, String>>
	{
		var result = Future.trigger();
		loadedModelCount = 0;

		var onLoaded = (data, m) ->
		{
			modelDirectory.set(m.id, hxd.res.Any.fromBytes(m.url, data).toModel());

			loadedModelCount++;
			updateLoadPercentage();
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

	public function getUndefinedModel()
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

	public function getModel(modelId:String) return modelCache.loadModel(modelDirectory.get(modelId));

	public function getAnimation(modelId:String) return modelCache.loadAnimation(modelDirectory.get(modelId));

	public function hasModelCache(modelId:String) return modelDirectory.exists(modelId);
	public function hasTextureCache(textureId:String) return textureDirectory.exists(textureId);

	public function loadTextures(list:Array<String>):Future<Outcome<Noise, String>>
	{
		var result = Future.trigger();
		loadedTextureCount = 0;

		var onLoaded = (data, url) ->
		{
			var texture = hxd.res.Any.fromBytes(url, data).toTexture();
			textureDirectory.set(url, texture);

			loadedTextureCount++;
			updateLoadPercentage();
			if (loadedTextureCount == list.length) result.trigger(Success(Noise));
		}

		var loadRoutine = (t) ->
		{
			var loader = new BinaryLoader(t);
			loader.onError = e -> result.trigger(Failure(e));
			loader.load();
			loader.onLoaded = data -> onLoaded(data, t);
		}

		for (t in list)
		{
			loadRoutine(t);
		}

		return result;
	}

	public function loadImages(list:Array<String>):Future<Outcome<Noise, String>>
	{
		var result = Future.trigger();
		loadedImageCount = 0;

		var onLoaded = (data, url) ->
		{
			var image = hxd.res.Any.fromBytes(url, data).toImage();
			imageDirectory.set(url, image);

			loadedImageCount++;
			updateLoadPercentage();
			if (loadedImageCount == list.length) result.trigger(Success(Noise));
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

	function updateLoadPercentage()
	{
		loadPercentage.set((loadedModelCount + loadedModelTextureCount + loadedTextureCount + loadedImageCount) / totalAssetCount);
	}

	public function getTexture(url:String) return textureDirectory.get(url);
	public function getImage(url:String) return imageDirectory.get(url);
	public function getModelPreviewUrl(modelGroupId:String) return rawCache.groups.filter(data -> return data.id == modelGroupId)[0].previewUrl;
}

typedef RawModelCache =
{
	var groups:Array<RawModelGroupData>;
}

typedef RawModelGroupData =
{
	var id:String;
	@:optional var previewUrl:String; // TODO remove optional
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