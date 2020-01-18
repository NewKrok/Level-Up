package levelup.editor;

import coconut.data.Model;
import format.agal.Tools;
import hpp.util.GeomUtil.SimplePoint;
import levelup.TerrainAssets.TerrainConfig;
import levelup.game.GameState.InitialUnitData;
import levelup.game.GameState.PlayerId;
import levelup.game.GameState.StaticObjectConfig;
import levelup.game.GameState.Trigger;
import levelup.game.GameWorld.Region;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorModel implements Model
{
	@:editable var name:String;
	@:editable var startingTime:Float;
	@:editable var sunAndMoonOffsetPercent:Float;
	@:editable var dayColor:String;
	@:editable var nightColor:String;
	@:editable var sunsetColor:String;
	@:editable var dawnColor:String;
	@:editable var showGrid:Bool;

	@:editable var currentSnap:Float = 0.5;

	@:skipCheck @:editable var size:SimplePoint;
	@:skipCheck @:editable var regions:Array<Region>;
	@:skipCheck @:editable var triggers:Array<Trigger>;
	@:skipCheck @:editable var units:Array<InitialUnitData>;
	@:skipCheck @:editable var staticObjects:Array<StaticObjectConfig>;

	@:editable var isXDragLocked:Bool = false;
	@:editable var isYDragLocked:Bool = false;
	@:editable var selectedPlayer:PlayerId = PlayerId.Player1;
	@:editable var toolState:ToolState = Library;

	@:transition function toggleXDragLock() return { isXDragLocked: !isXDragLocked };
	@:transition function toggleYDragLock() return { isYDragLocked: !isYDragLocked };
}

enum ToolState
{
	Library;
	TerrainEditor;
	HeightMapEditor;
	DayAndNightEditor;
	RegionEditor;
	CameraEditor;
	WeatherEditor;
	ScriptEditor;
	UnitEditor;
	TeamEditor;
}