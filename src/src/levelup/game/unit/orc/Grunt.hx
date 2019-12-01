package levelup.game.unit.orc;

import levelup.game.unit.BaseUnit;
import levelup.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Grunt extends BaseUnit
{
	public function new(s2d:Object, parent, owner:PlayerId)
	{
		super(s2d, parent, owner, {
			id: "grunt",
			icon: Res.model.character.orc.grunt.icon.toTile(),
			idleModel: Res.model.character.orc.grunt.IdleAnim,
			idleAnimSpeedMultiplier: 0.2,
			runModel: Res.model.character.orc.grunt.WalkAnim,
			runAnimSpeedMultiplier: 0.8,
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
			maxMana: 1,
			detectionRange: 5,
			unitSize: 0.8,
			isFlyingUnit: false,
			zOffset: 0
		});
	}
}