package demo.game.unit.orc;

import demo.game.GameState.Player;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Minion extends AICharacter
{
	public function new(s2d:Object, owner:Player)
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
			attackRadius: 2,
			attackSpeed: 1000,
			damagePercentDelay: 0.5,
			damageMin: 1,
			damageMax: 2,
			maxLife: 5
		});
	}
}