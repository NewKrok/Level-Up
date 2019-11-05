package levelup.game.js;

import levelup.game.js.AStar.GridNode;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:native("Graph") extern class Graph
{
	var grid:Array<Array<GridNode>>;

	function new(rawGrid:Array<Array<Int>>, settings:GraphSettings = null);
}

typedef GraphSettings =
{
	@:optional var diagonal:Bool;
}