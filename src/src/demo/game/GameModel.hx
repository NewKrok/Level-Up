package demo.game;

import coconut.data.Model;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameModel implements Model
{
	@:observable var state:PlayState = Loading;

	@:transition function initGame() return { state: InitVideoInProgress };
	@:transition function startGame() return { state: GameStarted };
}

enum PlayState {
	Loading;
	InitVideoInProgress;
	GameStarted;
}