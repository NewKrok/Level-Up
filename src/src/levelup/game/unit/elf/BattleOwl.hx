package levelup.game.unit.elf;

import levelup.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;
import levelup.game.unit.BaseUnit;

/**
 * ...
 * @author Krisztian Somoracz
 */
class BattleOwl extends BaseUnit
{
	public function new(s2d:Object, parent, owner:PlayerId)
	{
		super(s2d, parent, owner, {
			id: "battleowl",
			icon: Res.model.character.elf.battleowl.icon.toTile(),
			idleModel: Res.model.character.elf.battleowl.IdleAnim,
			idleAnimSpeedMultiplier: 2.5,
			runModel: Res.model.character.elf.battleowl.FlyAnim,
			runAnimSpeedMultiplier: 1.5,
			attackModel: Res.model.character.elf.battleowl.Attack01Anim,
			deathModel: Res.model.character.elf.battleowl.DeathAnim,
			modelScale: 0.004,
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
			zOffset: 3.5
		});
	}
}