package demo.game.character;

import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Skeleton extends BaseCharacter
{
	public function new()
	{
		super({
			model: Res.model.character.skeleton.skel,
			modelScale: 0.1,
			moveAnimationName: null,
			speed: 5,
			speedMultiplier: 2
		});
	}
}