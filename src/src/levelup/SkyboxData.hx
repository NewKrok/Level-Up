package levelup;

class SkyboxData
{
	private static var config:Map<String, SkyboxAssetConfig> = new Map<String, SkyboxAssetConfig>();

	public static function addData(rawData:Dynamic)
	{
		var skyboxAssetConfig:Array<SkyboxAssetConfig> = cast rawData.data;
		for (p in skyboxAssetConfig)
		{
			config.set(p.id, {
				id: p.id,
				assets: [for (i in 1...7) "asset/texture/skybox/" + p.id.split(".")[1] + "/sb_" + i + ".jpg"]
			});
		}
	}

	public static function getConfig(skyboxId:String) return config.get(skyboxId);
}

typedef SkyboxAssetConfig =
{
	var id:String;
	var assets:Array<String>;
}