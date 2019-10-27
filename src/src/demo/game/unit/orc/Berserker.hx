package demo.game.unit.orc;

import demo.game.GameState.Player;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Berserker extends AICharacter
{
	public function new(s2d:Object, owner:Player)
	{
		super(s2d, owner, {
			idleModel: Res.model.character.orc.berserker.IdleAnim,
			idleAnimSpeedMultiplier: 1.5,
			runModel: Res.model.character.orc.berserker.WalkAnim,
			attackModel: Res.model.character.orc.berserker.Attack01Anim,
			deathModel: Res.model.character.orc.berserker.DeathAnim,
			modelScale: 0.008,
			speed: 5,
			speedMultiplier: 1,
			attackRadius: 2,
			attackSpeed: 1000,
			damagePercentDelay: 0.5,
			damageMin: 3,
			damageMax: 6,
			maxLife: 15
		});
	}
}