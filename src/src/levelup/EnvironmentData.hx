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
			if (e.id.indexOf("{") == -1)
			{
				count++;
				config.set(e.id, e);
			}
			else
			{
				var assetFrom = Std.parseInt(e.id.substring(e.id.indexOf("{") + 1, e.id.indexOf("...")));
				var assetTo = Std.parseInt(e.id.substring(e.id.indexOf("...") + 3, e.id.indexOf("}")));
				for (i in assetFrom...assetTo)
				{
					count++;

					var pureId = e.id.substring(0, e.id.indexOf("{"));
					var countStr = i < 10 ? "0" + i : Std.string(i);

					var envConfig = {
						id: pureId + countStr,
						name: StringTools.replace(e.name, "{counter}", countStr),
						modelScale: e.modelScale,
						environmentId: e.environmentId,
						assetGroup: StringTools.replace(e.assetGroup, "{counter}", countStr),
						previewUrl: e.previewUrl,
						zOffset: e.zOffset,
						isPathBlocker: e.isPathBlocker,
						hasTransparentTexture: e.hasTransparentTexture,
						hasAnimation: e.hasAnimation
					}
					config.set(envConfig.id, envConfig);
				}
			}
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