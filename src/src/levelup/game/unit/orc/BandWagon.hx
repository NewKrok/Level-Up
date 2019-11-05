package levelup.game.unit.orc;
import levelup.game.GameState;
import levelup.game.unit.AICharacter;

import levelup.game.GameState.PlayerId;
import h2d.Object;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class BandWagon extends AICharacter
{
	public function new(s2d:Object, parent, owner:PlayerId)
	{
		super(s2d, parent, owner, {
			icon: Res.model.character.orc.bandwagon.icon.toTile(),
			idleModel: Res.model.character.orc.bandwagon.IdleAnim,
			idleAnimSpeedMultiplier: 0.1,
			runModel: Res.model.character.orc.bandwagon.WalkAnim,
			runAnimSpeedMultiplier: 1,
			attackModel: Res.model.character.orc.bandwagon.Attack01Anim,
			deathModel: Res.model.character.orc.bandwagon.DeathAnim,
			modelScale: 0.007,
			speed: 5,
			speedMultiplier: 2,
			attackRange: 7,
			attackSpeed: 200,
			damagePercentDelay: 0.5,
			damageMin: 10,
			damageMax: 20,
			maxLife: 50,
			maxMana: 1,
			detectionRange: 7,
			unitSize: 1.1,
			isFlyingUnit: false,
			zOffset: 0
		});
	}
}