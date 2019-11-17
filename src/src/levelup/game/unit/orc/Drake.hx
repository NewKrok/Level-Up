package levelup.game.unit.orc;

import levelup.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;
import levelup.game.unit.BaseUnit;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Drake extends BaseUnit
{
	public function new(s2d:Object, parent, owner:PlayerId)
	{
		super(s2d, parent, owner, {
			icon: Res.model.character.orc.drake.icon.toTile(),
			idleModel: Res.model.character.orc.drake.IdleAnim,
			idleAnimSpeedMultiplier: 2.5,
			runModel: Res.model.character.orc.drake.WalkAnim,
			runAnimSpeedMultiplier: 1.5,
			attackModel: Res.model.character.orc.drake.Attack01Anim,
			deathModel: Res.model.character.orc.drake.DeathAnim,
			modelScale: 0.0037,
			speed: 2,
			speedMultiplier: 1,
			attackRange: 2.1,
			attackSpeed: 1500,
			damagePercentDelay: 0.5,
			damageMin: 2,
			damageMax: 5,
			maxLife: 30,
			maxMana: 1,
			detectionRange: 5,
			unitSize: 1,
			isFlyingUnit: true,
			zOffset: 2.5
		});
	}
}