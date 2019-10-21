package demo.game.character;

import demo.game.GameState.Player;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Warrior extends AICharacter
{
	public function new(owner:Player)
	{
		super(owner, {
			idleModel: Res.model.character.orc.grunt.IdleAnim,
			runModel: Res.model.character.orc.grunt.WalkAnim,
			attackModel: Res.model.character.orc.grunt.Attack01Anim,
			deathModel: Res.model.character.orc.grunt.DeathAnim,
			modelScale: 0.008,
			speed: 5,
			speedMultiplier: 0.5,
			attackRadius: 2,
			attackSpeed: 1000,
			attackDuration: 500,
			damageMin: 1,
			damageMax: 5,
			maxLife: 10
		});
	}
}