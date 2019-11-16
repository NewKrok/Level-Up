package levelup.game.unit.human;

import levelup.game.unit.AICharacter;
import levelup.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Archer extends AICharacter
{
	public function new(s2d:Object, parent, owner:PlayerId)
	{
		super(s2d, parent, owner, {
			icon: Res.model.character.orc.minion.icon.toTile(),
			idleModel: Res.model.character.human.archer.IdleAnim,
			idleAnimSpeedMultiplier: 1,
			runModel: Res.model.character.human.archer.WalkAnim,
			runAnimSpeedMultiplier: 1.8,
			attackModel: Res.model.character.human.archer.Attack01Anim,
			deathModel: Res.model.character.human.archer.DeathAnim,
			modelScale: 0.008,
			speed: 8,
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