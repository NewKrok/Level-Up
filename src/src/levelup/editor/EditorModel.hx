package levelup.editor;

import coconut.data.Model;
import hpp.util.GeomUtil.SimplePoint;
import levelup.Terrain.TerrainConfig;
import levelup.game.GameState.InitialUnitData;
import levelup.game.GameState.PlayerId;
import levelup.game.GameState.StaticObjectConfig;
import levelup.game.GameState.Trigger;
import levelup.game.GameState.WorldEntity;
import levelup.game.GameWorld.Region;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorModel implements Model
{
	@:editable var name:String;
	@:editable var baseTerrainId:String;

	@:skipCheck @:editable var size:SimplePoint;
	@:skipCheck @:editable var pathFindingMap:Array<Array<WorldEntity>>;
	@:skipCheck @:editable var regions:Array<Region>;
	@:skipCheck @:editable var triggers:Array<Trigger>;
	@:skipCheck @:editable var units:Array<InitialUnitData>;
	@:skipCheck @:editable var staticObjects:Array<StaticObjectConfig>;

	@:editable var isXDragLocked:Bool = false;
	@:editable var isYDragLocked:Bool = false;
	@:editable var currentSnap:Float = 0.5;
	@:editable var selectedPlayer:PlayerId = PlayerId.Player1;

	@:transition function toggleXDragLock() return { isXDragLocked: !isXDragLocked };
	@:transition function toggleYDragLock() return { isYDragLocked: !isYDragLocked };
}