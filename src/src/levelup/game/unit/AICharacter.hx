package levelup.game.unit;

import levelup.game.GameWorld;
import levelup.game.GameState.PlayerId;
import levelup.game.unit.BaseUnit.UnitConfig;
import levelup.game.unit.BaseUnit.UnitState;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AICharacter extends BaseUnit
{
	public function new(s2d:Object, parent, owner:PlayerId, config:UnitConfig)
	{
		super(s2d, parent, owner, config);
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