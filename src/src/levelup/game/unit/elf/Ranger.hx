package levelup.game.unit.elf;

import levelup.game.unit.BaseUnit;
import levelup.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Ranger extends BaseUnit
{
	public function new(s2d:Object, parent, owner:PlayerId)
	{
		super(s2d, parent, owner, {
			id: "ranger",
			icon: Res.model.character.elf.ranger.icon.toTile(),
			idleModel: Res.model.character.elf.ranger.IdleAnim,
			idleAnimSpeedMultiplier: 0.5,
			runModel: Res.model.character.elf.ranger.RunAnim,
			runAnimSpeedMultiplier: 1.5,
			attackModel: Res.model.character.elf.ranger.Attack01StartAnim,
			deathModel: Res.model.character.elf.ranger.DeathAnim,
			modelScale: 0.008,
			speed: 1,
			speedMultiplier: 1,
			attackRange: 10,
			attackSpeed: 1800,
			damagePercentDelay: 0.5,
			damageMin: 1,
			damageMax: 2,
			maxLife: 15,
			maxMana: 1,
			detectionRange: 10,
			unitSize: 0.7,
			isFlyingUnit: false,
			zOffset: 0
		});
	}
}