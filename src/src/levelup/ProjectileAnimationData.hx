package levelup;

class ProjectileAnimationData
{
	private static var config:Map<String, ProjectileAnimationConfig> = new Map<String, ProjectileAnimationConfig>();

	public static function addData(rawData:Dynamic)
	{
		var projectileAnimationConfig:Array<ProjectileAnimationConfig> = cast rawData.data;
		for (p in projectileAnimationConfig) config.set(p.id, p);
	}

	public static function getConfig(projectileAnimationId:String) return config.get(projectileAnimationId);
}

typedef ProjectileAnimationConfig =
{
	var id:String;
	var assetGroup:String;
	var modelId:String;
	var modelScale:Float;
	var idleEffect:Dynamic;
	var startEffect:Dynamic;
	var finishEffect:Dynamic;
}