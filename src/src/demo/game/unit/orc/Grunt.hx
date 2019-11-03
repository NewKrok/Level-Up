package demo.game.unit.orc;

import demo.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Grunt extends AICharacter
{
	public function new(s2d:Object, owner:PlayerId)
	{
		super(s2d, owner, {
			idleModel: Res.model.character.orc.grunt.IdleAnim,
			idleAnimSpeedMultiplier: 0.8,
			runModel: Res.model.character.orc.grunt.WalkAnim,
			attackModel: Res.model.character.orc.grunt.Attack01Anim,
			deathModel: Res.model.character.orc.grunt.DeathAnim,
			modelScale: 0.008,
			speed: 5,
			speedMultiplier: 1,
			attackRange: 2.1,
			attackSpeed: 1500,
			damagePercentDelay: 0.5,
			damageMin: 2,
			damageMax: 5,
			maxLife: 30,
			detectionRange: 5,
			unitSize: 0.9
		});
	}
}