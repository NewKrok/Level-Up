package levelup.game.unit.orc;

import levelup.game.unit.BaseUnit;
import levelup.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Berserker extends BaseUnit
{
	public function new(s2d:Object, parent, owner:PlayerId)
	{
		super(s2d, parent, owner, {
			icon: Res.model.character.orc.berserker.icon.toTile(),
			idleModel: Res.model.character.orc.berserker.IdleAnim,
			idleAnimSpeedMultiplier: 0.3,
			runModel: Res.model.character.orc.berserker.WalkAnim,
			runAnimSpeedMultiplier: 1,
			attackModel: Res.model.character.orc.berserker.Attack01Anim,
			deathModel: Res.model.character.orc.berserker.DeathAnim,
			modelScale: 0.008,
			speed: 5,
			speedMultiplier: 2,
			attackRange: 2.1,
			attackSpeed: 900,
			damagePercentDelay: 0.5,
			damageMin: 3,
			damageMax: 6,
			maxLife: 20,
			maxMana: 1,
			detectionRange: 5,
			unitSize: 0.9,
			isFlyingUnit: false,
			zOffset: 0
		});
	}
}