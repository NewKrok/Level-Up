package levelup.editor;

import coconut.data.List;
import coconut.data.Model;
import coconut.ui.RenderResult;
import format.agal.Tools;
import hpp.util.GeomUtil.SimplePoint;
import hxd.Event;
import levelup.TerrainAssets.TerrainConfig;
import levelup.game.GameState.InitialUnitData;
import levelup.game.GameState.PlayerId;
import levelup.game.GameState.StaticObjectConfig;
import levelup.game.GameWorld.Region;
import levelup.game.GameWorld.SkyboxConfig;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EditorModel implements Model
{
	@:editable var id:String;
	@:editable var title:String;
	@:editable var subTitle:String;
	@:editable var description:String;
	@:editable var preloaderImage:String;
	@:editable var startingTime:Float;
	@:editable var sunAndMoonOffsetPercent:Float;
	@:editable var dayColor:String;
	@:editable var nightColor:String;
	@:editable var sunsetColor:String;
	@:editable var dawnColor:String;
	@:editable var showGrid:Bool;
	@:editable var defaultTerrainIdForNewAdventure:String;

	@:editable var currentSnap:Float = 0.5;

	@:skipCheck @:editable var size:SimplePoint;
	@:skipCheck @:editable var regions:Array<Region>;
	@:skipCheck @:editable var units:Array<InitialUnitData>;
	@:skipCheck @:editable var staticObjects:Array<StaticObjectConfig>;

	@:skipCheck @:observable var views:Map<EditorViewId, RenderResult> = [];

	@:editable var isXDragLocked:Bool = false;
	@:editable var isYDragLocked:Bool = false;
	@:editable var selectedPlayer:PlayerId = PlayerId.Player1;
	@:editable var selectedModule:EditorModule = null;

	@:observable var modules:List<EditorModule> = null;

	@:transition function toggleXDragLock() return { isXDragLocked: !isXDragLocked };
	@:transition function toggleYDragLock() return { isYDragLocked: !isYDragLocked };

	@:transition function registerModule(module:EditorModule)
	{
		var newModules:List<EditorModule> = modules.append(module);

		return {
			modules: newModules,
			selectedModule: selectedModule == null ? module : selectedModule
		};
	}
	public function getModule(c:Dynamic) return modules.toArray().filter(m ->Std.is(m, c))[0];

	public function registerView(id:EditorViewId, view:RenderResult) return views.set(id, view);

	public function getView(id:EditorViewId) return views.get(id);
}

typedef EditorModule = {
	var id(default, never):String;
	var icon(default, never):String;
	var instance(default, never):EditorModuleInstance;
}

typedef EditorModuleInstance =
{
	@:optional var onWorldClick(default, never):Event->Void;
	@:optional var onWorldMouseDown(default, never):Event->Void;
	@:optional var onWorldMouseUp(default, never):Event->Void;
	@:optional var onWorldMouseMove(default, never):Event->Void;
	@:optional var onWorldWheel(default, never):Event->Void;
	@:optional var update(default, never):Float->Void;
	@:optional var view(default, never):RenderResult;
}

enum EditorViewId
{
	VDialogManager;
	VEditorTools;
}