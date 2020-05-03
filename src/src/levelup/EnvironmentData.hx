package levelup;

class EnvironmentData
{
	public static var count(default, null):Int = 0;
	public static var config(default, null):Map<String, EnvironmentConfig> = new Map<String, EnvironmentConfig>();

	public static function addData(rawData:Dynamic)
	{
		var environmentConfig:Array<EnvironmentConfig> = cast rawData.environments;
		for (e in environmentConfig)
		{
			count++;
			config.set(e.id, e);
		}
	}

	public static function getEnvironmentConfig(environmentId:String):EnvironmentConfig return config.get(environmentId);
}

typedef EnvironmentConfig = {
	var id(default, never):String;
	var name(default, never):String;
	var assetGroup(default, never):String;
	var modelScale(default, never):Float;
	var environmentId(default, never):EnvironmentId;
	var zOffset(default, never):Float;
	var hasAnimation(default, never):Bool;
	var previewUrl(default, never):String;
	var hasTransparentTexture(default, never):Bool;
	var isPathBlocker(default, never):Bool;
}

enum abstract EnvironmentId(String) from String to String
{
	var Bridge = "bridge";
	var Rock = "rock";
	var Tree = "tree";
	var Trunk = "trunk";
	var Plant = "plant";
}