package demo.game.character;

import demo.game.GameState.Player;
import demo.game.character.BaseCharacter.CharacterConfig;
import demo.game.character.BaseCharacter.CharacterState;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AICharacter extends BaseCharacter
{
	public function new(owner:Player, config:CharacterConfig)
	{
		super(owner, config);
	}

	override public function update(d:Float)
	{
		super.update(d);

		if (target == null && nearestTarget != null && state.value != CharacterState.AttackTriggered)
		{
			attack(nearestTarget);
		}
	}
}