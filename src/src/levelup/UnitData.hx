package levelup;

class UnitData
{
	public static var count(default, null):Int = 0;
	public static var humanCount(default, null):Int = 0;
	public static var elfCount(default, null):Int = 0;
	public static var orcCount(default, null):Int = 0;
	public static var undeadCount(default, null):Int = 0;
	public static var neutralCount(default, null):Int = 0;
	public static var config(default, null):Map<String, UnitConfig> = new Map<String, UnitConfig>();

	public static function addData(rawData:Dynamic)
	{
		var unitConfig:Array<UnitConfig> = cast rawData.units;
		for (u in unitConfig)
		{
			count++;
			if (u.race == RaceId.Human) humanCount++;
			else if (u.race == RaceId.Elf) elfCount++;
			else if (u.race == RaceId.Orc) orcCount++;
			else if (u.race == RaceId.Undead) undeadCount++;
			else if (u.race == RaceId.Neutral) neutralCount++;
			config.set(u.id, u);
		}
	}

	public static function getUnitConfig(unitId:String) return config.get(unitId);
}

typedef UnitConfig =
{
	var id:String;
	var name:String;
	var uniqueNames:Array<String>;
	var race:RaceId;
	var icon:String;
	var assetGroup:String;
	var idleAnimSpeedMultiplier:Float;
	var runAnimSpeedMultiplier:Float;
	var attackAnimSpeedMultiplier:Float;
	var deathAnimSpeedMultiplier:Float;
	var hasContinuousAttackAnimation:Bool;
	var modelScale:Float;
	var canRotate:Bool;
	var isBuilding:Bool;
	var speed:Float;
	var speedMultiplier:Float;
	var projectileConfig:ProjectileConfig;
	var attackRange:Float;
	var attackSpeed:Int;
	var damagePercentDelay:Float;
	var damageMin:Float;
	var damageMax:Float;
	var maxLife:Float;
	var maxMana:Float;
	var detectionRange:Float;
	var unitSize:Float;
	var height:Float;
	var isFlyingUnit:Bool;
	var zOffset:Float;
}

enum abstract RaceId(String) from String to String
{
	var Human = "human";
	var Orc = "orc";
	var Elf = "elf";
	var Undead = "undead";
	var Neutral = "neutral";
}

typedef ProjectileConfig =
{
	var type:ProjectileType;
	var lifeTime:Int;
	var speed:Float;
	var arc:Float;
	var initialPoint:{x:Float, y:Float, z:Float};
	var projectileAnimationId:String;
	@:optional var xAutoRotation:Float;
	@:optional var zAutoRotation:Float;
	@:optional var yAutoRotation:Float;
}

enum abstract ProjectileType(String) from String to String
{
	var Pointer = "pointer";
	var Follower = "follower";
}