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
	// TODO remove this class
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