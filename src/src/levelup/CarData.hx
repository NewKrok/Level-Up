package levelup;

import levelup.heaps.component.car.Car.CarConfig;

class CarData
{
	public static var count(default, null):Int = 0;
	public static var config(default, null):Map<String, CarConfig> = new Map<String, CarConfig>();

	public static function addData(rawData:Dynamic)
	{
		var unitConfig:Array<CarConfig> = cast rawData.units;
		for (u in unitConfig)
		{
			count++;
			config.set(u.id, u);
		}
	}

	public static function getConfig(id:String) return config.get(id);
}