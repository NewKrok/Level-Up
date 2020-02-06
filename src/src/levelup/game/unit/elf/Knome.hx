package levelup.game.unit.elf;

import levelup.game.unit.BaseUnit;
import levelup.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Knome extends BaseUnit
{
	public function new(s2d:Object, parent, owner:PlayerId)
	{
		super(s2d, parent, owner, {
			id: "knome",
			icon: Res.model.character.elf.knome.icon.toTile(),
			idleModel: Res.model.character.elf.knome.IdleAnim,
			idleAnimSpeedMultiplier: 0.5,
			runModel: Res.model.character.elf.knome.WalkAnim,
			runAnimSpeedMultiplier: 1.5,
			attackModel: Res.model.character.elf.knome.WorkRoutineAnim,
			deathModel: Res.model.character.elf.knome.DeathAnim,
			modelScale: 0.008,
			speed: 4,
			speedMultiplier: 1,
			attackRange: 2.1,
			attackSpeed: 1800,
			damagePercentDelay: 0.5,
			damageMin: 1,
			damageMax: 2,
			maxLife: 50,
			maxMana: 1,
			detectionRange: 4,
			unitSize: 0.7,
			isFlyingUnit: false,
			zOffset: 0
		});
	}
}