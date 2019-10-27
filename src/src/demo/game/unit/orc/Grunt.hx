package demo.game.unit.orc;

import demo.game.GameState.Player;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Grunt extends AICharacter
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
			speedMultiplier: 6,
			attackRadius: 2,
			attackSpeed: 1000,
			damagePercentDelay: 0.5,
			damageMin: 1,
			damageMax: 5,
			maxLife: 20
		});
	}
}