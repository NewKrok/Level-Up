package levelup;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Player
{
	public static var colors(default, never):Array<String> = [
		"FF0000",
		"0000FF",
		"00FF00",
		"FFFF00",
		"328DDE",
		"FF00FF",
		"FFFFFF",
		"000000",
		"888888",
		"532C6D"
	];
}

@:enum abstract PlayerId(Int) from Int to Int {
	var Player1 = 0;
	var Player2 = 1;
	var Player3 = 2;
	var Player4 = 3;
	var Player5 = 4;
	var Player6 = 5;
	var Player7 = 6;
	var Player8 = 7;
	var Player9 = 8;
	var Player10 = 9;
}