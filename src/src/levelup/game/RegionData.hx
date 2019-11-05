package levelup.game;

import levelup.game.GameWorld.Region;
import levelup.game.unit.BaseUnit;

using Lambda;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class RegionData
{
	public var data:Region = _;
	var onUnitEntersToRegion:BaseUnit->Void = _;
	var onUnitLeavesFromRegion:BaseUnit->Void = _;

	var collideList:Array<BaseUnit> = [];

	public function updateCollidedUnits(list:Array<BaseUnit>)
	{
		for (u in list)
		{
			if (!collideList.has(u)) onUnitEntersToRegion(u);
		}

		for (u in collideList)
		{
			if (!list.has(u)) onUnitLeavesFromRegion(u);
		}

		collideList = list;
	}
}