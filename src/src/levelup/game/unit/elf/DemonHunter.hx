package levelup.game.unit.elf;

import levelup.game.unit.BaseUnit;
import levelup.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class DemonHunter extends BaseUnit
{
	public function new(s2d:Object, parent, owner:PlayerId)
	{
		super(s2d, parent, owner, {
			id: "demonhunter",
			icon: Res.model.character.elf.demonhunter.icon.toTile(),
			idleModel: Res.model.character.elf.demonhunter.IdleAnim,
			idleAnimSpeedMultiplier: 0.5,
			runModel: Res.model.character.elf.demonhunter.RunAnim,
			runAnimSpeedMultiplier: 1.5,
			attackModel: Res.model.character.elf.demonhunter.Attack01Anim,
			deathModel: Res.model.character.elf.demonhunter.DeathAnim,
			modelScale: 0.008,
			speed: 4,
			speedMultiplier: 1,
			attackRange: 2.1,
			attackSpeed: 1800,
			damagePercentDelay: 0.5,
			damageMin: 1,
			damageMax: 2,
			maxLife: 30,
			maxMana: 1,
			detectionRange: 4,
			unitSize: 0.7,
			isFlyingUnit: false,
			zOffset: 0
		});
	}
}