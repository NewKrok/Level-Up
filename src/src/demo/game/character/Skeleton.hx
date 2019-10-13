package demo.game.character;

import demo.game.GameState.Player;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Skeleton extends BaseCharacter
{
	public function new(owner:Player)
	{
		super(owner, {
			idleModel: Res.model.character.skeleton.skel,
			runModel: Res.model.character.skeleton.skel,
			attackModel: Res.model.character.skeleton.skel,
			modelScale: 0.1,
			speed: 5,
			speedMultiplier: 2,
			attackRadius: 2,
			attackSpeed: 1000,
			attackDuration: 500,
			damageMin: 1,
			damageMax: 5,
			maxLife: 100
		});
	}
}