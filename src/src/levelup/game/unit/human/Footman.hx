package levelup.game.unit.human;

import levelup.game.unit.AICharacter;
import levelup.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Footman extends AICharacter
{
	public function new(s2d:Object, parent, owner:PlayerId)
	{
		super(s2d, parent, owner, {
			icon: Res.model.character.orc.minion.icon.toTile(),
			idleModel: Res.model.character.human.footman.IdleAnim,
			idleAnimSpeedMultiplier: 1,
			runModel: Res.model.character.human.footman.WalkAnim,
			runAnimSpeedMultiplier: 1.8,
			attackModel: Res.model.character.human.footman.Attack01Anim,
			deathModel: Res.model.character.human.footman.DeathAnim,
			modelScale: 0.008,
			speed: 6,
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