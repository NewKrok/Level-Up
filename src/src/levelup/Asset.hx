package levelup;

import h3d.mat.BlendMode;
import hxd.Res;
import hxd.res.Model;
import levelup.EnvironmentData;
import levelup.UnitData.RaceId;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Asset
{
	static public function getAsset(id)
	{
		var foundEnvElements = environment.filter(function (e) { return e.id == id; });
		if (foundEnvElements != null && foundEnvElements.length > 0) return foundEnvElements[0];

		var foundPropElements = props.filter(function (e) { return e.id == id; });
		if (foundPropElements != null && foundPropElements.length > 0) return foundPropElements[0];

		var foundBuildingElements = buildings.filter(function (e) { return e.id == id; });
		if (foundBuildingElements != null && foundBuildingElements.length > 0) return foundBuildingElements[0];

		var foundUnitElements = units.filter(function (e) { return e.id == id; });
		if (foundUnitElements != null && foundUnitElements.length > 0) return foundUnitElements[0];

		return null;
	}

	static public var environment(default, null):Array<AssetConfig> = [];
	static public var props(default, null):Array<AssetConfig> = [];
	static public var buildings(default, null):Array<AssetConfig> = [];
	static public var units(default, null):Array<AssetConfig> = [];
}

typedef AssetConfig = {
	@:optional var id(default, never):String;
	@:optional var name(default, never):String;
	@:optional var assetGroup(default, never):String;
	@:optional var modelScale(default, never):Float;
	@:optional var unitName(default, never):String;
	@:optional var environmentId(default, never):EnvironmentId;
	@:optional var race(default, never):RaceId;
	@:optional var zOffset(default, never):Float;
	@:optional var hasAnimation(default, never):Bool;
	@:optional var previewUrl(default, never):String;
	@:optional var hasTransparentTexture(default, never):Bool;
	@:optional var isPathBlocker(default, never):Bool;
}