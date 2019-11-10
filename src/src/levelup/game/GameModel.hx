package levelup.game;

import coconut.data.Model;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameModel implements Model
{
	@:observable var gameState:PlayState = Loading;

	@:transition function initGame() return { gameState: InitVideoInProgress };
	@:transition function startGame() return { gameState: GameStarted };
}

enum PlayState {
	Loading;
	InitVideoInProgress;
	GameStarted;
}