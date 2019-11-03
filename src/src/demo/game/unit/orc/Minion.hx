package demo.game.unit.orc;

import demo.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Minion extends AICharacter
{
	public function new(s2d:Object, owner:PlayerId)
	{
		super(s2d, owner, {
			idleModel: Res.model.character.orc.minion.IdleAnim,
			idleAnimSpeedMultiplier: 0.8,
			runModel: Res.model.character.orc.minion.WalkAnim,
			attackModel: Res.model.character.orc.minion.WorkRoutineAnim,
			deathModel: Res.model.character.orc.minion.DeathAnim,
			modelScale: 0.008,
			speed: 4,
			speedMultiplier: 1,
			attackRange: 2.1,
			attackSpeed: 1800,
			damagePercentDelay: 0.5,
			damageMin: 1,
			damageMax: 2,
			maxLife: 15,
			detectionRange: 4,
			unitSize: 0.9
		});
	}
}