package demo.game.js;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:native("astar") extern class AStar
{
	static function search(graph:Graph, start:Dynamic, end:Dynamic, settings:AStarSettings = null):Array<GridNode>;
}

typedef GridNode =
{
	var x:Int;
	var y:Int;
	var weight:Int;
	var closed:Bool;
}

typedef AStarSettings =
{
	@:optional var heuristic:(Dynamic->Dynamic)->Dynamic;
	@:optional var closest:Bool;
}