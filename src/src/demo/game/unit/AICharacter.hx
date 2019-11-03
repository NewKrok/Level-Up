package demo.game.unit;

import demo.game.GameState.PlayerId;
import demo.game.unit.BaseUnit.UnitConfig;
import demo.game.unit.BaseUnit.UnitState;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AICharacter extends BaseUnit
{
	public function new(s2d:Object, owner:PlayerId, config:UnitConfig)
	{
		super(s2d, owner, config);
	}

	override public function update(d:Float)
	{
		super.update(d);

		if (target == null && nearestTarget != null && state.value != UnitState.AttackTriggered)
		{
			attack(nearestTarget).handle(function()
			{
				moveTo(GameWorld.instance.getRandomWalkablePoint());
			});
		}
	}
}