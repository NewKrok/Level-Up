package demo.game.unit.orc;

import demo.game.GameState.Player;
import demo.game.unit.BaseUnit;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class PlayerGrunt extends BaseUnit
{
	public function new(s2d:Object, owner:Player)
	{
		super(s2d, owner, {
			idleModel: Res.model.character.orc.grunt.IdleAnim,
			idleAnimSpeedMultiplier: 0.8,
			runModel: Res.model.character.orc.grunt.WalkAnim,
			attackModel: Res.model.character.orc.grunt.Attack01Anim,
			deathModel: Res.model.character.orc.grunt.DeathAnim,
			modelScale: 0.008,
			speed: 5,
			speedMultiplier: 3,
			attackRange: 2.1,
			attackSpeed: 1000,
			damagePercentDelay: 0.5,
			damageMin: 3,
			damageMax: 8,
			maxLife: 500,
			detectionRange: 3,
			unitSize: 0.9
		});
	}

	override public function update(d:Float)
	{
		super.update(d);

		if (target == null && nearestTarget != null && state.value != UnitState.AttackTriggered && state != MoveTo)
		{
			attack(nearestTarget).handle(function()
			{

			});
		}
	}
}