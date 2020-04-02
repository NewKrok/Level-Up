package levelup;

class UnitData
{
	private static var config:Map<String, UnitConfig> = new Map<String, UnitConfig>();

	public static function addData(rawData:Dynamic)
	{
		var unitConfig:Array<UnitConfig> = cast rawData.units;
		for (u in unitConfig) config.set(u.id, u);
	}

	public static function getUnitConfig(unitId:String) return config.get(unitId);
}

typedef UnitConfig =
{
	var id:String;
	var unitName:String;
	var name:Array<String>;
	var icon:String;
	var modelGroup:String;
	var idleAnimSpeedMultiplier:Float;
	var runAnimSpeedMultiplier:Float;
	var modelScale:Float;
	var speed:Float;
	var speedMultiplier:Float;
	var attackRange:Float;
	var attackSpeed:Int;
	var damagePercentDelay:Float;
	var damageMin:Float;
	var damageMax:Float;
	var maxLife:Float;
	var maxMana:Float;
	var detectionRange:Float;
	var unitSize:Float;
	var isFlyingUnit:Bool;
	var zOffset:Float;
}